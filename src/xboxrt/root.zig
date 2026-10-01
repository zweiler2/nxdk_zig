pub const vcruntime = struct {
    pub const excpt = @import("vcruntime/excpt.zig");
};
pub const libc_extensions = struct {
    pub const direct = @import("libc_extensions/direct.zig");
};
