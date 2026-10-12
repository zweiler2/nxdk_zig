const std = @import("std");
const winapi = @import("winapi");
const nxdk_hal = @import("nxdk_hal");
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
    vt.dirOpenFile = dirOpenFile;
    vt.fileReadPositional = fileReadPositional;
    vt.fileStat = fileStat;
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

const console_vtable: std.Io.Writer.VTable = .{
    .drain = consoleDrain,
};

fn consoleDrain(w: *std.Io.Writer, data: []const []const u8, splat: usize) std.Io.Writer.Error!usize {
    const header: []u8 = w.buffered();
    if (header.len != 0) {
        consoleWrite(header);
    }
    _ = w.consumeAll();

    var consumed: usize = 0;
    for (data[0 .. data.len - 1]) |chunk| {
        consoleWrite(chunk);
        consumed += chunk.len;
    }
    const pattern = data[data.len - 1];
    for (0..splat) |_| {
        consoleWrite(pattern);
        consumed += pattern.len;
    }

    return consumed;
}

fn consoleWrite(bytes: []const u8) void {
    const static = struct {
        const console_chunk_len = 256;
        pub var console_scratch: [console_chunk_len + 1]u8 = undefined;
    };
    var rest: []const u8 = bytes;
    while (rest.len != 0) {
        const n = @min(rest.len, static.console_chunk_len);
        @memcpy(static.console_scratch[0..n], rest[0..n]);
        static.console_scratch[n] = 0;
        const cstr: [*c]const u8 = @ptrCast(&static.console_scratch);
        if (nxdk_hal.video.XVideoGetFB() != null) {
            nxdk_hal.debug.debugPrint("%s", cstr);
        }
        _ = xboxkrnl.xboxkrnl.DbgPrint("%s", cstr);
        rest = rest[n..];
    }
}

