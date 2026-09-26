const xboxkrnl = @import("xboxkrnl");
const minwinbase = @import("minwinbase.zig");

pub extern fn GetSystemTime(lpSystemTime: minwinbase.LPSYSTEMTIME) void;
pub extern fn GetSystemTimeAsFileTime(lpSystemTimeAsFileTime: minwinbase.LPFILETIME) void;
pub extern fn GetSystemTimePreciseAsFileTime(lpSystemTimeAsFileTime: minwinbase.LPFILETIME) void;
pub extern fn GetTickCount() xboxkrnl.xboxdef.DWORD;
pub extern fn GetLocalTime(lpSystemTime: minwinbase.LPSYSTEMTIME) void;

// Unprovided fields are intentionally disabled to catch code trying to access them
pub const _SYSTEM_INFO = extern struct {
    DUMMYUNIONNAME: extern union {
        // dwOemId: xboxkrnl.xboxdef.DWORD,
        DUMMYSTRUCTNAME: extern struct {
            wProcessorArchitecture: xboxkrnl.xboxdef.WORD,
            wReserved: xboxkrnl.xboxdef.WORD,
        },
    },
    dwPageSize: xboxkrnl.xboxdef.DWORD,
    // lpMinimumApplicationAddress: xboxkrnl.xboxdef.LPVOID,
    // lpMaximumApplicationAddress: xboxkrnl.xboxdef.LPVOID,
    dwActiveProcessorMask: xboxkrnl.xboxdef.DWORD_PTR,
    dwNumberOfProcessors: xboxkrnl.xboxdef.DWORD,
    // dwProcessorType: xboxkrnl.xboxdef.DWORD,
    dwAllocationGranularity: xboxkrnl.xboxdef.DWORD,
    // wProcessorLevel: xboxkrnl.xboxdef.WORD,
    // wProcessorRevision: xboxkrnl.xboxdef.WORD,
};
pub const SYSTEM_INFO = _SYSTEM_INFO;
pub const LPSYSTEM_INFO = *_SYSTEM_INFO;

pub const PROCESSOR_ARCHITECTURE_INTEL = 0;
pub const PROCESSOR_ARCHITECTURE_ARM = 5;
pub const PROCESSOR_ARCHITECTURE_IA64 = 6;
pub const PROCESSOR_ARCHITECTURE_AMD64 = 9;
pub const PROCESSOR_ARCHITECTURE_ARM64 = 12;
pub const PROCESSOR_ARCHITECTURE_UNKNOWN = 0xFF_FF;

pub extern fn GetSystemInfo(lpSystemInfo: LPSYSTEM_INFO) void;
