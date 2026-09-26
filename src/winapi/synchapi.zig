const xboxkrnl = @import("xboxkrnl");
const winbase = @import("winbase.zig");

pub const CRITICAL_SECTION = xboxkrnl.xboxdef.RTL_CRITICAL_SECTION;
pub const LPCRITICAL_SECTION = xboxkrnl.xboxdef.PRTL_CRITICAL_SECTION;
pub const PCRITICAL_SECTION = xboxkrnl.xboxdef.PRTL_CRITICAL_SECTION;

pub extern fn InitializeCriticalSection(lpCriticalSection: LPCRITICAL_SECTION) void;
pub extern fn InitializeCriticalSectionAndSpinCount(lpCriticalSection: LPCRITICAL_SECTION, dwSpinCount: xboxkrnl.xboxdef.DWORD) xboxkrnl.xboxdef.BOOL;
pub extern fn DeleteCriticalSection(lpCriticalSection: LPCRITICAL_SECTION) void;
pub extern fn EnterCriticalSection(lpCriticalSection: LPCRITICAL_SECTION) void;
pub extern fn TryEnterCriticalSection(lpCriticalSection: LPCRITICAL_SECTION) xboxkrnl.xboxdef.BOOL;
pub extern fn LeaveCriticalSection(lpCriticalSection: LPCRITICAL_SECTION) void;

pub extern fn InitializeConditionVariable(ConditionVariable: winbase.PCONDITION_VARIABLE) void;
pub extern fn SleepConditionVariableCS(ConditionVariable: winbase.PCONDITION_VARIABLE, CriticalSection: PCRITICAL_SECTION, dwMilliseconds: xboxkrnl.xboxdef.DWORD) xboxkrnl.xboxdef.BOOL;
pub extern fn SleepConditionVariableSRW(ConditionVariable: winbase.PCONDITION_VARIABLE, SRWLock: winbase.PSRWLOCK, dwMilliseconds: xboxkrnl.xboxdef.DWORD, Flags: xboxkrnl.xboxdef.ULONG) xboxkrnl.xboxdef.BOOL;
pub extern fn WakeConditionVariable(ConditionVariable: winbase.PCONDITION_VARIABLE) void;
pub extern fn WakeAllConditionVariable(ConditionVariable: winbase.PCONDITION_VARIABLE) void;
/// UninitializeConditionVariable is an nxdk extension to free associated system resources
pub extern fn UninitializeConditionVariable(ConditionVariable: winbase.PCONDITION_VARIABLE) void;

pub extern fn AcquireSRWLockExclusive(SRWLock: winbase.PSRWLOCK) void;
pub extern fn AcquireSRWLockShared(SRWLock: winbase.PSRWLOCK) void;
pub extern fn InitializeSRWLock(SRWLock: winbase.PSRWLOCK) void;
pub extern fn ReleaseSRWLockExclusive(SRWLock: winbase.PSRWLOCK) void;
pub extern fn ReleaseSRWLockShared(SRWLock: winbase.PSRWLOCK) void;
pub extern fn TryAcquireSRWLockExclusive(SRWLock: winbase.PSRWLOCK) xboxkrnl.xboxdef.BOOLEAN;
pub extern fn TryAcquireSRWLockShared(SRWLock: winbase.PSRWLOCK) xboxkrnl.xboxdef.BOOLEAN;

pub extern fn InitOnceExecuteOnce(InitOnce: winbase.PINIT_ONCE, InitFn: winbase.PINIT_ONCE_FN, Context: ?xboxkrnl.xboxdef.PVOID, Parameter: ?*xboxkrnl.xboxdef.LPVOID) xboxkrnl.xboxdef.BOOL;
pub extern fn InitOnceBeginInitialize(lpInitOnce: winbase.LPINIT_ONCE, dwFlags: xboxkrnl.xboxdef.DWORD, fPending: xboxkrnl.xboxdef.PBOOL, lpContext: ?*xboxkrnl.xboxdef.LPVOID) xboxkrnl.xboxdef.BOOL;
pub extern fn InitOnceComplete(lpInitOnce: winbase.LPINIT_ONCE, dwFlags: xboxkrnl.xboxdef.DWORD, lpContext: ?xboxkrnl.xboxdef.LPVOID) xboxkrnl.xboxdef.BOOL;

