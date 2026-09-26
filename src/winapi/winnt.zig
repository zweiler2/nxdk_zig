const xboxkrnl = @import("xboxkrnl");

pub const LONG = xboxkrnl.xboxdef.HRESULT;

pub const LPSTR = *xboxkrnl.xboxdef.CHAR;

pub const LONG64 = i64;
pub const PLONG64 = *i64;

pub extern fn InterlockedExchange64(Target: *volatile LONG64, Value: LONG64) LONG64;
pub extern fn InterlockedExchangePointer(Target: *volatile xboxkrnl.xboxdef.PVOID, Value: xboxkrnl.xboxdef.PVOID) xboxkrnl.xboxdef.PVOID;
pub extern fn InterlockedCompareExchangePointer(Destination: *volatile xboxkrnl.xboxdef.PVOID, Exchange: xboxkrnl.xboxdef.PVOID, Comperand: xboxkrnl.xboxdef.PVOID) xboxkrnl.xboxdef.PVOID;

pub const LPCTSTR = xboxkrnl.xboxdef.LPCSTR;

pub const _EXCEPTION_POINTERS = extern struct {
    ExceptionRecord: xboxkrnl.xboxdef.PEXCEPTION_RECORD,
    ContextRecord: xboxkrnl.xboxdef.PCONTEXT,
};
pub const EXCEPTION_POINTERS = _EXCEPTION_POINTERS;
pub const PEXCEPTION_POINTERS = *_EXCEPTION_POINTERS;

pub const IMAGE_DOS_SIGNATURE = 0x5A_4D;
pub const IMAGE_NT_SIGNATURE = 0x00_00_45_50;

pub const _IMAGE_DOS_HEADER = extern struct {
    e_magic: xboxkrnl.xboxdef.WORD,
    e_cblp: xboxkrnl.xboxdef.WORD,
    e_cp: xboxkrnl.xboxdef.WORD,
    e_crlc: xboxkrnl.xboxdef.WORD,
    e_cparhdr: xboxkrnl.xboxdef.WORD,
    e_minalloc: xboxkrnl.xboxdef.WORD,
    e_maxalloc: xboxkrnl.xboxdef.WORD,
    e_ss: xboxkrnl.xboxdef.WORD,
    e_sp: xboxkrnl.xboxdef.WORD,
    e_csum: xboxkrnl.xboxdef.WORD,
    e_ip: xboxkrnl.xboxdef.WORD,
    e_cs: xboxkrnl.xboxdef.WORD,
    e_lfarlc: xboxkrnl.xboxdef.WORD,
    e_ovno: xboxkrnl.xboxdef.WORD,
    e_res: [4]xboxkrnl.xboxdef.WORD,
    e_oemid: xboxkrnl.xboxdef.WORD,
    e_oeminfo: xboxkrnl.xboxdef.WORD,
    e_res2: [10]xboxkrnl.xboxdef.WORD,
    e_lfanew: xboxkrnl.xboxdef.LONG,
};
pub const IMAGE_DOS_HEADER = _IMAGE_DOS_HEADER;
pub const PIMAGE_DOS_HEADER = *_IMAGE_DOS_HEADER;

pub const _IMAGE_DATA_DIRECTORY = extern struct {
    VirtualAddress: xboxkrnl.xboxdef.WORD,
    Size: xboxkrnl.xboxdef.WORD,
};
pub const IMAGE_DATA_DIRECTORY = _IMAGE_DATA_DIRECTORY;
pub const PIMAGE_DATA_DIRECTORY = *_IMAGE_DATA_DIRECTORY;

pub const IMAGE_NT_OPTIONAL_HDR32_MAGIC = 0x10B;
pub const IMAGE_NT_OPTIONAL_HDR64_MAGIC = 0x20B;
pub const IMAGE_ROM_OPTIONAL_HDR_MAGIC = 0x107;
pub const IMAGE_NT_OPTIONAL_HDR_MAGIC = IMAGE_NT_OPTIONAL_HDR32_MAGIC;

