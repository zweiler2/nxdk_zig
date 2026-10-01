const xboxkrnl = @import("xboxkrnl");
const minwinbase = @import("minwinbase.zig");
const winbase = @import("winbase.zig");

pub extern fn GetFileAttributesA(
    lpFileName: xboxkrnl.xboxdef.LPCSTR,
) xboxkrnl.xboxdef.DWORD;
pub extern fn GetFileAttributesExA(
    lpFileName: xboxkrnl.xboxdef.LPCSTR,
    fInfoLevelId: winbase.GET_FILEEX_INFO_LEVELS,
    lpFileInformation: xboxkrnl.xboxdef.LPVOID,
) xboxkrnl.xboxdef.BOOL;
pub extern fn SetFileAttributesA(
    lpFileName: xboxkrnl.xboxdef.LPCSTR,
    dwFileAttributes: xboxkrnl.xboxdef.DWORD,
) xboxkrnl.xboxdef.BOOL;

pub extern fn CompareFileTime(
    lpFileTime1: *const minwinbase.FILETIME,
    lpFileTime2: *const minwinbase.FILETIME,
) xboxkrnl.xboxdef.LONG;
pub extern fn GetFileTime(
    hFile: xboxkrnl.xboxdef.HANDLE,
    lpCreationTime: minwinbase.LPFILETIME,
    lpLastAccessTime: minwinbase.LPFILETIME,
    lpLastWriteTime: minwinbase.LPFILETIME,
) xboxkrnl.xboxdef.BOOL;
pub extern fn SetFileTime(
    hFile: xboxkrnl.xboxdef.HANDLE,
    lpCreationTime: *const minwinbase.FILETIME,
    lpLastAccessTime: *const minwinbase.FILETIME,
    lpLastWriteTime: *const minwinbase.FILETIME,
) xboxkrnl.xboxdef.BOOL;

pub extern fn CreateFileA(
    lpFileName: xboxkrnl.xboxdef.LPCSTR,
    dwDesiredAccess: xboxkrnl.xboxdef.DWORD,
    dwShareMode: xboxkrnl.xboxdef.DWORD,
    lpSecurityAttributes: ?winbase.LPSECURITY_ATTRIBUTES,
    dwCreationDisposition: FILE_CREATION_DISPOSITION,
    dwFlagsAndAttributes: xboxkrnl.xboxdef.DWORD,
    hTemplateFile: ?xboxkrnl.xboxdef.HANDLE,
) xboxkrnl.xboxdef.HANDLE;
pub extern fn ReadFile(
    hFile: xboxkrnl.xboxdef.HANDLE,
    lpBuffer: xboxkrnl.xboxdef.LPVOID,
    nNumberOfBytesToRead: xboxkrnl.xboxdef.DWORD,
    lpNumberOfBytesRead: xboxkrnl.xboxdef.LPDWORD,
    lpOverlapped: minwinbase.LPOVERLAPPED,
) xboxkrnl.xboxdef.BOOL;
pub extern fn WriteFile(
    hFile: xboxkrnl.xboxdef.HANDLE,
    lpBuffer: xboxkrnl.xboxdef.LPCVOID,
    nNumberOfBytesToWrite: xboxkrnl.xboxdef.DWORD,
    lpNumberOfBytesWritten: xboxkrnl.xboxdef.LPDWORD,
    lpOverlapped: ?minwinbase.LPOVERLAPPED,
) xboxkrnl.xboxdef.BOOL;
pub extern fn SetEndOfFile(
    hFile: xboxkrnl.xboxdef.HANDLE,
) xboxkrnl.xboxdef.BOOL;
pub extern fn SetFilePointer(
    hFile: xboxkrnl.xboxdef.HANDLE,
    lDistanceToMove: xboxkrnl.xboxdef.LONG,
    lpDistanceToMoveHigh: xboxkrnl.xboxdef.PLONG,
    dwMoveMethod: xboxkrnl.xboxdef.DWORD,
) xboxkrnl.xboxdef.DWORD;
pub extern fn SetFilePointerEx(
    hFile: xboxkrnl.xboxdef.HANDLE,
    liDistanceToMove: xboxkrnl.xboxdef.LARGE_INTEGER,
    lpNewFilePointer: ?xboxkrnl.xboxdef.PLARGE_INTEGER,
    dwMoveMethod: xboxkrnl.xboxdef.DWORD,
) xboxkrnl.xboxdef.BOOL;