fn lockStderr(userdata: ?*anyopaque, _: ?std.Io.Terminal.Mode) std.Io.Cancelable!std.Io.LockedStderr {
    const self: *DebugIo = @ptrCast(@alignCast(userdata.?));
    if (!self.stderr_writer_initialized) {
        self.stderr_writer.io = debug_io;
        self.stderr_writer.interface.vtable = &console_vtable;
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

fn fileWritePositional(
    userdata: ?*anyopaque,
    file: std.Io.File,
    header: []const u8,
    data: []const []const u8,
    splat: usize,
    offset: u64,
) std.Io.File.WritePositionalError!usize {
    _ = userdata;

    const bytes: []const u8 = blk: {
        if (header.len != 0) {
            break :blk header;
        }
        if (data.len == 0) {
            return 0;
        }
        for (data[0 .. data.len - 1]) |slice| {
            if (slice.len != 0) break :blk slice;
        }
        const pattern: []const u8 = data[data.len - 1];
        if (pattern.len == 0 or splat == 0) {
            return 0;
        }
        break :blk pattern;
    };

    const signed_offset: i64 = @bitCast(offset);
    const byte_offset: xboxkrnl.xboxdef.LARGE_INTEGER = .{ .QuadPart = signed_offset };

    var io_status_block: xboxkrnl.xboxkrnl.IO_STATUS_BLOCK = undefined;
    const status: xboxkrnl.xboxdef.NTSTATUS = xboxkrnl.xboxkrnl.NtWriteFile(
        file.handle,
        null,
        null,
        null,
        &io_status_block,
        @ptrCast(bytes.ptr),
        std.math.lossyCast(u32, bytes.len),
        &byte_offset,
    );

    const status_bits: u32 = @bitCast(status);
    switch (status_bits) {
        xboxkrnl.ntstatus.STATUS_SUCCESS => return io_status_block.Information,
        // A pending status is a warning, so it would otherwise sail past a
        // NT_SUCCESS test. Our handles are opened with
        // FILE_SYNCHRONOUS_IO_NONALERT, so a synchronous write can never be
        // left pending.
        xboxkrnl.ntstatus.STATUS_PENDING => unreachable,
        xboxkrnl.ntstatus.STATUS_INVALID_USER_BUFFER,
        xboxkrnl.ntstatus.STATUS_NO_MEMORY,
        xboxkrnl.ntstatus.STATUS_QUOTA_EXCEEDED,
        xboxkrnl.ntstatus.STATUS_WORKING_SET_QUOTA,
        => return error.SystemResources,
        xboxkrnl.ntstatus.STATUS_INVALID_HANDLE => return error.NotOpenForWriting,
        xboxkrnl.ntstatus.STATUS_FILE_LOCK_CONFLICT => return error.LockViolation,
        xboxkrnl.ntstatus.STATUS_ACCESS_DENIED => return error.AccessDenied,
        xboxkrnl.ntstatus.STATUS_DISK_FULL => return error.NoSpaceLeft,
        xboxkrnl.ntstatus.STATUS_FILE_TOO_LARGE => return error.FileTooBig,
        xboxkrnl.ntstatus.STATUS_CANCELLED => return error.Canceled,
        else => return error.Unexpected,
    }
}

fn dirCreateFile(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    sub_path: []const u8,
    flags: std.Io.Dir.CreateFileOptions,
) std.Io.File.OpenError!std.Io.File {
    _ = userdata;

    if (std.mem.eql(u8, sub_path, ".") or std.mem.eql(u8, sub_path, "..")) {
        return error.IsDir;
    }

    var path_buffer: [winapi.windef.MAX_PATH:0]u8 = undefined;
    if (sub_path.len == 0 or sub_path.len >= path_buffer.len) {
        return if (sub_path.len == 0)
            error.BadPathName
        else
            error.NameTooLong;
    }
    @memcpy(path_buffer[0..sub_path.len], sub_path);
    path_buffer[sub_path.len] = 0;

    var ansi_path: xboxkrnl.xboxdef.ANSI_STRING = undefined;
    xboxkrnl.xboxkrnl.RtlInitAnsiString(&ansi_path, &path_buffer);

    const attributes: xboxkrnl.xboxkrnl.OBJECT_ATTRIBUTES = .{
        .RootDirectory = try rootDirectoryFor(dir, sub_path),
        .ObjectName = &ansi_path,
        .Attributes = xboxkrnl.xboxkrnl.OBJ_CASE_INSENSITIVE,
    };

    const access: xboxkrnl.xboxkrnl.ACCESS_MASK = @bitCast(
        xboxkrnl.xboxkrnl.FILE_READ_ATTRIBUTES |
            @as(xboxkrnl.xboxdef.DWORD, if (flags.read)
                @bitCast(winapi.fileapi.FILE_GENERIC_READ)
            else
                0) |
            @as(xboxkrnl.xboxdef.DWORD, @bitCast(winapi.fileapi.FILE_GENERIC_WRITE)),
    );

    const disposition: xboxkrnl.xboxdef.DWORD =
        if (flags.exclusive)
            xboxkrnl.xboxkrnl.FILE_CREATE
        else if (flags.truncate)
            xboxkrnl.xboxkrnl.FILE_OVERWRITE_IF
        else
            xboxkrnl.xboxkrnl.FILE_OPEN_IF;

    var io_status_block: xboxkrnl.xboxkrnl.IO_STATUS_BLOCK = undefined;
    var handle: xboxkrnl.xboxdef.HANDLE = undefined;
    const status: xboxkrnl.xboxdef.NTSTATUS = xboxkrnl.xboxkrnl.NtCreateFile(
        &handle,
        access,
        &attributes,
        &io_status_block,
        null,
        xboxkrnl.xboxdef.FILE_ATTRIBUTE_NORMAL,
        xboxkrnl.xboxkrnl.FILE_SHARE_READ | xboxkrnl.xboxkrnl.FILE_SHARE_WRITE,
        disposition,
        // Handles are never opened with FILE_FLAG_OVERLAPPED, so all IO on them
        // is synchronous and non-alertable. A create always makes a plain file,
        // so there is no directory case to permit.
        xboxkrnl.xboxkrnl.FILE_SYNCHRONOUS_IO_NONALERT |
            xboxkrnl.xboxkrnl.FILE_NON_DIRECTORY_FILE,
    );
    if (!xboxkrnl.xboxkrnl.NT_SUCCESS(status)) {
        return ntStatusToOpenError(status);
    }
    errdefer _ = winapi.handleapi.CloseHandle(handle);

    // TODO: Revisit this?
    // INFO: There is no LockFileEx() in the NXDK, so `flags.lock` is ignored.

    return .{
        .handle = handle,
        .flags = .{ .nonblocking = false },
    };
}

fn dirOpenFile(
    userdata: ?*anyopaque,
    dir: std.Io.Dir,
    sub_path: []const u8,
    flags: std.Io.Dir.OpenFileOptions,
) std.Io.File.OpenError!std.Io.File {
    _ = userdata;

    const allow_directory = flags.allow_directory and !flags.isWrite();
    if (!allow_directory) {
        if (std.mem.eql(u8, sub_path, ".") or std.mem.eql(u8, sub_path, "..")) {
            return error.IsDir;
        }
    }

    var path_buffer: [winapi.windef.MAX_PATH:0]u8 = undefined;
    if (sub_path.len == 0 or sub_path.len >= path_buffer.len) {
        return if (sub_path.len == 0) error.BadPathName else error.NameTooLong;
    }
    @memcpy(path_buffer[0..sub_path.len], sub_path);
    path_buffer[sub_path.len] = 0;

    var ansi_path: xboxkrnl.xboxdef.ANSI_STRING = undefined;
    xboxkrnl.xboxkrnl.RtlInitAnsiString(&ansi_path, &path_buffer);

    const attributes: xboxkrnl.xboxkrnl.OBJECT_ATTRIBUTES = .{
        .RootDirectory = try rootDirectoryFor(dir, sub_path),
        .ObjectName = &ansi_path,
        .Attributes = xboxkrnl.xboxkrnl.OBJ_CASE_INSENSITIVE,
    };

    const access: xboxkrnl.xboxkrnl.ACCESS_MASK = @bitCast(
        xboxkrnl.xboxkrnl.FILE_READ_ATTRIBUTES |
            @as(xboxkrnl.xboxdef.DWORD, if (flags.isRead())
                @bitCast(winapi.fileapi.FILE_GENERIC_READ)
            else
                0) |
            @as(xboxkrnl.xboxdef.DWORD, if (flags.isWrite())
                @bitCast(winapi.fileapi.FILE_GENERIC_WRITE)
            else
                0),
    );

    // Our handles are never opened with FILE_FLAG_OVERLAPPED, so all IO on them is synchronous and non-alertable.
    var create_options: xboxkrnl.xboxdef.ULONG = xboxkrnl.xboxkrnl.FILE_SYNCHRONOUS_IO_NONALERT;
    if (!allow_directory) {
        create_options |= xboxkrnl.xboxkrnl.FILE_NON_DIRECTORY_FILE;
    }

    var io_status_block: xboxkrnl.xboxkrnl.IO_STATUS_BLOCK = undefined;
    var handle: xboxkrnl.xboxdef.HANDLE = undefined;
    const status: xboxkrnl.xboxdef.NTSTATUS = xboxkrnl.xboxkrnl.NtCreateFile(
        &handle,
        access,
        &attributes,
        &io_status_block,
        null,
        xboxkrnl.xboxdef.FILE_ATTRIBUTE_NORMAL,
        xboxkrnl.xboxkrnl.FILE_SHARE_READ | xboxkrnl.xboxkrnl.FILE_SHARE_WRITE,
        xboxkrnl.xboxkrnl.FILE_OPEN,
        create_options,
    );
    if (!xboxkrnl.xboxkrnl.NT_SUCCESS(status)) return ntStatusToOpenError(status);
    errdefer _ = winapi.handleapi.CloseHandle(handle);

    // TODO: Revisit this?
    // INFO: There is no LockFileEx() in the NXDK, so `flags.lock` is ignored.

    return .{
        .handle = handle,
        .flags = .{ .nonblocking = false },
    };
}

fn fileReadPositional(
    userdata: ?*anyopaque,
    file: std.Io.File,
    data: []const []u8,
    offset: u64,
) std.Io.File.ReadPositionalError!usize {
    _ = userdata;

    var index: usize = 0;
    while (index < data.len and data[index].len == 0) index += 1;
    if (index == data.len) return 0;
    const buffer = data[index];

    const signed_offset: i64 = @bitCast(offset);
    const byte_offset: xboxkrnl.xboxdef.LARGE_INTEGER = .{ .QuadPart = signed_offset };

    var io_status_block: xboxkrnl.xboxkrnl.IO_STATUS_BLOCK = undefined;
    const status: xboxkrnl.xboxdef.NTSTATUS = xboxkrnl.xboxkrnl.NtReadFile(
        file.handle,
        null,
        null,
        null,
        &io_status_block,
        @ptrCast(buffer.ptr),
        std.math.lossyCast(u32, buffer.len),
        &byte_offset,
    );

    const status_bits: u32 = @bitCast(status);
    switch (status_bits) {
        xboxkrnl.ntstatus.STATUS_SUCCESS => return io_status_block.Information,
        // A pending status is a warning, so it would otherwise sail past a
        // NT_SUCCESS test. Our handles are opened with
        // FILE_SYNCHRONOUS_IO_NONALERT, so a synchronous read can never be
        // left pending.
        xboxkrnl.ntstatus.STATUS_PENDING => unreachable,
        // Reading at or past the end of the file is not an error; it just
        // yields however many bytes were actually available. std reports this
        // as error.EndOfStream and converts it to 0 in the caller.
        xboxkrnl.ntstatus.STATUS_END_OF_FILE => return 0,
        xboxkrnl.ntstatus.STATUS_INVALID_HANDLE => return error.NotOpenForReading,
        // Reading a directory is the one case that produces this, and the
        // answer is the same one a create would give.
        xboxkrnl.ntstatus.STATUS_INVALID_DEVICE_REQUEST => return error.IsDir,
        xboxkrnl.ntstatus.STATUS_FILE_LOCK_CONFLICT => return error.LockViolation,
        xboxkrnl.ntstatus.STATUS_ACCESS_DENIED => return error.AccessDenied,
        xboxkrnl.ntstatus.STATUS_INVALID_USER_BUFFER,
        xboxkrnl.ntstatus.STATUS_NO_MEMORY,
        xboxkrnl.ntstatus.STATUS_QUOTA_EXCEEDED,
        xboxkrnl.ntstatus.STATUS_WORKING_SET_QUOTA,
        => return error.SystemResources,
        xboxkrnl.ntstatus.STATUS_CANCELLED => return error.Canceled,
        else => return error.Unexpected,
    }
}

fn fileStat(
    userdata: ?*anyopaque,
    file: std.Io.File,
) std.Io.File.StatError!std.Io.File.Stat {
    _ = userdata;

    var io_status_block: xboxkrnl.xboxkrnl.IO_STATUS_BLOCK = undefined;

    var info: xboxkrnl.xboxkrnl.FILE_ALL_INFORMATION = undefined;
    const status: xboxkrnl.xboxdef.NTSTATUS = xboxkrnl.xboxkrnl.NtQueryInformationFile(
        file.handle,
        &io_status_block,
        @ptrCast(&info),
        @sizeOf(xboxkrnl.xboxkrnl.FILE_ALL_INFORMATION),
        .FileAllInformation,
    );

    const status_bits: u32 = @bitCast(status);
    // The structure ends with a variable-length name, so querying into a
    // fixed-size buffer always overflows. Only the fixed prefix is of interest,
    // so that still counts as success.
    if (status_bits == xboxkrnl.ntstatus.STATUS_SUCCESS or
        status_bits == xboxkrnl.ntstatus.STATUS_BUFFER_OVERFLOW)
    {
        return .{
            .inode = @bitCast(info.InternalInformation.IndexNumber.QuadPart),
            .size = @bitCast(info.StandardInformation.EndOfFile.QuadPart),
            .block_size = blockSize(),
            .permissions = .default_file,
            .kind = if (info.BasicInformation.FileAttributes &
                xboxkrnl.xboxdef.FILE_ATTRIBUTE_DIRECTORY != 0)
                .directory
            else
                .file,
            .atime = std.os.windows.fromSysTime(info.BasicInformation.LastAccessTime.QuadPart),
            .mtime = std.os.windows.fromSysTime(info.BasicInformation.LastWriteTime.QuadPart),
            .ctime = std.os.windows.fromSysTime(info.BasicInformation.ChangeTime.QuadPart),
            .nlink = info.StandardInformation.NumberOfLinks,
        };
    }

    var open_info: xboxkrnl.xboxkrnl.FILE_NETWORK_OPEN_INFORMATION = undefined;
    const open_status: xboxkrnl.xboxdef.NTSTATUS = xboxkrnl.xboxkrnl.NtQueryInformationFile(
        file.handle,
        &io_status_block,
        @ptrCast(&open_info),
        @sizeOf(xboxkrnl.xboxkrnl.FILE_NETWORK_OPEN_INFORMATION),
        .FileNetworkOpenInformation,
    );

    if (@as(u32, @bitCast(open_status)) != xboxkrnl.ntstatus.STATUS_SUCCESS) {
        if (@as(u32, @bitCast(open_status)) == xboxkrnl.ntstatus.STATUS_CANCELLED) {
            return error.Canceled;
        }
        return win32ToStatError(xboxkrnl.xboxkrnl.RtlNtStatusToDosError(open_status));
    }

    return .{
        .inode = 0,
        .size = @bitCast(open_info.EndOfFile.QuadPart),
        .block_size = blockSize(),
        .permissions = .default_file,
        .kind = if (open_info.FileAttributes & xboxkrnl.xboxdef.FILE_ATTRIBUTE_DIRECTORY != 0)
            .directory
        else
            .file,
        .atime = std.os.windows.fromSysTime(open_info.LastAccessTime.QuadPart),
        .mtime = std.os.windows.fromSysTime(open_info.LastWriteTime.QuadPart),
        .ctime = std.os.windows.fromSysTime(open_info.ChangeTime.QuadPart),
        // NXDK's GetFileInformationByHandle hardcodes this to 1 for FAT.
        .nlink = 1,
    };
}

fn fileSetLength(userdata: ?*anyopaque, file: std.Io.File, length: u64) std.Io.File.SetLengthError!void {
    _ = userdata;

    const signed_len: i64 = @bitCast(length);
    if (signed_len < 0) {
        return error.FileTooBig; // Avoid ambiguous EINVAL errors.
    }

    const end_of_file: xboxkrnl.xboxdef.LARGE_INTEGER = .{ .QuadPart = signed_len };
    var info: xboxkrnl.xboxkrnl.FILE_END_OF_FILE_INFORMATION = .{ .EndOfFile = end_of_file };

    var io_status_block: xboxkrnl.xboxkrnl.IO_STATUS_BLOCK = undefined;
    const status: xboxkrnl.xboxdef.NTSTATUS = xboxkrnl.xboxkrnl.NtSetInformationFile(
        file.handle,
        &io_status_block,
        @ptrCast(&info),
        @sizeOf(xboxkrnl.xboxkrnl.FILE_END_OF_FILE_INFORMATION),
        .FileEndOfFileInformation,
    );

    switch (@as(u32, @bitCast(status))) {
        xboxkrnl.ntstatus.STATUS_SUCCESS => return,
        xboxkrnl.ntstatus.STATUS_ACCESS_DENIED,
        xboxkrnl.ntstatus.STATUS_USER_MAPPED_FILE,
        => return error.AccessDenied,
        // A file that cannot be resized is one that is locked, or is a device
        // rather than a plain file.
        xboxkrnl.ntstatus.STATUS_NOT_SUPPORTED => return error.NonResizable,
        xboxkrnl.ntstatus.STATUS_FILE_LOCK_CONFLICT => return error.FileBusy,
        // The one documented cause left is a length the filesystem cannot
        // express. The sign check above has already rejected anything that
        // overflows i64, so anything reaching here is a filesystem limit.
        xboxkrnl.ntstatus.STATUS_INVALID_PARAMETER => return error.FileTooBig,
        xboxkrnl.ntstatus.STATUS_CANCELLED => return error.Canceled,
        else => return error.Unexpected,
    }
}

fn fileClose(userdata: ?*anyopaque, files: []const std.Io.File) void {
    _ = userdata;
    for (files) |file| {
        _ = winapi.handleapi.CloseHandle(file.handle);
    }
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

fn ntStatusToOpenError(status: xboxkrnl.xboxdef.NTSTATUS) std.Io.File.OpenError {
    return switch (@as(u32, @bitCast(status))) {
        xboxkrnl.ntstatus.STATUS_OBJECT_NAME_INVALID,
        xboxkrnl.ntstatus.STATUS_OBJECT_PATH_SYNTAX_BAD,
        => error.BadPathName,
        xboxkrnl.ntstatus.STATUS_OBJECT_NAME_NOT_FOUND,
        xboxkrnl.ntstatus.STATUS_OBJECT_PATH_NOT_FOUND,
        => error.FileNotFound,
        xboxkrnl.ntstatus.STATUS_OBJECT_NAME_COLLISION,
        => error.PathAlreadyExists,
        xboxkrnl.ntstatus.STATUS_ACCESS_DENIED,
        => error.AccessDenied,
        xboxkrnl.ntstatus.STATUS_FILE_IS_A_DIRECTORY,
        => error.IsDir,
        xboxkrnl.ntstatus.STATUS_NOT_A_DIRECTORY,
        => error.NotDir,
        xboxkrnl.ntstatus.STATUS_SHARING_VIOLATION,
        xboxkrnl.ntstatus.STATUS_DELETE_PENDING,
        => error.FileBusy,
        xboxkrnl.ntstatus.STATUS_INVALID_HANDLE,
        => error.Unexpected,
        xboxkrnl.ntstatus.STATUS_CANCELLED,
        => error.Canceled,
        else => win32ToOpenError(xboxkrnl.xboxkrnl.RtlNtStatusToDosError(status)),
    };
}

fn win32ToStatError(win32_err: xboxkrnl.xboxdef.DWORD) std.Io.File.StatError {
    return switch (win32_err) {
        winapi.winerror.ERROR_ACCESS_DENIED,
        => error.AccessDenied,
        winapi.winerror.ERROR_NOT_ENOUGH_MEMORY,
        winapi.winerror.ERROR_NO_SYSTEM_RESOURCES,
        => error.SystemResources,
        else => error.Unexpected,
    };
}

/// Picks the OBJECT_ATTRIBUTES.RootDirectory that `sub_path` should be resolved
/// against: absolute paths anchor at the DOS devices directory, a relative one
/// at `dir` itself.
fn rootDirectoryFor(dir: std.Io.Dir, sub_path: []const u8) std.Io.File.OpenError!xboxkrnl.xboxdef.HANDLE {
    return switch (std.Io.Dir.path.parsePathWindows(u8, sub_path).kind) {
        .drive_absolute,
        .unc_absolute,
        .local_device,
        .root_local_device,
        => xboxkrnl.xboxkrnl.ObDosDevicesDirectory(),
        .relative => dir.handle,
        // TODO: Revisit this?
        // INFO: There is no NtQueryObject() in the NXDK, so a directory's own
        // path cannot be recovered in order to re-anchor these against it.
        .rooted,
        .drive_relative,
        => error.BadPathName,
    };
}

fn blockSize() xboxkrnl.xboxdef.DWORD {
    var system_info: winapi.sysinfoapi.SYSTEM_INFO = undefined;
    winapi.sysinfoapi.GetSystemInfo(&system_info);
    return @max(system_info.dwPageSize, system_info.dwAllocationGranularity);
}
