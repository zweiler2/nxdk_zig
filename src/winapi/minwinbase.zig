const xboxkrnl = @import("xboxkrnl");

pub const _FILETIME = extern struct {
    dwLowDateTime: xboxkrnl.xboxdef.DWORD,
    dwHighDateTime: xboxkrnl.xboxdef.DWORD,
};
pub const FILETIME = _FILETIME;
pub const LPFILETIME = *_FILETIME;

pub const _OVERLAPPED = extern struct {
    Internal: xboxkrnl.xboxdef.ULONG_PTR,
    InternalHigh: xboxkrnl.xboxdef.ULONG_PTR,
    Offset: xboxkrnl.xboxdef.DWORD,
    OffsetHigh: xboxkrnl.xboxdef.DWORD,
    hEvent: xboxkrnl.xboxdef.HANDLE,
};
pub const OVERLAPPED = _OVERLAPPED;
pub const LPOVERLAPPED = *_OVERLAPPED;

pub const _SYSTEMTIME = extern struct {
    wYear: xboxkrnl.xboxdef.WORD,
    wMonth: xboxkrnl.xboxdef.WORD,
    wDayOfWeek: xboxkrnl.xboxdef.WORD,
    wDay: xboxkrnl.xboxdef.WORD,
    wHour: xboxkrnl.xboxdef.WORD,
    wMinute: xboxkrnl.xboxdef.WORD,
    wSecond: xboxkrnl.xboxdef.WORD,
    wMilliseconds: xboxkrnl.xboxdef.WORD,
};
pub const SYSTEMTIME = _SYSTEMTIME;
pub const PSYSTEMTIME = *_SYSTEMTIME;
pub const LPSYSTEMTIME = *_SYSTEMTIME;

pub const STILL_ACTIVE = xboxkrnl.ntstatus.STATUS_PENDING;
pub const EXCEPTION_ACCESS_VIOLATION = xboxkrnl.ntstatus.STATUS_ACCESS_VIOLATION;
pub const EXCEPTION_DATATYPE_MISALIGNMENT = xboxkrnl.ntstatus.STATUS_DATATYPE_MISALIGNMENT;
pub const EXCEPTION_BREAKPOINT = xboxkrnl.ntstatus.STATUS_BREAKPOINT;
pub const EXCEPTION_SINGLE_STEP = xboxkrnl.ntstatus.STATUS_SINGLE_STEP;
pub const EXCEPTION_ARRAY_BOUNDS_EXCEEDED = xboxkrnl.ntstatus.STATUS_ARRAY_BOUNDS_EXCEEDED;
pub const EXCEPTION_FLT_DENORMAL_OPERAND = xboxkrnl.ntstatus.STATUS_FLOAT_DENORMAL_OPERAND;
pub const EXCEPTION_FLT_DIVIDE_BY_ZERO = xboxkrnl.ntstatus.STATUS_FLOAT_DIVIDE_BY_ZERO;
pub const EXCEPTION_FLT_INEXACT_RESULT = xboxkrnl.ntstatus.STATUS_FLOAT_INEXACT_RESULT;
pub const EXCEPTION_FLT_INVALID_OPERATION = xboxkrnl.ntstatus.STATUS_FLOAT_INVALID_OPERATION;
pub const EXCEPTION_FLT_OVERFLOW = xboxkrnl.ntstatus.STATUS_FLOAT_OVERFLOW;
pub const EXCEPTION_FLT_STACK_CHECK = xboxkrnl.ntstatus.STATUS_FLOAT_STACK_CHECK;
pub const EXCEPTION_FLT_UNDERFLOW = xboxkrnl.ntstatus.STATUS_FLOAT_UNDERFLOW;
pub const EXCEPTION_INT_DIVIDE_BY_ZERO = xboxkrnl.ntstatus.STATUS_INTEGER_DIVIDE_BY_ZERO;
pub const EXCEPTION_INT_OVERFLOW = xboxkrnl.ntstatus.STATUS_INTEGER_OVERFLOW;
pub const EXCEPTION_PRIV_INSTRUCTION = xboxkrnl.ntstatus.STATUS_PRIVILEGED_INSTRUCTION;
pub const EXCEPTION_IN_PAGE_ERROR = xboxkrnl.ntstatus.STATUS_IN_PAGE_ERROR;
pub const EXCEPTION_ILLEGAL_INSTRUCTION = xboxkrnl.ntstatus.STATUS_ILLEGAL_INSTRUCTION;
pub const EXCEPTION_NONCONTINUABLE_EXCEPTION = xboxkrnl.ntstatus.STATUS_NONCONTINUABLE_EXCEPTION;
pub const EXCEPTION_STACK_OVERFLOW = xboxkrnl.ntstatus.STATUS_STACK_OVERFLOW;
pub const EXCEPTION_INVALID_DISPOSITION = xboxkrnl.ntstatus.STATUS_INVALID_DISPOSITION;
pub const EXCEPTION_GUARD_PAGE = xboxkrnl.ntstatus.STATUS_GUARD_PAGE_VIOLATION;
pub const EXCEPTION_INVALID_HANDLE = xboxkrnl.ntstatus.STATUS_INVALID_HANDLE;

pub const _FILE_INFO_BY_HANDLE_CLASS = enum(c_int) {
    FileBasicInfo,
    FileStandardInfo,
    FileNameInfo,
    FileRenameInfo,
    FileDispositionInfo,
    FileAllocationInfo,
    FileEndOfFileInfo,
    FileStreamInfo,
    FileCompressionInfo,
    FileAttributeTagInfo,
    FileIdBothDirectoryInfo,
    FileIdBothDirectoryRestartInfo,
    FileIoPriorityHintInfo,
    FileRemoteProtocolInfo,
    FileFullDirectoryInfo,
    FileFullDirectoryRestartInfo,
    FileStorageInfo,
    FileAlignmentInfo,
    FileIdInfo,
    FileIdExtdDirectoryInfo,
    FileIdExtdDirectoryRestartInfo,
    FileDispositionInfoEx,
    FileRenameInfoEx,
    FileCaseSensitiveInfo,
    FileNormalizedNameInfo,
    MaximumFileInfoByHandleClass,
};
pub const FILE_INFO_BY_HANDLE_CLASS = _FILE_INFO_BY_HANDLE_CLASS;
pub const PFILE_INFO_BY_HANDLE_CLASS = *_FILE_INFO_BY_HANDLE_CLASS;