pub extern fn GetFileSize(
    hFile: xboxkrnl.xboxdef.HANDLE,
    lpFileSizeHigh: xboxkrnl.xboxdef.LPDWORD,
) xboxkrnl.xboxdef.DWORD;
pub extern fn GetFileSizeEx(
    hFile: xboxkrnl.xboxdef.HANDLE,
    lpFileSize: xboxkrnl.xboxdef.PLARGE_INTEGER,
) xboxkrnl.xboxdef.BOOL;

pub extern fn FindFirstFileA(
    lpFileName: xboxkrnl.xboxdef.LPCSTR,
    lpFindFileData: winbase.LPWIN32_FIND_DATAA,
) xboxkrnl.xboxdef.HANDLE;
pub extern fn FindNextFileA(
    hFindFile: xboxkrnl.xboxdef.HANDLE,
    lpFindFileData: winbase.LPWIN32_FIND_DATAA,
) xboxkrnl.xboxdef.BOOL;
pub extern fn FindClose(
    hFindFile: xboxkrnl.xboxdef.HANDLE,
) xboxkrnl.xboxdef.BOOL;

pub extern fn DeleteFileA(
    lpFileName: xboxkrnl.xboxdef.LPCSTR,
) xboxkrnl.xboxdef.BOOL;
pub extern fn RemoveDirectoryA(
    lpPathName: xboxkrnl.xboxdef.LPCSTR,
) xboxkrnl.xboxdef.BOOL;
pub extern fn CreateDirectoryA(
    lpPathName: xboxkrnl.xboxdef.LPCSTR,
    lpSecurityAttributes: winbase.LPSECURITY_ATTRIBUTES,
) xboxkrnl.xboxdef.BOOL;
pub extern fn MoveFileA(
    lpExistingFileName: xboxkrnl.xboxdef.LPCSTR,
    lpNewFileName: xboxkrnl.xboxdef.LPCSTR,
) xboxkrnl.xboxdef.BOOL;
pub extern fn CopyFileA(
    lpExistingFileName: xboxkrnl.xboxdef.LPCSTR,
    lpNewFileName: xboxkrnl.xboxdef.LPCSTR,
    bFailIfExists: xboxkrnl.xboxdef.BOOL,
) xboxkrnl.xboxdef.BOOL;

pub extern fn GetDiskFreeSpaceExA(
    lpDirectoryName: xboxkrnl.xboxdef.LPCSTR,
    lpFreeBytesAvailableToCaller: xboxkrnl.xboxdef.PULARGE_INTEGER,
    lpTotalNumberOfBytes: xboxkrnl.xboxdef.PULARGE_INTEGER,
    lpTotalNumberOfFreeBytes: xboxkrnl.xboxdef.PULARGE_INTEGER,
) xboxkrnl.xboxdef.BOOL;
pub extern fn GetDiskFreeSpaceA(
    lpRootPathName: xboxkrnl.xboxdef.LPCSTR,
    lpSectorsPerCluster: xboxkrnl.xboxdef.LPDWORD,
    lpBytesPerSector: xboxkrnl.xboxdef.LPDWORD,
    lpNumberOfFreeClusters: xboxkrnl.xboxdef.LPDWORD,
    lpTotalNumberOfClusters: xboxkrnl.xboxdef.LPDWORD,
) xboxkrnl.xboxdef.BOOL;
pub extern fn GetLogicalDrives() xboxkrnl.xboxdef.DWORD;
pub extern fn GetLogicalDriveStringsA(
    nBufferLength: xboxkrnl.xboxdef.DWORD,
    lpBuffer: xboxkrnl.xboxdef.LPSTR,
) xboxkrnl.xboxdef.DWORD;

