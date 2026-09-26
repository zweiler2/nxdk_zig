pub const hal = @import("hal/root.zig");
pub const winapi = @import("winapi/root.zig");
pub const xboxkrnl = @import("xboxkrnl/root.zig");
pub const xboxrt = @import("xboxrt/root.zig");
pub const pbkit = @import("pbkit/root.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
