const std = @import("std");

pub const LPCVOID = *const anyopaque;
pub const VOID = void;
pub const PVOID = *anyopaque;
pub const LPVOID = *anyopaque;
pub const HANDLE = PVOID;
pub const PHANDLE = *PVOID;

pub fn NtCurrentThread() HANDLE {
    return @import("std").zig.c_translation.helpers.cast(HANDLE, -@as(c_int, 2));
}

pub const BOOLEAN = u8;
pub const PBOOLEAN = *u8;

pub const SCHAR = i8;
pub const PSCHAR = *i8;

pub const CHAR = u8;
pub const PCHAR = *u8;
pub const CCHAR = u8;
pub const LPCH = *u8;
pub const PCH = *u8;
pub const OCHAR = u8;
pub const POCHAR = *u8;
pub const SHORT = c_short;
pub const PSHORT = *c_short;
pub const INT = c_int;
pub const PINT = *c_int;
pub const LPINT = *c_int;
pub const LONG = c_long;
pub const PLONG = *c_long;
pub const LPLONG = *c_long;
pub const LONGLONG = c_longlong;
pub const PLONGLONG = *c_longlong;

pub const BYTE = u8;
pub const UCHAR = u8;
pub const PUCHAR = *u8;
pub const USHORT = c_ushort;
pub const PUSHORT = *c_ushort;
pub const CSHORT = c_ushort;
pub const WORD = c_ushort;
pub const WCHAR = c_ushort;
pub const PWSTR = *c_ushort;
pub const UINT = c_uint;
pub const PUINT = *c_uint;
pub const LPUINT = *c_uint;
pub const DWORD = c_ulong;
pub const PDWORD = *c_ulong;
pub const LPDWORD = *c_ulong;
pub const ULONG = c_ulong;
pub const PULONG = *c_ulong;
pub const ULONGLONG = c_ulonglong;

pub const NTSTATUS = LONG;
pub const PNTSTATUS = *NTSTATUS;

pub const MAXDWORD = 0xFF_FF_FF_FF;

pub const SIZE_T = c_uint;
pub const PSIZE_T = *c_uint;

pub const BOOL = c_int;
pub const PBOOL = *c_int;
pub const PCSZ = [*c]const u8;
pub const PCSTR = [*c]const u8;
pub const LPCSTR = [*c]const u8;

pub const QUAD = ULONGLONG;

pub const ULONG_PTR = ULONG;
pub const LONG_PTR = LONG;

pub const DWORD_PTR = ULONG_PTR;

pub const _FLOATING_SAVE_AREA = extern struct {
    ControlWord: WORD align(1),
    StatusWord: WORD align(1),
    TagWord: WORD align(1),
    ErrorOpcode: WORD align(1),
    ErrorOffset: DWORD align(1),
    ErrorSelector: DWORD align(1),
    DataOffset: DWORD align(1),
    DataSelector: DWORD align(1),
    MXCsr: DWORD align(1),
    Reserved2: DWORD align(1),
    RegisterArea: [128]BYTE,
    XmmRegisterArea: [128]BYTE,
    Reserved4: [224]BYTE,
    Cr0NpxState: DWORD align(1),
};
pub const FLOATING_SAVE_AREA = _FLOATING_SAVE_AREA;
pub const PFLOATING_SAVE_AREA = *_FLOATING_SAVE_AREA;

// ContextFlags usage
pub const CONTEXT_X86 = 0x00010000; // generic x86 processor flag
pub const CONTEXT_i386 = CONTEXT_X86; // backward compatiblity
pub const CONTEXT_CONTROL = (CONTEXT_X86 | 0x00_00_00_01);
pub const CONTEXT_INTEGER = (CONTEXT_X86 | 0x00_00_00_02);
pub const CONTEXT_SEGMENTS = (CONTEXT_X86 | 0x00_00_00_04);
pub const CONTEXT_FLOATING_POINT = (CONTEXT_X86 | 0x00_00_00_08);
pub const CONTEXT_EXTENDED_REGISTERS = (CONTEXT_X86 | 0x00_00_00_20); // cpu specific extensions

pub const _CONTEXT = extern struct {
    ContextFlags: DWORD,
    FloatSave: FLOATING_SAVE_AREA,
    Edi: DWORD,
    Esi: DWORD,
    Ebx: DWORD,
    Edx: DWORD,
    Ecx: DWORD,
    Eax: DWORD,
    Ebp: DWORD,
    Eip: DWORD,
    SegCs: DWORD,
    EFlags: DWORD,
    Esp: DWORD,
    SegSs: DWORD,
};
pub const CONTEXT = _CONTEXT;
pub const PCONTEXT = *_CONTEXT;

pub const EXCEPTION_NONCONTINUABLE = 0x01;
pub const EXCEPTION_UNWINDING = 0x02;
pub const EXCEPTION_EXIT_UNWIND = 0x04;
pub const EXCEPTION_STACK_INVALID = 0x08;
pub const EXCEPTION_NESTED_CALL = 0x10;
pub const EXCEPTION_TARGET_UNWIND = 0x20;
pub const EXCEPTION_COLLIDED_UNWIND = 0x40;
pub const EXCEPTION_UNWIND = (EXCEPTION_UNWINDING | EXCEPTION_EXIT_UNWIND | EXCEPTION_TARGET_UNWIND | EXCEPTION_COLLIDED_UNWIND);
pub const EXCEPTION_MAXIMUM_PARAMETERS = 15;