pub const _BY_HANDLE_FILE_INFORMATION = extern struct {
    dwFileAttributes: xboxkrnl.xboxdef.DWORD,
    ftCreationTime: minwinbase.FILETIME,
    ftLastAccessTime: minwinbase.FILETIME,
    ftLastWriteTime: minwinbase.FILETIME,
    dwVolumeSerialNumber: xboxkrnl.xboxdef.DWORD,
    nFileSizeHigh: xboxkrnl.xboxdef.DWORD,
    nFileSizeLow: xboxkrnl.xboxdef.DWORD,
    nNumberOfLinks: xboxkrnl.xboxdef.DWORD,
    nFileIndexHigh: xboxkrnl.xboxdef.DWORD,
    nFileIndexLow: xboxkrnl.xboxdef.DWORD,
};
pub const BY_HANDLE_FILE_INFORMATION = _BY_HANDLE_FILE_INFORMATION;
pub const PBY_HANDLE_FILE_INFORMATION = *_BY_HANDLE_FILE_INFORMATION;
pub const LPBY_HANDLE_FILE_INFORMATION = *_BY_HANDLE_FILE_INFORMATION;

pub extern fn SetFileInformationByHandle(
    hFile: xboxkrnl.xboxdef.HANDLE,
    FileInformationClass: minwinbase.FILE_INFO_BY_HANDLE_CLASS,
    lpFileInformation: xboxkrnl.xboxdef.LPVOID,
    dwBufferSize: xboxkrnl.xboxdef.DWORD,
) xboxkrnl.xboxdef.BOOL;
pub extern fn GetFileInformationByHandle(
    hFile: xboxkrnl.xboxdef.HANDLE,
    lpFileInformation: LPBY_HANDLE_FILE_INFORMATION,
) xboxkrnl.xboxdef.BOOL;

pub const GetFileAttributes = GetFileAttributesA;
pub const GetFileAttributesEx = GetFileAttributesExA;
pub const SetFileAttributes = SetFileAttributesA;
pub const CreateFile = CreateFileA;
pub const FindFirstFile = FindFirstFileA;
pub const FindNextFile = FindNextFileA;
pub const DeleteFile = DeleteFileA;
pub const RemoveDirectory = RemoveDirectoryA;
pub const CreateDirectory = CreateDirectoryA;
pub const MoveFile = MoveFileA;
pub const CopyFile = CopyFileA;
pub const GetDiskFreeSpaceEx = GetDiskFreeSpaceExA;
pub const GetDiskFreeSpace = GetDiskFreeSpaceA;
pub const GetLogicalDriveStrings = GetLogicalDriveStringsA;

