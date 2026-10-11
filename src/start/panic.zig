const std = @import("std");
const nxdk_hal = @import("nxdk_hal");
const xboxkrnl = @import("xboxkrnl");

pub const panic = std.debug.FullPanic(panicImpl);
var panic_buf: [512]u8 = @splat(0);
threadlocal var in_panic: bool = false;

// `noinline` so `@returnAddress()` below resolves to the call site in the code
// that panicked instead of to whatever function `panicImpl` got inlined into.
noinline fn panicImpl(msg: []const u8, first_trace_addr: ?usize) noreturn {
    // Report the message *before* the re-entrancy gate: a nested panic (a
    // Debug safety check firing while already inside the handler) hits
    // `while (true) {}` below, and would otherwise freeze the console on the
    // last line with no message at all. DbgPrint mirrors the line to the host
    // debugger; the framebuffer glyph blitter only renders when video is up.
    {
        var writer: std.Io.Writer = .fixed(&panic_buf);
        writer.end = 0;

        writer.print("panic: {s}\n", .{msg}) catch {};

        if (writer.end == writer.buffer.len) {
            writer.buffer[writer.end - 1] = 0;
        } else {
            writer.writeByte(0) catch {};
        }
        _ = xboxkrnl.xboxkrnl.DbgPrint("%s", &panic_buf);
        if (nxdk_hal.video.XVideoGetFB() != null) {
            nxdk_hal.debug.debugPrint("%s", &panic_buf);
        }
    }
    if (in_panic) {
        while (true) {}
    }
    in_panic = true;

    // Symbolize the address the compiler handed us. Safety panics always pass a
    // real return address, but `@panic` passes null (the compiler materialises a
    // constant `?usize = null`), so fall back to our own return address — with
    // `panicImpl` marked `noinline` that is the caller's call site in user code.
    // This is a single-entry synthetic trace rather than `dumpCurrentStackTrace`,
    // so no unwinder is involved and it behaves identically in ReleaseSafe/Fast.
    //
    // Resolve `first_addr - 1`: a return address is the instruction *after* the
    // `call`, which can land on the first byte past the caller's line fragment
    // (this build puts it on a `nop` padding byte). Stepping back one byte puts
    // it on the last byte of the `call` itself, which routinely falls inside the
    // caller's fragment. This is the standard "call site vs return site" fix
    // used by unwinders; without it even llvm-addr2line maps the address to the
    // function boundary (`wWinMainCRTStartup ??:0`).
    const first_addr = (first_trace_addr orelse @returnAddress()) -| 1;

    // The symbolization below goes through the console writer in debug_io.zig,
    // which drops the framebuffer sink on its own and still reaches the host
    // debugger. It loads the PDB lazily through the cached `SelfInfo`; a failed
    // load degrades to `???:?:?` rather than recursing into the panic handler.
    // `dumpStackTrace` locks stderr (see debug_io.zig), prints, and swallows
    // write errors.
    var addr_buf: [1]usize = .{first_addr};
    const trace: std.debug.StackTrace = .{
        .return_addresses = addr_buf[0..],
        .skipped = .none,
    };
    std.debug.dumpStackTrace(&trace);

    while (true) {}
}
