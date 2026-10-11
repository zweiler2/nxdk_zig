const std = @import("std");
const builtin = @import("builtin");
const winapi = @import("winapi");
const xboxkrnl = @import("xboxkrnl");

comptime {
    if (!builtin.single_threaded) {
        @compileError("cwdFn() is not thread safe.");
    }
}

pub fn cwdFn() std.Io.Dir {
    if (cwd_handle == null) {
        cwd_handle = openWorkingDirectory();
    }
    return .{ .handle = cwd_handle.? };
}

// NXDK's _getcwd() (lib/xboxrt/libc_extensions/direct.c:97) returns the literal
// "D:\" and _chdir()/_chdrive() are stubs, so the working directory cannot
// change and is resolved on first use. ObDosDevicesDirectory() is the \?? namespace
// root -- correct for anchoring a drive-absolute path, but it is not the D:\
// directory itself, so a relative open against it would look for a *device*
// named after the file.
//
// A container-level initializer would be the more obvious home for this, but Zig
// requires those to be comptime-known. The handle is never closed, matching std:
// Dir.cwd() documents closing the returned Dir as illegal behavior.
var cwd_handle: ?xboxkrnl.xboxdef.HANDLE = null;

fn openWorkingDirectory() xboxkrnl.xboxdef.HANDLE {
    var path_buffer: [3:0]u8 = "D:\\".*;

    var ansi_path: xboxkrnl.xboxdef.ANSI_STRING = undefined;
    xboxkrnl.xboxkrnl.RtlInitAnsiString(&ansi_path, &path_buffer);

    const attributes: xboxkrnl.xboxkrnl.OBJECT_ATTRIBUTES = .{
        .RootDirectory = xboxkrnl.xboxkrnl.ObDosDevicesDirectory(),
        .ObjectName = &ansi_path,
        .Attributes = xboxkrnl.xboxkrnl.OBJ_CASE_INSENSITIVE,
    };

    var io_status_block: xboxkrnl.xboxkrnl.IO_STATUS_BLOCK = undefined;
    var handle: xboxkrnl.xboxdef.HANDLE = undefined;
    const status: xboxkrnl.xboxdef.NTSTATUS = xboxkrnl.xboxkrnl.NtCreateFile(
        &handle,
        xboxkrnl.xboxkrnl.FILE_TRAVERSE |
            xboxkrnl.xboxkrnl.FILE_READ_ATTRIBUTES |
            xboxkrnl.xboxkrnl.SYNCHRONIZE,
        &attributes,
        &io_status_block,
        null,
        xboxkrnl.xboxdef.FILE_ATTRIBUTE_NORMAL,
        xboxkrnl.xboxkrnl.FILE_SHARE_READ | xboxkrnl.xboxkrnl.FILE_SHARE_WRITE,
        xboxkrnl.xboxkrnl.FILE_OPEN,
        xboxkrnl.xboxkrnl.FILE_SYNCHRONOUS_IO_NONALERT |
            xboxkrnl.xboxkrnl.FILE_DIRECTORY_FILE,
    );
    if (xboxkrnl.xboxkrnl.NT_SUCCESS(status)) {
        return handle;
    }
    // `D:` is not mounted (xemu at panic time exposes the DVD without a DOS
    // drive letter). Fall back to the boot volume's directory, taken from the
    // path the kernel used to launch us (`\Device\CdRom0\default.xbe`), so a
    // relative open still lands in the image's own directory. If even that
    // fails there is no meaningful cwd, so hand back an invalid handle and let
    // opens fail cleanly instead of silently resolving against `\??`.
    return openBootDeviceDirectory() orelse
        winapi.winbase.INVALID_HANDLE_VALUE;
}

/// Opens the directory holding the running image (`\Device\CdRom0` for
/// `\Device\CdRom0\default.xbe`) as recorded in `XeImageFileName`.
fn openBootDeviceDirectory() ?xboxkrnl.xboxdef.HANDLE {
    const image_file = xboxkrnl.xboxkrnl.XeImageFileName();
    const buffer = image_file.*.Buffer orelse
        return null;
    const path = std.mem.span(buffer);
    const last_sep = std.mem.lastIndexOfScalar(u8, path, std.Io.Dir.path.sep_windows) orelse
        return null;

    const dir = path[0..last_sep];
    var path_buffer: [winapi.windef.MAX_PATH:0]u8 = undefined;
    if (dir.len == 0 or dir.len >= path_buffer.len) {
        return null;
    }
    @memcpy(path_buffer[0..dir.len], dir);
    path_buffer[dir.len] = 0;

    var ansi_path: xboxkrnl.xboxdef.ANSI_STRING = undefined;
    xboxkrnl.xboxkrnl.RtlInitAnsiString(&ansi_path, &path_buffer);

    const attributes: xboxkrnl.xboxkrnl.OBJECT_ATTRIBUTES = .{
        .RootDirectory = null, // fully qualified device path: NULL root
        .ObjectName = &ansi_path,
        .Attributes = xboxkrnl.xboxkrnl.OBJ_CASE_INSENSITIVE,
    };

    var io_status_block: xboxkrnl.xboxkrnl.IO_STATUS_BLOCK = undefined;
    var handle: xboxkrnl.xboxdef.HANDLE = undefined;
    const status: xboxkrnl.xboxdef.NTSTATUS = xboxkrnl.xboxkrnl.NtCreateFile(
        &handle,
        xboxkrnl.xboxkrnl.FILE_TRAVERSE |
            xboxkrnl.xboxkrnl.FILE_READ_ATTRIBUTES |
            xboxkrnl.xboxkrnl.SYNCHRONIZE,
        &attributes,
        &io_status_block,
        null,
        xboxkrnl.xboxdef.FILE_ATTRIBUTE_NORMAL,
        xboxkrnl.xboxkrnl.FILE_SHARE_READ | xboxkrnl.xboxkrnl.FILE_SHARE_WRITE,
        xboxkrnl.xboxkrnl.FILE_OPEN,
        xboxkrnl.xboxkrnl.FILE_SYNCHRONOUS_IO_NONALERT |
            xboxkrnl.xboxkrnl.FILE_DIRECTORY_FILE,
    );
    if (!xboxkrnl.xboxkrnl.NT_SUCCESS(status)) {
        return null;
    }
    return handle;
}