pub const FILE_ACCESS_FLAGS = packed struct(xboxkrnl.xboxdef.DWORD) {
    FILE_READ_DATA: u1 = 0,
    FILE_WRITE_DATA: u1 = 0,
    FILE_APPEND_DATA: u1 = 0,
    FILE_READ_EA: u1 = 0,
    FILE_WRITE_EA: u1 = 0,
    FILE_EXECUTE: u1 = 0,
    FILE_DELETE_CHILD: u1 = 0,
    FILE_READ_ATTRIBUTES: u1 = 0,
    FILE_WRITE_ATTRIBUTES: u1 = 0,
    _9: u1 = 0,
    _10: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    DELETE: u1 = 0,
    READ_CONTROL: u1 = 0,
    WRITE_DAC: u1 = 0,
    WRITE_OWNER: u1 = 0,
    SYNCHRONIZE: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
    // FILE_LIST_DIRECTORY (bit index 0) conflicts with FILE_READ_DATA
    // FILE_ADD_FILE (bit index 1) conflicts with FILE_WRITE_DATA
    // FILE_ADD_SUBDIRECTORY (bit index 2) conflicts with FILE_APPEND_DATA
    // FILE_CREATE_PIPE_INSTANCE (bit index 2) conflicts with FILE_APPEND_DATA
    // FILE_TRAVERSE (bit index 5) conflicts with FILE_EXECUTE
    // STANDARD_RIGHTS_READ (bit index 17) conflicts with READ_CONTROL
    // STANDARD_RIGHTS_WRITE (bit index 17) conflicts with READ_CONTROL
    // STANDARD_RIGHTS_EXECUTE (bit index 17) conflicts with READ_CONTROL
};
pub const FILE_READ_DATA: FILE_ACCESS_FLAGS = .{ .FILE_READ_DATA = 1 };
pub const FILE_LIST_DIRECTORY: FILE_ACCESS_FLAGS = .{ .FILE_READ_DATA = 1 };
pub const FILE_WRITE_DATA: FILE_ACCESS_FLAGS = .{ .FILE_WRITE_DATA = 1 };
pub const FILE_ADD_FILE: FILE_ACCESS_FLAGS = .{ .FILE_WRITE_DATA = 1 };
pub const FILE_APPEND_DATA: FILE_ACCESS_FLAGS = .{ .FILE_APPEND_DATA = 1 };
pub const FILE_ADD_SUBDIRECTORY: FILE_ACCESS_FLAGS = .{ .FILE_APPEND_DATA = 1 };
pub const FILE_CREATE_PIPE_INSTANCE: FILE_ACCESS_FLAGS = .{ .FILE_APPEND_DATA = 1 };
pub const FILE_READ_EA: FILE_ACCESS_FLAGS = .{ .FILE_READ_EA = 1 };
pub const FILE_WRITE_EA: FILE_ACCESS_FLAGS = .{ .FILE_WRITE_EA = 1 };
pub const FILE_EXECUTE: FILE_ACCESS_FLAGS = .{ .FILE_EXECUTE = 1 };
pub const FILE_TRAVERSE: FILE_ACCESS_FLAGS = .{ .FILE_EXECUTE = 1 };
pub const FILE_DELETE_CHILD: FILE_ACCESS_FLAGS = .{ .FILE_DELETE_CHILD = 1 };
pub const FILE_READ_ATTRIBUTES: FILE_ACCESS_FLAGS = .{ .FILE_READ_ATTRIBUTES = 1 };
pub const FILE_WRITE_ATTRIBUTES: FILE_ACCESS_FLAGS = .{ .FILE_WRITE_ATTRIBUTES = 1 };
pub const DELETE: FILE_ACCESS_FLAGS = .{ .DELETE = 1 };
pub const READ_CONTROL: FILE_ACCESS_FLAGS = .{ .READ_CONTROL = 1 };
pub const WRITE_DAC: FILE_ACCESS_FLAGS = .{ .WRITE_DAC = 1 };
pub const WRITE_OWNER: FILE_ACCESS_FLAGS = .{ .WRITE_OWNER = 1 };
pub const SYNCHRONIZE: FILE_ACCESS_FLAGS = .{ .SYNCHRONIZE = 1 };
pub const STANDARD_RIGHTS_REQUIRED: FILE_ACCESS_FLAGS = .{
    .DELETE = 1,
    .READ_CONTROL = 1,
    .WRITE_DAC = 1,
    .WRITE_OWNER = 1,
};
pub const STANDARD_RIGHTS_READ: FILE_ACCESS_FLAGS = .{ .READ_CONTROL = 1 };
pub const STANDARD_RIGHTS_WRITE: FILE_ACCESS_FLAGS = .{ .READ_CONTROL = 1 };
pub const STANDARD_RIGHTS_EXECUTE: FILE_ACCESS_FLAGS = .{ .READ_CONTROL = 1 };
pub const STANDARD_RIGHTS_ALL: FILE_ACCESS_FLAGS = .{
    .DELETE = 1,
    .READ_CONTROL = 1,
    .WRITE_DAC = 1,
    .WRITE_OWNER = 1,
    .SYNCHRONIZE = 1,
};
pub const SPECIFIC_RIGHTS_ALL: FILE_ACCESS_FLAGS = .{
    .FILE_READ_DATA = 1,
    .FILE_WRITE_DATA = 1,
    .FILE_APPEND_DATA = 1,
    .FILE_READ_EA = 1,
    .FILE_WRITE_EA = 1,
    .FILE_EXECUTE = 1,
    .FILE_DELETE_CHILD = 1,
    .FILE_READ_ATTRIBUTES = 1,
    .FILE_WRITE_ATTRIBUTES = 1,
    ._9 = 1,
    ._10 = 1,
    ._11 = 1,
    ._12 = 1,
    ._13 = 1,
    ._14 = 1,
    ._15 = 1,
};
pub const FILE_ALL_ACCESS: FILE_ACCESS_FLAGS = .{
    .FILE_READ_DATA = 1,
    .FILE_WRITE_DATA = 1,
    .FILE_APPEND_DATA = 1,
    .FILE_READ_EA = 1,
    .FILE_WRITE_EA = 1,
    .FILE_EXECUTE = 1,
    .FILE_DELETE_CHILD = 1,
    .FILE_READ_ATTRIBUTES = 1,
    .FILE_WRITE_ATTRIBUTES = 1,
    .DELETE = 1,
    .READ_CONTROL = 1,
    .WRITE_DAC = 1,
    .WRITE_OWNER = 1,
    .SYNCHRONIZE = 1,
};
pub const FILE_GENERIC_READ: FILE_ACCESS_FLAGS = .{
    .FILE_READ_DATA = 1,
    .FILE_READ_EA = 1,
    .FILE_READ_ATTRIBUTES = 1,
    .READ_CONTROL = 1,
    .SYNCHRONIZE = 1,
};
pub const FILE_GENERIC_WRITE: FILE_ACCESS_FLAGS = .{
    .FILE_WRITE_DATA = 1,
    .FILE_APPEND_DATA = 1,
    .FILE_WRITE_EA = 1,
    .FILE_WRITE_ATTRIBUTES = 1,
    .READ_CONTROL = 1,
    .SYNCHRONIZE = 1,
};
pub const FILE_GENERIC_EXECUTE: FILE_ACCESS_FLAGS = .{
    .FILE_EXECUTE = 1,
    .FILE_READ_ATTRIBUTES = 1,
    .READ_CONTROL = 1,
    .SYNCHRONIZE = 1,
};

