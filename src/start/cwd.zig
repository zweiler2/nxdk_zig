const std = @import("std");
const builtin = @import("builtin");
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
    if (!xboxkrnl.xboxkrnl.NT_SUCCESS(status)) {
        std.debug.panic("could not open the working directory: {x}", .{@as(u32, @bitCast(status))});
    }
    return handle;
}