pub const IMAGE_SUBSYSTEM_UNKNOWN = 0;
pub const IMAGE_SUBSYSTEM_NATIVE = 1;
pub const IMAGE_SUBSYSTEM_WINDOWS_GUI = 2;
pub const IMAGE_SUBSYSTEM_WINDOWS_CUI = 3;
pub const IMAGE_SUBSYSTEM_OS2_CUI = 5;
pub const IMAGE_SUBSYSTEM_POSIX_CUI = 7;
pub const IMAGE_SUBSYSTEM_WINDOWS_CE_GUI = 9;
pub const IMAGE_SUBSYSTEM_EFI_APPLICATION = 10;
pub const IMAGE_SUBSYSTEM_EFI_BOOT_SERVICE_DRIVER = 11;
pub const IMAGE_SUBSYSTEM_EFI_RUNTIME_DRIVER = 12;
pub const IMAGE_SUBSYSTEM_EFI_ROM = 13;
pub const IMAGE_SUBSYSTEM_XBOX = 14;
pub const IMAGE_SUBSYSTEM_WINDOWS_BOOT_APPLICATION = 16;

pub const IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE = 0x00_40;
pub const IMAGE_DLLCHARACTERISTICS_FORCE_INTEGRITY = 0x00_80;
pub const IMAGE_DLLCHARACTERISTICS_NX_COMPAT = 0x01_00;
pub const IMAGE_DLLCHARACTERISTICS_NO_ISOLATION = 0x02_00;
pub const IMAGE_DLLCHARACTERISTICS_NO_SEH = 0x04_00;
pub const IMAGE_DLLCHARACTERISTICS_NO_BIND = 0x08_00;
pub const IMAGE_DLLCHARACTERISTICS_WDM_DRIVER = 0x20_00;
pub const IMAGE_DLLCHARACTERISTICS_TERMINAL_SERVER_AWARE = 0x80_00;

pub const IMAGE_NUMBEROF_DIRECTORY_ENTRIES = 16;
pub const IMAGE_DIRECTORY_ENTRY_EXPORT = 0;
pub const IMAGE_DIRECTORY_ENTRY_IMPORT = 1;
pub const IMAGE_DIRECTORY_ENTRY_RESOURCE = 2;
pub const IMAGE_DIRECTORY_ENTRY_EXCEPTION = 3;
pub const IMAGE_DIRECTORY_ENTRY_SECURITY = 4;
pub const IMAGE_DIRECTORY_ENTRY_BASERELOC = 5;
pub const IMAGE_DIRECTORY_ENTRY_DEBUG = 6;
pub const IMAGE_DIRECTORY_ENTRY_ARCHITECTURE = 7;
pub const IMAGE_DIRECTORY_ENTRY_GLOBALPTR = 8;
pub const IMAGE_DIRECTORY_ENTRY_TLS = 9;
pub const IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG = 10;
pub const IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT = 11;
pub const IMAGE_DIRECTORY_ENTRY_IAT = 12;
pub const IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT = 13;
pub const IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR = 14;

pub const _IMAGE_OPTIONAL_HEADER = extern struct {
    Magic: xboxkrnl.xboxdef.WORD,
    MajorLinkerVersion: xboxkrnl.xboxdef.BYTE,
    MinorLinkerVersion: xboxkrnl.xboxdef.BYTE,
    SizeOfCode: xboxkrnl.xboxdef.DWORD,
    SizeOfInitializedData: xboxkrnl.xboxdef.DWORD,
    SizeOfUninitializedData: xboxkrnl.xboxdef.DWORD,
    AddressOfEntryPoint: xboxkrnl.xboxdef.DWORD,
    BaseOfCode: xboxkrnl.xboxdef.DWORD,
    BaseOfData: xboxkrnl.xboxdef.DWORD,
    ImageBase: xboxkrnl.xboxdef.DWORD,
    SectionAlignment: xboxkrnl.xboxdef.DWORD,
    FileAlignment: xboxkrnl.xboxdef.DWORD,
    MajorOperatingSystemVersion: xboxkrnl.xboxdef.WORD,
    MinorOperatingSystemVersion: xboxkrnl.xboxdef.WORD,
    MajorImageVersion: xboxkrnl.xboxdef.WORD,
    MinorImageVersion: xboxkrnl.xboxdef.WORD,
    MajorSubsystemVersion: xboxkrnl.xboxdef.WORD,
    MinorSubsystemVersion: xboxkrnl.xboxdef.WORD,
    Win32VersionValue: xboxkrnl.xboxdef.DWORD,
    SizeOfImage: xboxkrnl.xboxdef.DWORD,
    SizeOfHeaders: xboxkrnl.xboxdef.DWORD,
    CheckSum: xboxkrnl.xboxdef.DWORD,
    Subsystem: xboxkrnl.xboxdef.WORD,
    DllCharacteristics: xboxkrnl.xboxdef.WORD,
    SizeOfStackReserve: xboxkrnl.xboxdef.DWORD,
    SizeOfStackCommit: xboxkrnl.xboxdef.DWORD,
    SizeOfHeapReserve: xboxkrnl.xboxdef.DWORD,
    SizeOfHeapCommit: xboxkrnl.xboxdef.DWORD,
    LoaderFlags: xboxkrnl.xboxdef.DWORD,
    NumberOfRvaAndSizes: xboxkrnl.xboxdef.DWORD,
    DataDirectory: [IMAGE_NUMBEROF_DIRECTORY_ENTRIES]IMAGE_DATA_DIRECTORY,
};
pub const IMAGE_OPTIONAL_HEADER32 = _IMAGE_OPTIONAL_HEADER;
pub const PIMAGE_OPTION_HEADER32 = *_IMAGE_OPTIONAL_HEADER;

