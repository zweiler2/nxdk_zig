const xboxkrnl = @import("xboxkrnl");

pub extern fn RaiseException(dwExceptionCode: xboxkrnl.xboxdef.DWORD, dwExceptionFlags: xboxkrnl.xboxdef.DWORD, nNumberOfArguments: xboxkrnl.xboxdef.DWORD, lpArguments: ?*const xboxkrnl.xboxdef.ULONG_PTR) xboxkrnl.xboxdef.VOID;