/// same as STATUS_ABANDONED_WAIT_0
pub const WAIT_ABANDONED: xboxkrnl.xboxdef.DWORD = 0x00_00_00_80;
/// same as STATUS_USER_APC
pub const WAIT_IO_COMPLETION: xboxkrnl.xboxdef.DWORD = 0x00_00_00_C0;
/// same as STATUS_WAIT_0
pub const WAIT_OBJECT_0: xboxkrnl.xboxdef.DWORD = 0x00_00_00_00;
/// same as STATUS_TIMEOUT
pub const WAIT_TIMEOUT: xboxkrnl.xboxdef.DWORD = 0x00_00_01_02;
pub const WAIT_FAILED: xboxkrnl.xboxdef.DWORD = 0xFF_FF_FF_FF;

pub extern fn Sleep(dwMilliseconds: xboxkrnl.xboxdef.DWORD) void;
pub extern fn SleepEx(dwMilliseconds: xboxkrnl.xboxdef.DWORD, bAlertable: xboxkrnl.xboxdef.BOOL) xboxkrnl.xboxdef.DWORD;

pub extern fn WaitForSingleObjectEx(hHandle: xboxkrnl.xboxdef.HANDLE, dwMilliseconds: xboxkrnl.xboxdef.DWORD, bAlertable: xboxkrnl.xboxdef.BOOL) xboxkrnl.xboxdef.DWORD;
pub extern fn WaitForSingleObject(hHandle: xboxkrnl.xboxdef.HANDLE, dwMilliseconds: xboxkrnl.xboxdef.DWORD) xboxkrnl.xboxdef.DWORD;
pub extern fn WaitForMultipleObjectsEx(nCount: xboxkrnl.xboxdef.DWORD, lpHandles: [*c]const xboxkrnl.xboxdef.HANDLE, bWaitAll: xboxkrnl.xboxdef.BOOL, dwMilliseconds: xboxkrnl.xboxdef.DWORD, bAlertable: xboxkrnl.xboxdef.BOOL) xboxkrnl.xboxdef.DWORD;
pub extern fn WaitForMultipleObjects(nCount: xboxkrnl.xboxdef.DWORD, lpHandles: [*c]const xboxkrnl.xboxdef.HANDLE, bWaitAll: xboxkrnl.xboxdef.BOOL, dwMilliseconds: xboxkrnl.xboxdef.DWORD) xboxkrnl.xboxdef.DWORD;

pub extern fn CreateSemaphore(lpSemaphoreAttributes: winbase.LPSECURITY_ATTRIBUTES, lInitialCount: xboxkrnl.xboxdef.LONG, lMaximumCount: xboxkrnl.xboxdef.LONG, lpName: xboxkrnl.xboxdef.LPCSTR) xboxkrnl.xboxdef.HANDLE;
pub extern fn ReleaseSemaphore(hSemaphore: xboxkrnl.xboxdef.HANDLE, lReleaseCount: xboxkrnl.xboxdef.LONG, lpPreviousCount: xboxkrnl.xboxdef.LPLONG) xboxkrnl.xboxdef.BOOL;

pub extern fn CreateMutexA(lpMutexAttributes: winbase.LPSECURITY_ATTRIBUTES, bInitialOwner: xboxkrnl.xboxdef.BOOL, lpName: xboxkrnl.xboxdef.LPCSTR) xboxkrnl.xboxdef.HANDLE;
pub extern fn ReleaseMutex(hMutex: xboxkrnl.xboxdef.HANDLE) xboxkrnl.xboxdef.BOOL;

pub extern fn CreateEventA(lpEventAttributes: winbase.LPSECURITY_ATTRIBUTES, bManualReset: xboxkrnl.xboxdef.BOOL, bInitialState: xboxkrnl.xboxdef.BOOL, lpName: xboxkrnl.xboxdef.LPCSTR) xboxkrnl.xboxdef.HANDLE;
pub extern fn SetEvent(hEvent: xboxkrnl.xboxdef.HANDLE) xboxkrnl.xboxdef.BOOL;
pub extern fn ResetEvent(hEvent: xboxkrnl.xboxdef.HANDLE) xboxkrnl.xboxdef.BOOL;
pub extern fn PulseEvent(hEvent: xboxkrnl.xboxdef.HANDLE) xboxkrnl.xboxdef.BOOL;

// #ifndef UNICODE
pub const CreateMutex = CreateMutexA;
pub const CreateEvent = CreateEventA;
// #else
// #error nxdk does not support the Unicode API
// #endif