pub const IMAGE_FILE_MACHINE_I386 = 0x01_4C;
pub const IMAGE_FILE_MACHINE_IA64 = 0x02_00;
pub const IMAGE_FILE_MACHINE_AMD64 = 0x86_64;

pub const IMAGE_FILE_RELOCS_STRIPPED = 0x00_01;
pub const IMAGE_FILE_EXECUTABLE_IMAGE = 0x00_02;
pub const IMAGE_FILE_LINE_NUMS_STRIPPED = 0x00_04;
pub const IMAGE_FILE_LOCAL_SYMS_STRIPPED = 0x00_08;
pub const IMAGE_FILE_AGGRESIVE_WS_TRIM = 0x00_10;
pub const IMAGE_FILE_LARGE_ADDRESS_AWARE = 0x00_20;
pub const IMAGE_FILE_BYTES_REVERSED_LO = 0x00_80;
pub const IMAGE_FILE_32BIT_MACHINE = 0x01_00;
pub const IMAGE_FILE_DEBUG_STRIPPED = 0x02_00;
pub const IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP = 0x04_00;
pub const IMAGE_FILE_NET_RUN_FROM_SWAP = 0x08_00;
pub const IMAGE_FILE_SYSTEM = 0x10_00;
pub const IMAGE_FILE_DLL = 0x20_00;
pub const IMAGE_FILE_UP_SYSTEM_ONLY = 0x40_00;
pub const IMAGE_FILE_BYTES_REVERSED_HI = 0x80_00;

pub const _IMAGE_FILE_HEADER = extern struct {
    Machine: xboxkrnl.xboxdef.WORD,
    NumberOfSections: xboxkrnl.xboxdef.WORD,
    TimeDateStamp: xboxkrnl.xboxdef.DWORD,
    PointerToSymbolTable: xboxkrnl.xboxdef.DWORD,
    NumberOfSymbols: xboxkrnl.xboxdef.DWORD,
    SizeOfOptionalHeader: xboxkrnl.xboxdef.WORD,
    Characteristics: xboxkrnl.xboxdef.WORD,
};
pub const IMAGE_FILE_HEADER = _IMAGE_FILE_HEADER;
pub const PIMAGE_FILE_HEADER = *_IMAGE_FILE_HEADER;

pub const _IMAGE_NT_HEADERS32 = extern struct {
    Signature: xboxkrnl.xboxdef.DWORD,
    FileHeader: IMAGE_FILE_HEADER,
    OptionalHeader: IMAGE_OPTIONAL_HEADER32,
};
pub const IMAGE_NT_HEADERS32 = _IMAGE_NT_HEADERS32;
pub const PIMAGE_NT_HEADERS32 = *_IMAGE_NT_HEADERS32;

pub const IMAGE_SIZEOF_SHORT_NAME = 8;

