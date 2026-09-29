const std = @import("std");
const winapi = @import("winapi");
const xboxkrnl = @import("xboxkrnl");

pub const debug_io: std.Io = .{
    .userdata = &instance,
    .vtable = &vtable,
};
var instance: DebugIo = .{};
const vtable: std.Io.VTable = blk: {
    var vt: std.Io.VTable = std.Io.failing.vtable.*;
    vt.lockStderr = lockStderr;
    vt.unlockStderr = unlockStderr;
    vt.swapCancelProtection = swapCancelProtection;
    vt.fileWritePositional = fileWritePositional;
    vt.dirCreateFile = dirCreateFile;
    vt.fileSetLength = fileSetLength;
    vt.fileClose = fileClose;
    break :blk vt;
};

const DebugIo = struct {
    stderr_writer: std.Io.File.Writer = .{
        .io = undefined,
        .interface = std.Io.File.Writer.initInterface(&.{}),
        .file = undefined,
        .mode = .positional,
    },
    stderr_writer_initialized: bool = false,
};

fn lockStderr(userdata: ?*anyopaque, _: ?std.Io.Terminal.Mode) std.Io.Cancelable!std.Io.LockedStderr {
    const self: *DebugIo = @ptrCast(@alignCast(userdata.?));
    if (!self.stderr_writer_initialized) {
        self.stderr_writer.file = std.Io.File.stderr();
        self.stderr_writer.io = debug_io;
        self.stderr_writer_initialized = true;
    }
    return .{
        .file_writer = &self.stderr_writer,
        .terminal_mode = .no_color,
    };
}

fn unlockStderr(userdata: ?*anyopaque) void {
    const self: *DebugIo = @ptrCast(@alignCast(userdata.?));
    if (self.stderr_writer.err == null) {
        self.stderr_writer.interface.flush() catch {};
    }
    self.stderr_writer.err = null;
    self.stderr_writer.interface.end = 0;
    self.stderr_writer.interface.buffer = &.{};
}

fn swapCancelProtection(_: ?*anyopaque, _: std.Io.CancelProtection) std.Io.CancelProtection {
    return .unblocked;
}

fn win32ToWriteError(win32_err: xboxkrnl.xboxdef.DWORD) std.Io.File.WritePositionalError {
    return switch (win32_err) {
        winapi.winerror.ERROR_ACCESS_DENIED,
        => error.AccessDenied,
        winapi.winerror.ERROR_INVALID_HANDLE,
        => error.NotOpenForWriting,
        winapi.winerror.ERROR_NOT_ENOUGH_MEMORY,
        winapi.winerror.ERROR_NO_SYSTEM_RESOURCES,
        => error.SystemResources,
        winapi.winerror.ERROR_BROKEN_PIPE,
        => error.BrokenPipe,
        winapi.winerror.ERROR_DISK_FULL,
        => error.NoSpaceLeft,
        winapi.winerror.ERROR_LOCK_VIOLATION,
        => error.LockViolation,
        winapi.winerror.ERROR_FILE_TOO_LARGE,
        => error.FileTooBig,
        else => error.Unexpected,
    };
}

fn win32ToOpenError(win32_err: xboxkrnl.xboxdef.DWORD) std.Io.File.OpenError {
    return switch (win32_err) {
        winapi.winerror.ERROR_FILE_NOT_FOUND,
        winapi.winerror.ERROR_PATH_NOT_FOUND,
        winapi.winerror.ERROR_INVALID_NAME,
        => error.FileNotFound,
        winapi.winerror.ERROR_ACCESS_DENIED,
        => error.AccessDenied,
        winapi.winerror.ERROR_ALREADY_EXISTS,
        winapi.winerror.ERROR_FILE_EXISTS,
        => error.PathAlreadyExists,
        winapi.winerror.ERROR_DISK_FULL,
        => error.NoSpaceLeft,
        winapi.winerror.ERROR_DIRECTORY,
        => error.NotDir,
        winapi.winerror.ERROR_SHARING_VIOLATION,
        winapi.winerror.ERROR_LOCK_VIOLATION,
        => error.FileBusy,
        winapi.winerror.ERROR_NOT_ENOUGH_MEMORY,
        winapi.winerror.ERROR_NO_SYSTEM_RESOURCES,
        => error.SystemResources,
        winapi.winerror.ERROR_FILE_TOO_LARGE,
        => error.FileTooBig,
        else => error.Unexpected,
    };
}

fn protectionToPage(protection: std.process.MemoryProtection) ?winapi.winnt.PAGE_PROTECTION_FLAGS {
    return switch (@as(u3, @bitCast(protection))) {
        0b000 => .{ .PAGE_NOACCESS = @intFromBool(true) },
        0b001 => .{ .PAGE_READONLY = @intFromBool(true) },
        0b010 => null,
        0b011 => .{ .PAGE_READWRITE = @intFromBool(true) },
        0b100 => .{ .PAGE_EXECUTE = @intFromBool(true) },
        0b101 => .{ .PAGE_EXECUTE_READ = @intFromBool(true) },
        0b110 => null,
        0b111 => .{ .PAGE_EXECUTE_READWRITE = @intFromBool(true) },
    };
}

