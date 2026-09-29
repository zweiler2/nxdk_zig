const std = @import("std");
const xboxkrnl = @import("xboxkrnl");
const windef = @import("windef.zig");
const minwinbase = @import("minwinbase.zig");

pub const INVALID_HANDLE_VALUE: xboxkrnl.xboxdef.HANDLE = @ptrFromInt(@as(usize, @bitCast(@as(isize, -1))));

pub const INFINITE = 0xFF_FF_FF_FF;

pub const CREATE_SUSPENDED = 0x00_00_00_04;
/// The `STACK_SIZE_PARAM_IS_A_RESERVATION` flag has no effect when passed to
/// `CreateThread()` or `_beginthreadex()`, stacks are always committed memory in the Xbox
pub const STACK_SIZE_PARAM_IS_A_RESERVATION = 0x00_01_00_00;

pub const THREAD_PRIORITY_ABOVE_NORMAL = 1;
pub const THREAD_PRIORITY_BELOW_NORMAL = -1;
pub const THREAD_PRIORITY_HIGHEST = 2;
pub const THREAD_PRIORITY_IDLE = -15;
pub const THREAD_PRIORITY_LOWEST = -2;
pub const THREAD_PRIORITY_NORMAL = 0;
pub const THREAD_PRIORITY_TIME_CRITICAL = 15;
pub const THREAD_PRIORITY_ERROR_RETURN = 0x7F_FF_FF_FF;

pub const PFLS_CALLBACK_FUNCTION = fn () callconv(windef.WINAPI) xboxkrnl.xboxdef.VOID;
pub const FLS_OUT_OF_INDEXES = 0xFF_FF_FF_FF;
pub const FLS_MAXIMUM_AVAILABLE = 64;
pub const TLS_OUT_OF_INDEXES = FLS_OUT_OF_INDEXES;
pub const TLS_MINIMUM_AVAILABLE = FLS_MAXIMUM_AVAILABLE;

pub const _INIT_ONCE = extern struct {
    Ptr: xboxkrnl.xboxdef.PVOID,
};
pub const INIT_ONCE = _INIT_ONCE;
pub const PINIT_ONCE = *_INIT_ONCE;
pub const LPINIT_ONCE = *_INIT_ONCE;
pub const INIT_ONCE_STATIC_INIT: _INIT_ONCE = .{
    .Ptr = @ptrFromInt(0),
};
pub const INIT_ONCE_CTX_RESERVED_BITS = 2;
pub const INIT_ONCE_CHECK_ONLY = 0x00_00_00_01;
pub const INIT_ONCE_ASYNC = 0x00_00_00_02;
pub const INIT_ONCE_INIT_FAILED = 0x00_00_00_04;
pub const PINIT_ONCE_FN = fn (PINIT_ONCE, xboxkrnl.xboxdef.PVOID, *xboxkrnl.xboxdef.PVOID) callconv(windef.CALLBACK) xboxkrnl.xboxdef.BOOL;

pub const _CONDITION_VARIABLE = extern struct {
    initOnce: INIT_ONCE,
    /// eventHandles[0]: Created as SynchronizationEvent to wake a single thread
    ///
    /// eventHandles[1]: Created as NotificationEvent to wake all threads at once
    eventHandles: [2]xboxkrnl.xboxdef.PVOID,
    waitCount: c_int,
};
pub const CONDITION_VARIABLE = _CONDITION_VARIABLE;
pub const PCONDITION_VARIABLE = *_CONDITION_VARIABLE;
pub const CONDITION_VARIABLE_INIT: _CONDITION_VARIABLE = .{
    .initOnce = INIT_ONCE_STATIC_INIT,
    .eventHandles = .{ INVALID_HANDLE_VALUE, INVALID_HANDLE_VALUE },
    .waitCount = 0,
};
pub const CONDITION_VARIABLE_LOCKMODE_SHARED = 0x01;

