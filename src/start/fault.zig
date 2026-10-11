//! User-mode fault reporting for nxdk_zig.
//!
//! The Xbox kernel exports no exception-registration API — `RtlAddVectoredExceptionHandler`,
//! `NtSetInformationThread`, `KeRegisterBugCheckCallback` are all absent from
//! `xboxkrnl.exe.def` — so Zig std's `maybeEnableSegfaultHandler`, which binds through
//! ntdll, can never work here (see the note in `start.zig`). The one mechanism the kernel
//! does honor is the classic x86 SEH chain hanging off the TEB at `%fs:0`; nxdk's own MSVC
//! SEH runtime (`_except_handler3` in `lib/xboxrt/vcruntime/excpt.cpp`) is built on it,
//! which is why C++ `throw` / `__try` work on Xbox hardware.
//!
//! `install()` pushes a frame of our own onto that chain, so a hardware exception (#PF on a
//! bad dereference, illegal instruction, …) lands in `faultHandler`. It reports the fault
//! in the same shape as the `@panic` path — a Zig-std-style message line followed by a
//! PDB-symbolized `file:line:col: 0x… in function` frame — and then freezes, because the
//! faulting instruction must never be resumed (std's own handler aborts for the same
//! reason).
//!
//! Limitations: `install()` only covers the calling thread (each thread has its own TEB
//! chain) — call it again from any additional threads. Faults raised before video init
//! reach DbgPrint only, exactly like `panicImpl`.

const std = @import("std");
const nxdk_hal = @import("nxdk_hal");
const xboxkrnl = @import("xboxkrnl");
const winapi = @import("winapi");
const excpt = @import("xboxrt").vcruntime.excpt;

var fault_buf: [512]u8 = @splat(0);
threadlocal var in_fault: bool = false;

/// Push our frame onto the TEB exception chain (`fs:[0]`), using the same three
/// instructions nxdk's SEH runtime uses to install temporary frames. The caller
/// must provide stable storage for `frame` for the lifetime of the thread (the
/// frame remains on the chain until the thread exits or the chain is popped).
pub fn install(frame: *excpt.EXCEPTION_REGISTRATION) void {
    frame.* = .{
        .handler = @ptrFromInt(@intFromPtr(&faultHandler)),
        .prev = undefined, // written by the `movl %%fs:0, (%[reg])` below
    };
    asm volatile (
        \\movl %%fs:0, %%eax
        \\movl %%eax, (%[reg])
        \\movl %[reg], %%fs:0
        :
        : [reg] "r" (frame),
        : .{ .eax = true, .memory = true });
}

fn faultHandler(
    record: *xboxkrnl.xboxdef.EXCEPTION_RECORD,
    registration_frame: *excpt.EXCEPTION_REGISTRATION,
    context: *xboxkrnl.xboxdef.CONTEXT,
    dispatcher_context: *?*anyopaque,
) callconv(.c) excpt.EXCEPTION_DISPOSITION {
    _ = .{ registration_frame, dispatcher_context };

    // Unwind passes visit every frame in the chain asking it to release state; we
    // own none, so keep looking. (C++ `throw` triggers exactly this path.)
    if (record.ExceptionFlags & (xboxkrnl.xboxdef.EXCEPTION_UNWINDING | xboxkrnl.xboxdef.EXCEPTION_EXIT_UNWIND) != 0) {
        return .ExceptionContinueSearch;
    }

    // Gate before anything else: a fault while reporting a fault (e.g. a bogus
    // non-null framebuffer pointer passed to `debugPrint`) would otherwise recurse
    // without bound. The DbgPrint mirroring below may already have reached the host
    // before the recursion trips the gate.
    if (in_fault) {
        while (true) {}
    }
    in_fault = true;

    // Wording follows std's `defaultHandleSegfault`: "{name} at address 0x{x}".
    // NTSTATUS is a signed `c_long`; reinterpret as `u32` so the 0xC000_xxxx
    // constants and the `{x}` format both work.
    const code: u32 = @bitCast(record.ExceptionCode);
    const addr: ?usize = switch (code) {
        // ExceptionInformation[1] is the faulting virtual address; fall back to the
        // instruction pointer if the kernel supplied no parameters.
        winapi.minwinbase.EXCEPTION_ACCESS_VIOLATION => if (record.NumberParameters >= 2)
            @as(usize, @intCast(record.ExceptionInformation[1]))
        else
            context.Eip,
        winapi.minwinbase.EXCEPTION_DATATYPE_MISALIGNMENT,
        winapi.minwinbase.EXCEPTION_STACK_OVERFLOW,
        => null,
        else => context.Eip,
    };

    var unknown_buf: [48]u8 = undefined;
    const name: []const u8 = switch (code) {
        winapi.minwinbase.EXCEPTION_ACCESS_VIOLATION => "Segmentation fault",
        winapi.minwinbase.EXCEPTION_ILLEGAL_INSTRUCTION => "Illegal instruction",
        winapi.minwinbase.EXCEPTION_INT_DIVIDE_BY_ZERO => "Integer divide by zero",
        winapi.minwinbase.EXCEPTION_DATATYPE_MISALIGNMENT => "Unaligned memory access",
        winapi.minwinbase.EXCEPTION_STACK_OVERFLOW => "Stack overflow",
        else => std.fmt.bufPrint(&unknown_buf, "Unhandled exception 0x{x}", .{code}) catch "Unhandled exception",
    };

    // Same fixed-buffer + DbgPrint + framebuffer pattern as `panicImpl`: the message
    // reaches the host debugger even when video is not up yet, and the glyph blitter
    // only runs when `XVideoSetMode` has established a framebuffer.
    {
        var writer: std.Io.Writer = .fixed(&fault_buf);
        writer.end = 0;

        if (addr) |a| {
            writer.print("{s} at address 0x{x}\n", .{ name, a }) catch {};
        } else {
            writer.print("{s} (no address available)\n", .{name}) catch {};
        }

        if (writer.end == writer.buffer.len) {
            writer.buffer[writer.end - 1] = 0;
        } else {
            writer.writeByte(0) catch {};
        }
        _ = xboxkrnl.xboxkrnl.DbgPrint("%s", &fault_buf);
        if (nxdk_hal.video.XVideoGetFB() != null) {
            nxdk_hal.debug.debugPrint("%s", &fault_buf);
        }
    }

    // A single-entry synthetic trace like `panicImpl`'s, but the EIP already points
    // *at* the faulting instruction (inside its source-line fragment), so — unlike a
    // return address — there is no `- 1` call-site adjustment. The symbolization
    // below goes through the console writer in debug_io.zig and loads the PDB lazily
    // through the cached `SelfInfo`; failures degrade to `???:?:?`.
    const eip: usize = context.Eip;
    var addr_buf: [1]usize = .{eip};
    const trace: std.debug.StackTrace = .{
        .return_addresses = addr_buf[0..],
        .skipped = .none,
    };
    std.debug.dumpStackTrace(&trace);

    // Never return: resuming the faulting instruction would just fault again (and
    // landing here a second time would mean reporting a fault from within the fault
    // report, which the gate above turns into a plain freeze).
    while (true) {}
}
