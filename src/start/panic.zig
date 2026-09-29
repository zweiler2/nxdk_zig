const std = @import("std");
const nxdk_hal = @import("nxdk_hal");

pub const panic = std.debug.FullPanic(panicImpl);
var panic_buf: [256]u8 = @splat(0);

fn panicImpl(msg: []const u8, first_trace_addr: ?usize) noreturn {
    // _ = first_trace_addr;

    if (nxdk_hal.video.XVideoGetFB() == null) {
        while (true) {} // halt; a trap would re-enter the kernel exception dispatcher
    }

    var writer: std.Io.Writer = .fixed(&panic_buf);

    writer.print("PANIC: {s} at ", .{msg}) catch {};
    writer.print("0x{x}", .{first_trace_addr orelse 0}) catch {};

    // const n = @min(msg.len, panic_buf.len - 1);
    // @memcpy(panic_buf[0..n], msg[0..n]);
    // panic_buf[n] = 0;
    // nxdk_hal.debug.debugPrint("PANIC: %s at ", panic_buf[0..n :0].ptr);
    // panic_buf = @splat(0);

    // panic_buf[panic_buf.len - 1] = 0;
    // panic_buf[0] = 'A';
    // nxdk_hal.debug.debugPrint("%s\n", &panic_buf);

    if (writer.end == writer.buffer.len) {
        writer.buffer[writer.end - 1] = 0;
    } else {
        writer.writeByte(0) catch {};
    }
    nxdk_hal.debug.debugPrint("%s", &panic_buf);

    while (true) {} // halt; a trap would re-enter the kernel exception dispatcher
}