pub const _IMAGE_SECTION_HEADER = extern struct {
    Name: [IMAGE_SIZEOF_SHORT_NAME]xboxkrnl.xboxdef.BYTE,
    Misc: extern union {
        PhysicalAddress: xboxkrnl.xboxdef.DWORD,
        VirtualSize: xboxkrnl.xboxdef.DWORD,
    },
    VirtualAddress: xboxkrnl.xboxdef.DWORD,
    SizeOfRawData: xboxkrnl.xboxdef.DWORD,
    PointerToRawData: xboxkrnl.xboxdef.DWORD,
    PointerToRelocations: xboxkrnl.xboxdef.DWORD,
    PointerToLinenumbers: xboxkrnl.xboxdef.DWORD,
    NumberOfRelocations: xboxkrnl.xboxdef.WORD,
    NumberOfLinenumbers: xboxkrnl.xboxdef.WORD,
    Characteristics: xboxkrnl.xboxdef.DWORD,
};
pub const IMAGE_SECTION_HEADER = _IMAGE_SECTION_HEADER;
pub const PIMAGE_SECTION_HEADER = *_IMAGE_SECTION_HEADER;

pub const _IMAGE_IMPORT_DESCRIPTOR = extern struct {
    DUMMYUNIONNAME: extern union {
        Characteristics: xboxkrnl.xboxdef.DWORD,
        OriginalFirstThunk: xboxkrnl.xboxdef.DWORD,
    },
    TimeDateStamp: xboxkrnl.xboxdef.DWORD,
    ForwarderChain: xboxkrnl.xboxdef.DWORD,
    Name: xboxkrnl.xboxdef.DWORD,
    FirstThunk: xboxkrnl.xboxdef.DWORD,
};
pub const IMAGE_IMPORT_DESCRIPTOR = _IMAGE_IMPORT_DESCRIPTOR;
pub const PIMAGE_IMPORT_DESCRIPTOR = *_IMAGE_IMPORT_DESCRIPTOR;

pub const _IMAGE_EXPORT_DIRECTORY = extern struct {
    Characteristics: xboxkrnl.xboxdef.DWORD,
    TimeDateStamp: xboxkrnl.xboxdef.DWORD,
    MajorVersion: xboxkrnl.xboxdef.WORD,
    MinorVersion: xboxkrnl.xboxdef.WORD,
    Name: xboxkrnl.xboxdef.DWORD,
    Base: xboxkrnl.xboxdef.DWORD,
    NumberOfFunctions: xboxkrnl.xboxdef.DWORD,
    NumberOfNames: xboxkrnl.xboxdef.DWORD,
    AddressOfFunctions: xboxkrnl.xboxdef.DWORD,
    AddressOfNames: xboxkrnl.xboxdef.DWORD,
    AddressOfNameOrdinals: xboxkrnl.xboxdef.DWORD,
};
pub const IMAGE_EXPORT_DIRECTORY = _IMAGE_EXPORT_DIRECTORY;
pub const PIMAGE_EXPORT_DIRECTORY = *_IMAGE_EXPORT_DIRECTORY;

pub const _IMAGE_TLS_DIRECTORY32 = extern struct {
    StartAddressOfRawData: xboxkrnl.xboxdef.DWORD,
    EndAddressOfRawData: xboxkrnl.xboxdef.DWORD,
    AddressOfIndex: xboxkrnl.xboxdef.DWORD,
    AddressOfCallBacks: xboxkrnl.xboxdef.DWORD,
    SizeOfZeroFill: xboxkrnl.xboxdef.DWORD,
    Anonymus: extern union {
        Characteristics: xboxkrnl.xboxdef.DWORD,
        Anonymus: packed struct {
            Reserved0: u20,
            Alignment: u4,
            Reserved1: u8,
        },
    },
};
pub const IMAGE_TLS_DIRECTORY_32 = _IMAGE_TLS_DIRECTORY32;
pub const PIMAGE_TLS_DIRECTORY_32 = *_IMAGE_TLS_DIRECTORY32;

// The XBE_ prefixed functionality is an nxdk-specific extension, and not usually found in winnt.h