pub const _SRWLOCK = extern struct {
    /// highest bit: reader lock (0=free, 1=locked)
    ///
    /// second-highest bit: global lock (0=free, 1=locked)
    ///
    /// remainder: blocking readers
    Ptr: xboxkrnl.xboxdef.DWORD_PTR,
};
pub const SRWLOCK = _SRWLOCK;
pub const PSRWLOCK = *_SRWLOCK;

pub const SRWLOCK_INIT: _SRWLOCK = .{
    .Ptr = 0,
};

pub const FILE_BEGIN = 0;
pub const FILE_CURRENT = 1;
pub const FILE_END = 2;
pub const INVALID_SET_FILE_POINTER: xboxkrnl.xboxdef.DWORD = std.math.maxInt(xboxkrnl.xboxdef.DWORD);
pub const INVALID_FILE_SIZE: xboxkrnl.xboxdef.DWORD = std.math.maxInt(xboxkrnl.xboxdef.DWORD);

pub const FILE_FLAG_WRITE_THROUGH = 0x80_00_00_00;
pub const FILE_FLAG_OVERLAPPED = 0x40_00_00_00;
pub const FILE_FLAG_NO_BUFFERING = 0x20_00_00_00;
pub const FILE_FLAG_RANDOM_ACCESS = 0x10_00_00_00;
pub const FILE_FLAG_SEQUENTIAL_SCAN = 0x08_00_00_00;
pub const FILE_FLAG_DELETE_ON_CLOSE = 0x04_00_00_00;
pub const FILE_FLAG_BACKUP_SEMANTICS = 0x02_00_00_00;
pub const FILE_FLAG_POSIX_SEMANTICS = 0x01_00_00_00;

pub const _GET_FILEEX_INFO_LEVELS = enum(c_int) {
    GetFileExInfoStandard,
    GetFileExMaxInfoLevel,
};
pub const GET_FILEEX_INFO_LEVELS = _GET_FILEEX_INFO_LEVELS;

pub const _WIN32_FILE_ATTRIBUTE_DATA = extern struct {
    dwFileAttributes: xboxkrnl.xboxdef.DWORD,
    ftCreationTime: minwinbase.FILETIME,
    ftLastAccessTime: minwinbase.FILETIME,
    ftLastWriteTime: xboxkrnl.xboxdef.FILETIME,
    nFileSizeHigh: xboxkrnl.xboxdef.DWORD,
    nFileSizeLow: xboxkrnl.xboxdef.DWORD,
};
pub const WIN32_FILE_ATTRIBUTE_DATA = _WIN32_FILE_ATTRIBUTE_DATA;
pub const LPWIN32_FILE_ATTRIBUTE_DATA = *_WIN32_FILE_ATTRIBUTE_DATA;

pub const _SECURITY_ATTRIBUTES = extern struct {
    nLength: xboxkrnl.xboxdef.DWORD,
    lpSecurityDescriptor: xboxkrnl.xboxdef.LPVOID,
    bInheritHandle: xboxkrnl.xboxdef.BOOL,
};
pub const SECURITY_ATTRIBUTES = _SECURITY_ATTRIBUTES;
pub const PSECURITY_ATTRIBUTES = *_SECURITY_ATTRIBUTES;
pub const LPSECURITY_ATTRIBUTES = *_SECURITY_ATTRIBUTES;

pub const _WIN32_FIND_DATAA = extern struct {
    dwFileAttributes: xboxkrnl.xboxdef.DWORD,
    ftCreationTime: minwinbase.FILETIME,
    ftLastAccessTime: minwinbase.FILETIME,
    ftLastWriteTime: minwinbase.FILETIME,
    nFileSizeHigh: xboxkrnl.xboxdef.DWORD,
    nFileSizeLow: xboxkrnl.xboxdef.DWORD,
    dwReserved0: xboxkrnl.xboxdef.DWORD,
    dwReserved1: xboxkrnl.xboxdef.DWORD,
    cFileName: [windef.MAX_PATH]xboxkrnl.xboxdef.CHAR,
    cAlternateFileName: [14]xboxkrnl.xboxdef.CHAR,
};
pub const WIN32_FIND_DATAA = _WIN32_FIND_DATAA;
pub const PWIN32_FIND_DATAA = *_WIN32_FIND_DATAA;
pub const LPWIN32_FIND_DATAA = *_WIN32_FIND_DATAA;