pub const LOCK_FILE_FLAGS = packed struct(u32) {
    FAIL_IMMEDIATELY: u1 = 0,
    EXCLUSIVE_LOCK: u1 = 0,
    _2: u1 = 0,
    _3: u1 = 0,
    _4: u1 = 0,
    _5: u1 = 0,
    _6: u1 = 0,
    _7: u1 = 0,
    _8: u1 = 0,
    _9: u1 = 0,
    _10: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
};
pub const LOCKFILE_EXCLUSIVE_LOCK: LOCK_FILE_FLAGS = .{ .EXCLUSIVE_LOCK = 1 };
pub const LOCKFILE_FAIL_IMMEDIATELY: LOCK_FILE_FLAGS = .{ .FAIL_IMMEDIATELY = 1 };

pub const FILE_CREATION_DISPOSITION = enum(xboxkrnl.xboxdef.DWORD) {
    CREATE_NEW = 1,
    CREATE_ALWAYS = 2,
    OPEN_EXISTING = 3,
    OPEN_ALWAYS = 4,
    TRUNCATE_EXISTING = 5,
};
pub const CREATE_NEW: FILE_CREATION_DISPOSITION = .CREATE_NEW;
pub const CREATE_ALWAYS: FILE_CREATION_DISPOSITION = .CREATE_ALWAYS;
pub const OPEN_EXISTING: FILE_CREATION_DISPOSITION = .OPEN_EXISTING;
pub const OPEN_ALWAYS: FILE_CREATION_DISPOSITION = .OPEN_ALWAYS;
pub const TRUNCATE_EXISTING: FILE_CREATION_DISPOSITION = .TRUNCATE_EXISTING;