pub const _XBE_CERTIFICATE_HEADER = extern struct {
    SizeOfHeader: xboxkrnl.xboxdef.DWORD,
    TimeDateStamp: xboxkrnl.xboxdef.DWORD,
    TitleID: xboxkrnl.xboxdef.DWORD,
    TitleName: [40]xboxkrnl.xboxdef.WCHAR,
    AlternateTitleIDs: [16]xboxkrnl.xboxdef.DWORD,
    AllowedMedia: xboxkrnl.xboxdef.DWORD,
    GameRegion: xboxkrnl.xboxdef.DWORD,
    GameRatings: xboxkrnl.xboxdef.DWORD,
    DiscNumber: xboxkrnl.xboxdef.DWORD,
    Version: xboxkrnl.xboxdef.DWORD,
    LANKey: [16]xboxkrnl.xboxdef.BYTE,
    SignatureKey: [16]xboxkrnl.xboxdef.BYTE,
    AlternateSignatureKeys: [16 * 16]xboxkrnl.xboxdef.BYTE,
};
pub const XBE_CERTIFICATE_HEADER = _XBE_CERTIFICATE_HEADER;
pub const PXBE_CERTIFICATE_HEADER = *_XBE_CERTIFICATE_HEADER;

pub const _XBE_LIBRARY_HEADER = extern struct {
    LibraryName: [8]xboxkrnl.xboxdef.CHAR,
    MajorVersion: xboxkrnl.xboxdef.WORD,
    MinorVersion: xboxkrnl.xboxdef.WORD,
    BuildVersion: xboxkrnl.xboxdef.WORD,
    LibraryFlags: xboxkrnl.xboxdef.WORD,
};
pub const XBE_LIBRARY_HEADER = _XBE_LIBRARY_HEADER;
pub const PXBE_LIBRARY_HEADER = *_XBE_LIBRARY_HEADER;

pub const _XBE_FILE_HEADER = extern struct {
    Magic: xboxkrnl.xboxdef.DWORD,
    Signature: [256]xboxkrnl.xboxdef.UCHAR,
    ImageBase: xboxkrnl.xboxdef.DWORD,
    SizeOfHeaders: xboxkrnl.xboxdef.DWORD,
    SizeOfImage: xboxkrnl.xboxdef.DWORD,
    SizeOfImageHeader: xboxkrnl.xboxdef.DWORD,
    TimeDateStamp: xboxkrnl.xboxdef.DWORD,
    CertificateHeader: PXBE_CERTIFICATE_HEADER,
    NumberOfSections: xboxkrnl.xboxdef.DWORD,
    PointerToSectionTable: xboxkrnl.xboxdef.PXBE_SECTION_HEADER,
    InitFlags: xboxkrnl.xboxdef.DWORD,
    AddressOfEntryPoint: xboxkrnl.xboxdef.DWORD,
    PointerToTlsDirectory: PIMAGE_TLS_DIRECTORY_32,
    SizeOfStack: xboxkrnl.xboxdef.DWORD,
    SizeOfHeapReserve: xboxkrnl.xboxdef.DWORD,
    SizeOfHeapCommit: xboxkrnl.xboxdef.DWORD,
    PeImageBase: xboxkrnl.xboxdef.DWORD,
    PeSizeOfImage: xboxkrnl.xboxdef.DWORD,
    PeImageCheckSum: xboxkrnl.xboxdef.DWORD,
    PeTimeDateStamp: xboxkrnl.xboxdef.DWORD,
    PeDebugPath: xboxkrnl.xboxdef.DWORD,
    PeDebugFilename: xboxkrnl.xboxdef.DWORD,
    PeDebugFilenameUnicode: xboxkrnl.xboxdef.DWORD,
    PointerToKernelThunkTable: xboxkrnl.xboxdef.DWORD,
    PointerToDebugImportTable: xboxkrnl.xboxdef.DWORD,
    NumberOfLibraries: xboxkrnl.xboxdef.DWORD,
    PointerToLibraries: PXBE_LIBRARY_HEADER,
    PointerToKernelLibrary: PXBE_LIBRARY_HEADER,
    PointerToXapiLibrary: PXBE_LIBRARY_HEADER,
    PointerToLogoBitmap: xboxkrnl.xboxdef.DWORD,
    SizeOfLogoBitmap: xboxkrnl.xboxdef.DWORD,
};
pub const XBE_FILE_HEADER = _XBE_FILE_HEADER;
pub const PXBE_FILE_HEADER = *_XBE_FILE_HEADER;

pub const XBE_DEFAULT_BASE = 0x01_00_00;
pub const CURRENT_XBE_HEADER: PXBE_FILE_HEADER = @ptrFromInt(XBE_DEFAULT_BASE);