pub const _FILE_BASIC_INFO = extern struct {
    CreationTime: xboxkrnl.xboxdef.LARGE_INTEGER,
    LastAccessTime: xboxkrnl.xboxdef.LARGE_INTEGER,
    LastWriteTime: xboxkrnl.xboxdef.LARGE_INTEGER,
    ChangeTime: xboxkrnl.xboxdef.LARGE_INTEGER,
    FileAttributes: xboxkrnl.xboxdef.DWORD,
};
pub const FILE_BASIC_INFO = _FILE_BASIC_INFO;
pub const PFILE_BASIC_INFO = *_FILE_BASIC_INFO;

pub const _FILE_DISPOSITION_INFO = extern struct {
    DeleteFile: xboxkrnl.xboxdef.BOOLEAN,
};
pub const FILE_DISPOSITION_INFO = _FILE_DISPOSITION_INFO;
pub const PFILE_DISPOSITION_INFO = *_FILE_DISPOSITION_INFO;

pub const _FILE_ALLOCATION_INFO = extern struct {
    AllocationSize: xboxkrnl.xboxdef.LARGE_INTEGER,
};
pub const FILE_ALLOCATION_INFO = _FILE_ALLOCATION_INFO;
pub const PFILE_ALLOCATION_INFO = *_FILE_ALLOCATION_INFO;

pub const _FILE_END_OF_FILE_INFO = extern struct {
    EndOfFile: xboxkrnl.xboxdef.LARGE_INTEGER,
};
pub const FILE_END_OF_FILE_INFO = _FILE_END_OF_FILE_INFO;
pub const PFILE_END_OF_FILE_INFO = *_FILE_END_OF_FILE_INFO;

pub const WIN32_FIND_DATA = WIN32_FIND_DATAA;
pub const PWIN32_FIND_DATA = PWIN32_FIND_DATAA;
pub const LPWIN32_FIND_DATA = LPWIN32_FIND_DATAA;

pub extern fn ZeroMemory(
    Destination: xboxkrnl.xboxdef.PVOID,
    length: xboxkrnl.xboxdef.SIZE_T,
) callconv(windef.WINAPI) xboxkrnl.xboxdef.VOID;

pub extern fn GetLastError() xboxkrnl.xboxdef.DWORD;
pub extern fn SetLastError(
    err: xboxkrnl.xboxdef.DWORD,
) xboxkrnl.xboxdef.VOID;

pub extern fn OutputDebugStringA(
    lpOutputString: xboxkrnl.xboxdef.LPCTSTR,
) callconv(windef.WINAPI) xboxkrnl.xboxdef.VOID;

pub extern fn IsBadWritePtr(
    lp: xboxkrnl.xboxdef.LPVOID,
    ucb: xboxkrnl.xboxdef.UINT_PTR,
) xboxkrnl.xboxdef.BOOL;

pub extern fn GetOverlappedResult(
    hFile: xboxkrnl.xboxdef.HANDLE,
    lpOverlapped: minwinbase.LPOVERLAPPED,
    lpNumberOfBytesTransferred: xboxkrnl.xboxdef.LPDWORD,
    bWait: xboxkrnl.xboxdef.BOOL,
) xboxkrnl.xboxdef.BOOL;

pub inline fn SecureZeroMemory(ptr: xboxkrnl.xboxdef.PVOID, cnt: xboxkrnl.xboxdef.SIZE_T) xboxkrnl.xboxdef.PVOID {
    var cur_ptr: *volatile u8 = @ptrCast(@alignCast(ptr));
    const end_ptr: *volatile u8 = @as(*volatile u8, @ptrCast(ptr)) + cnt;

    while (cur_ptr < end_ptr) {
        cur_ptr.* = 0;
        cur_ptr += 1;
    }

    return ptr;
}

pub const OutputDebugString = OutputDebugStringA;
