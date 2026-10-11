const std = @import("std");
const builtin = @import("builtin");
const user = @import("user");
const fault = @import("fault.zig");
const xboxrt = @import("xboxrt");

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
    /// `std.debug.printLineInfo` shows the source line under each
    /// `file:line:col: 0x… in function` frame by reading the file named in the
    /// PDB — an absolute path on the *build host*, which the console can never
    /// reach. Fail immediately so the frame still prints without the snippet
    /// instead of attempting a doomed filesystem open from the panic handler.
    pub fn printLineFromFile(
        io: std.Io,
        writer: *std.Io.Writer,
        source_location: std.debug.SourceLocation,
    ) error{FileNotFound}!void {
        _ = .{ io, writer, source_location };
        return error.FileNotFound;
    }
};

pub export fn main() u8 {
    // Catch hardware faults (#PF on a bad dereference, illegal instruction, …)
    // through our own `%fs:0` SEH frame before anything else runs. NOTE: we
    // deliberately do NOT call `std.debug.maybeEnableSegfaultHandler()` — it
    // registers via `RtlAddVectoredExceptionHandler`, an ntdll.dll import the
    // Xbox kernel cannot bind: on xemu the thunk lands on a null/garbage IAT
    // entry and calling it faults the boot path before any output can be
    // rendered (black screen). The kernel also exports no registration API of
    // its own, so `fault.zig` hooks the only place it does honor: the classic
    // x86 SEH chain at `fs:[0]`. The dead `std.start` `wWinMainCRTStartup`
    // keeps the ntdll import alive in the binary, but it must never be called.
    var fault_reg: xboxrt.vcruntime.excpt.EXCEPTION_REGISTRATION = undefined;
    fault.install(&fault_reg);

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
    if (@typeInfo(ReturnType) != .error_union) {
        @compileError(bad_main_ret);
    }

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
