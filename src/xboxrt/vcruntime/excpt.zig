const xboxkrnl = @import("xboxkrnl");
const winapi = @import("winapi");

pub const _EXCEPTION_REGISTRATION = extern struct {
    prev: *_EXCEPTION_REGISTRATION,
    handler: *anyopaque,
};
pub const EXCEPTION_REGISTRATION = _EXCEPTION_REGISTRATION;
pub const PEXCEPTION_REGISTRATION = *_EXCEPTION_REGISTRATION;

extern fn _exception_code() xboxkrnl.xboxdef.DWORD;
pub const GetExceptionCode = _exception_code;

extern fn _exception_info() winapi.winnt.PEXCEPTION_POINTERS;
pub const GetExceptionInformation = _exception_info;

pub const EXCEPTION_EXECUTE_HANDLER = 1;
pub const EXCEPTION_CONTINUE_SEARCH = 0;
pub const EXCEPTION_CONTINUE_EXECUTION = -1;

pub const _EXCEPTION_DISPOSITION = enum(c_int) {
    ExceptionContinueExecution = 0,
    ExceptionContinueSearch = 1,
    ExceptionNestedException = 2,
    ExceptionCollidedUnwind = 3,
};
pub const EXCEPTION_DISPOSITION = _EXCEPTION_DISPOSITION;
