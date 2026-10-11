const nxdk_hal = @import("nxdk_hal");

// Every case below is a fault a user can actually trip over while writing
// ordinary Zig against the Xbox: panics, null/wild pointer accesses, a divide
// by zero, an illegal instruction, and unbounded recursion. A misaligned
// access is deliberately *not* in the list: x86 silently allows every
// unaligned load/store the compiler can emit for Zig code, so the only way to
// fault on misalignment is a hand-written SSE aligned move (no user code does
// that). The handler in `start/fault.zig` still reports #GP/#AC should one
// ever occur.
const ErrorType = enum {
    panic,
    null_pointer_read,
    null_pointer_write,
    pointer_deref_and_write,
    illegal_instruction,
    divide_by_zero,
    stack_overflow,
};

pub fn main() void {
    _ = nxdk_hal.video.XVideoSetMode(640, 480, 32, nxdk_hal.video.REFRESH_DEFAULT);

    const err: ErrorType = .panic;
    switch (err) {
        .panic => testPanic(),
        .null_pointer_read => nullPointerRead(),
        .null_pointer_write => nullPointerWrite(),
        .pointer_deref_and_write => pointerDerefAndWrite(),
        .illegal_instruction => illegalInstruction(),
        .divide_by_zero => divideByZero(),
        .stack_overflow => stackOverflow(),
    }
}

fn testPanic() void {
    @panic("Panic tested");
}

fn nullPointerRead() void {
    const p: *allowzero u32 = @ptrFromInt(0x00000000);
    const v: u32 = p.*;
    _ = v;
}

fn nullPointerWrite() void {
    const p: *allowzero u32 = @ptrFromInt(0x00000000);
    p.* = 0x1234;
}

fn pointerDerefAndWrite() void {
    const value: *align(1) i32 = @ptrFromInt(0xdeadbeef);
    value.* = 3;
}

fn illegalInstruction() noreturn {
    // Inserts the platform trap instruction (`ud2` on x86), the same #UD a
    // corrupted jump target can raise, without hand-written inline asm.
    @trap();
}

fn divideByZero() void {
    // Integer divide-by-zero is illegal behavior: Debug/ReleaseSafe insert a
    // guard that panics before the CPU divides. With runtime safety off the
    // backend emits the real `idiv`, so the divide raises the hardware #DE.
    // Volatile loads/stores keep the operands opaque and the result observable
    // so the division cannot be constant-folded or eliminated as dead code.
    @setRuntimeSafety(false);
    var numerator: i32 = 1;
    var denominator: i32 = 0;
    var result: i32 = 0;
    const a = @as(*volatile i32, &numerator).*;
    const b = @as(*volatile i32, &denominator).*;
    @as(*volatile i32, &result).* = @divTrunc(a, b);
}

// A stack frame larger than one page makes the compiler emit the `__chkstk`
// prologue; on the Xbox that is xboxrt's stack probe, which detects the
// growing recursion well before the guard page and reports a proper stack
// overflow instead of a plain access violation.
const stack_frame = 8192;

// Read through a volatile pointer so the optimizer cannot prove the recursion
// terminates: a provably-infinite or provably-bounded recursion collapses into
// a plain loop in ReleaseFast and never grows the stack.
var keep_recursing: bool = true;

// The per-frame buffer is always written, and read again *after* the recursive
// call, so the frame must stay live across the call (no tail-call/loop
// rewrite). The buffer is indexed at a runtime offset through a volatile
// pointer, so no optimization level can shrink the alloca or eliminate the
// store.
fn stackOverflow() void {
    _ = stackOverflowImpl(0);
}

noinline fn stackOverflowImpl(n: u32) u32 {
    var buf: [stack_frame]u8 = undefined;
    const cell: *volatile u8 = &buf[n % buf.len];
    cell.* = @truncate(n);
    if (!@as(*volatile bool, &keep_recursing).*) return 0;
    const r = stackOverflowImpl(n +% 1);
    return r +% cell.*;
}
