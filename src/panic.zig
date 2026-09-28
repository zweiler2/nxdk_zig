const nxdk_hal = @import("nxdk_hal");

var panic_buf: [256]u8 = undefined;

pub fn panic(msg: []const u8, stack_trace: ?*@import("std").builtin.StackTrace, first_trace_addr: ?usize) noreturn {
    _ = first_trace_addr;
    _ = stack_trace;

    if (nxdk_hal.video.XVideoGetFB() != null) {
        const n = @min(msg.len, panic_buf.len - 1);
        @memcpy(panic_buf[0..n], msg[0..n]);
        panic_buf[n] = 0;
        nxdk_hal.debug.debugPrint("PANIC: %s\n", panic_buf[0..n :0].ptr);
    }

    while (true) {} // halt; a trap would re-enter the kernel exception dispatcher
}