pub const _EXCEPTION_RECORD = extern struct {
    ExceptionCode: NTSTATUS,
    ExceptionFlags: ULONG,
    ExceptionRecord: ?*_EXCEPTION_RECORD,
    ExceptionAddress: ?PVOID,
    NumberParameters: ULONG,
    ExceptionInformation: [EXCEPTION_MAXIMUM_PARAMETERS]ULONG_PTR,
};
pub const EXCEPTION_RECORD = _EXCEPTION_RECORD;
pub const PEXCEPTION_RECORD = *_EXCEPTION_RECORD;

pub const _STRING = extern struct {
    Length: USHORT,
    MaximumLength: USHORT,
    Buffer: ?PCHAR,
};
pub const STRING = _STRING;
pub const PSTRING = *_STRING;

pub const ANSI_STRING = STRING;
pub const PANSI_STRING = *STRING;

/// MS's way to represent a 64-bit signed int on platforms that may not support them directly.
pub const _LARGE_INTEGER = extern union {
    Anonymus: extern struct {
        LowPart: ULONG, // The low-order 32 bits.
        HighPart: LONG, // The high-order 32 bits.
    },
    u: extern struct {
        LowPart: ULONG, // The low-order 32 bits.
        HighPart: LONG, // The high-order 32 bits.
    },
    QuadPart: LONGLONG, // A signed 64-bit integer.
};
pub const LARGE_INTEGER = _LARGE_INTEGER;
pub const PLARGE_INTEGER = *_LARGE_INTEGER;

/// MS's way to represent a 64-bit unsigned int on platforms that may not support them directly.
pub const _ULARGE_INTEGER = extern union {
    Anonymus: extern struct {
        LowPart: ULONG = 0, // The low-order 32 bits.
        HighPart: ULONG = 0, // The high-order 32 bits.
    },
    u: extern struct {
        LowPart: ULONG = 0, // The low-order 32 bits.
        HighPart: ULONG = 0, // The high-order 32 bits.
    },
    QuadPart: ULONGLONG, // An unsigned 64-bit integer.
};
pub const ULARGE_INTEGER = _ULARGE_INTEGER;
pub const PULARGE_INTEGER = *_ULARGE_INTEGER;

/// Header or descriptor for an entry in a doubly linked list.
///
/// Initialized by InitializeListHead, members shouldn't be updated manually.
pub const _LIST_ENTRY = extern struct {
    Flink: *_LIST_ENTRY, // Points to the next entry of the list or the header if there is no next entry
    Blink: *_LIST_ENTRY, // Points to the previous entry of the list or the header if there is no previous entry
};
pub const LIST_ENTRY = _LIST_ENTRY;
pub const PLIST_ENTRY = *_LIST_ENTRY;

/// Struct for modelling critical sections in the XBOX-kernel
pub const _RTL_CRITICAL_SECTION = extern struct {
    Synchronization: extern union {
        Event: extern struct {
            Type: UCHAR,
            Absolute: UCHAR,
            Size: UCHAR,
            Inserted: UCHAR,
            SignalState: LONG,
            WaitListHead: LIST_ENTRY,
        },
        RawEvent: [4]ULONG,
    },
    LockCount: LONG,
    RecursionCount: LONG,
    OwningThread: ?PVOID,
};
pub const RTL_CRITICAL_SECTION = _RTL_CRITICAL_SECTION;
pub const PRTL_CRITICAL_SECTION = *_RTL_CRITICAL_SECTION;

// values for FileAttributes
pub const FILE_ATTRIBUTE_READONLY = 0x00000001;
pub const FILE_ATTRIBUTE_HIDDEN = 0x00000002;
pub const FILE_ATTRIBUTE_SYSTEM = 0x00000004;
pub const FILE_ATTRIBUTE_DIRECTORY = 0x00000010;
pub const FILE_ATTRIBUTE_ARCHIVE = 0x00000020;
pub const FILE_ATTRIBUTE_DEVICE = 0x00000040;
pub const FILE_ATTRIBUTE_NORMAL = 0x00000080;
pub const FILE_ATTRIBUTE_TEMPORARY = 0x00000100;
pub const INVALID_FILE_ATTRIBUTES = 0xFFFFFFFF;

pub const _XBE_SECTION_HEADER = extern struct {
    Flags: DWORD,
    VirtualAddress: DWORD,
    VirtualSize: DWORD,
    FileAddress: DWORD,
    FileSize: DWORD,
    SectionName: ?PCSZ,
    SectionReferenceCount: LONG,
    HeadReferenceCount: *WORD,
    TailReferenceCount: *WORD,
    CheckSum: [20]BYTE,
};
pub const XBE_SECTION_HEADER = _XBE_SECTION_HEADER;
pub const PXBE_SECTION_HEADER = *_XBE_SECTION_HEADER;
