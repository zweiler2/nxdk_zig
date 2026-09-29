const xboxkrnl = @import("xboxkrnl");

pub extern fn CloseHandle(hObject: xboxkrnl.xboxdef.HANDLE) xboxkrnl.xboxdef.BOOL;