fn fileWritePositional(
    _: ?*anyopaque,
    file: std.Io.File,
    header: []const u8,
    data: []const []const u8,
    splat: usize,
    _: u64,
) std.Io.File.WritePositionalError!usize {
    var total: usize = 0;
    var written: u32 = 0;

    if (header.len > 0) {
        if (winapi.fileapi.WriteFile(
            file.handle,
            @ptrCast(header.ptr),
            @intCast(header.len),
            &written,
            null,
        ) == xboxkrnl.xboxkrnl.FALSE) {
            return win32ToWriteError(winapi.winbase.GetLastError());
        }
        total += written;
    }

    for (data, 0..) |slice, i| {
        const count: usize = if (i == data.len - 1) splat else 1;
        var j: usize = 0;
        while (j < count) : (j += 1) {
            if (slice.len > 0) {
                if (winapi.fileapi.WriteFile(
                    file.handle,
                    @ptrCast(slice.ptr),
                    @intCast(slice.len),
                    &written,
                    null,
                ) == xboxkrnl.xboxkrnl.FALSE)
                    return win32ToWriteError(winapi.winbase.GetLastError());
                total += written;
            }
        }
    }

    return total;
}

fn dirCreateFile(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    sub_path: []const u8,
    flags: std.Io.Dir.CreateFileOptions,
) std.Io.File.OpenError!std.Io.File {
    _ = userdata;
    _ = dir;
    if (std.mem.eql(u8, sub_path, ".") or
        std.mem.eql(u8, sub_path, ".."))
    {
        return error.IsDir;
    }

    var path_buffer: [std.Io.Dir.max_path_bytes:0]u8 = undefined;
    if (sub_path.len > path_buffer.len) {
        return error.NameTooLong;
    }
    @memcpy(&path_buffer, sub_path);
    path_buffer[sub_path.len] = 0;
    const path: [:0]const u8 = path_buffer[0..sub_path.len :0];

    const access: xboxkrnl.xboxdef.DWORD = @bitCast(
        @as(xboxkrnl.xboxdef.DWORD, @bitCast(winapi.fileapi.FILE_GENERIC_WRITE)) |
            @as(xboxkrnl.xboxdef.DWORD, if (flags.read)
                @bitCast(winapi.fileapi.FILE_GENERIC_READ)
            else
                0),
    );
    const disposition: winapi.fileapi.FILE_CREATION_DISPOSITION =
        if (flags.exclusive)
            .CREATE_NEW
        else if (flags.truncate)
            .CREATE_ALWAYS
        else
            .OPEN_ALWAYS;

    const handle: xboxkrnl.xboxdef.HANDLE = winapi.fileapi.CreateFileA(
        path.ptr,
        access,
        0,
        null,
        @intFromEnum(disposition),
        0,
        null,
    );
    if (handle == winapi.winbase.INVALID_HANDLE_VALUE) {
        return win32ToOpenError(winapi.winbase.GetLastError());
    }
    errdefer _ = winapi.handleapi.CloseHandle(handle);

    // TODO: Revisit this?
    // INFO: There is no LockFileEx() in the NXDK
    // if (flags.lock != .none) {
    //     var lock_flags: winapi.fileapi.LOCK_FILE_FLAGS = .{
    //         .EXCLUSIVE_LOCK = @intFromBool(flags.lock == .exclusive),
    //     };
    //     if (flags.lock_nonblocking) {
    //         lock_flags.FAIL_IMMEDIATELY = 1;
    //     }
    //     var overlapped: winapi.minwinbase.OVERLAPPED = std.mem.zeroes(winapi.minwinbase.OVERLAPPED);
    //     if (winapi.fileapi.LockFileEx(
    //         handle,
    //         lock_flags,
    //         0,
    //         std.math.maxInt(u32),
    //         std.math.maxInt(u32),
    //         &overlapped,
    //     ) == xboxkrnl.xboxkrnl.FALSE) {
    //         const err = winapi.winbase.GetLastError();
    //         return switch (err) {
    //             .ERROR_LOCK_VIOLATION => error.WouldBlock,
    //             else => win32ToOpenError(err),
    //         };
    //     }
    // }

    return .{
        .handle = handle,
        .flags = .{ .nonblocking = false },
    };
}

fn fileSetLength(userdata: ?*anyopaque, file: std.Io.File, length: u64) std.Io.File.SetLengthError!void {
    _ = userdata;
    const signed_len: i64 = @bitCast(length);
    if (signed_len < 0) {
        return error.FileTooBig; // Avoid ambiguous EINVAL errors.
    }
    const end_of_file: xboxkrnl.xboxdef.LARGE_INTEGER = .{ .QuadPart = signed_len };
    if (winapi.fileapi.SetFilePointerEx(
        file.handle,
        end_of_file,
        null,
        winapi.winbase.FILE_BEGIN,
    ) == xboxkrnl.xboxkrnl.FALSE) {
        const err: xboxkrnl.xboxdef.DWORD = winapi.winbase.GetLastError();
        return switch (err) {
            winapi.winerror.ERROR_ACCESS_DENIED => error.AccessDenied,
            winapi.winerror.ERROR_INVALID_HANDLE => error.FileBusy,
            else => error.Unexpected,
        };
    }
    if (winapi.fileapi.SetEndOfFile(file.handle) == xboxkrnl.xboxkrnl.FALSE) {
        const err: xboxkrnl.xboxdef.DWORD = winapi.winbase.GetLastError();
        return switch (err) {
            winapi.winerror.ERROR_ACCESS_DENIED => error.AccessDenied,
            winapi.winerror.ERROR_INVALID_HANDLE => error.FileBusy,
            else => error.Unexpected,
        };
    }
}

fn fileClose(userdata: ?*anyopaque, files: []const std.Io.File) void {
    _ = userdata;
    for (files) |file| {
        _ = winapi.handleapi.CloseHandle(file.handle);
    }
}
