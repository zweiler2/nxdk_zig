const std = @import("std");
const builtin = @import("builtin");
const user = @import("user");
const nxdk_hal = @import("nxdk_hal");

comptime {
    if (builtin.link_libc) {
        @compileError("nxdk_zig targets are freestanding: link_libc must not be enabled. Use the pdclib instead.");
    }
}

pub const panic = @import("panic.zig").panic;
pub const std_options_cwd = @import("cwd.zig").cwdFn;
pub const std_options_debug_io = @import("debug_io.zig").debug_io;
pub const os = struct {
    pub const heap = struct {
        pub const page_allocator = @import("page_allocator.zig").page_allocator;
    };
};
pub const debug = struct {
    pub const SelfInfo = @import("SelfInfo.zig");
    pub fn getDebugInfoAllocator() std.mem.Allocator {
        return os.heap.page_allocator;
    }
};

pub export fn main() u8 {
    const fn_info = @typeInfo(@TypeOf(user.main)).@"fn";
    if (fn_info.params.len == 0) {
        return wrapMain(user.main());
    }
    if (fn_info.params[0].type.? == std.process.Init.Minimal) {
        return wrapMain(user.main(std.process.Init.Minimal{
            .environ = .empty,
            .args = .{ .vector = &.{} },
        }));
    }

    const gpa = debug_allocator.allocator();
    _ = debug_allocator.deinit(); // Leaks do not affect return code.

    const arena_backing_allocator = std.heap.page_allocator;

    var arena_allocator: std.heap.ArenaAllocator = .init(arena_backing_allocator);
    defer arena_allocator.deinit();

    var threaded: std.Io.Threaded = .init(gpa, .{
        .argv0 = .init(.{ .vector = &.{} }),
        .environ = .empty,
    });
    defer threaded.deinit();

    var environ_map = std.process.Environ.createMap(.empty, gpa) catch |err|
        std.debug.panic("failed to parse environment variables: {t}", .{err});
    defer environ_map.deinit();

    const preopens = std.process.Preopens.init(arena_allocator.allocator()) catch |err|
        std.debug.panic("failed to init preopens: {t}", .{err});

    return wrapMain(user.main(std.process.Init{
        .minimal = .{
            .environ = .empty,
            .args = .{ .vector = &.{} },
        },
        .arena = &arena_allocator,
        .gpa = gpa,
        .io = threaded.io(),
        .environ_map = &environ_map,
        .preopens = preopens,
    }));
}

inline fn wrapMain(result: anytype) u8 {
    const ReturnType = @TypeOf(result);
    switch (ReturnType) {
        void => return 0,
        noreturn => unreachable,
        u8 => return result,
        else => {},
    }
    if (@typeInfo(ReturnType) != .error_union) @compileError(bad_main_ret);

    const unwrapped_result = result catch |err| {
        std.log.err("{t}", .{err});
        if (@errorReturnTrace()) |trace| std.debug.dumpErrorReturnTrace(trace);
        return 1;
    };

    return switch (@TypeOf(unwrapped_result)) {
        noreturn => unreachable,
        void => 0,
        u8 => unwrapped_result,
        else => @compileError(bad_main_ret),
    };
}

/// General error message for a malformed return type
const bad_main_ret = "expected return type of main to be 'void', '!void', 'noreturn', 'u8', or '!u8'";

var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
