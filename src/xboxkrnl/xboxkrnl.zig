const std = @import("std");
const xboxdef = @import("xboxdef.zig");
const ntstatus = @import("ntstatus.zig");

// pub const IN = "";
// pub const OUT = "";
// pub const UNALIGNED = "";
// pub const OPTIONAL = "";
// pub const XBAPI = "__declspec(dllimport)";
pub const NTAPI: std.builtin.CallingConvention = .winapi;
pub const CDECL: std.builtin.CallingConvention = .c;
pub const FASTCALL: std.builtin.CallingConvention = .{ .x86_fastcall = .{} };
pub const DECLSPEC_NORETURN = noreturn;
// pub const RESTRICTED_POINTER = "__restrict__";

pub const TRUE = 1;
pub const FALSE = 0;

pub fn NT_SUCCESS(Status: xboxdef.NTSTATUS) bool {
    return Status >= 0;
}
pub fn NT_INFORMATION(Status: xboxdef.NTSTATUS) bool {
    return @as(xboxdef.ULONG, @intCast(Status)) >> 30 == 1;
}
pub fn NT_WARNING(Status: xboxdef.NTSTATUS) bool {
    return @as(xboxdef.ULONG, @intCast(Status)) >> 30 == 2;
}
pub fn NT_ERROR(Status: xboxdef.NTSTATUS) bool {
    return @as(xboxdef.ULONG, @intCast(Status)) >> 30 == 3;
}

// Used in AvSendTVEncoderOption
pub const AV_PACK_NONE = 0x00_00_00_00;
pub const AV_PACK_STANDARD = 0x00_00_00_01;
pub const AV_PACK_RFU = 0x00_00_00_02;
pub const AV_PACK_SCART = 0x00_00_00_03;
pub const AV_PACK_HDTV = 0x00_00_00_04;
pub const AV_PACK_VGA = 0x00_00_00_05;
pub const AV_PACK_SVIDEO = 0x00_00_00_06;

pub const PHYSICAL_ADDRESS = xboxdef.ULONG;
pub const PPHYSICAL_ADDRESS = *xboxdef.ULONG;

pub const KIRQL = xboxdef.UCHAR;
pub const PKIRQL = *xboxdef.UCHAR;

pub const PASSIVE_LEVEL = 0;
pub const APC_LEVEL = 1;
pub const DISPATCH_LEVEL = 2;

pub const PFN_COUNT = xboxdef.ULONG;
pub const PFN_NUMBER = xboxdef.ULONG;
pub const PPFN_NUMBER = *xboxdef.ULONG;
pub const KPRIORITY = xboxdef.LONG;
pub const DEVICE_TYPE = xboxdef.ULONG;
pub const LOGICAL = xboxdef.ULONG;

pub const PCSZ = [*c]const u8;
pub const PCSTR = [*c]const u8;
pub const LPCSTR = [*c]const u8;
pub const PSZ = [*c]u8;
pub const PSTR = [*c]u8;
pub const PCWSTR = [*c]xboxdef.WCHAR;
pub const LPCWSTR = [*c]xboxdef.WCHAR;

pub const ACCESS_MASK = xboxdef.ULONG;
pub const PACCESS_MASK = *xboxdef.ULONG;

pub const KPROCESSOR_MODE = xboxdef.CCHAR;
pub const _MODE = enum(c_int) {
    KernelMode,
    UserMode,
    MaximumMode,
};
pub const MODE = _MODE;

pub fn RTL_CONSTANT_STRING(s: PCSZ) xboxdef.STRING {
    return .{
        .Length = @sizeOf(s) - @sizeOf((s)[0]),
        .MaximumLength = @sizeOf(s),
        .Buffer = (s),
    };
}

/// This struct defines a counted string used for ANSI-strings
pub const OBJECT_STRING = xboxdef.STRING;
pub const POBJECT_STRING = *xboxdef.STRING;

/// This struct defines a counted string used for UNICODE-strings
pub const _UNICODE_STRING = extern struct {
    Length: xboxdef.USHORT, // Length in bytes of the string stored in the buffer
    MaximumLength: xboxdef.USHORT, // Length in bytes of the buffer
    Buffer: xboxdef.PWSTR, // Pointer to the buffer used for the character-string
};
pub const UNICODE_STRING = _UNICODE_STRING;
pub const PUNICODE_STRING = *_UNICODE_STRING;
pub const PCUNICODE_STRING = *const _UNICODE_STRING;

pub inline fn InitializeListHead(ListHead: xboxdef.PLIST_ENTRY) xboxdef.VOID {
    ListHead.Flink = ListHead;
    ListHead.Blink = ListHead;
}

pub inline fn IsListEmpty(ListHead: *const xboxdef.LIST_ENTRY) xboxdef.BOOLEAN {
    return @intFromBool(ListHead.Flink == ListHead);
}

pub inline fn RemoveHeadList(ListHead: xboxdef.PLIST_ENTRY) xboxdef.PLIST_ENTRY {
    const head: xboxdef.PLIST_ENTRY = ListHead.Flink;
    RemoveEntryList(head);
    return head;
}

pub inline fn RemoveTailList(ListHead: xboxdef.PLIST_ENTRY) xboxdef.PLIST_ENTRY {
    const tail: xboxdef.PLIST_ENTRY = ListHead.Blink;
    RemoveEntryList(tail);
    return tail;
}

pub inline fn RemoveEntryList(Entry: xboxdef.PLIST_ENTRY) xboxdef.BOOLEAN {
    var _EX_Flink: xboxdef.PLIST_ENTRY = Entry.Flink;
    var _EX_Blink: xboxdef.PLIST_ENTRY = Entry.Blink;
    _EX_Blink.Flink = _EX_Flink;
    _EX_Flink.Blink = _EX_Blink;
}

pub inline fn InsertTailList(ListHead: xboxdef.PLIST_ENTRY, Entry: xboxdef.PLIST_ENTRY) xboxdef.VOID {
    var _EX_ListHead: xboxdef.PLIST_ENTRY = ListHead;
    var _EX_Blink: xboxdef.PLIST_ENTRY = _EX_ListHead.Blink;
    Entry.Flink = _EX_ListHead;
    Entry.Blink = _EX_Blink;
    _EX_Blink.Flink = Entry;
    _EX_ListHead.Blink = Entry;
}

pub inline fn InsertHeadList(ListHead: xboxdef.PLIST_ENTRY, Entry: xboxdef.PLIST_ENTRY) xboxdef.VOID {
    var _EX_ListHead: xboxdef.PLIST_ENTRY = ListHead;
    var _EX_Flink: xboxdef.PLIST_ENTRY = _EX_ListHead.Flink;
    Entry.Flink = _EX_Flink;
    Entry.Blink = _EX_ListHead;
    _EX_Flink.Blink = Entry;
    _EX_ListHead.Flink = Entry;
}

pub inline fn PopEntryList(ListHead: PSINGLE_LIST_ENTRY) PSINGLE_LIST_ENTRY {
    const next: ?PSINGLE_LIST_ENTRY = ListHead.Next;
    const FirstEntry: ?PSINGLE_LIST_ENTRY = ListHead.Next;
    if (FirstEntry) |FE| {
        ListHead.Next = FE.Next;
    }
    return next;
}

pub inline fn PushEntryList(ListHead: PSINGLE_LIST_ENTRY, Entry: PSINGLE_LIST_ENTRY) xboxdef.VOID {
    Entry.Next = ListHead.Next;
    ListHead.Next = Entry;
}

pub inline fn CONTAINING_RECORD(Address: *anyopaque, Type: type, Field: []const u8) *Type {
    return @fieldParentPtr(Field, Address);
}

pub const PAGE_SIZE = 4096;
pub inline fn ROUND_TO_PAGES(Size: xboxdef.ULONG_PTR) xboxdef.ULONG_PTR {
    return (Size + PAGE_SIZE - 1) & ~(PAGE_SIZE - 1);
}

/// Time information
pub const _TIME_FIELDS = extern struct {
    Year: xboxdef.SHORT, // Specifies a value from 1601 on
    Month: xboxdef.SHORT, // Specifies a value from 1 to 12
    Day: xboxdef.SHORT, // Specifies a value from 1 to 31
    Hour: xboxdef.SHORT, // Specifies a value from 0 to 23
    Minute: xboxdef.SHORT, // Specifies a value from 0 to 59
    Second: xboxdef.SHORT, // Specifies a value from 0 to 59
    Milliseconds: xboxdef.SHORT, // Specifies a value from 0 to 999
    Weekday: xboxdef.SHORT, // Specifies a value from 0 to 6 (Sunday to Saturday)
};
pub const TIME_FIELDS = _TIME_FIELDS;
pub const PTIME_FIELDS = *_TIME_FIELDS;

pub const _WAIT_TYPE = enum(c_int) {
    WaitAll = 0,
    WaitAny = 1,
};
pub const WAIT_TYPE = _WAIT_TYPE;

pub const _IO_STATUS_BLOCK = extern struct {
    Anonymous: extern union {
        Status: xboxdef.NTSTATUS,
        Pointer: xboxdef.PVOID,
    },
    Information: xboxdef.ULONG_PTR,
};
pub const IO_STATUS_BLOCK = _IO_STATUS_BLOCK;
pub const PIO_STATUS_BLOCK = *_IO_STATUS_BLOCK;

pub const _FSINFOCLASS = enum(c_int) {
    FileFsVolumeInformation = 1,
    FileFsLabelInformation,
    FileFsSizeInformation,
    FileFsDeviceInformation,
    FileFsAttributeInformation,
    FileFsControlInformation,
    FileFsFullSizeInformation,
    FileFsObjectIdInformation,
    FileFsMaximumInformation,
};
pub const FS_INFORMATION_CLASS = _FSINFOCLASS;
pub const PFS_INFORMATION_CLASS = *_FSINFOCLASS;

pub const _FILE_FS_LABEL_INFORMATION = extern struct {
    VolumeLabelLength: xboxdef.ULONG,
    VolumeLabel: [1]xboxdef.OCHAR,
};
pub const FILE_FS_LABEL_INFORMATION = _FILE_FS_LABEL_INFORMATION;
pub const PFILE_FS_LABEL_INFORMATION = *_FILE_FS_LABEL_INFORMATION;

pub const _FILE_FS_VOLUME_INFORMATION = extern struct {
    VolumeCreationTime: xboxdef.LARGE_INTEGER,
    VolumeSerialNumber: xboxdef.ULONG,
    VolumeLabelLength: xboxdef.ULONG,
    SupportsObjects: xboxdef.BOOLEAN,
    VolumeLabel: [1]xboxdef.OCHAR,
};
pub const FILE_FS_VOLUME_INFORMATION = _FILE_FS_VOLUME_INFORMATION;
pub const PFILE_FS_VOLUME_INFORMATION = *_FILE_FS_VOLUME_INFORMATION;

pub const _FILE_FS_SIZE_INFORMATION = extern struct {
    TotalAllocationUnits: xboxdef.LARGE_INTEGER,
    AvailableAllocationUnits: xboxdef.LARGE_INTEGER,
    SectorsPerAllocationUnit: xboxdef.ULONG,
    BytesPerSector: xboxdef.ULONG,
};
pub const FILE_FS_SIZE_INFORMATION = _FILE_FS_SIZE_INFORMATION;
pub const PFILE_FS_SIZE_INFORMATION = *_FILE_FS_SIZE_INFORMATION;

pub const _FILE_FS_FULL_SIZE_INFORMATION = extern struct {
    TotalAllocationUnits: xboxdef.LARGE_INTEGER,
    CallerAvailableAllocationUnits: xboxdef.LARGE_INTEGER,
    ActualAvailableAllocationUnits: xboxdef.LARGE_INTEGER,
    SectorsPerAllocationUnit: xboxdef.ULONG,
    BytesPerSector: xboxdef.ULONG,
};
pub const FILE_FS_FULL_SIZE_INFORMATION = _FILE_FS_FULL_SIZE_INFORMATION;
pub const PFILE_FS_FULL_SIZE_INFORMATION = *_FILE_FS_FULL_SIZE_INFORMATION;

pub const _FILE_FS_OBJECTID_INFORMATION = extern struct {
    ObjectId: [16]xboxdef.UCHAR,
    ExtendedInfo: [48]xboxdef.UCHAR,
};
pub const FILE_FS_OBJECTID_INFORMATION = _FILE_FS_OBJECTID_INFORMATION;
pub const PFILE_FS_OBJECTID_INFORMATION = *_FILE_FS_OBJECTID_INFORMATION;

pub const _FILE_FS_DEVICE_INFORMATION = extern struct {
    DeviceType: DEVICE_TYPE,
    Characteristics: xboxdef.ULONG,
};
pub const FILE_FS_DEVICE_INFORMATION = _FILE_FS_DEVICE_INFORMATION;
pub const PFILE_FS_DEVICE_INFORMATION = *_FILE_FS_DEVICE_INFORMATION;

pub const _FILE_FS_ATTRIBUTE_INFORMATION = extern struct {
    FileSystemAttributes: xboxdef.ULONG,
    MaximumComponentNameLength: xboxdef.LONG,
    FileSystemNameLength: xboxdef.ULONG,
    FileSystemName: [1]xboxdef.OCHAR,
};
pub const FILE_FS_ATTRIBUTE_INFORMATION = _FILE_FS_ATTRIBUTE_INFORMATION;
pub const PFILE_FS_ATTRIBUTE_INFORMATION = *_FILE_FS_ATTRIBUTE_INFORMATION;

pub const _MEMORY_BASIC_INFORMATION = extern struct {
    BaseAddress: xboxdef.PVOID,
    AllocationBase: xboxdef.PVOID,
    AllocationProtect: xboxdef.DWORD,
    RegionSize: xboxdef.DWORD,
    State: xboxdef.DWORD,
    Protect: xboxdef.DWORD,
    Type: xboxdef.DWORD,
};
pub const MEMORY_BASIC_INFORMATION = _MEMORY_BASIC_INFORMATION;
pub const PMEMORY_BASIC_INFORMATION = *_MEMORY_BASIC_INFORMATION;

pub const _SID_IDENTIFIER_AUTHORITY = extern struct {
    Value: [6]xboxdef.BYTE,
};
pub const SID_IDENTIFIER_AUTHORITY = _SID_IDENTIFIER_AUTHORITY;
pub const PSID_IDENTIFIER_AUTHORITY = *_SID_IDENTIFIER_AUTHORITY;

pub const _SID = extern struct {
    Revision: xboxdef.BYTE,
    SubAuthorityCount: xboxdef.BYTE,
    IdentifierAuthority: SID_IDENTIFIER_AUTHORITY,
    SubAuthority: [1]xboxdef.DWORD, // Actually has size 'SubAuthorityCount'
};
pub const SID = _SID;
pub const PSID = *_SID;
pub const PISID = *_SID;

pub const _FILE_INFORMATION_CLASS = enum(c_int) {
    FileDirectoryInformation = 1,
    FileFullDirectoryInformation,
    FileBothDirectoryInformation,
    FileBasicInformation,
    FileStandardInformation,
    FileInternalInformation,
    FileEaInformation,
    FileAccessInformation,
    FileNameInformation,
    FileRenameInformation,
    FileLinkInformation,
    FileNamesInformation,
    FileDispositionInformation,
    FilePositionInformation,
    FileFullEaInformation,
    FileModeInformation,
    FileAlignmentInformation,
    FileAllInformation,
    FileAllocationInformation,
    FileEndOfFileInformation,
    FileAlternateNameInformation,
    FileStreamInformation,
    FilePipeInformation,
    FilePipeLocalInformation,
    FilePipeRemoteInformation,
    FileMailslotQueryInformation,
    FileMailslotSetInformation,
    FileCompressionInformation,
    FileObjectIdInformation,
    FileCompletionInformation,
    FileMoveClusterInformation,
    FileQuotaInformation,
    FileReparsePointInformation,
    FileNetworkOpenInformation,
    FileAttributeTagInformation,
    FileTrackingInformation,
    FileMaximumInformation,
};
pub const FILE_INFORMATION_CLASS = _FILE_INFORMATION_CLASS;
pub const PFILE_INFORMATION_CLASS = *_FILE_INFORMATION_CLASS;

pub const _FILE_DIRECTORY_INFORMATION = extern struct {
    NextEntryOffset: xboxdef.ULONG,
    FileIndex: xboxdef.ULONG,
    CreationTime: xboxdef.LARGE_INTEGER,
    LastAccessTime: xboxdef.LARGE_INTEGER,
    LastWriteTime: xboxdef.LARGE_INTEGER,
    ChangeTime: xboxdef.LARGE_INTEGER,
    EndOfFile: xboxdef.LARGE_INTEGER,
    AllocationSize: xboxdef.LARGE_INTEGER,
    FileAttributes: xboxdef.ULONG,
    FileNameLength: xboxdef.ULONG,
    FileName: [1]xboxdef.OCHAR,
};
pub const FILE_DIRECTORY_INFORMATION = _FILE_DIRECTORY_INFORMATION;
pub const PFILE_DIRECTORY_INFORMATION = *_FILE_DIRECTORY_INFORMATION;

pub const _FILE_FULL_DIR_INFORMATION = extern struct {
    NextEntryOffset: xboxdef.ULONG,
    FileIndex: xboxdef.ULONG,
    CreationTime: xboxdef.LARGE_INTEGER,
    LastAccessTime: xboxdef.LARGE_INTEGER,
    LastWriteTime: xboxdef.LARGE_INTEGER,
    ChangeTime: xboxdef.LARGE_INTEGER,
    EndOfFile: xboxdef.LARGE_INTEGER,
    AllocationSize: xboxdef.LARGE_INTEGER,
    FileAttributes: xboxdef.ULONG,
    FileNameLength: xboxdef.ULONG,
    EaSize: xboxdef.ULONG,
    FileName: [1]xboxdef.WCHAR,
};
pub const FILE_FULL_DIR_INFORMATION = _FILE_FULL_DIR_INFORMATION;
pub const PFILE_FULL_DIR_INFORMATION = *_FILE_FULL_DIR_INFORMATION;

pub const _FILE_BOTH_DIR_INFORMATION = extern struct {
    NextEntryOffset: xboxdef.ULONG,
    FileIndex: xboxdef.ULONG,
    CreationTime: xboxdef.LARGE_INTEGER,
    LastAccessTime: xboxdef.LARGE_INTEGER,
    LastWriteTime: xboxdef.LARGE_INTEGER,
    ChangeTime: xboxdef.LARGE_INTEGER,
    EndOfFile: xboxdef.LARGE_INTEGER,
    AllocationSize: xboxdef.LARGE_INTEGER,
    FileAttributes: xboxdef.ULONG,
    FileNameLength: xboxdef.ULONG,
    EaSize: xboxdef.ULONG,
    ShortNameLength: xboxdef.CCHAR,
    ShortName: [12]xboxdef.WCHAR,
    FileName: [1]xboxdef.WCHAR,
};
pub const FILE_BOTH_DIR_INFORMATION = _FILE_BOTH_DIR_INFORMATION;
pub const PFILE_BOTH_DIR_INFORMATION = *_FILE_BOTH_DIR_INFORMATION;

pub const _FILE_BASIC_INFORMATION = extern struct {
    CreationTime: xboxdef.LARGE_INTEGER,
    LastAccessTime: xboxdef.LARGE_INTEGER,
    LastWriteTime: xboxdef.LARGE_INTEGER,
    ChangeTime: xboxdef.LARGE_INTEGER,
    FileAttributes: xboxdef.ULONG,
};
pub const FILE_BASIC_INFORMATION = _FILE_BASIC_INFORMATION;
pub const PFILE_BASIC_INFORMATION = *_FILE_BASIC_INFORMATION;

pub const _FILE_STANDARD_INFORMATION = extern struct {
    AllocationSize: xboxdef.LARGE_INTEGER,
    EndOfFile: xboxdef.LARGE_INTEGER,
    NumberOfLinks: xboxdef.ULONG,
    DeletePending: xboxdef.BOOLEAN,
    Directory: xboxdef.BOOLEAN,
};
pub const FILE_STANDARD_INFORMATION = _FILE_STANDARD_INFORMATION;
pub const PFILE_STANDARD_INFORMATION = *_FILE_STANDARD_INFORMATION;

pub const _FILE_INTERNAL_INFORMATION = extern struct {
    IndexNumber: xboxdef.LARGE_INTEGER,
};
pub const FILE_INTERNAL_INFORMATION = _FILE_INTERNAL_INFORMATION;
pub const PFILE_INTERNAL_INFORMATION = *_FILE_INTERNAL_INFORMATION;

pub const _FILE_EA_INFORMATION = extern struct {
    EaSize: xboxdef.ULONG,
};
pub const FILE_EA_INFORMATION = _FILE_EA_INFORMATION;
pub const PFILE_EA_INFORMATION = *_FILE_EA_INFORMATION;

pub const _FILE_ACCESS_INFORMATION = extern struct {
    AccessFlags: ACCESS_MASK,
};
pub const FILE_ACCESS_INFORMATION = _FILE_ACCESS_INFORMATION;
pub const PFILE_ACCESS_INFORMATION = *_FILE_ACCESS_INFORMATION;

pub const _FILE_NAME_INFORMATION = extern struct {
    FileNameLength: xboxdef.ULONG,
    FileName: [1]xboxdef.OCHAR,
};
pub const FILE_NAME_INFORMATION = _FILE_NAME_INFORMATION;
pub const PFILE_NAME_INFORMATION = *_FILE_NAME_INFORMATION;

pub const _FILE_RENAME_INFORMATION = extern struct {
    ReplaceIfExists: xboxdef.BOOLEAN,
    RootDirectory: xboxdef.HANDLE,
    FileName: OBJECT_STRING,
};
pub const FILE_RENAME_INFORMATION = _FILE_RENAME_INFORMATION;
pub const PFILE_RENAME_INFORMATION = *_FILE_RENAME_INFORMATION;

pub const _FILE_LINK_INFORMATION = extern struct {
    ReplaceIfExists: xboxdef.BOOLEAN,
    RootDirectory: xboxdef.HANDLE,
    FileNameLength: xboxdef.ULONG,
    FileName: [1]xboxdef.OCHAR,
};
pub const FILE_LINK_INFORMATION = _FILE_LINK_INFORMATION;
pub const PFILE_LINK_INFORMATION = *_FILE_LINK_INFORMATION;

pub const _FILE_NAMES_INFORMATION = extern struct {
    NextEntryOffset: xboxdef.ULONG,
    FileIndex: xboxdef.ULONG,
    FileNameLength: xboxdef.ULONG,
    FileName: [1]xboxdef.OCHAR,
};
pub const FILE_NAMES_INFORMATION = _FILE_NAMES_INFORMATION;
pub const PFILE_NAMES_INFORMATION = *_FILE_NAMES_INFORMATION;

pub const _FILE_DISPOSITION_INFORMATION = extern struct {
    DeleteFile: xboxdef.BOOLEAN,
};
pub const FILE_DISPOSITION_INFORMATION = _FILE_DISPOSITION_INFORMATION;
pub const PFILE_DISPOSITION_INFORMATION = *_FILE_DISPOSITION_INFORMATION;

pub const _FILE_POSITION_INFORMATION = extern struct {
    CurrentByteOffset: xboxdef.LARGE_INTEGER,
};
pub const FILE_POSITION_INFORMATION = _FILE_POSITION_INFORMATION;
pub const PFILE_POSITION_INFORMATION = *_FILE_POSITION_INFORMATION;

pub const _FILE_FULL_EA_INFORMATION = extern struct {
    NextEntryOffset: xboxdef.ULONG,
    Flags: xboxdef.UCHAR,
    EaNameLength: xboxdef.UCHAR,
    EaValueLength: xboxdef.USHORT,
    EaName: [1]xboxdef.CHAR,
};
pub const FILE_FULL_EA_INFORMATION = _FILE_FULL_EA_INFORMATION;
pub const PFILE_FULL_EA_INFORMATION = *_FILE_FULL_EA_INFORMATION;

pub const _FILE_MODE_INFORMATION = extern struct {
    Mode: xboxdef.ULONG,
};
pub const FILE_MODE_INFORMATION = _FILE_MODE_INFORMATION;
pub const PFILE_MODE_INFORMATION = *_FILE_MODE_INFORMATION;

pub const _FILE_ALIGNMENT_INFORMATION = extern struct {
    AlignmentRequirement: xboxdef.ULONG,
};
pub const FILE_ALIGNMENT_INFORMATION = _FILE_ALIGNMENT_INFORMATION;
pub const PFILE_ALIGNMENT_INFORMATION = *_FILE_ALIGNMENT_INFORMATION;

pub const _FILE_ALL_INFORMATION = extern struct {
    BasicInformation: FILE_BASIC_INFORMATION,
    StandardInformation: FILE_STANDARD_INFORMATION,
    InternalInformation: FILE_INTERNAL_INFORMATION,
    EaInformation: FILE_EA_INFORMATION,
    AccessInformation: FILE_ACCESS_INFORMATION,
    PositionInformation: FILE_POSITION_INFORMATION,
    ModeInformation: FILE_MODE_INFORMATION,
    AlignmentInformation: FILE_ALIGNMENT_INFORMATION,
    NameInformation: FILE_NAME_INFORMATION,
};
pub const FILE_ALL_INFORMATION = _FILE_ALL_INFORMATION;
pub const PFILE_ALL_INFORMATION = *_FILE_ALL_INFORMATION;

pub const _FILE_ALLOCATION_INFORMATION = extern struct {
    AllocationSize: xboxdef.LARGE_INTEGER,
};
pub const FILE_ALLOCATION_INFORMATION = _FILE_ALLOCATION_INFORMATION;
pub const PFILE_ALLOCATION_INFORMATION = *_FILE_ALLOCATION_INFORMATION;

pub const _FILE_END_OF_FILE_INFORMATION = extern struct {
    EndOfFile: xboxdef.LARGE_INTEGER,
};
pub const FILE_END_OF_FILE_INFORMATION = _FILE_END_OF_FILE_INFORMATION;
pub const PFILE_END_OF_FILE_INFORMATION = *_FILE_END_OF_FILE_INFORMATION;

pub const _FILE_STREAM_INFORMATION = extern struct {
    NextEntryOffset: xboxdef.ULONG,
    StreamNameLength: xboxdef.ULONG,
    StreamSize: xboxdef.LARGE_INTEGER,
    StreamAllocationSize: xboxdef.LARGE_INTEGER,
    StreamName: [1]xboxdef.OCHAR,
};
pub const FILE_STREAM_INFORMATION = _FILE_STREAM_INFORMATION;
pub const PFILE_STREAM_INFORMATION = *_FILE_STREAM_INFORMATION;

pub const _FILE_PIPE_INFORMATION = extern struct {
    ReadMode: xboxdef.ULONG,
    CompletionMode: xboxdef.ULONG,
};
pub const FILE_PIPE_INFORMATION = _FILE_PIPE_INFORMATION;
pub const PFILE_PIPE_INFORMATION = *_FILE_PIPE_INFORMATION;

pub const _FILE_PIPE_LOCAL_INFORMATION = extern struct {
    NamedPipeType: xboxdef.ULONG,
    NamedPipeConfiguration: xboxdef.ULONG,
    MaximumInstances: xboxdef.ULONG,
    CurrentInstances: xboxdef.ULONG,
    InboundQuota: xboxdef.ULONG,
    ReadDataAvailable: xboxdef.ULONG,
    OutboundQuota: xboxdef.ULONG,
    WriteQuotaAvailable: xboxdef.ULONG,
    NamedPipeState: xboxdef.ULONG,
    NamedPipeEnd: xboxdef.ULONG,
};
pub const FILE_PIPE_LOCAL_INFORMATION = _FILE_PIPE_LOCAL_INFORMATION;
pub const PFILE_PIPE_LOCAL_INFORMATION = *_FILE_PIPE_LOCAL_INFORMATION;

pub const _FILE_PIPE_REMOTE_INFORMATION = extern struct {
    CollectDataTime: xboxdef.LARGE_INTEGER,
    MaximumCollectionCount: xboxdef.ULONG,
};
pub const FILE_PIPE_REMOTE_INFORMATION = _FILE_PIPE_REMOTE_INFORMATION;
pub const PFILE_PIPE_REMOTE_INFORMATION = *_FILE_PIPE_REMOTE_INFORMATION;

pub const _FILE_MAILSLOT_QUERY_INFORMATION = extern struct {
    MaximumMessageSize: xboxdef.ULONG,
    MailslotQuota: xboxdef.ULONG,
    NextMessageSize: xboxdef.ULONG,
    MessagesAvailable: xboxdef.ULONG,
    ReadTimeout: xboxdef.LARGE_INTEGER,
};
pub const FILE_MAILSLOT_QUERY_INFORMATION = _FILE_MAILSLOT_QUERY_INFORMATION;
pub const PFILE_MAILSLOT_QUERY_INFORMATION = *_FILE_MAILSLOT_QUERY_INFORMATION;

pub const _FILE_MAILSLOT_SET_INFORMATION = extern struct {
    ReadTimeout: xboxdef.PLARGE_INTEGER,
};
pub const FILE_MAILSLOT_SET_INFORMATION = _FILE_MAILSLOT_SET_INFORMATION;
pub const PFILE_MAILSLOT_SET_INFORMATION = *_FILE_MAILSLOT_SET_INFORMATION;

pub const _FILE_COMPRESSION_INFORMATION = extern struct {
    CompressedFileSize: xboxdef.LARGE_INTEGER,
    CompressionFormat: xboxdef.USHORT,
    CompressionUnitShift: xboxdef.UCHAR,
    ChunkShift: xboxdef.UCHAR,
    ClusterShift: xboxdef.UCHAR,
    Reserved: [3]xboxdef.UCHAR,
};
pub const FILE_COMPRESSION_INFORMATION = _FILE_COMPRESSION_INFORMATION;
pub const PFILE_COMPRESSION_INFORMATION = *_FILE_COMPRESSION_INFORMATION;

pub const _FILE_OBJECTID_INFORMATION = extern struct {
    FileReference: xboxdef.LONGLONG,
    ObjectId: [16]xboxdef.UCHAR,
    Anonymous: extern union {
        Anonymous: extern struct {
            BirthVolumeId: [16]xboxdef.UCHAR,
            BirthObjectId: [16]xboxdef.UCHAR,
            DomainId: [16]xboxdef.UCHAR,
        },
        ExtendedInfo: [48]xboxdef.UCHAR,
    },
};
pub const FILE_OBJECTID_INFORMATION = _FILE_OBJECTID_INFORMATION;
pub const PFILE_OBJECTID_INFORMATION = *_FILE_OBJECTID_INFORMATION;

pub const _FILE_COMPLETION_INFORMATION = extern struct {
    Port: xboxdef.HANDLE,
    Key: xboxdef.PVOID,
};
pub const FILE_COMPLETION_INFORMATION = _FILE_COMPLETION_INFORMATION;
pub const PFILE_COMPLETION_INFORMATION = *_FILE_COMPLETION_INFORMATION;

pub const _FILE_MOVE_CLUSTER_INFORMATION = extern struct {
    ClusterCount: xboxdef.ULONG,
    RootDirectory: xboxdef.HANDLE,
    FileNameLength: xboxdef.ULONG,
    FileName: [1]xboxdef.OCHAR,
};
pub const FILE_MOVE_CLUSTER_INFORMATION = _FILE_MOVE_CLUSTER_INFORMATION;
pub const PFILE_MOVE_CLUSTER_INFORMATION = *_FILE_MOVE_CLUSTER_INFORMATION;

pub const _FILE_QUOTA_INFORMATION = extern struct {
    NextEntryOffset: xboxdef.ULONG,
    SidLength: xboxdef.ULONG,
    ChangeTime: xboxdef.LARGE_INTEGER,
    QuotaUsed: xboxdef.LARGE_INTEGER,
    QuotaThreshold: xboxdef.LARGE_INTEGER,
    QuotaLimit: xboxdef.LARGE_INTEGER,
    Sid: SID,
};
pub const FILE_QUOTA_INFORMATION = _FILE_QUOTA_INFORMATION;
pub const PFILE_QUOTA_INFORMATION = *_FILE_QUOTA_INFORMATION;

pub const _FILE_REPARSE_POINT_INFORMATION = extern struct {
    FileReference: xboxdef.LONGLONG,
    Tag: xboxdef.ULONG,
};
pub const FILE_REPARSE_POINT_INFORMATION = _FILE_REPARSE_POINT_INFORMATION;
pub const PFILE_REPARSE_POINT_INFORMATION = *_FILE_REPARSE_POINT_INFORMATION;

pub const _FILE_NETWORK_OPEN_INFORMATION = extern struct {
    CreationTime: xboxdef.LARGE_INTEGER,
    LastAccessTime: xboxdef.LARGE_INTEGER,
    LastWriteTime: xboxdef.LARGE_INTEGER,
    ChangeTime: xboxdef.LARGE_INTEGER,
    AllocationSize: xboxdef.LARGE_INTEGER,
    EndOfFile: xboxdef.LARGE_INTEGER,
    FileAttributes: xboxdef.ULONG,
};
pub const FILE_NETWORK_OPEN_INFORMATION = _FILE_NETWORK_OPEN_INFORMATION;
pub const PFILE_NETWORK_OPEN_INFORMATION = *_FILE_NETWORK_OPEN_INFORMATION;

pub const _FILE_ATTRIBUTE_TAG_INFORMATION = extern struct {
    FileAttributes: xboxdef.ULONG,
    ReparseTag: xboxdef.ULONG,
};
pub const FILE_ATTRIBUTE_TAG_INFORMATION = _FILE_ATTRIBUTE_TAG_INFORMATION;
pub const PFILE_ATTRIBUTE_TAG_INFORMATION = *_FILE_ATTRIBUTE_TAG_INFORMATION;

pub const _FILE_TRACKING_INFORMATION = extern struct {
    DestinationFile: xboxdef.HANDLE,
    ObjectInformationLength: xboxdef.ULONG,
    ObjectInformation: [1]xboxdef.CHAR,
};
pub const FILE_TRACKING_INFORMATION = _FILE_TRACKING_INFORMATION;
pub const PFILE_TRACKING_INFORMATION = *_FILE_TRACKING_INFORMATION;

/// Object Attributes Structure
pub const _OBJECT_ATTRIBUTES = extern struct {
    RootDirectory: xboxdef.HANDLE, // Optional handle to the root object directory for the path name specified by the ObjectName member. If RootDirectory is NULL, ObjectName must point to a fully qualified object name that includes the full path to the target object. If RootDirectory is non-NULL, ObjectName specifies an object name relative to the RootDirectory directory.
    ObjectName: xboxdef.PANSI_STRING, // Pointer to an ANSI string that contains the name of the object for which a handle is to be opened. This must either be a fully qualified object name, or a relative path name to the directory specified by the RootDirectory member.
    Attributes: xboxdef.ULONG, // Bitmask of flags that specify object handle attributes.
};
pub const OBJECT_ATTRIBUTES = _OBJECT_ATTRIBUTES;
pub const POBJECT_ATTRIBUTES = *_OBJECT_ATTRIBUTES;

pub const OBJ_INHERIT = 0x00000002;
pub const OBJ_PERMANENT = 0x00000010;
pub const OBJ_EXCLUSIVE = 0x00000020;
pub const OBJ_CASE_INSENSITIVE = 0x00000040;
pub const OBJ_OPENIF = 0x00000080;
pub const OBJ_OPENLINK = 0x00000100;
pub const OBJ_VALID_ATTRIBUTES = 0x000001F2;

pub const SECURITY_DESCRIPTOR_CONTROL = xboxdef.USHORT;
pub const PSECURITY_DESCRIPTOR_CONTROL = *xboxdef.USHORT;

pub const _ACL = extern struct {
    AclRevision: xboxdef.BYTE,
    Sbz1: xboxdef.BYTE,
    AclSize: xboxdef.WORD,
    AceCount: xboxdef.WORD,
    Sbz2: xboxdef.WORD,
};
pub const ACL = _ACL;
pub const PACL = *_ACL;

pub const _SECURITY_DESCRIPTOR = extern struct {
    Revision: xboxdef.BYTE,
    Sbz1: xboxdef.BYTE,
    Control: SECURITY_DESCRIPTOR_CONTROL,
    Owner: PSID,
    Group: PSID,
    Sacl: PACL,
    Dacl: PACL,
};
pub const SECURITY_DESCRIPTOR = _SECURITY_DESCRIPTOR;
pub const PSECURITY_DESCRIPTOR = *_SECURITY_DESCRIPTOR;
pub const PISECURITY_DESCRIPTOR = *_SECURITY_DESCRIPTOR;

pub inline fn InitializeObjectAttributes(
    p: POBJECT_ATTRIBUTES,
    n: PUNICODE_STRING,
    a: xboxdef.ULONG,
    r: xboxdef.HANDLE,
    s: PSECURITY_DESCRIPTOR,
) xboxdef.VOID {
    _ = s;
    p.RootDirectory = r;
    p.Attributes = a;
    p.ObjectName = n;
}

pub inline fn ObDosDevicesDirectory() xboxdef.HANDLE {
    return @ptrFromInt(@as(usize, @bitCast(@as(isize, -3))));
}
pub inline fn ObWin32NamedObjectsDirectory() xboxdef.HANDLE {
    return @ptrFromInt(@as(usize, @bitCast(@as(isize, -4))));
}

pub const _EVENT_TYPE = enum(c_int) {
    NotificationEvent = 0,
    SynchronizationEvent,
};
pub const EVENT_TYPE = _EVENT_TYPE;

/// Memory manager statistics
pub const _MM_STATISTICS = extern struct {
    Length: xboxdef.ULONG, // Length of MM_STATISTICS in bytes
    TotalPhysicalPages: xboxdef.ULONG,
    AvailablePages: xboxdef.ULONG,
    VirtualMemoryBytesCommitted: xboxdef.ULONG,
    VirtualMemoryBytesReserved: xboxdef.ULONG,
    CachePagesCommitted: xboxdef.ULONG,
    PoolPagesCommitted: xboxdef.ULONG,
    StackPagesCommitted: xboxdef.ULONG,
    ImagePagesCommitted: xboxdef.ULONG,
};
pub const MM_STATISTICS = _MM_STATISTICS;
pub const PMM_STATISTICS = *_MM_STATISTICS;

pub const _LAUNCH_DATA_HEADER = extern struct {
    dwLaunchDataType: xboxdef.DWORD,
    dwTitleId: xboxdef.DWORD,
    szLaunchPath: [520]xboxdef.CHAR,
    dwFlags: xboxdef.DWORD,
};
pub const LAUNCH_DATA_HEADER = _LAUNCH_DATA_HEADER;
pub const PLAUNCH_DATA_HEADER = *_LAUNCH_DATA_HEADER;

pub const _LAUNCH_DATA_PAGE = extern struct {
    Header: LAUNCH_DATA_HEADER,
    Pad: [492]xboxdef.UCHAR,
    LaunchData: [3072]xboxdef.UCHAR,
};
pub const LAUNCH_DATA_PAGE = _LAUNCH_DATA_PAGE;
pub const PLAUNCH_DATA_PAGE = *_LAUNCH_DATA_PAGE;

pub const LDT_TITLE = 0;
pub const LDT_LAUNCH_DASHBOARD = 1;
pub const LDT_FROM_DASHBOARD = 2;
pub const LDT_NONE = 0xFF_FF_FF_FF;

pub const LDT_LAUNCH_DASHBOARD_REASON_NONE = 0;
pub const LDT_LAUNCH_DASHBOARD_REASON_ERROR = 1;
pub const LDT_LAUNCH_DASHBOARD_REASON_SAVEDATA = 2;
pub const LDT_LAUNCH_DASHBOARD_REASON_SETTINGS = 3;
pub const LDT_LAUNCH_DASHBOARD_REASON_MUSIC = 4;
pub const LDT_LAUNCH_DASHBOARD_REASON_NETWORK = 6;
pub const LDT_LAUNCH_DASHBOARD_REASON_NEW_ACCOUNT = 7;
pub const LDT_LAUNCH_DASHBOARD_REASON_SERVER_INFO = 8;
pub const LDT_LAUNCH_DASHBOARD_REASON_SHOW_POLICIES = 9;
pub const LDT_LAUNCH_DASHBOARD_REASON_ONLINE_MENU = 10;
pub const LDT_LAUNCH_DASHBOARD_REASON_FORCE_ACCOUNT_NAME_CHANGE = 11;
pub const LDT_LAUNCH_DASHBOARD_REASON_FORCE_BILLING_CHANGE = 12;

pub const _DISPATCHER_HEADER = extern struct {
    Type: xboxdef.UCHAR,
    Absolute: xboxdef.UCHAR,
    Size: xboxdef.UCHAR,
    Inserted: xboxdef.UCHAR,
    SignalState: xboxdef.LONG,
    WaitListHead: xboxdef.LIST_ENTRY,
};
pub const DISPATCHER_HEADER = _DISPATCHER_HEADER;

pub const _KDPC = extern struct {
    Type: xboxdef.CSHORT,
    Inserted: xboxdef.BOOLEAN,
    Padding: xboxdef.UCHAR,
    DpcListEntry: xboxdef.LIST_ENTRY,
    DeferredRoutine: xboxdef.PVOID,
    DeferredContext: xboxdef.PVOID,
    SystemArgument1: xboxdef.PVOID,
    SystemArgument2: xboxdef.PVOID,
};
pub const KDPC = _KDPC;
pub const PKDPC = *_KDPC;
pub const PRKDPC = *_KDPC; // TODO: Needs a restriced pointer somehow? See https://github.com/ziglang/zig/issues/23367

///  The kernels way of representing a timer object. MS recommends not to
///  manipulate the members directly.
pub const _KTIMER = extern struct {
    Header: DISPATCHER_HEADER,
    DueTime: xboxdef.ULARGE_INTEGER,
    TimerListEntry: xboxdef.LIST_ENTRY,
    Dpc: PKDPC,
    Period: xboxdef.LONG,
};
pub const KTIMER = _KTIMER;
pub const PKTIMER = *_KTIMER;

pub const _KPROCESS = extern struct {
    ReadListHead: xboxdef.LIST_ENTRY,
    ThreadListHead: xboxdef.LIST_ENTRY,
    StackCount: xboxdef.ULONG,
    ThreadQuantum: xboxdef.LONG,
    BasePriority: xboxdef.SCHAR,
    DisableBoost: xboxdef.UCHAR,
    DisableQuantum: xboxdef.UCHAR,
};
pub const KPROCESS = _KPROCESS;
pub const PKPROCESS = *_KPROCESS;

pub const _KAPC_STATE = extern struct {
    ApcListHead: [2]xboxdef.LIST_ENTRY,
    Process: PKPROCESS,
    KernelApcInProgress: xboxdef.UCHAR,
    KernelApcPending: xboxdef.UCHAR,
    UserApcPending: xboxdef.UCHAR,
    ApcQueueable: xboxdef.UCHAR,
};
pub const KAPC_STATE = _KAPC_STATE;

pub const _KQUEUE = extern struct {
    Header: DISPATCHER_HEADER,
    EntryListHead: xboxdef.LIST_ENTRY,
    CurrentCount: xboxdef.ULONG,
    MaximumCount: xboxdef.ULONG,
    ThreadListHead: xboxdef.LIST_ENTRY,
};
pub const KQUEUE = _KQUEUE;
pub const PKQUEUE = *_KQUEUE;
pub const PRKQUEUE = *_KQUEUE; // TODO: Needs a restriced pointer somehow? See https://github.com/ziglang/zig/issues/23367

pub const _KWAIT_BLOCK = extern struct {
    WaitListEntry: xboxdef.LIST_ENTRY,
    Thread: *_KTHREAD,
    Object: xboxdef.PVOID,
    NextWaitBlock: *_KWAIT_BLOCK,
    WaitKey: xboxdef.SHORT,
    WaitType: xboxdef.SHORT,
};
pub const KWAIT_BLOCK = _KWAIT_BLOCK;
pub const PKWAIT_BLOCK = *_KWAIT_BLOCK;

pub const _KAPC = extern struct {
    Type: xboxdef.SHORT,
    ApcMode: xboxdef.CHAR,
    Inserted: xboxdef.UCHAR,
    Thread: *_KTHREAD,
    ApcListEntry: xboxdef.LIST_ENTRY,
    KernelRoutine: xboxdef.PVOID,
    RundownRoutine: xboxdef.PVOID,
    NormalRoutine: xboxdef.PVOID,
    NormalContext: xboxdef.PVOID,
    SystemArgument1: xboxdef.PVOID,
    SystemArgument2: xboxdef.PVOID,
};
pub const KAPC = _KAPC;
pub const PKAPC = *_KAPC;
pub const PRKAPC = *_KAPC; // TODO: Needs a restriced pointer somehow? See https://github.com/ziglang/zig/issues/23367

pub const _KSEMAPHORE = extern struct {
    Header: DISPATCHER_HEADER,
    Limit: xboxdef.LONG,
};
pub const KSEMAPHORE = _KSEMAPHORE;
pub const PKSEMAPHORE = *_KSEMAPHORE;
pub const PRKSEMAPHORE = *_KSEMAPHORE; // TODO: Needs a restriced pointer somehow? See https://github.com/ziglang/zig/issues/23367

pub const _KTHREAD = extern struct {
    Header: DISPATCHER_HEADER,
    MutantListHead: xboxdef.LIST_ENTRY,
    KernelTime: xboxdef.ULONG,
    StackBase: xboxdef.PVOID,
    StackLimit: xboxdef.PVOID,
    KernelStack: xboxdef.PVOID,
    TlsData: xboxdef.PVOID,
    State: xboxdef.UCHAR,
    Alerted: [2]xboxdef.UCHAR,
    Alertable: xboxdef.UCHAR,
    NpxState: xboxdef.UCHAR,
    Saturation: xboxdef.CHAR,
    Priority: xboxdef.SCHAR,
    Padding: xboxdef.UCHAR,
    ApcState: KAPC_STATE,
    ContextSwitches: xboxdef.ULONG,
    WaitStatus: xboxdef.LONG,
    WaitIrql: xboxdef.UCHAR,
    WaitMode: xboxdef.CHAR,
    WaitNext: xboxdef.UCHAR,
    WaitReason: xboxdef.UCHAR,
    WaitBlockList: PKWAIT_BLOCK,
    WaitListEntry: xboxdef.LIST_ENTRY,
    WaitTime: xboxdef.ULONG,
    KernelApcDisable: xboxdef.ULONG,
    Quantum: xboxdef.LONG,
    BasePriority: xboxdef.SCHAR,
    DecrementCount: xboxdef.UCHAR,
    PriorityDecrement: xboxdef.SCHAR,
    DisableBoost: xboxdef.UCHAR,
    NpxIrql: xboxdef.UCHAR,
    SuspendCount: xboxdef.CHAR,
    Preempted: xboxdef.UCHAR,
    HasTerminated: xboxdef.UCHAR,
    Queue: PKQUEUE,
    QueueListEntry: xboxdef.LIST_ENTRY,
    Timer: KTIMER,
    TimerWaitBlock: KWAIT_BLOCK,
    SuspendApc: KAPC,
    SuspendSemaphore: KSEMAPHORE,
    ThreadListEntry: xboxdef.LIST_ENTRY,
};
pub const KTHREAD = _KTHREAD;
pub const PKTHREAD = *_KTHREAD;
pub const PRKTHREAD = *_KTHREAD; // TODO: Needs a restriced pointer somehow? See https://github.com/ziglang/zig/issues/23367

pub const _TIMER_TYPE = enum(c_int) {
    NotificationTimer,
    SynchronizationTimer,
};
pub const TIMER_TYPE = _TIMER_TYPE;

pub const _KINTERRUPT = extern struct {
    ServiceRoutine: xboxdef.PVOID,
    ServiceContext: xboxdef.PVOID,
    BusInterruptLevel: xboxdef.ULONG,
    Irql: xboxdef.ULONG,
    Connected: xboxdef.UCHAR,
    ShareVector: xboxdef.UCHAR,
    Mode: xboxdef.UCHAR,
    Padding7: xboxdef.UCHAR,
    ServiceCount: xboxdef.ULONG,
    DispatchCode: [22]xboxdef.ULONG,
};
pub const KINTERRUPT = _KINTERRUPT;
pub const PKINTERRUPT = *_KINTERRUPT;

pub const _KSYSTEM_TIME = extern struct {
    LowPart: xboxdef.ULONG,
    High1Time: xboxdef.LONG,
    High2Time: xboxdef.LONG,
};
pub const KSYSTEM_TIME = _KSYSTEM_TIME;

pub const _FIRMWARE_REENTRY = enum(c_int) {
    HalHaltRoutine,
    HalRebootRoutine,
    HalQuickRebootRoutine,
    HalKdRebootRoutine,
    HalFatalErrorRebootRoutine,
    HalMaximumRoutine,
};
pub const FIRMWARE_REENTRY = _FIRMWARE_REENTRY;

pub const _OBJECT_TYPE = extern struct {
    AllocateProcedure: xboxdef.PVOID,
    FreeProcedure: xboxdef.PVOID,
    CloseProcedure: xboxdef.PVOID,
    DeleteProcedure: xboxdef.PVOID,
    ParseProcedure: xboxdef.PVOID,
    DefaultObject: xboxdef.PVOID,
    PoolTag: xboxdef.ULONG,
};
pub const OBJECT_TYPE = _OBJECT_TYPE;
pub const POBJECT_TYPE = *_OBJECT_TYPE;

pub const _OBJECT_HEADER = extern struct {
    PointerCount: xboxdef.LONG,
    HandleCount: xboxdef.LONG,
    Type: POBJECT_TYPE,
    Flags: xboxdef.ULONG,
    Body: xboxdef.QUAD,
};
pub const OBJECT_HEADER = _OBJECT_HEADER;
pub const POBJECT_HEADER = *_OBJECT_HEADER;

pub inline fn OBJECT_TO_OBJECT_HEADER(Object: OBJECT_HEADER) *OBJECT_HEADER {
    return CONTAINING_RECORD(Object, OBJECT_HEADER, "Body");
}

pub const PKDEFERRED_ROUTINE = fn (
    Dpc: PKDPC,
    DeferredContext: xboxdef.PVOID,
    SystemArgument1: xboxdef.PVOID,
    SystemArgument2: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.VOID;

pub const _KDEVICE_QUEUE = extern struct {
    Type: xboxdef.SHORT,
    Size: xboxdef.UCHAR,
    Busy: xboxdef.UCHAR,
    DeviceListHead: xboxdef.LIST_ENTRY,
};
pub const KDEVICE_QUEUE = _KDEVICE_QUEUE;
pub const PKDEVICE_QUEUE = *_KDEVICE_QUEUE;

pub const PKSTART_ROUTINE = fn (
    StartContext: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.VOID;

pub const _FILE_SEGMENT_ELEMENT = extern union {
    Buffer: xboxdef.PVOID,
    Alignment: xboxdef.DWORD,
};
pub const FILE_SEGMENT_ELEMENT = _FILE_SEGMENT_ELEMENT;
pub const PFILE_SEGMENT_ELEMENT = *_FILE_SEGMENT_ELEMENT;

pub const PIO_APC_ROUTINE = fn (
    ApcContext: xboxdef.PVOID,
    IoStatusBlock: PIO_STATUS_BLOCK,
    Reserved: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.VOID;

pub const _SEMAPHORE_BASIC_INFORMATION = extern struct {
    CurrentCount: xboxdef.LONG,
    MaximumCount: xboxdef.LONG,
};
pub const SEMAPHORE_BASIC_INFORMATION = _SEMAPHORE_BASIC_INFORMATION;
pub const PSEMAPHORE_BASIC_INFORMATION = *_SEMAPHORE_BASIC_INFORMATION;

pub const _MUTANT_BASIC_INFORMATION = extern struct {
    CurrentCount: xboxdef.LONG,
    OwnedByCaller: xboxdef.UCHAR,
    AbandonedState: xboxdef.UCHAR,
};
pub const MUTANT_BASIC_INFORMATION = _MUTANT_BASIC_INFORMATION;
pub const PMUTANT_BASIC_INFORMATION = *_MUTANT_BASIC_INFORMATION;

pub const _IO_COMPLETION_BASIC_INFORMATION = extern struct {
    Depth: xboxdef.LONG,
};
pub const IO_COMPLETION_BASIC_INFORMATION = _IO_COMPLETION_BASIC_INFORMATION;
pub const PIO_COMPLETION_BASIC_INFORMATION = *_IO_COMPLETION_BASIC_INFORMATION;

pub const _EVENT_BASIC_INFORMATION = extern struct {
    EventType: EVENT_TYPE,
    EventState: xboxdef.LONG,
};
pub const EVENT_BASIC_INFORMATION = _EVENT_BASIC_INFORMATION;
pub const PEVENT_BASIC_INFORMATION = *_EVENT_BASIC_INFORMATION;

pub const _PS_STATISTICS = extern struct {
    Length: xboxdef.ULONG,
    ThreadCount: xboxdef.ULONG,
    HandleCount: xboxdef.ULONG,
};
pub const PS_STATISTICS = _PS_STATISTICS;
pub const PPS_STATISTICS = *_PS_STATISTICS;

pub const _ETHREAD = extern struct {
    Tcb: KTHREAD,
    CreateTime: xboxdef.LARGE_INTEGER,
    ExitTime: xboxdef.LARGE_INTEGER,
    Anonymous0: extern union {
        ExitStatus: xboxdef.NTSTATUS,
        OfsChain: xboxdef.PVOID,
    },
    Anonymous1: extern union {
        ReaperListEntry: xboxdef.LIST_ENTRY,
        ActiveTimerListHead: xboxdef.LIST_ENTRY,
    },
    UniqueThread: xboxdef.HANDLE,
    StartAddress: xboxdef.PVOID,
    IrpList: xboxdef.LIST_ENTRY,
    DebugData: xboxdef.PVOID,
};
pub const ETHREAD = _ETHREAD;
pub const PETHREAD = *_ETHREAD;

pub const PCREATE_THREAD_NOTIFY_ROUTINE = fn (
    Thread: PETHREAD,
    ThreadId: xboxdef.HANDLE,
    Create: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.VOID;

/// Enumeration type for indicating whether an interrupt is level- or edge-triggered.
pub const _KINTERRUPT_MODE = enum(c_int) {
    /// Interrupt is level-triggered. Used for traditional PCI line-based interrupts.
    LevelSensitive,
    /// Interrupt is edge-triggered. Used for PCI message-signaled interrupts
    Latched,
};
pub const KINTERRUPT_MODE = _KINTERRUPT_MODE;

pub const PKSERVICE_ROUTINE = fn (
    Interrupt: PKINTERRUPT,
    ServiceContext: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.BOOLEAN;

pub const _TIMER_BASIC_INFORMATION = extern struct {
    RemainingTime: xboxdef.LARGE_INTEGER,
    TimerState: xboxdef.BOOLEAN,
};
pub const TIMER_BASIC_INFORMATION = _TIMER_BASIC_INFORMATION;
pub const PTIMER_BASIC_INFORMATION = *_TIMER_BASIC_INFORMATION;

pub const PTIMER_APC_ROUTINE = fn (
    TimerContext: xboxdef.PVOID,
    TimerLowValue: xboxdef.ULONG,
    TimerHighValue: xboxdef.LONG,
) callconv(NTAPI) xboxdef.VOID;

pub const _XBOX_KRNL_VERSION = extern struct {
    Major: xboxdef.USHORT,
    Minor: xboxdef.USHORT,
    Build: xboxdef.USHORT,
    Qfe: xboxdef.USHORT,
};
pub const XBOX_KRNL_VERSION = _XBOX_KRNL_VERSION;
pub const PXBOX_KRNL_VERSION = *_XBOX_KRNL_VERSION;

/// Information about the XBOX-hardware
pub const _XBOX_HARDWARE_INFO = extern struct {
    Flags: xboxdef.ULONG,
    GpuRevision: xboxdef.UCHAR,
    McpRevision: xboxdef.UCHAR,
    reserved: [2]xboxdef.UCHAR,
};
pub const XBOX_HARDWARE_INFO = _XBOX_HARDWARE_INFO;

pub const XBOX_HW_FLAG_INTERNAL_USB_HUB = 0x00_00_00_01;
pub const XBOX_HW_FLAG_DEVKIT_KERNEL = 0x00_00_00_02;
pub const XBOX_480P_MACROVISION_ENABLED = 0x00_00_00_04;
pub const XBOX_HW_FLAG_ARCADE = 0x00_00_00_08;

pub const XBOX_KEY_LENGTH = 16;
pub const XBOX_KEY_DATA = [XBOX_KEY_LENGTH]xboxdef.UCHAR;

pub const _GENERIC_MAPPING = extern struct {
    GenericRead: ACCESS_MASK,
    GenericWrite: ACCESS_MASK,
    GenericExecute: ACCESS_MASK,
    GenericAll: ACCESS_MASK,
};
pub const GENERIC_MAPPING = _GENERIC_MAPPING;
pub const PGENERIC_MAPPING = *_GENERIC_MAPPING;

/// Describes an entry in (or the header of) a singly linked list
pub const _SINGLE_LIST_ENTRY = extern struct {
    /// Pointer to the next (or first, if this is a header) entry in the singly linked list (NULL if there is none)
    Next: ?*_SINGLE_LIST_ENTRY,
};
pub const SINGLE_LIST_ENTRY = _SINGLE_LIST_ENTRY;
pub const PSINGLE_LIST_ENTRY = *_SINGLE_LIST_ENTRY;

/// Serves as a header for a singly linked list. Initialized by ExInitializeSListHead
pub const _SLIST_HEADER = extern struct {
    Alignment: xboxdef.ULONGLONG,
    Anonymous: extern struct {
        Next: SINGLE_LIST_ENTRY,
        Depth: xboxdef.USHORT,
        Sequence: xboxdef.USHORT,
    },
};
pub const SLIST_HEADER = _SLIST_HEADER;
pub const PSLIST_HEADER = *_SLIST_HEADER;

pub const _KEVENT = extern struct {
    Header: DISPATCHER_HEADER,
};
pub const KEVENT = _KEVENT;
pub const PKEVENT = *_KEVENT;
pub const PRKEVENT = *_KEVENT; // TODO: Needs a restriced pointer somehow? See https://github.com/ziglang/zig/issues/23367

pub const _KDEVICE_QUEUE_ENTRY = extern struct {
    DeviceListEntry: xboxdef.LIST_ENTRY,
    SortKey: xboxdef.ULONG,
    Inserted: xboxdef.BOOLEAN,
};
pub const KDEVICE_QUEUE_ENTRY = _KDEVICE_QUEUE_ENTRY;
pub const PKDEVICE_QUEUE_ENTRY = *_KDEVICE_QUEUE_ENTRY;

pub const _IO_COMPLETION_CONTEXT = extern struct {
    Port: xboxdef.PVOID,
    Key: xboxdef.PVOID,
};
pub const IO_COMPLETION_CONTEXT = _IO_COMPLETION_CONTEXT;
pub const PIO_COMPLETION_CONTEXT = *_IO_COMPLETION_CONTEXT;

pub const _FILE_OBJECT = extern struct {
    Type: xboxdef.CSHORT,
    DeletePending: u1,
    ReadAccess: u1,
    WriteAccess: u1,
    DeleteAccess: u1,
    SharedRead: u1,
    SharedWrite: u1,
    SharedDelete: u1,
    Reserved: u1,
    Flags: xboxdef.UCHAR,
    DeviceObject: *_DEVICE_OBJECT,
    FsContext: xboxdef.PVOID,
    FsContext2: xboxdef.PVOID,
    FinalStatus: xboxdef.NTSTATUS,
    CurrentByteOffset: xboxdef.LARGE_INTEGER,
    RelatedFileObject: *_FILE_OBJECT,
    CompletionContext: PIO_COMPLETION_CONTEXT,
    LockCount: xboxdef.LONG,
    Lock: KEVENT,
    Event: KEVENT,
};
pub const FILE_OBJECT = _FILE_OBJECT;
pub const PFILE_OBJECT = *_FILE_OBJECT;

pub const STATUS_CONTINUE_COMPLETION = ntstatus.STATUS_SUCCESS;

pub const _IO_COMPLETION_ROUTINE_RESULT = enum(c_int) { ContinueCompletion = STATUS_CONTINUE_COMPLETION, StopCompletion = ntstatus.STATUS_MORE_PROCESSING_REQUIRED };
pub const IO_COMPLETION_ROUTINE_RESULT = _IO_COMPLETION_ROUTINE_RESULT;
pub const PIO_COMPLETION_ROUTINE_RESULT = *_IO_COMPLETION_ROUTINE_RESULT;

pub const _LUID_AND_ATTRIBUTES = extern struct {
    Luid: std.os.windows.NET.LUID,
    Attributes: xboxdef.ULONG,
};
pub const LUID_AND_ATTRIBUTES = _LUID_AND_ATTRIBUTES;
pub const PLUID_AND_ATTRIBUTES = *_LUID_AND_ATTRIBUTES;

pub const INITIAL_PRIVILEGE_COUNT = 3;

pub const _INITIAL_PRIVILEGE_SET = extern struct {
    PrivilegeCount: xboxdef.ULONG,
    Control: xboxdef.ULONG,
    Privilege: [INITIAL_PRIVILEGE_COUNT]LUID_AND_ATTRIBUTES,
};
pub const INITIAL_PRIVILEGE_SET = _INITIAL_PRIVILEGE_SET;
pub const PINITIAL_PRIVILEGE_SET = *_INITIAL_PRIVILEGE_SET;

pub const PACCESS_TOKEN = xboxdef.PVOID;

pub const _SECURITY_IMPERSONATION_LEVEL = enum(c_int) {
    SecurityAnonymous,
    SecurityIdentification,
    SecurityImpersonation,
    SecurityDelegation,
};
pub const SECURITY_IMPERSONATION_LEVEL = _SECURITY_IMPERSONATION_LEVEL;
pub const PSECURITY_IMPERSONATION_LEVEL = *_SECURITY_IMPERSONATION_LEVEL;

pub const _SECURITY_SUBJECT_CONTEXT = extern struct {
    ClientToken: PACCESS_TOKEN,
    ImpersonationLevel: SECURITY_IMPERSONATION_LEVEL,
    PrimaryToken: PACCESS_TOKEN,
    ProcessAuditId: xboxdef.PVOID,
};
pub const SECURITY_SUBJECT_CONTEXT = _SECURITY_SUBJECT_CONTEXT;
pub const PSECURITY_SUBJECT_CONTEXT = *_SECURITY_SUBJECT_CONTEXT;

pub const ANYSIZE_ARRAY = 1;

pub const _PRIVILEGE_SET = extern struct {
    PrivilegeCount: xboxdef.ULONG,
    Control: xboxdef.ULONG,
    Privilege: [ANYSIZE_ARRAY]LUID_AND_ATTRIBUTES,
};
pub const PRIVILEGE_SET = _PRIVILEGE_SET;
pub const PPRIVILEGE_SET = *_PRIVILEGE_SET;

pub const _ACCESS_STATE = extern struct {
    OperationID: std.os.windows.NET.LUID,
    SecurityEvaluated: xboxdef.BOOLEAN,
    GenerateAudit: xboxdef.BOOLEAN,
    GenerateOnClose: xboxdef.BOOLEAN,
    PrivilegesAllocated: xboxdef.BOOLEAN,
    Flags: xboxdef.ULONG,
    RemainingDesiredAccess: ACCESS_MASK,
    PreviouslyGrantedAccess: ACCESS_MASK,
    OriginalDesiredAccess: ACCESS_MASK,
    SubjectSecurityContext: SECURITY_SUBJECT_CONTEXT,
    SecurityDescriptor: PSECURITY_DESCRIPTOR,
    AuxData: xboxdef.PVOID,
    Privileges: extern union {
        InitialPrivilegeSet: INITIAL_PRIVILEGE_SET,
        PrivilegeSet: PRIVILEGE_SET,
    },
    AuditPrivileges: xboxdef.BOOLEAN,
    ObjectName: UNICODE_STRING,
    ObjectTypeName: UNICODE_STRING,
};
pub const ACCESS_STATE = _ACCESS_STATE;
pub const PACCESS_STATE = *_ACCESS_STATE;

pub const SECURITY_CONTEXT_TRACKING_MODE = xboxdef.BOOLEAN;
pub const PSECURITY_CONTEXT_TRACKING_MODE = *xboxdef.BOOLEAN;

pub const _SECURITY_QUALITY_OF_SERVICE = extern struct {
    Length: xboxdef.ULONG,
    ImpersonationLevel: SECURITY_IMPERSONATION_LEVEL,
    ContextTrackingMode: SECURITY_CONTEXT_TRACKING_MODE,
    EffectiveOnly: xboxdef.BOOLEAN,
};
pub const SECURITY_QUALITY_OF_SERVICE = _SECURITY_QUALITY_OF_SERVICE;
pub const PSECURITY_QUALITY_OF_SERVICE = *_SECURITY_QUALITY_OF_SERVICE;

pub const _IO_SECURITY_CONTEXT = extern struct {
    SecurityQos: PSECURITY_QUALITY_OF_SERVICE,
    AccessState: PACCESS_STATE,
    DesiredAccess: ACCESS_MASK,
    FullCreateOptions: xboxdef.ULONG,
};
pub const IO_SECURITY_CONTEXT = _IO_SECURITY_CONTEXT;
pub const PIO_SECURITY_CONTEXT = *_IO_SECURITY_CONTEXT;

pub const _NAMED_PIPE_CREATE_PARAMETERS = extern struct {
    NamedPipeType: xboxdef.ULONG,
    ReadMode: xboxdef.ULONG,
    CompletionMode: xboxdef.ULONG,
    MaximumInstances: xboxdef.ULONG,
    InboundQuota: xboxdef.ULONG,
    OutboundQuota: xboxdef.ULONG,
    DefaultTimeout: xboxdef.LARGE_INTEGER,
    TimeoutSpecified: xboxdef.BOOLEAN,
};
pub const NAMED_PIPE_CREATE_PARAMETERS = _NAMED_PIPE_CREATE_PARAMETERS;
pub const PNAMED_PIPE_CREATE_PARAMETERS = *_NAMED_PIPE_CREATE_PARAMETERS;

pub const _MAILSLOT_CREATE_PARAMETERS = extern struct {
    MailslotQuota: xboxdef.ULONG,
    MaximumMessageSize: xboxdef.ULONG,
    ReadTimeout: xboxdef.LARGE_INTEGER,
    TimeoutSpecified: xboxdef.BOOLEAN,
};
pub const MAILSLOT_CREATE_PARAMETERS = _MAILSLOT_CREATE_PARAMETERS;
pub const PMAILSLOT_CREATE_PARAMETERS = *_MAILSLOT_CREATE_PARAMETERS;

pub const _DIRECTORY_NOTIFY_INFORMATION_CLASS = enum(c_int) { DirectoryNotifyInformation = 1, DirectoryNotifyExtendedInformation };
pub const DIRECTORY_NOTIFY_INFORMATION_CLASS = _DIRECTORY_NOTIFY_INFORMATION_CLASS;
pub const PDIRECTORY_NOTIFY_INFORMATION_CLASS = *_DIRECTORY_NOTIFY_INFORMATION_CLASS;

pub const SECURITY_INFORMATION = xboxdef.ULONG;
pub const PSECURITY_INFORMATION = *xboxdef.ULONG;

pub const MAXIMUM_VOLUME_LABEL_LENGTH = 32 * @sizeOf(xboxdef.WCHAR);

pub const _VPB = extern struct {
    Type: xboxdef.CSHORT,
    Size: xboxdef.CSHORT,
    Flags: xboxdef.USHORT,
    VolumeLabelLength: xboxdef.USHORT,
    DeviceObject: *_DEVICE_OBJECT,
    RealDevice: *_DEVICE_OBJECT,
    SerialNumber: xboxdef.ULONG,
    ReferenceCount: xboxdef.ULONG,
    VolumeLabel: [MAXIMUM_VOLUME_LABEL_LENGTH / @sizeOf(xboxdef.WCHAR)]xboxdef.WCHAR,
};
pub const VPB = _VPB;
pub const PVPB = *_VPB;

pub const _SCSI_REQUEST_BLOCK = extern struct {
    Length: xboxdef.USHORT,
    Function: xboxdef.UCHAR,
    SrbStatus: xboxdef.UCHAR,
    ScsiStatus: xboxdef.UCHAR,
    PathId: xboxdef.UCHAR,
    TargetId: xboxdef.UCHAR,
    Lun: xboxdef.UCHAR,
    QueueTag: xboxdef.UCHAR,
    QueueAction: xboxdef.UCHAR,
    CdbLength: xboxdef.UCHAR,
    SenseInfoBufferLength: xboxdef.UCHAR,
    SrbFlags: xboxdef.ULONG,
    DataTransferLength: xboxdef.ULONG,
    TimeOutValue: xboxdef.ULONG,
    DataBuffer: xboxdef.PVOID,
    SenseInfoBuffer: xboxdef.PVOID,
    NextSrb: *_SCSI_REQUEST_BLOCK,
    OriginalRequest: xboxdef.PVOID,
    SrbExtension: xboxdef.PVOID,
    Anonymus: extern union {
        InternalStatus: xboxdef.ULONG,
        QueueSortKey: xboxdef.ULONG,
        LinkTimeoutValue: xboxdef.ULONG,
    },
    Cdb: [16]xboxdef.UCHAR,
};
pub const SCSI_REQUEST_BLOCK = _SCSI_REQUEST_BLOCK;
pub const PSCSI_REQUEST_BLOCK = *_SCSI_REQUEST_BLOCK;

pub const _FILE_GET_QUOTA_INFORMATION = extern struct {
    NextEntryOffset: xboxdef.ULONG,
    SidLength: xboxdef.ULONG,
    Sid: SID,
};
pub const FILE_GET_QUOTA_INFORMATION = _FILE_GET_QUOTA_INFORMATION;
pub const PFILE_GET_QUOTA_INFORMATION = *_FILE_GET_QUOTA_INFORMATION;

pub const _DEVICE_RELATION_TYPE = enum(c_int) {
    BusRelations,
    EjectionRelations,
    PowerRelations,
    RemovalRelations,
    TargetDeviceRelation,
    SingleBusRelations,
    TransportRelations,
};
pub const DEVICE_RELATION_TYPE = _DEVICE_RELATION_TYPE;
pub const PDEVICE_RELATION_TYPE = *_DEVICE_RELATION_TYPE;

pub const PINTERFACE_REFERENCE = fn (
    Context: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.VOID;

pub const PINTERFACE_DEREFERENCE = fn (
    Context: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.VOID;

pub const _INTERFACE = extern struct {
    Size: xboxdef.USHORT,
    Version: xboxdef.USHORT,
    Context: xboxdef.PVOID,
    InterfaceReference: PINTERFACE_REFERENCE,
    InterfaceDereference: PINTERFACE_DEREFERENCE,
};
pub const INTERFACE = _INTERFACE;
pub const PINTERFACE = *_INTERFACE;

/// Power States/Levels
pub const _SYSTEM_POWER_STATE = enum(c_int) {
    PowerSystemUnspecified = 0,
    PowerSystemWorking,
    PowerSystemSleeping1,
    PowerSystemSleeping2,
    PowerSystemSleeping3,
    PowerSystemHibernate,
    PowerSystemShutdown,
    PowerSystemMaximum,
};
pub const SYSTEM_POWER_STATE = _SYSTEM_POWER_STATE;
pub const PSYSTEM_POWER_STATE = *_SYSTEM_POWER_STATE;

pub const _DEVICE_POWER_STATE = enum(c_int) {
    PowerDeviceUnspecified = 0,
    PowerDeviceD0,
    PowerDeviceD1,
    PowerDeviceD2,
    PowerDeviceD3,
    PowerDeviceMaximum,
};
pub const DEVICE_POWER_STATE = _DEVICE_POWER_STATE;
pub const PDEVICE_POWER_STATE = *_DEVICE_POWER_STATE;

pub const _DEVICE_CAPABILITIES = extern struct {
    Size: xboxdef.USHORT,
    Version: xboxdef.USHORT,
    DeviceD1: u1,
    DeviceD2: u1,
    LockSupported: u1,
    EjectSupported: u1,
    Removable: u1,
    DockDevice: u1,
    UniqueID: u1,
    SilentInstall: u1,
    RawDeviceOK: u1,
    SurpriseRemovalOK: u1,
    WakeFromD0: u1,
    WakeFromD1: u1,
    WakeFromD2: u1,
    WakeFromD3: u1,
    HardwareDisabled: u1,
    NonDynamic: u1,
    WarmEjectSupported: u1,
    NoDisplayInUI: u1,
    Reserved: u14,
    Address: xboxdef.ULONG,
    UINumber: xboxdef.ULONG,
    DeviceState: [@intFromEnum(SYSTEM_POWER_STATE.PowerSystemMaximum)]DEVICE_POWER_STATE,
    SystemWake: SYSTEM_POWER_STATE,
    DeviceWake: DEVICE_POWER_STATE,
    D1Latency: xboxdef.ULONG,
    D2Latency: xboxdef.ULONG,
    D3Latency: xboxdef.ULONG,
};
pub const DEVICE_CAPABILITIES = _DEVICE_CAPABILITIES;
pub const PDEVICE_CAPABILITIES = *_DEVICE_CAPABILITIES;

pub const _INTERFACE_TYPE = enum(c_int) {
    InterfaceTypeUndefined = -1,
    Internal,
    Isa,
    Eisa,
    MicroChannel,
    TurboChannel,
    PCIBus,
    VMEBus,
    NuBus,
    PCMCIABus,
    CBus,
    MPIBus,
    MPSABus,
    ProcessorInternal,
    InternalPowerBus,
    PNPISABus,
    PNPBus,
    Vmcs,
    ACPIBus,
    MaximumInterfaceType,
};
pub const INTERFACE_TYPE = _INTERFACE_TYPE;
pub const PINTERFACE_TYPE = *_INTERFACE_TYPE;

pub const _IO_RESOURCE_DESCRIPTOR = extern struct {
    Option: xboxdef.UCHAR,
    Type: xboxdef.UCHAR,
    ShareDisposition: xboxdef.UCHAR,
    Spare1: xboxdef.UCHAR,
    Flags: xboxdef.USHORT,
    Spare2: xboxdef.USHORT,
    Anonymus: extern union {
        Port: extern struct {
            Length: xboxdef.ULONG,
            Alignment: xboxdef.ULONG,
            MinimumAddress: PHYSICAL_ADDRESS,
            MaximumAddress: PHYSICAL_ADDRESS,
        },
        Memory: extern struct {
            Length: xboxdef.ULONG,
            Alignment: xboxdef.ULONG,
            MinimumAddress: PHYSICAL_ADDRESS,
            MaximumAddress: PHYSICAL_ADDRESS,
        },
        Interrupt: extern struct {
            MinimumVector: xboxdef.ULONG,
            MaximumVector: xboxdef.ULONG,
        },
        Dma: extern struct {
            MinimumChannel: xboxdef.ULONG,
            MaximumChannel: xboxdef.ULONG,
        },
        Generic: extern struct {
            Length: xboxdef.ULONG,
            Alignment: xboxdef.ULONG,
            MinimumAddress: PHYSICAL_ADDRESS,
            MaximumAddress: PHYSICAL_ADDRESS,
        },
        DevicePrivate: extern struct {
            Data: [3]xboxdef.ULONG,
        },
        BusNumber: extern struct {
            Length: xboxdef.ULONG,
            MinBusNumber: xboxdef.ULONG,
            MaxBusNumber: xboxdef.ULONG,
            Reserved: xboxdef.ULONG,
        },
        ConfigData: extern struct {
            Priority: xboxdef.ULONG,
            Reserved1: xboxdef.ULONG,
            Reserved2: xboxdef.ULONG,
        },
    },
};
pub const IO_RESOURCE_DESCRIPTOR = _IO_RESOURCE_DESCRIPTOR;
pub const PIO_RESOURCE_DESCRIPTOR = *_IO_RESOURCE_DESCRIPTOR;

pub const _IO_RESOURCE_LIST = extern struct {
    Version: xboxdef.USHORT,
    Revision: xboxdef.USHORT,
    Count: xboxdef.ULONG,
    Descriptors: [1]IO_RESOURCE_DESCRIPTOR,
};
pub const IO_RESOURCE_LIST = _IO_RESOURCE_LIST;
pub const PIO_RESOURCE_LIST = *_IO_RESOURCE_LIST;

pub const _IO_RESOURCE_REQUIREMENTS_LIST = extern struct {
    ListSize: xboxdef.ULONG,
    InterfaceType: INTERFACE_TYPE,
    BusNumber: xboxdef.ULONG,
    SlotNumber: xboxdef.ULONG,
    Reserved: [3]xboxdef.ULONG,
    AlternativeLists: xboxdef.ULONG,
    List: [1]IO_RESOURCE_LIST,
};
pub const IO_RESOURCE_REQUIREMENTS_LIST = _IO_RESOURCE_REQUIREMENTS_LIST;
pub const PIO_RESOURCE_REQUIREMENTS_LIST = *_IO_RESOURCE_REQUIREMENTS_LIST;

pub const _BUS_QUERY_ID_TYPE = enum(c_int) {
    BusQueryDeviceID,
    BusQueryHardwareIDs,
    BusQueryCompatibleIDs,
    BusQueryInstanceID,
    BusQueryDeviceSerialNumber,
    BusQueryContainerID,
};
pub const BUS_QUERY_ID_TYPE = _BUS_QUERY_ID_TYPE;
pub const PBUS_QUERY_ID_TYPE = *_BUS_QUERY_ID_TYPE;

pub const _DEVICE_TEXT_TYPE = enum(c_int) {
    DeviceTextDescription,
    DeviceTextLocationInformation,
};
pub const DEVICE_TEXT_TYPE = _DEVICE_TEXT_TYPE;
pub const PDEVICE_TEXT_TYPE = *_DEVICE_TEXT_TYPE;

pub const LCID = xboxdef.ULONG;

pub const _DEVICE_USAGE_NOTIFICATION_TYPE = enum(c_int) {
    DeviceUsageTypeUndefined,
    DeviceUsageTypePaging,
    DeviceUsageTypeHibernation,
    DeviceUsageTypeDumpFile,
    DeviceUsageTypeBoot,
    DeviceUsageTypePostDisplay,
    DeviceUsageTypeGuestAssigned,
};
pub const DEVICE_USAGE_NOTIFICATION_TYPE = _DEVICE_USAGE_NOTIFICATION_TYPE;

pub const _POWER_SEQUENCE = extern struct {
    SequenceD1: xboxdef.ULONG,
    SequenceD2: xboxdef.ULONG,
    SequenceD3: xboxdef.ULONG,
};
pub const POWER_SEQUENCE = _POWER_SEQUENCE;
pub const PPOWER_SEQUENCE = *_POWER_SEQUENCE;

pub const _POWER_STATE_TYPE = enum(c_int) {
    SystemPowerState = 0,
    DevicePowerState,
};
pub const POWER_STATE_TYPE = _POWER_STATE_TYPE;
pub const PPOWER_STATE_TYPE = *_POWER_STATE_TYPE;

pub const _POWER_STATE = extern union {
    SystemState: SYSTEM_POWER_STATE,
    DeviceState: DEVICE_POWER_STATE,
};
pub const POWER_STATE = _POWER_STATE;
pub const PPOWER_STATE = *_POWER_STATE;

pub const _POWER_ACTION = enum(c_int) {
    PowerActionNone = 0,
    PowerActionReserved,
    PowerActionSleep,
    PowerActionHibernate,
    PowerActionShutdown,
    PowerActionShutdownReset,
    PowerActionShutdownOff,
    PowerActionWarmEject,
    PowerActionDisplayOff,
};
pub const POWER_ACTION = _POWER_ACTION;
pub const PPOWER_ACTION = *_POWER_ACTION;

pub const _CM_RESOURCE_LIST = extern struct {
    Count: xboxdef.ULONG,
    List: [1]CM_FULL_RESOURCE_DESCRIPTOR,
};
pub const CM_RESOURCE_LIST = _CM_RESOURCE_LIST;
pub const PCM_RESOURCE_LIST = *_CM_RESOURCE_LIST;

pub const _CM_FULL_RESOURCE_DESCRIPTOR = extern struct {
    InterfaceType: INTERFACE_TYPE,
    BusNumber: xboxdef.ULONG,
    PartialResourceList: CM_PARTIAL_RESOURCE_LIST,
};
pub const CM_FULL_RESOURCE_DESCRIPTOR = _CM_FULL_RESOURCE_DESCRIPTOR;
pub const PCM_FULL_RESOURCE_DESCRIPTOR = *_CM_FULL_RESOURCE_DESCRIPTOR;

pub const _CM_PARTIAL_RESOURCE_LIST = extern struct {
    Version: xboxdef.USHORT,
    Revision: xboxdef.USHORT,
    Count: xboxdef.ULONG,
    PartialDescriptors: [1]CM_PARTIAL_RESOURCE_DESCRIPTOR,
};
pub const CM_PARTIAL_RESOURCE_LIST = _CM_PARTIAL_RESOURCE_LIST;
pub const PCM_PARTIAL_RESOURCE_LIST = *_CM_PARTIAL_RESOURCE_LIST;

pub const KAFFINITY = xboxdef.ULONG_PTR;

pub const _CM_PARTIAL_RESOURCE_DESCRIPTOR = extern struct {
    Type: xboxdef.UCHAR,
    ShareDisposition: xboxdef.UCHAR,
    Flags: xboxdef.USHORT,
    Anonymous: extern union {
        Generic: extern struct {
            Start: PHYSICAL_ADDRESS,
            Length: xboxdef.ULONG,
        },
        Port: extern struct {
            Start: PHYSICAL_ADDRESS,
            Length: xboxdef.ULONG,
        },
        Interrupt: extern struct {
            Level: xboxdef.ULONG,
            Vector: xboxdef.ULONG,
            Affinity: KAFFINITY,
        },
        Memory: extern struct {
            Start: PHYSICAL_ADDRESS,
            Length: xboxdef.ULONG,
        },
        Dma: extern struct {
            Channel: xboxdef.ULONG,
            Port: xboxdef.ULONG,
            Reserved1: xboxdef.ULONG,
        },
        DevicePrivate: extern struct {
            Data: [3]xboxdef.ULONG,
        },
        BusNumber: extern struct {
            Start: xboxdef.ULONG,
            Length: xboxdef.ULONG,
            Reserved: xboxdef.ULONG,
        },
        DeviceSpecificData: extern struct {
            DataSize: xboxdef.ULONG,
            Reserved1: xboxdef.ULONG,
            Reserved2: xboxdef.ULONG,
        },
    },
};
pub const CM_PARTIAL_RESOURCE_DESCRIPTOR = _CM_PARTIAL_RESOURCE_DESCRIPTOR;
pub const PCM_PARTIAL_RESOURCE_DESCRIPTOR = *_CM_PARTIAL_RESOURCE_DESCRIPTOR;

pub const IO_COMPLETION_ROUTINE = fn (
    DeviceObject: *_DEVICE_OBJECT,
    Irp: *_IRP,
    Context: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.NTSTATUS;
pub const PIO_COMPLETION_ROUTINE = *IO_COMPLETION_ROUTINE;

pub const _IO_STACK_LOCATION = extern struct {
    MajorFunction: xboxdef.UCHAR,
    MinorFunction: xboxdef.UCHAR,
    Flags: xboxdef.UCHAR,
    Control: xboxdef.UCHAR,
    Parameters: extern union {
        Create: extern struct {
            SecurityContext: PIO_SECURITY_CONTEXT,
            Options: xboxdef.ULONG,
            FileAttributes: xboxdef.USHORT,
            ShareAccess: xboxdef.USHORT,
            EaLength: xboxdef.ULONG,
        },
        CreatePipe: extern struct {
            SecurityContext: PIO_SECURITY_CONTEXT,
            Options: xboxdef.ULONG,
            Reserved: xboxdef.USHORT,
            ShareAccess: xboxdef.USHORT,
            Parameters: PNAMED_PIPE_CREATE_PARAMETERS,
        },
        CreateMailslot: extern struct {
            SecurityContext: PIO_SECURITY_CONTEXT,
            Options: xboxdef.ULONG,
            Reserved: xboxdef.USHORT,
            ShareAccess: xboxdef.USHORT,
            Parameters: PMAILSLOT_CREATE_PARAMETERS,
        },
        Read: extern struct {
            Length: xboxdef.ULONG,
            Key: xboxdef.ULONG,
            Flags: xboxdef.ULONG,
            ByteOffset: xboxdef.LARGE_INTEGER,
        },
        Write: extern struct {
            Length: xboxdef.ULONG,
            Key: xboxdef.ULONG,
            Flags: xboxdef.ULONG,
            ByteOffset: xboxdef.LARGE_INTEGER,
        },
        QueryDirectory: extern struct {
            Length: xboxdef.ULONG,
            FileName: PUNICODE_STRING,
            FileInformationClass: FILE_INFORMATION_CLASS,
            FileIndex: xboxdef.ULONG,
        },
        NotifyDirectory: extern struct {
            Length: xboxdef.ULONG,
            CompletionFilter: xboxdef.ULONG,
        },
        NotifyDirectoryEx: extern struct {
            Length: xboxdef.ULONG,
            CompletionFilter: xboxdef.ULONG,
            DirectoryNotifyInformationClass: DIRECTORY_NOTIFY_INFORMATION_CLASS,
        },
        QueryFile: extern struct {
            Length: xboxdef.ULONG,
            FileInformationClass: FILE_INFORMATION_CLASS,
        },
        SetFile: extern struct {
            Length: xboxdef.ULONG,
            FileInformationClass: FILE_INFORMATION_CLASS,
            FileObject: PFILE_OBJECT,
            Anonymous: extern union {
                Anonymous: extern struct {
                    ReplaceIfExists: xboxdef.BOOLEAN,
                    AdvanceOnly: xboxdef.BOOLEAN,
                },
                ClusterCount: xboxdef.ULONG,
                DeleteHandle: xboxdef.HANDLE,
            },
        },
        QueryEa: extern struct {
            Length: xboxdef.ULONG,
            EaList: xboxdef.PVOID,
            EaListLength: xboxdef.ULONG,
            EaIndex: xboxdef.ULONG,
        },
        SetEa: extern struct {
            Length: xboxdef.ULONG,
        },
        QueryVolume: extern struct {
            Length: xboxdef.ULONG,
            FsInformationClass: FS_INFORMATION_CLASS,
        },
        SetVolume: extern struct {
            Length: xboxdef.ULONG,
            FsInformationClass: FS_INFORMATION_CLASS,
        },
        FileSystemControl: extern struct {
            OutputBufferLength: xboxdef.ULONG,
            InputBufferLength: xboxdef.ULONG,
            FsControlCode: xboxdef.ULONG,
            Type3InputBuffer: xboxdef.PVOID,
        },
        LockControl: extern struct {
            Length: xboxdef.PLARGE_INTEGER,
            Key: xboxdef.ULONG,
            ByteOffset: xboxdef.LARGE_INTEGER,
        },
        DeviceIoControl: extern struct {
            OutputBufferLength: xboxdef.ULONG,
            InputBufferLength: xboxdef.ULONG,
            IoControlCode: xboxdef.ULONG,
            Type3InputBuffer: xboxdef.PVOID,
        },
        QuerySecurity: extern struct {
            SecurityInformation: SECURITY_INFORMATION,
            Length: xboxdef.ULONG,
        },
        SetSecurity: extern struct {
            SecurityInformation: SECURITY_INFORMATION,
            SecurityDescriptor: PSECURITY_DESCRIPTOR,
        },
        MountVolume: extern struct {
            Vpb: PVPB,
            DeviceObject: PDEVICE_OBJECT,
            OutputBufferLength: xboxdef.ULONG,
        },
        VerifyVolume: extern struct {
            Vpb: PVPB,
            DeviceObject: PDEVICE_OBJECT,
        },
        Scsi: extern struct {
            Srb: *_SCSI_REQUEST_BLOCK,
        },
        QueryQuota: extern struct {
            Length: xboxdef.ULONG,
            StartSid: PSID,
            SidList: PFILE_GET_QUOTA_INFORMATION,
            SidListLength: xboxdef.ULONG,
        },
        SetQuota: extern struct {
            Length: xboxdef.ULONG,
        },
        QueryDeviceRelations: extern struct {
            Type: DEVICE_RELATION_TYPE,
        },
        QueryInterface: extern struct {
            InterfaceType: *const std.os.windows.GUID,
            Size: xboxdef.USHORT,
            Version: xboxdef.USHORT,
            Interface: PINTERFACE,
            InterfaceSpecificData: xboxdef.PVOID,
        },
        DeviceCapabilities: extern struct {
            Capabilities: PDEVICE_CAPABILITIES,
        },
        FilterResourceRequirements: extern struct {
            IoResourceRequirementList: PIO_RESOURCE_REQUIREMENTS_LIST,
        },
        ReadWriteConfig: extern struct {
            WhichSpace: xboxdef.ULONG,
            Buffer: xboxdef.PVOID,
            Offset: xboxdef.ULONG,
            Length: xboxdef.ULONG,
        },
        SetLock: extern struct {
            Lock: xboxdef.BOOLEAN,
        },
        QueryId: extern struct {
            IdType: BUS_QUERY_ID_TYPE,
        },
        QueryDeviceText: extern struct {
            DeviceTextType: DEVICE_TEXT_TYPE,
            LocaleId: LCID,
        },
        UsageNotification: extern struct {
            InPath: xboxdef.BOOLEAN,
            Reserved: [3]xboxdef.BOOLEAN,
            Type: DEVICE_USAGE_NOTIFICATION_TYPE,
        },
        WaitWake: extern struct {
            PowerState: SYSTEM_POWER_STATE,
        },
        PowerSequence: extern struct {
            PowerSequence: PPOWER_SEQUENCE,
        },
        Power: extern struct {
            SystemContext: xboxdef.ULONG,
            Type: POWER_STATE_TYPE,
            State: POWER_STATE,
            ShutdownType: POWER_ACTION,
        },
        StartDevice: extern struct {
            AllocatedResources: PCM_RESOURCE_LIST,
            AllocatedResourcesTranslated: PCM_RESOURCE_LIST,
        },
        WMI: extern struct {
            ProviderId: xboxdef.ULONG_PTR,
            DataPath: xboxdef.PVOID,
            BufferSize: xboxdef.ULONG,
            Buffer: xboxdef.PVOID,
        },
        Others: extern struct {
            Argument1: xboxdef.PVOID,
            Argument2: xboxdef.PVOID,
            Argument3: xboxdef.PVOID,
            Argument4: xboxdef.PVOID,
        },
    },
    DeviceObject: PDEVICE_OBJECT,
    FileObject: PFILE_OBJECT,
    CompletionRoutine: PIO_COMPLETION_ROUTINE,
    Context: xboxdef.PVOID,
};
pub const IO_STACK_LOCATION = _IO_STACK_LOCATION;
pub const PIO_STACK_LOCATION = *_IO_STACK_LOCATION;

/// This struct represents an I/O request packet
pub const _IRP = extern struct {
    Type: xboxdef.CSHORT,
    Size: xboxdef.USHORT,
    Flags: xboxdef.ULONG, // Flags for the packet
    ThreadListEntry: xboxdef.LIST_ENTRY,
    IoStatus: IO_STATUS_BLOCK,
    StackCount: xboxdef.CHAR,
    CurrentLocation: xboxdef.CHAR,
    PendingReturned: xboxdef.BOOLEAN,
    Cancel: xboxdef.BOOLEAN, // Has the packet been canceled?
    UserIosb: PIO_STATUS_BLOCK,
    UserEvent: PKEVENT,
    Overlay: extern union {
        AsynchronousParameters: extern struct {
            UserApcRoutine: PIO_APC_ROUTINE,
            UserApcContext: xboxdef.PVOID,
        },
        AllocationSize: xboxdef.LARGE_INTEGER,
    },
    UserBuffer: xboxdef.PVOID,
    SegmentArray: PFILE_SEGMENT_ELEMENT,
    LockedBufferLength: xboxdef.ULONG,
    Tail: extern union {
        Overlay: extern struct {
            Anonymous0: extern union {
                DeviceQueueEntry: KDEVICE_QUEUE_ENTRY,
                Anonymous: extern struct {
                    DriverContext: [5]xboxdef.PVOID,
                },
            },
            Thread: PETHREAD,

            Anonymous1: extern struct {
                ListEntry: xboxdef.LIST_ENTRY,
                Anonymous: extern union {
                    CurrentStackLocation: *_IO_STACK_LOCATION,
                    PacketType: xboxdef.ULONG,
                },
            },
            OriginalFileObject: PFILE_OBJECT,
        },
        Apc: KAPC,
        CompletionKey: xboxdef.PVOID,
    },
};
pub const IRP = _IRP;
pub const PIRP = *_IRP;

pub const IRP_NOCACHE = 0x00_00_00_01;
pub const IRP_MOUNT_COMPLETION = 0x00_00_00_02;
pub const IRP_SYNCHRONOUS_API = 0x00_00_00_04;
pub const IRP_CREATE_OPERATION = 0x00_00_00_08;
pub const IRP_READ_OPERATION = 0x00_00_00_10;
pub const IRP_WRITE_OPERATION = 0x00_00_00_20;
pub const IRP_CLOSE_OPERATION = 0x00_00_00_40;
pub const IRP_DEFER_IO_COMPLETION = 0x00_00_00_80;
pub const IRP_OB_QUERY_NAME = 0x00_00_01_00;
pub const IRP_UNLOCK_USER_BUFFER = 0x00_00_02_00;
pub const IRP_SCATTER_GATHER_OPERATION = 0x00_00_04_00;
pub const IRP_UNMAP_SEGMENT_ARRAY = 0x00_00_08_00;
pub const IRP_NO_CANCELIO = 0x00_00_10_00;

pub const PDRIVER_STARTIO = fn (
    DeviceObject: *_DEVICE_OBJECT,
    Irp: *_IRP,
) callconv(NTAPI) xboxdef.VOID;

pub const PDRIVER_DELETEDEVICE = fn (
    DeviceObject: *_DEVICE_OBJECT,
) callconv(NTAPI) xboxdef.VOID;

pub const PDRIVER_DISMOUNTVOLUME = fn (
    DeviceObject: *_DEVICE_OBJECT,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub const PDRIVER_DISPATCH = fn (
    DeviceObject: *_DEVICE_OBJECT,
    Irp: *_IRP,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub const _DRIVER_OBJECT = extern struct {
    DriverStartIo: PDRIVER_STARTIO,
    DriverDeleteDevice: PDRIVER_DELETEDEVICE,
    DriverDismountVolume: PDRIVER_DISMOUNTVOLUME,
    MajorFunction: [0x0E]PDRIVER_DISPATCH,
};
pub const DRIVER_OBJECT = _DRIVER_OBJECT;
pub const PDRIVER_OBJECT = *_DRIVER_OBJECT;

pub const _DEVICE_OBJECT = extern struct {
    Type: xboxdef.CSHORT,
    Size: xboxdef.USHORT,
    ReferenceCount: xboxdef.LONG,
    DriverObject: PDRIVER_OBJECT,
    MountedOrSelfDevice: *_DEVICE_OBJECT,
    CurrentIrp: PIRP,
    Flags: xboxdef.ULONG,
    DeviceExtension: xboxdef.PVOID,
    DeviceType: xboxdef.UCHAR,
    StartIoFlags: xboxdef.UCHAR,
    StackSize: xboxdef.CCHAR,
    DeletePending: xboxdef.BOOLEAN,
    SectorSize: xboxdef.ULONG,
    AlignmentRequirement: xboxdef.ULONG,
    DeviceQueue: KDEVICE_QUEUE,
    DeviceLock: KEVENT,
    StartIoKey: xboxdef.ULONG,
};
pub const DEVICE_OBJECT = _DEVICE_OBJECT;
pub const PDEVICE_OBJECT = *_DEVICE_OBJECT;

pub const _OBJECT_DIRECTORY_INFORMATION = extern struct {
    Name: OBJECT_STRING,
    Type: xboxdef.ULONG,
};
pub const OBJECT_DIRECTORY_INFORMATION = _OBJECT_DIRECTORY_INFORMATION;
pub const POBJECT_DIRECTORY_INFORMATION = *_OBJECT_DIRECTORY_INFORMATION;

pub const _ERWLOCK = extern struct {
    LockCount: xboxdef.LONG,
    WritersWaitingCount: xboxdef.ULONG,
    ReadersWaitingCount: xboxdef.ULONG,
    ReadersEntryCount: xboxdef.ULONG,
    WriterEvent: KEVENT,
    ReaderSemaphore: KSEMAPHORE,
};
pub const ERWLOCK = _ERWLOCK;
pub const PERWLOCK = *_ERWLOCK;

pub const _XBOX_REFURB_INFO = extern struct {
    Signature: xboxdef.ULONG,
    PowerCycleCount: xboxdef.ULONG,
    FirstSetTime: xboxdef.LARGE_INTEGER,
};
pub const XBOX_REFURB_INFO = _XBOX_REFURB_INFO;

pub const _KFLOATING_SAVE = extern struct {
    ControlWord: xboxdef.ULONG,
    StatusWord: xboxdef.ULONG,
    ErrorOffset: xboxdef.ULONG,
    ErrorSelector: xboxdef.ULONG,
    DataOffset: xboxdef.ULONG,
    DataSelector: xboxdef.ULONG,
    Cr0NpxState: xboxdef.ULONG,
    Spare1: xboxdef.ULONG,
};
pub const KFLOATING_SAVE = _KFLOATING_SAVE;
pub const PKFLOATING_SAVE = *_KFLOATING_SAVE;

pub const _HARDWARE_PTE = extern struct {
    Valid: u1,
    Write: u1,
    Owner: u1,
    WriteThrough: u1,
    CacheDisable: u1,
    Accessed: u1,
    Dirty: u1,
    LargePage: u1,
    Global: u1,
    GuardOrEndOfAllocation: u1,
    PersistAllocation: u1,
    reserved: u1,
    PageFrameNumber: u20,
};
pub const HARDWARE_PTE = _HARDWARE_PTE;
pub const PHARDWARE_PTE = *_HARDWARE_PTE;

pub const PPS_APC_ROUTINE = fn (
    ApcArgument1: xboxdef.PVOID,
    ApcArgument2: xboxdef.PVOID,
    ApcArgument3: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.VOID;

pub const _KWAIT_REASON = enum(c_int) {
    Executive,
    FreePage,
    PageIn,
    PoolAllocation,
    DelayExecution,
    Suspended,
    UserRequest,
    WrExecutive,
    WrFreePage,
    WrPageIn,
    WrPoolAllocation,
    WrDelayExecution,
    WrSuspended,
    WrUserRequest,
    WrEventPair,
    WrQueue,
    WrLpcReceive,
    WrLpcReply,
    WrVirtualMemory,
    WrPageOut,
    WrRendezvous,
    WrFsCacheIn,
    WrFsCacheOut,
    Spare4,
    Spare5,
    Spare6,
    WrKernel,
    MaximumWaitReason,
};
pub const KWAIT_REASON = _KWAIT_REASON;

pub const _KMUTANT = extern struct {
    Header: DISPATCHER_HEADER,
    MutantListEntry: xboxdef.LIST_ENTRY,
    OwnerThread: PRKTHREAD,
    Abandoned: xboxdef.BOOLEAN,
};
pub const KMUTANT = _KMUTANT;
pub const PKMUTANT = *_KMUTANT;
pub const PRKMUTANT = *_KMUTANT; // TODO: Needs a restriced pointer somehow? See https://github.com/ziglang/zig/issues/23367

pub const _SHARE_ACCESS = extern struct {
    OpenCount: xboxdef.UCHAR,
    Readers: xboxdef.UCHAR,
    Writers: xboxdef.UCHAR,
    Deleters: xboxdef.UCHAR,
    SharedRead: xboxdef.UCHAR,
    SharedWrite: xboxdef.UCHAR,
    SharedDelete: xboxdef.UCHAR,
};
pub const SHARE_ACCESS = _SHARE_ACCESS;
pub const PSHARE_ACCESS = *_SHARE_ACCESS;

pub const PKSYNCHRONIZE_ROUTINE = fn (
    SynchronizeContext: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.BOOLEAN;

pub const PKRUNDOWN_ROUTINE = fn (
    Apc: PKAPC,
) callconv(NTAPI) xboxdef.VOID;

pub const PKNORMAL_ROUTINE = fn (
    NormalContext: xboxdef.PVOID,
    SystemArgument1: xboxdef.PVOID,
    SystemArgument2: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.VOID;

pub const PKKERNEL_ROUTINE = fn (
    Apc: PKAPC,
    NormalRoutine: *PKNORMAL_ROUTINE,
    NormalContext: *xboxdef.PVOID,
    SystemArgument1: *xboxdef.PVOID,
    SystemArgument2: *xboxdef.PVOID,
) callconv(NTAPI) xboxdef.VOID;

pub const PHAL_SHUTDOWN_NOTIFICATION = fn (
    ShutdownRegistration: *_HAL_SHUTDOWN_REGISTRATION,
) callconv(NTAPI) xboxdef.VOID;

/// Describes a shutdown notification, containing a function pointer and a priority
pub const _HAL_SHUTDOWN_REGISTRATION = extern struct {
    /// Function pointer which will be called on shutdown
    NotificationRoutine: PHAL_SHUTDOWN_NOTIFICATION,
    /// Priority of the notification.The higher the priority, the earliert the callback function is called
    Priority: xboxdef.LONG,
    /// Used to put the notifications into a linked list
    ListEntry: xboxdef.LIST_ENTRY,
};
pub const HAL_SHUTDOWN_REGISTRATION = _HAL_SHUTDOWN_REGISTRATION;
pub const PHAL_SHUTDOWN_REGISTRATION = *_HAL_SHUTDOWN_REGISTRATION;

pub const pfXcSHAInit = fn (pbSHAContext: xboxdef.PUCHAR) callconv(NTAPI) xboxdef.VOID;
pub const pfXcSHAUpdate = fn (pbSHAContext: xboxdef.PUCHAR, pbInput: xboxdef.PUCHAR, dwInputLength: xboxdef.ULONG) callconv(NTAPI) xboxdef.VOID;
pub const pfXcSHAFinal = fn (pbSHAContext: xboxdef.PUCHAR, pbDigest: xboxdef.PUCHAR) callconv(NTAPI) xboxdef.VOID;
pub const pfXcRC4Key = fn (pbKeyStruct: xboxdef.PUCHAR, dwKeyLength: xboxdef.ULONG, pbKey: xboxdef.PUCHAR) callconv(NTAPI) xboxdef.VOID;
pub const pfXcRC4Crypt = fn (pbKeyStruct: xboxdef.PUCHAR, dwInputLength: xboxdef.ULONG, pbInput: xboxdef.PUCHAR) callconv(NTAPI) xboxdef.VOID;
pub const pfXcHMAC = fn (pbKey: xboxdef.PUCHAR, dwKeyLength: xboxdef.ULONG, pbInput: xboxdef.PUCHAR, dwInputLength: xboxdef.ULONG, pbInput2: xboxdef.PUCHAR, dwInputLength2: xboxdef.ULONG, pbDigest: xboxdef.PUCHAR) callconv(NTAPI) xboxdef.VOID;
pub const pfXcPKEncPublic = fn (pbPubKey: xboxdef.PUCHAR, pbInput: xboxdef.PUCHAR, pbOutput: xboxdef.PUCHAR) callconv(NTAPI) xboxdef.ULONG;
pub const pfXcPKDecPrivate = fn (pbPrvKey: xboxdef.PUCHAR, pbInput: xboxdef.PUCHAR, pbOutput: xboxdef.PUCHAR) callconv(NTAPI) xboxdef.ULONG;
pub const pfXcPKGetKeyLen = fn (pbPubKey: xboxdef.PUCHAR) callconv(NTAPI) xboxdef.ULONG;
pub const pfXcVerifyPKCS1Signature = fn (pbSig: xboxdef.PUCHAR, pbPubKey: xboxdef.PUCHAR, pbDigest: xboxdef.PUCHAR) callconv(NTAPI) xboxdef.BOOLEAN;
pub const pfXcModExp = fn (pA: xboxdef.PULONG, pB: xboxdef.PULONG, pC: xboxdef.PULONG, pD: xboxdef.PULONG, dwN: xboxdef.ULONG) callconv(NTAPI) xboxdef.ULONG;
pub const pfXcDESKeyParity = fn (pbKey: xboxdef.PUCHAR, dwKeyLength: xboxdef.ULONG) callconv(NTAPI) xboxdef.VOID;
pub const pfXcKeyTable = fn (dwCipher: xboxdef.ULONG, pbKeyTable: xboxdef.PUCHAR, pbKey: xboxdef.PUCHAR) callconv(NTAPI) xboxdef.VOID;
pub const pfXcBlockCrypt = fn (dwCipher: xboxdef.ULONG, pbOutput: xboxdef.PUCHAR, pbInput: xboxdef.PUCHAR, pbKeyTable: xboxdef.PUCHAR, dwOp: xboxdef.ULONG) callconv(NTAPI) xboxdef.VOID;
pub const pfXcBlockCryptCBC = fn (dwCipher: xboxdef.ULONG, dwInputLength: xboxdef.ULONG, pbOutput: xboxdef.PUCHAR, pbInput: xboxdef.PUCHAR, pbKeyTable: xboxdef.PUCHAR, dwOp: xboxdef.ULONG, pbFeedback: xboxdef.PUCHAR) callconv(NTAPI) xboxdef.VOID;
pub const pfXcCryptService = fn (dwOp: xboxdef.ULONG, pArgs: xboxdef.PVOID) callconv(NTAPI) xboxdef.ULONG;

pub const _CRYPTO_VECTOR = extern struct {
    pXcSHAInit: pfXcSHAInit,
    pXcSHAUpdate: pfXcSHAUpdate,
    pXcSHAFinal: pfXcSHAFinal,
    pXcRC4Key: pfXcRC4Key,
    pXcRC4Crypt: pfXcRC4Crypt,
    pXcHMAC: pfXcHMAC,
    pXcPKEncPublic: pfXcPKEncPublic,
    pXcPKDecPrivate: pfXcPKDecPrivate,
    pXcPKGetKeyLen: pfXcPKGetKeyLen,
    pXcVerifyPKCS1Signature: pfXcVerifyPKCS1Signature,
    pXcModExp: pfXcModExp,
    pXcDESKeyParity: pfXcDESKeyParity,
    pXcKeyTable: pfXcKeyTable,
    pXcBlockCrypt: pfXcBlockCrypt,
    pXcBlockCryptCBC: pfXcBlockCryptCBC,
    pXcCryptService: pfXcCryptService,
};
pub const CRYPTO_VECTOR = _CRYPTO_VECTOR;
pub const PCRYPTO_VECTOR = *_CRYPTO_VECTOR;

pub const _OBJECT_HANDLE_TABLE = extern struct {
    HandleCount: xboxdef.LONG,
    FirstFreeTableEntry: xboxdef.LONG_PTR,
    NextHandleNeedingPool: xboxdef.HANDLE,
    RootTable: [*c][*c]xboxdef.PVOID,
    BuiltinRootTable: [8][*c]xboxdef.PVOID,
};
pub const OBJECT_HANDLE_TABLE = _OBJECT_HANDLE_TABLE;
pub const POBJECT_HANDLE_TABLE = *_OBJECT_HANDLE_TABLE;

pub const _MMPFNFREE = extern struct {
    PackedPfnFlink: xboxdef.USHORT,
    PackedPfnBlink: xboxdef.USHORT,
};
pub const MMPFNFREE = _MMPFNFREE;
pub const PMMPFNFREE = *_MMPFNFREE;

pub const _MMPFNREGION = extern struct {
    FreePagesByColor: [32]MMPFNFREE,
    AvailablePages: PFN_COUNT,
};
pub const MMPFNREGION = _MMPFNREGION;
pub const PMMPFNREGION = *_MMPFNREGION;

pub const _MMPTE = extern struct {
    Anonymous: extern union {
        Long: xboxdef.ULONG,
        Hard: HARDWARE_PTE,
        List: extern struct {
            Valid: u1,
            OneEntry: u1,
            NextEntry: u30,
        },
    },
};
pub const MMPTE = _MMPTE;
pub const PMMPTE = *_MMPTE;

pub const _MMPFN_BUSY_TYPE = enum(c_int) {
    MmUnknownUsage,
    MmStackUsage,
    MmVirtualPageTableUsage,
    MmSystemPageTableUsage,
    MmPoolUsage,
    MmVirtualMemoryUsage,
    MmSystemMemoryUsage,
    MmImageUsage,
    MmFsCacheUsage,
    MmContiguousUsage,
    MmDebuggerUsage,
    MmMaximumUsage,
};
pub const MMPFN_BUSY_TYPE = _MMPFN_BUSY_TYPE;

pub const PMMREMOVE_PAGE_ROUTINE = fn (
    BusyType: MMPFN_BUSY_TYPE,
    TargetPte: PMMPTE,
) callconv(FASTCALL) PFN_NUMBER;

pub const _MMPTERANGE = extern struct {
    HeadPte: MMPTE,
    FirstCommittedPte: PMMPTE,
    LastCommittedPte: PMMPTE,
    LastReservedPte: PMMPTE,
    AvailablePages: *PFN_COUNT,
    RemovePageRoutine: PMMREMOVE_PAGE_ROUTINE,
};
pub const MMPTERANGE = _MMPTERANGE;
pub const PMMPTERANGE = *_MMPTERANGE;

pub const _MMADDRESS_NODE = extern struct {
    StartingVpn: xboxdef.ULONG_PTR,
    EndingVpn: xboxdef.ULONG_PTR,
    Parent: *_MMADDRESS_NODE,
    LeftChild: *_MMADDRESS_NODE,
    RightChild: *_MMADDRESS_NODE,
};
pub const MMADDRESS_NODE = _MMADDRESS_NODE;
pub const PMMADDRESS_NODE = *_MMADDRESS_NODE;

pub const _MMGLOBALDATA = extern struct {
    RetailPfnRegion: PMMPFNREGION,
    SystemPteRange: PMMPTERANGE,
    AvailablePages: xboxdef.PULONG,
    AllocatedPagesByUsage: *PFN_COUNT,
    AddressSpaceLock: xboxdef.PRTL_CRITICAL_SECTION,
    VadRoot: *PMMADDRESS_NODE,
    VadHint: *PMMADDRESS_NODE,
    VadFreeHint: *PMMADDRESS_NODE,
};
pub const MMGLOBALDATA = _MMGLOBALDATA;
pub const PMMGLOBALDATA = *_MMGLOBALDATA;

pub const PIDE_INTERRUPT_ROUTINE = fn () callconv(NTAPI) xboxdef.VOID;

pub const PIDE_FINISHIO_ROUTINE = fn () callconv(NTAPI) xboxdef.VOID;

pub const PIDE_POLL_RESET_COMPLETE_ROUTINE = fn () callconv(NTAPI) xboxdef.BOOLEAN;

pub const PIDE_TIMEOUT_EXPIRED_ROUTINE = fn () callconv(NTAPI) xboxdef.VOID;

pub const PIDE_START_PACKET_ROUTINE = fn (
    DeviceObject: PDEVICE_OBJECT,
    Irp: PIRP,
) callconv(NTAPI) xboxdef.VOID;

pub const PIDE_START_NEXT_PACKET_ROUTINE = fn () callconv(NTAPI) xboxdef.VOID;

pub const _IDE_CHANNEL_OBJECT = extern struct {
    InterruptRoutine: PIDE_INTERRUPT_ROUTINE,
    FinishIoRoutine: PIDE_FINISHIO_ROUTINE,
    PollResetCompleteRoutine: PIDE_POLL_RESET_COMPLETE_ROUTINE,
    TimeoutExpiredRoutine: PIDE_TIMEOUT_EXPIRED_ROUTINE,
    StartPacketRoutine: PIDE_START_PACKET_ROUTINE,
    StartNextPacketRoutine: PIDE_START_NEXT_PACKET_ROUTINE,
    InterruptIrql: KIRQL,
    ExpectingBusMasterInterrupt: xboxdef.BOOLEAN,
    StartPacketBusy: xboxdef.BOOLEAN,
    StartPacketRequested: xboxdef.BOOLEAN,
    Timeout: xboxdef.UCHAR,
    IoRetries: xboxdef.UCHAR,
    MaximumIoRetries: xboxdef.UCHAR,
    CurrentIrp: PIRP,
    DeviceQueue: KDEVICE_QUEUE,
    PhysicalRegionDescriptorTablePhysical: xboxdef.ULONG,
    TimerDpc: KDPC,
    FinishDpc: KDPC,
    Timer: KTIMER,
    InterruptObject: KINTERRUPT,
};
pub const IDE_CHANNEL_OBJECT = _IDE_CHANNEL_OBJECT;
pub const PIDE_CHANNEL_OBJECT = *_IDE_CHANNEL_OBJECT;

pub const PKSYSTEM_ROUTINE = fn (
    StartRoutine: ?PKSTART_ROUTINE,
    StartContext: ?xboxdef.PVOID,
) callconv(NTAPI) xboxdef.VOID;

// KPRIORITY values
pub const LOW_PRIORITY = 0; // Lowest thread priority level
pub const LOW_REALTIME_PRIORITY = 16; // Lowest realtime priority level
pub const HIGH_PRIORITY = 31; // Highest thread priority level
pub const MAXIMUM_PRIORITY = 32; // Number of thread priority levels

/// Decrements the reference count of the section and unloads it if the reference count reaches zero.
///
/// @param `Section` The section to be unloaded.
///
/// @return `STATUS_SUCCESS` or the error.
pub extern fn XeUnloadSection(
    Section: xboxdef.PXBE_SECTION_HEADER,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern var XePublicKeyData: xboxdef.UCHAR[284];

/// Loads the supplied section into memory or increases its reference count if it's already loaded.
///
/// @param `Section` The section to be loaded.
///
/// @return `STATUS_SUCCESS` or the error.
pub extern fn XeLoadSection(
    Section: xboxdef.PXBE_SECTION_HEADER,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern var XeImageFileName: xboxdef.ANSI_STRING[1];

pub extern fn XcVerifyPKCS1Signature(
    pbSig: xboxdef.PUCHAR,
    pbPubKey: xboxdef.PUCHAR,
    pbDigest: xboxdef.PUCHAR,
) callconv(NTAPI) xboxdef.BOOLEAN;

pub extern fn XcUpdateCrypto(
    pNewVector: PCRYPTO_VECTOR,
    pROMVector: ?PCRYPTO_VECTOR,
) callconv(NTAPI) xboxdef.VOID;

/// Updates the internal state of the SHA-1 algorithm by hashing some input data.
///
/// @param `pbSHAContext` A pointer to the buffer holding the internal state of the algorithm
///
/// @param `pbInput` A pointer to the bytes which are to get hashed
///
/// @param `dwInputLength` The number of bytes in the buffer given in the pbInput parameter
pub extern fn XcSHAUpdate(
    pbSHAContext: xboxdef.PUCHAR,
    pbInput: xboxdef.PUCHAR,
    dwInputLength: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.VOID;

/// Initializes a buffer which will get used to generate a SHA-1 hash.
///
/// @param `pbSHAContext` A pointer to a 116-byte buffer to be used as storage for the internal state of the algorithm
pub extern fn XcSHAInit(
    pbSHAContext: xboxdef.PUCHAR,
) callconv(NTAPI) xboxdef.VOID;

/// Extracts the final SHA-1 hash from the buffer used to calculate the hash.
///
/// @param `pbSHAContext` A pointer to the buffer used to hold the internal state of the algorithm
///
/// @param `pbDigest` A pointer to a 20-byte buffer in which the hash will be stored
pub extern fn XcSHAFinal(
    pbSHAContext: xboxdef.PUCHAR,
    pbDigest: xboxdef.PUCHAR,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn XcRC4Key(
    pbKeyStruct: xboxdef.PUCHAR,
    dwKeyLength: xboxdef.ULONG,
    pbKey: xboxdef.PUCHAR,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn XcRC4Crypt(
    pbKeyStruct: xboxdef.PUCHAR,
    dwInputLength: xboxdef.ULONG,
    pbInput: xboxdef.PUCHAR,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn XcPKGetKeyLen(
    pbPubKey: xboxdef.PUCHAR,
) callconv(NTAPI) xboxdef.ULONG;

pub extern fn XcPKEncPublic(
    pbPubKey: xboxdef.PUCHAR,
    pbInput: xboxdef.PUCHAR,
    pbOutput: xboxdef.PUCHAR,
) callconv(NTAPI) xboxdef.ULONG;

pub extern fn XcPKDecPrivate(
    pbPrvKey: xboxdef.PUCHAR,
    pbInput: xboxdef.PUCHAR,
    pbOutput: xboxdef.PUCHAR,
) callconv(NTAPI) xboxdef.ULONG;

pub extern fn XcModExp(
    pA: xboxdef.PULONG,
    pB: xboxdef.PULONG,
    pC: xboxdef.PULONG,
    pD: xboxdef.PULONG,
    dwN: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.ULONG;

pub extern fn XcKeyTable(
    dwCipher: xboxdef.ULONG,
    pbKeyTable: xboxdef.PUCHAR,
    pbKey: xboxdef.PUCHAR,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn XcHMAC(
    pbKey: xboxdef.PUCHAR,
    dwKeyLength: xboxdef.ULONG,
    pbInput: xboxdef.PUCHAR,
    dwInputLength: xboxdef.ULONG,
    pbInput2: xboxdef.PUCHAR,
    dwInputLength2: xboxdef.ULONG,
    pbDigest: xboxdef.PUCHAR,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn XcDESKeyParity(
    pbKey: xboxdef.PUCHAR,
    dwKeyLength: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn XcCryptService(
    dwOp: xboxdef.ULONG,
    pArgs: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.ULONG;

pub extern fn XcBlockCryptCBC(
    dwCipher: xboxdef.ULONG,
    dwInputLength: xboxdef.ULONG,
    pbOutput: xboxdef.PUCHAR,
    pbInput: xboxdef.PUCHAR,
    pbKeyTable: xboxdef.PUCHAR,
    dwOp: xboxdef.ULONG,
    pbFeedback: xboxdef.PUCHAR,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn XcBlockCrypt(
    dwCipher: xboxdef.ULONG,
    pbOutput: xboxdef.PUCHAR,
    pbInput: xboxdef.PUCHAR,
    pbKeyTable: xboxdef.PUCHAR,
    dwOp: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.VOID;

pub extern var XboxSignatureKey: XBOX_KEY_DATA;

pub extern var XboxLANKey: XBOX_KEY_DATA;

pub extern var XboxKrnlVersion: XBOX_KRNL_VERSION;

pub extern var XboxHardwareInfo: XBOX_HARDWARE_INFO;

pub extern var XboxHDKey: XBOX_KEY_DATA;

pub extern var XboxEEPROMKey: XBOX_KEY_DATA;

pub extern var XboxAlternateSignatureKeys: [*c]XBOX_KEY_DATA;

/// Writes a number of USHORT values from the specified port address into a buffer.
///
/// @param `Port` The memory mapped I/O address of the port. E.g., `(PUSHORT)0x0cf8` for port 0x0CF8.
///
/// @param `Buffer` Pointer to a buffer containing the values to be written.
///
/// @param `Count` Specifies the number of values to be written to the port.
pub extern fn WRITE_PORT_BUFFER_USHORT(
    Port: xboxdef.PUSHORT,
    Buffer: xboxdef.PUSHORT,
    Count: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.VOID;

/// Writes a number of ULONG values from the specified port address into a buffer.
///
/// @param `Port` The memory mapped I/O address of the port. E.g., `(PULONG)0x0C_F8` for port 0x0C_F8.
///
/// @param `Buffer` Pointer to a buffer containing the values to be written.
///
/// @param `Count` Specifies the number of values to be written to the port.
pub extern fn WRITE_PORT_BUFFER_ULONG(
    Port: xboxdef.PULONG,
    Buffer: xboxdef.PULONG,
    Count: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.VOID;

/// Writes a number of UCHAR values from the specified port address into a buffer.
///
/// @param `Port` The memory mapped I/O address of the port. E.g., `(PUCHAR)0x0C_F8` for port 0x0C_F8.
///
/// @param `Buffer` Pointer to a buffer containing the values to be written.
///
/// @param `Count` Specifies the number of values to be written to the port.
pub extern fn WRITE_PORT_BUFFER_UCHAR(
    Port: xboxdef.PUCHAR,
    Buffer: xboxdef.PUCHAR,
    Count: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.VOID;

// Fills a specified memory area with a specified value
//
// @param `Destination` A pointer to the memory block which is to be filled
//
// @param `Length` The length of the memory block which is to be filled
//
// @param `Fill` The byte-value with which the memory block will be filled
pub extern fn RtlFillMemory(
    Destination: xboxdef.PVOID,
    Length: xboxdef.ULONG,
    Fill: xboxdef.UCHAR,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlMoveMemory(
    Destination: xboxdef.PVOID,
    Source: xboxdef.LPCVOID,
    Length: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.VOID;

/// Fills a specified memory area with zeroes
///
/// @param `Destination` A pointer to the memory block which is to be filled
///
/// @param `Length` The length of the memory block which is to be filled
pub extern fn RtlZeroMemory(
    Destination: xboxdef.PVOID,
    Length: xboxdef.SIZE_T,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlWalkFrameChain(
    Callers: [*c]xboxdef.PVOID,
    Count: xboxdef.ULONG,
    Flags: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.ULONG;

pub extern fn RtlVsprintf(
    [*c]xboxdef.CHAR,
    [*c]const xboxdef.CHAR,
    ...,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlVsnprintf(
    [*c]xboxdef.CHAR,
    xboxdef.SIZE_T,
    [*c]const xboxdef.CHAR,
    ...,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlUpperString(
    DestinationString: xboxdef.PSTRING,
    SourceString: xboxdef.PSTRING,
) callconv(NTAPI) xboxdef.VOID;

/// Returns the uppercased equivalent of a single character
///
/// @param `Character` The character which will be converted
///
/// @return The uppercased character
pub extern fn RtlUpperChar(
    Character: xboxdef.CHAR,
) callconv(NTAPI) xboxdef.CHAR;

pub extern fn RtlUpcaseUnicodeToMultiByteN(
    MultiByteString: xboxdef.PCHAR,
    MaxBytesInMultiByteString: xboxdef.ULONG,
    BytesInMultiByteString: xboxdef.PULONG,
    UnicodeString: xboxdef.PWSTR,
    BytesInUnicodeString: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn RtlUpcaseUnicodeString(
    DestinationString: PUNICODE_STRING,
    SourceString: PCUNICODE_STRING,
    AllocateDestinationString: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn RtlUpcaseUnicodeChar(
    SourceCharacter: xboxdef.WCHAR,
) callconv(NTAPI) xboxdef.WCHAR;

/// Initiates an unwind of procedure call frames
///
/// WARNING: THIS FUNCTION IS NOT SAFE TO CALL FROM C CODE! It does not follow the stdcall convention and trashes registers that are supposed to be callee-saved.
///
/// @param `TargetFrame` A pointer to the call frame that is the target of the unwind. If this parameter is NULL, the function performs an exit unwind.
///
/// @param `TargetIp` The continuation address of the unwind. If NULL, the function will return normally. This parameter is ignored if TargetFrame is NULL.
///
/// @param `ExceptionRecord` A pointer to an EXCEPTION_RECORD structure.
///
/// @param `ReturnValue` A value to be placed in the integer function return register before continuing execution.
pub extern fn RtlUnwind(
    TargetFrame: ?xboxdef.PVOID,
    TargetIp: ?xboxdef.PVOID,
    ExceptionRecord: ?xboxdef.PEXCEPTION_RECORD,
    ReturnValue: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlUnicodeToMultiByteSize(
    BytesInMultiByteString: xboxdef.PULONG,
    UnicodeString: xboxdef.PWSTR,
    BytesInUnicodeString: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn RtlUnicodeToMultiByteN(
    MultiByteString: xboxdef.PCHAR,
    MaxBytesInMultiByteString: xboxdef.ULONG,
    BytesInMultiByteString: xboxdef.PULONG,
    UnicodeString: xboxdef.PWSTR,
    BytesInUnicodeString: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn RtlUnicodeStringToInteger(
    String: xboxdef.PUNICODE_STRING,
    Base: xboxdef.ULONG,
    Value: xboxdef.PULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Converts the specified Unicode source string into an ANSI string.
///
/// @param `DestinationString` A pointer to an ANSI_STRING structure to hold the converted ANSI string.
///        If AllocateDestinationString is TRUE, the routine allocates a new buffer to hold the string data and
///        updates the Buffer member of DestinationString to point to the new buffer.
///        Otherwise, the routine uses the currently specified buffer to hold the string.
///
/// @param `SourceString` Pointer to the UNICODE_STRING structure that contains the source string to be converted to ANSI.
///
/// @param `AllocateDestinationString` If TRUE, this function allocates a buffer for the destination string which
///        must be deallocated by using RtlFreeAnsiString. If FALSE, the buffer specified in DestinationString will be used instead.
///
/// @return `STATUS_SUCCESS` if the conversion was successfull, otherwise an NTSTATUS error code.
pub extern fn RtlUnicodeStringToAnsiString(
    DestinationString: xboxdef.PSTRING,
    SourceString: PUNICODE_STRING,
    AllocateDestinationString: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Attempts to enter a critical section without blocking. If the call is successful, the calling thread takes ownership of the critical section.
///
/// @param `CriticalSection` A pointer to the critical section object.
///
/// @return If the critical section is successfully entered or the current thread already owns the critical section, the return value is nonzero.
/// If another thread already owns the critical section, the return value is zero.
pub extern fn RtlTryEnterCriticalSection(
    CriticalSection: xboxdef.PRTL_CRITICAL_SECTION,
) callconv(NTAPI) xboxdef.BOOLEAN;

/// The RtlTimeToTimeFields routine converts system time into a TIME_FIELDS structure
///
/// @param `Time` Pointer to a buffer containing the absolute system time as a large integer, accurate to 100-nanosecond resolution
///
/// @param `TimeFields` Pointer to a caller-allocated buffer, which must be at least sizeof(TIME_FIELDS), to contain the returned information
pub extern fn RtlTimeToTimeFields(
    Time: xboxdef.PLARGE_INTEGER,
    TimeFields: PTIME_FIELDS,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlTimeFieldsToTime(
    TimeFields: PTIME_FIELDS,
    Time: xboxdef.PLARGE_INTEGER,
) callconv(NTAPI) xboxdef.BOOLEAN;

pub extern fn RtlSprintf(
    [*c]xboxdef.CHAR,
    [*c]const xboxdef.CHAR,
    ...,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlSnprintf(
    [*c]xboxdef.CHAR,
    xboxdef.SIZE_T,
    [*c]const xboxdef.CHAR,
    ...,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlRip(
    ApiName: xboxdef.PVOID,
    Expression: xboxdef.PVOID,
    Message: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlRaiseStatus(
    Status: xboxdef.NTSTATUS,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlRaiseException(
    ExceptionRecord: xboxdef.PEXCEPTION_RECORD,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlNtStatusToDosError(
    Status: xboxdef.NTSTATUS,
) callconv(NTAPI) xboxdef.ULONG;

pub extern fn RtlMultiByteToUnicodeSize(
    BytesInUnicodeString: xboxdef.PULONG,
    MultiByteString: xboxdef.PCHAR,
    BytesInMultiByteString: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn RtlMultiByteToUnicodeN(
    UnicodeString: xboxdef.PWSTR,
    MaxBytesInUnicodeString: xboxdef.ULONG,
    BytesInUnicodeString: xboxdef.PULONG,
    MultiByteString: xboxdef.PCHAR,
    BytesInMultiByteString: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn RtlMapGenericMask(
    AccessMask: xboxdef.PACCESS_MASK,
    GenericMapping: xboxdef.PGENERIC_MAPPING,
) callconv(NTAPI) xboxdef.VOID;

/// Returns the lowercase equivalent of a single character
///
/// @param `Character` The character which will be converted
///
/// @return The lowercased character
pub extern fn RtlLowerChar(
    Character: xboxdef.CHAR,
) callconv(NTAPI) xboxdef.CHAR;

pub extern fn RtlLeaveCriticalSectionAndRegion(
    CriticalSection: xboxdef.PRTL_CRITICAL_SECTION,
) callconv(NTAPI) xboxdef.VOID;

/// Releases ownership of the specified critical section object.
///
/// @param `CriticalSection` A pointer to the critical section object.
pub extern fn RtlLeaveCriticalSection(
    CriticalSection: xboxdef.PRTL_CRITICAL_SECTION,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlIntegerToUnicodeString(
    Value: xboxdef.ULONG,
    Base: xboxdef.ULONG,
    String: PUNICODE_STRING,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn RtlIntegerToChar(
    Value: xboxdef.ULONG,
    Base: xboxdef.ULONG,
    OutputLength: xboxdef.LONG,
    String: xboxdef.PSZ,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Initializes a critical section object.
///
/// @param `CriticalSection` A pointer to the critical section object.
pub extern fn RtlInitializeCriticalSection(
    CriticalSection: xboxdef.PRTL_CRITICAL_SECTION,
) callconv(NTAPI) xboxdef.VOID;

pub inline fn RtlDeleteCriticalSection(CriticalSection: xboxdef.PRTL_CRITICAL_SECTION) void {
    _ = CriticalSection;
}

/// Initializes a counted string of Unicode characters. SourceString is used as the buffer, no memory is allocated.
///
/// @param `DestinationString` A pointer to the UNICODE_STRING structure to be initialized.
///
/// @param `SourceString` A pointer to a null-terminated character string which is used to
///        initialize the counted string structure pointed to by DestinationString.
pub extern fn RtlInitUnicodeString(
    DestinationString: PUNICODE_STRING,
    SourceString: PCWSTR,
) callconv(NTAPI) xboxdef.VOID;

/// Initializes a counted string of ANSI characters. SourceString is used as the buffer, no memory is allocated.
///
/// @param `DestinationString` A pointer to the ANSI_STRING structure to be initialized.
///
/// @param `SourceString` A pointer to a null-terminated character string which is used to initialize the
///        counted string structure pointed to by DestinationString.
pub extern fn RtlInitAnsiString(
    DestinationString: xboxdef.PANSI_STRING,
    SourceString: PCSZ,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlGetCallersAddress(
    CallersAddress: *xboxdef.PVOID,
    CallersCaller: *xboxdef.PVOID,
) callconv(NTAPI) xboxdef.VOID;

/// Frees the string buffer allocated by RtlAnsiStringToUnicodeString.
///
/// @param `UnicodeString` A pointer to a Unicode string whose buffer was previously allocated by RtlAnsiStringToUnicodeString.
pub extern fn RtlFreeUnicodeString(
    UnicodeString: PUNICODE_STRING,
) callconv(NTAPI) xboxdef.VOID;

/// Frees the string buffer allocated by RtlUnicodeStringToAnsiString.
///
/// @param `AnsiString` A pointer to an ANSI string whose buffer was previously allocated by RtlUnicodeStringToAnsiString.
pub extern fn RtlFreeAnsiString(
    AnsiString: xboxdef.PANSI_STRING,
) callconv(NTAPI) xboxdef.VOID;

/// Fills a specified memory area with repetitions of a ULONG value
///
/// @param `Destination` A pointer to the (ULONG-aligned) memory block which is to be filled
///
/// @param `Length` The length of the memory block which is to be filled
///
/// @param `Pattern` The ULONG-value with which the memory block will be filled
pub extern fn RtlFillMemoryUlong(
    Destination: xboxdef.PVOID,
    Length: xboxdef.SIZE_T,
    Pattern: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlExtendedMagicDivide(
    Dividend: xboxdef.LARGE_INTEGER,
    MagicDivisor: xboxdef.LARGE_INTEGER,
    ShiftCount: xboxdef.CCHAR,
) callconv(NTAPI) xboxdef.LARGE_INTEGER;

pub extern fn RtlExtendedLargeIntegerDivide(
    Dividend: xboxdef.LARGE_INTEGER,
    Divisor: xboxdef.ULONG,
    Remainder: xboxdef.PULONG,
) callconv(NTAPI) xboxdef.LARGE_INTEGER;

pub extern fn RtlExtendedIntegerMultiply(
    Multiplicand: xboxdef.LARGE_INTEGER,
    Multiplier: xboxdef.LONG,
) callconv(NTAPI) xboxdef.LARGE_INTEGER;

/// Compares two counted unicode strings (UNICODE_STRING objects, NOT C-style strings!) for equality
///
/// @param `String1` Pointer to the first unicode string
///
/// @param `String2` Pointer to the second unicode string
///
/// @param `CaseInSensitive` Whether to ignore the case of the strings or not
///
/// @return `TRUE` if the strings are equal, `FALSE` if not
pub extern fn RtlEqualUnicodeString(
    String1: *const UNICODE_STRING,
    String2: *const UNICODE_STRING,
    CaseInSensitive: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.BOOLEAN;

/// Compares two counted strings (ANSI_STRING objects, NOT C-style strings!) for equality
///
/// @param `String1` Pointer to the first string
///
/// @param `String2` Pointer to the second string
///
/// @param `CaseInSensitive` Whether to ignore the case of the strings or not
///
/// @return `TRUE` if the strings are equal, `FALSE` if not
pub extern fn RtlEqualString(
    String1: *const xboxdef.STRING,
    String2: *const xboxdef.STRING,
    CaseInSensitive: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.BOOLEAN;

pub extern fn RtlEnterCriticalSectionAndRegion(
    CriticalSection: xboxdef.PRTL_CRITICAL_SECTION,
) callconv(NTAPI) xboxdef.VOID;

/// Waits for ownership of the specified critical section object. The function returns when the calling thread is granted ownership.
///
/// @param `CriticalSection` A pointer to the critical section object.
pub extern fn RtlEnterCriticalSection(
    CriticalSection: xboxdef.PRTL_CRITICAL_SECTION,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlDowncaseUnicodeString(
    DestinationString: PUNICODE_STRING,
    SourceString: PUNICODE_STRING,
    AllocateDestinationString: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn RtlDowncaseUnicodeChar(
    SourceCharacter: xboxdef.WCHAR,
) callconv(NTAPI) xboxdef.WCHAR;

pub extern fn RtlCreateUnicodeString(
    DestinationString: PUNICODE_STRING,
    SourceString: PCWSTR,
) callconv(NTAPI) xboxdef.BOOLEAN;

pub extern fn RtlCopyUnicodeString(
    DestinationString: PUNICODE_STRING,
    SourceString: PUNICODE_STRING,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlCopyString(DestinationString: xboxdef.PSTRING, SourceString: xboxdef.PSTRING) callconv(NTAPI) xboxdef.VOID;

/// Compares two counted unicode strings (UNICODE_STRING objects, NOT C-style strings!)
///
/// @param `String1` Pointer to the first string
///
/// @param `String2` Pointer to the second string
///
/// @param `CaseInSensitive` Whether to ignore the case of the strings or not
///
/// @return Zero if the strings are equal, less than zero if String1 is less than String2, greater than zero if String1 is greater than String2
pub extern fn RtlCompareUnicodeString(
    String1: PUNICODE_STRING,
    String2: PUNICODE_STRING,
    CaseInSensitive: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.LONG;

/// Compares two counted strings (ANSI_STRING objects, NOT C-style strings!)
///
/// @param `String1` Pointer to the first string
///
/// @param `String2` Pointer to the second string
///
/// @param `CaseInSensitive` Whether to ignore the case of the strings or not
///
/// @return Zero if the strings are equal, less than zero if String1 is less than String2, greater than zero if String1 is greater than String2
pub extern fn RtlCompareString(
    String1: *const xboxdef.STRING,
    String2: *const xboxdef.STRING,
    CaseInSensitive: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.LONG;

/// Returns how many bytes in a block of memory match a specified pattern.
///
/// @param `Source` Pointer to a block of memory. Must be aligned on a ULONG boundary.
///
/// @param `Length` Number of bytes over which the comparison should be done. Must be a multiple of sizeof(ULONG).
///
/// @param `Pattern` Pattern to be compared byte by byte, repeatedly, through the specified memory range.
///
/// @return The number of bytes that were compared and found to be equal.
///         If all bytes compare as equal, the "Length"-value is returned.
///         If "Source" is not ULONG-aligned or if "Length" is not a multiple of sizeof(ULONG), zero is returned.
pub extern fn RtlCompareMemoryUlong(
    Source: xboxdef.PVOID,
    Length: xboxdef.SIZE_T,
    Pattern: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.SIZE_T;

/// Compares two blocks of memory and returns the number of bytes that match.
///
/// @param `Source1` A pointer to the first block of memory.
///
/// @param `Source2` A pointer to the second block of memory.
///
/// @param `Length` The number of bytes to compare.
///
/// @return The number of bytes in the two blocks that match. If all bytes match, the "Length"-value is returned.
pub extern fn RtlCompareMemory(
    Source1: xboxdef.LPCVOID,
    Source2: xboxdef.LPCVOID,
    Length: xboxdef.SIZE_T,
) callconv(NTAPI) xboxdef.SIZE_T;

/// Converts a single-byte character string (C-style string, NOT an ANSI_STRING object!) to an integer value
///
/// @param `String` Pointer to a null-terminated single-byte string
///
/// @param `Base` Specifies the base (decimal, binary, octal, hexadecimal).
///        If not given, the routine looks for prefixes in the given string (0x, 0o, 0b), default is decimal.
/// @param `Value` Pointer to a ULONG variable where the converted value will be stored
///
/// @return `STATUS_SUCCESS` if the string was successfully converted, `STATUS_INVALID_PARAMETER` otherwise
pub extern fn RtlCharToInteger(
    String: xboxdef.PCSZ,
    Base: ?xboxdef.ULONG,
    Value: xboxdef.PULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn RtlCaptureStackBackTrace(
    FramesToSkip: xboxdef.ULONG,
    FramesToCapture: xboxdef.ULONG,
    BackTrace: [*c]xboxdef.PVOID,
    BackTraceHash: xboxdef.PULONG,
) callconv(NTAPI) xboxdef.USHORT;

pub extern fn RtlCaptureContext(
    ContextRecord: xboxdef.PCONTEXT,
) callconv(NTAPI) xboxdef.VOID;

/// Reports a failed assertion to an attached debugger.
///
/// @param `FailedAssertion` A string containing the expression that made the assertion fail
///
/// @param `FileName` A string containing the name of the file containing the assertion
///
/// @param `LineNumber` The linenumber containing the assertion
///
/// @param `Message` An optional message (will also be shown by the debugger)
pub extern fn RtlAssert(
    FailedAssertion: xboxdef.PVOID,
    FileName: xboxdef.PVOID,
    LineNumber: xboxdef.ULONG,
    Message: ?xboxdef.PCHAR,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn RtlAppendUnicodeToString(
    Destination: PUNICODE_STRING,
    Sourc: PCWSTR,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn RtlAppendUnicodeStringToString(
    Destination: PUNICODE_STRING,
    Source: PUNICODE_STRING,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn RtlAppendStringToString(
    Destination: xboxdef.PSTRING,
    Source: xboxdef.PSTRING,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Converts the specified ANSI source string into a Unicode string.
///
/// @param `DestinationString` A pointer to a UNICODE_STRING structure to hold the converted Unicode string.
///        If AllocateDestinationString is TRUE, the routine allocates a new buffer to hold the string data and
///        updates the Buffer member of DestinationString to point to the new buffer.
///        Otherwise, the routine uses the currently specified buffer to hold the string.
///
/// @param `SourceString` Pointer to the ANSI_STRING structure that contains the source string to be converted to Unicode.
///
/// @param `AllocateDestinationString` If `TRUE`, this function allocates a buffer for the destination string which
///        must be deallocated by using RtlFreeUnicodeString. If `FALSE`, the buffer specified in DestinationString will be used instead.
///
/// @return `STATUS_SUCCESS` if the conversion was successfull, otherwise an NTSTATUS error code.
pub extern fn RtlAnsiStringToUnicodeString(
    DestinationString: PUNICODE_STRING,
    SourceString: xboxdef.PSTRING,
    AllocateDestinationString: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Reads a number of USHORT values from the specified port address into a buffer.
///
/// @param `Port` The memory mapped I/O address of the port. E.g., `(PUSHORT)0x0C_F8` for port 0x0C_F8.
///
/// @param `Buffer` Pointer to a buffer into which the array of values will be written.
///
/// @param `Count` Specifies the number of values to be read from the port and written into the buffer.
pub extern fn READ_PORT_BUFFER_USHORT(
    Port: xboxdef.PUSHORT,
    Buffer: xboxdef.PUSHORT,
    Count: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.VOID;

/// Reads a number of ULONG values from the specified port address into a buffer.
///
/// @param `Port` The memory mapped I/O address of the port. E.g., `(PULONG)0x0C_F8` for port 0x0C_F8.
///
/// @param `Buffer` Pointer to a buffer into which the array of values will be written.
///
/// @param `Count` Specifies the number of values to be read from the port and written into the buffer.
pub extern fn READ_PORT_BUFFER_ULONG(
    Port: xboxdef.PULONG,
    Buffer: xboxdef.PULONG,
    Count: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.VOID;

/// Reads a number of UCHAR values from the specified port address into a buffer.
///
/// @param `Port` The memory mapped I/O address of the port. E.g., `(PUCHAR)0x0C_F8` for port 0x0C_F8.
///
/// @param `Buffer` Pointer to a buffer into which the array of values will be written.
///
/// @param `Count` Specifies the number of values to be read from the port and written into the buffer.
pub extern fn READ_PORT_BUFFER_UCHAR(
    Port: xboxdef.PUCHAR,
    Buffer: xboxdef.PUCHAR,
    Count: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.VOID;

pub extern var PsThreadObjectType: OBJECT_TYPE;

pub extern fn PsTerminateSystemThread(
    ExitStatus: xboxdef.NTSTATUS,
) callconv(NTAPI) noreturn;

pub extern fn PsSetCreateThreadNotifyRoutine(
    NotifyRoutine: PCREATE_THREAD_NOTIFY_ROUTINE,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn PsQueryStatistics(
    ProcessStatistics: PPS_STATISTICS,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn PsCreateSystemThreadEx(
    ThreadHandle: xboxdef.PHANDLE,
    ThreadExtensionSize: xboxdef.SIZE_T,
    KernelStackSize: xboxdef.SIZE_T,
    TlsDataSize: xboxdef.SIZE_T,
    ThreadId: ?xboxdef.PHANDLE,
    StartRoutine: PKSTART_ROUTINE,
    StartContext: xboxdef.PVOID,
    CreateSuspended: xboxdef.BOOLEAN,
    DebuggerThread: xboxdef.BOOLEAN,
    SystemRoutine: ?PKSYSTEM_ROUTINE,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn PsCreateSystemThread(
    ThreadHandle: xboxdef.PHANDLE,
    ThreadId: ?xboxdef.PHANDLE,
    StartRoutine: PKSTART_ROUTINE,
    StartContext: xboxdef.PVOID,
    DebuggerThread: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Initialize the ethernet PHY
///
/// @param `forceReset` Whether to force a reset
///
/// @param `param` Optional parameters (seemingly unused)
///
/// @return Status code (zero on success)
pub extern fn PhyInitialize(
    forceReset: xboxdef.BOOLEAN,
    param: ?xboxdef.PVOID,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub const XNET_ETHERNET_LINK_ACTIVE = 0x01;
pub const XNET_ETHERNET_LINK_100MBPS = 0x02;
pub const XNET_ETHERNET_LINK_10MBPS = 0x04;
pub const XNET_ETHERNET_LINK_FULL_DUPLEX = 0x08;
pub const XNET_ETHERNET_LINK_HALF_DUPLEX = 0x10;

/// Returns link status information either from NIC registers or from the last value cached by the kernel
///
/// @param `update` If `FALSE`, the kernel returns the cached value, otherwise the hardware is polled and the cached value updated
///
/// @return Flags describing the status of the NIC. See `XNET_ETHERNET_LINK` bit masks.
pub extern fn PhyGetLinkState(
    update: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.DWORD;

pub extern var ObpObjectHandleTable: OBJECT_HANDLE_TABLE;
pub extern var ObSymbolicLinkObjectType: OBJECT_TYPE;

pub extern fn ObReferenceObjectByPointer(
    Object: xboxdef.PVOID,
    ObjectType: POBJECT_TYPE,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn ObReferenceObjectByName(
    ObjectName: POBJECT_STRING,
    Attributes: xboxdef.ULONG,
    ObjectType: POBJECT_TYPE,
    ParseContext: ?xboxdef.PVOID,
    Object: *xboxdef.PVOID,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn ObReferenceObjectByHandle(
    Handle: xboxdef.HANDLE,
    ObjectType: ?POBJECT_TYPE,
    ReturnedObject: *xboxdef.PVOID,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn ObOpenObjectByPointer(
    Object: xboxdef.PVOID,
    ObjectType: POBJECT_TYPE,
    Handle: xboxdef.PHANDLE,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn ObOpenObjectByName(
    ObjectAttributes: *const OBJECT_ATTRIBUTES,
    ObjectType: POBJECT_TYPE,
    ParseContext: ?xboxdef.PVOID,
    Handle: xboxdef.PHANDLE,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn ObMakeTemporaryObject(
    Object: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn ObInsertObject(
    Object: xboxdef.PVOID,
    ObjectAttributes: ?POBJECT_ATTRIBUTES,
    ObjectPointerBias: xboxdef.ULONG,
    Handle: xboxdef.PHANDLE,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern var ObDirectoryObjectType: OBJECT_TYPE;

pub extern fn ObCreateObject(
    ObjectType: POBJECT_TYPE,
    ObjectAttributes: ?POBJECT_ATTRIBUTES,
    ObjectBodySize: xboxdef.ULONG,
    Object: *xboxdef.PVOID,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Yields execution of the current thread for one timeslice
pub extern fn NtYieldExecution() callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtWriteFileGather(
    FileHandle: xboxdef.HANDLE,
    Event: ?xboxdef.HANDLE,
    ApcRoutine: ?*const PIO_APC_ROUTINE,
    ApcContext: ?xboxdef.PVOID,
    IoStatusBlock: PIO_STATUS_BLOCK,
    SegmentArray: PFILE_SEGMENT_ELEMENT,
    Length: xboxdef.ULONG,
    ByteOffset: ?*const xboxdef.LARGE_INTEGER,
) callconv(NTAPI) xboxdef.BOOLEAN;

pub extern fn NtWriteFile(
    FileHandle: xboxdef.HANDLE,
    Event: ?xboxdef.HANDLE,
    ApcRoutine: ?*const PIO_APC_ROUTINE,
    ApcContext: ?xboxdef.PVOID,
    IoStatusBlock: PIO_STATUS_BLOCK,
    Buffer: xboxdef.LPCVOID,
    Length: xboxdef.ULONG,
    ByteOffset: ?*const xboxdef.LARGE_INTEGER,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Waits until the specified object attains a state of "signaled". Also see NtWaitForSingleObject.
///
/// @param `Handle` The handle to the wait object.
///
/// @param `WaitMode` Specifies the processor mode in which the wait is to occur.
///
/// @param `Alertable` Specifies whether an alert can be delivered when the object is waiting (watch out for the STATUS_ALERTED return value).
///
/// @param `Timeout` An optional (set to NULL when not used) pointer to an absolute or relative time over which the wait is to occur.
///        If an explicit timeout value of zero is specified, then no wait occurs if the wait cannot be satisfied immediately.
///
/// @return The wait completion status, which can be
/// - `STATUS_SUCCESS` (specified object satisifed the wait),
/// - `STATUS_TIMEOUT` (a timeout occured), STATUS_ALERTED (the wait was aborted to deliver an alert to the current thread) or
/// - `STATUS_USER_APC` (the wait was aborted to deliver a user APC to the current thread).
pub extern fn NtWaitForSingleObjectEx(
    Handle: xboxdef.HANDLE,
    WaitMode: KPROCESSOR_MODE,
    Alertable: xboxdef.BOOLEAN,
    Timeout: ?xboxdef.PLARGE_INTEGER,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Waits until the specified object attains a state of "signaled".
///
/// When used with a semaphore, the semaphore gets decremented and the threaad continues, or
/// the thread waits until the semaphore-count becomes non-zero and then decrements the seamphore count and continues.
///
/// @param `Handle` The handle to the wait object.
///
/// @param `Alertable` Specifies whether an alert can be delivered when the object is waiting (watch out for the STATUS_ALERTED return value).
///
/// @param `Timeout` An optional (set to NULL when not used) pointer to an absolute or relative time over which the wait is to occur.
///        If an explicit timeout value of zero is specified, then no wait occurs if the wait cannot be satisfied immediately.
///
/// @return The wait completion status, which can be
/// - `STATUS_SUCCESS` (specified object satisifed the wait),
/// - `STATUS_TIMEOUT` (a timeout occured),
/// - `STATUS_ALERTED` (the wait was aborted to deliver an alert to the current thread) or
/// - `STATUS_USER_APC` (the wait was aborted to deliver a user APC to the current thread).
pub extern fn NtWaitForSingleObject(
    Handle: xboxdef.HANDLE,
    Alertable: xboxdef.BOOLEAN,
    Timeout: ?xboxdef.PLARGE_INTEGER,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Waits until the specified objects attain a state of "signaled".
///
/// The wait can be specified to either wait until all objects are signaled or until one of the objects is signaled. Also see NtWaitForSingleObject.
///
/// @param `Count` Specifies the number of objects that are to be waited on.
///
/// @param `Handles` An array of handles to wait objects.
///
/// @param `WaitType` Specifies the type of wait to perform (WaitAll or WaitAny)
///
/// @param `WaitMode` Specifies the processor mode in which the wait is to occur.
///
/// @param `Alertable` Specifies whether an alert can be delivered when the object is waiting (watch out for the STATUS_ALERTED return value).
///
/// @param `Timeout` An optional (set to NULL when not used) pointer to an absolute or relative time over which the wait is to occur.
///        If an explicit timeout value of zero is specified, then no wait occurs if the wait cannot be satisfied immediately.
///
/// @return The wait completion status. The index of the object in the array that satisfied the wait is returned. Can also be
/// - `STATUS_TIMEOUT` (a timeout occured),
/// - `STATUS_ALERTED` (the wait was aborted to deliver an alert to the current thread) or
/// - `STATUS_USER_APC` (the wait was aborted to deliver a user APC to the current thread).
pub extern fn NtWaitForMultipleObjectsEx(
    Count: xboxdef.ULONG,
    Handles: [*c]const xboxdef.HANDLE,
    WaitType: WAIT_TYPE,
    WaitMode: KPROCESSOR_MODE,
    Alertable: xboxdef.BOOLEAN,
    Timeout: ?xboxdef.PLARGE_INTEGER,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtUserIoApcDispatcher(
    ApcContext: xboxdef.PVOID,
    IoStatusBlock: PIO_STATUS_BLOCK,
    Reserved: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.VOID;

/// Suspends the target thread and optionally returns the previous suspend count.
///
/// @param `ThreadHandle` The handle of the thread object to suspend.
///
/// @param `PreviousSuspendCount` Optional pointer to a variable that receives the thread's previous suspend count.
///
/// @return The status of the operation.
pub extern fn NtSuspendThread(
    ThreadHandle: xboxdef.HANDLE,
    PreviousSuspendCount: ?xboxdef.PULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtSignalAndWaitForSingleObjectEx(
    SignalHandle: xboxdef.HANDLE,
    WaitHandle: xboxdef.HANDLE,
    WaitMode: KPROCESSOR_MODE,
    Alertable: xboxdef.BOOLEAN,
    Timeout: ?xboxdef.PLARGE_INTEGER,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtSetTimerEx(
    TimerHandle: xboxdef.HANDLE,
    DueTime: xboxdef.PLARGE_INTEGER,
    TimerApcRoutine: ?PTIMER_APC_ROUTINE,
    ApcMode: KPROCESSOR_MODE,
    TimerContext: ?xboxdef.PVOID,
    ResumeTimer: xboxdef.BOOLEAN,
    Period: ?xboxdef.LONG,
    PreviousState: ?xboxdef.PBOOLEAN,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Sets the current system time and optionally returns the old system time.
///
/// @param `SystemTime` A pointer to the new value for the system time.
///
/// @param `PreviousTime` An optional pointer to a variable that receives the previous system time.
///
/// @return The status of the operation.
/// - `STATUS_SUCCESS` when successfull,
/// - `STATUS_ACCESS_VIOLATION` if the input parameter cannot be read or the output cannot be written,
/// - `STATUS_INVALID_PARAMETER` if the input time is negative.
pub extern fn NtSetSystemTime(
    SystemTime: xboxdef.PLARGE_INTEGER,
    PreviousTime: ?xboxdef.PLARGE_INTEGER,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtSetIoCompletion(
    IoCompletionHandle: xboxdef.HANDLE,
    KeyContext: xboxdef.PVOID,
    ApcContext: xboxdef.PVOID,
    IoStatus: xboxdef.NTSTATUS,
    IoStatusInformation: xboxdef.ULONG_PTR,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtSetInformationFile(
    FileHandle: xboxdef.HANDLE,
    IoStatusBlock: PIO_STATUS_BLOCK,
    FileInformation: xboxdef.PVOID,
    Length: xboxdef.ULONG,
    FileInformationClass: FILE_INFORMATION_CLASS,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Sets an event to the signaled state.
///
/// @param `EventHandle` A HANDLE to the event object to be set.
///
/// @param `PreviousState` An optional pointer to a variable that will get set to the previous state of the event object.
///
/// @return `STATUS_SUCCESS` on success, an NTSTATUS error code otherwise.
pub extern fn NtSetEvent(
    EventHandle: xboxdef.HANDLE,
    PreviousState: ?xboxdef.PLONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Resumes the target thread (see NtSuspendThread) and optionally returns the previous suspend count.
///
/// @param `ThreadHandle` The handle of the thread object to resume.
///
/// @param `PreviousSuspendCount` Optional pointer to a variable that receives the thread's previous suspend count.
///
/// @return The status of the operation.
pub extern fn NtResumeThread(
    ThreadHandle: xboxdef.HANDLE,
    PreviousSuspendCount: ?xboxdef.PULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtRemoveIoCompletion(
    IoCompletionHandle: xboxdef.HANDLE,
    KeyContext: *xboxdef.PVOID,
    ApcContext: *xboxdef.PVOID,
    IoStatusBlock: PIO_STATUS_BLOCK,
    Timeout: xboxdef.PLARGE_INTEGER,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Releases a semaphore object.
///
/// When the semaphore is released, the current count of the semaphore is incremented by "ReleaseCount".
/// Any threads that are waiting for the semaphore are examined to see if the current semaphore value is sufficient to satisfy their wait.
/// If the value specified by "ReleaseCount" would cause the maximum count for the semaphore to be exceeded, then
/// the count for the semaphore is not affected and an error status is returned.
///
/// @param `SemaphoreHandle` An open handle to a semaphore object.
///
/// @param `ReleaseCount` The release count for the semaphore.
///        The count must be greater than zero and less than the maximum value specified for the semaphore.
///
/// @param `PreviousCount` An optional pointer to a variable that receives the previous count for the semaphore.
///
/// @return The status of the release operation, `STATUS_SUCCESS` on success.
pub extern fn NtReleaseSemaphore(
    SemaphoreHandle: xboxdef.HANDLE,
    ReleaseCount: xboxdef.LONG,
    PreviousCount: ?xboxdef.PLONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Releases a mutant object (mutex).
///
/// @param `MutantHandle` The handle to the mutant object.
///
/// @param `PreviousCount` An optional pointer to a variable that receives the previous mutant count.
///
/// @return The status of the operation.
pub extern fn NtReleaseMutant(
    MutantHandle: xboxdef.HANDLE,
    PreviousCount: ?xboxdef.PLONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtReadFileScatter(
    FileHandle: xboxdef.HANDLE,
    Event: ?xboxdef.HANDLE,
    ApcRoutine: ?*const PIO_APC_ROUTINE,
    ApcContext: ?xboxdef.PVOID,
    IoStatusBlock: PIO_STATUS_BLOCK,
    SegmentArray: PFILE_SEGMENT_ELEMENT,
    Length: xboxdef.ULONG,
    ByteOffset: ?*const xboxdef.LARGE_INTEGER,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtReadFile(
    FileHandle: xboxdef.HANDLE,
    Event: ?xboxdef.HANDLE,
    ApcRoutine: ?*const PIO_APC_ROUTINE,
    ApcContext: ?xboxdef.PVOID,
    IoStatusBlock: PIO_STATUS_BLOCK,
    Buffer: xboxdef.PVOID,
    Length: xboxdef.ULONG,
    ByteOffset: ?*const xboxdef.LARGE_INTEGER,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtQueueApcThread(
    ThreadHandle: xboxdef.HANDLE,
    ApcRoutine: PPS_APC_ROUTINE,
    ApcArgument1: xboxdef.PVOID,
    ApcArgument2: xboxdef.PVOID,
    ApcArgument3: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtQueryVolumeInformationFile(
    FileHandle: xboxdef.HANDLE,
    IoStatusBlock: PIO_STATUS_BLOCK,
    FsInformation: xboxdef.PVOID,
    Length: xboxdef.ULONG,
    FsInformationClass: FS_INFORMATION_CLASS,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtQueryVirtualMemory(
    BaseAddress: xboxdef.PVOID,
    MemoryInformation: PMEMORY_BASIC_INFORMATION,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtQueryTimer(
    TimerHandle: xboxdef.HANDLE,
    TimerInformation: PTIMER_BASIC_INFORMATION,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtQuerySymbolicLinkObject(
    LinkHandle: xboxdef.HANDLE,
    LinkTarget: POBJECT_STRING,
    ReturnedLength: ?xboxdef.PULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Queries the state of a semaphore object.
///
/// @param `SemaphoreHandle` An open handle to a semaphore object.
///
/// @param `SemaphoreInformation` A pointer to a buffer (SEMAPHORE_BASIC_INFORMATION-structure) that receives the queried information.
///
/// @return The status code of the query operation, `STATUS_SUCCESS` on success.
pub extern fn NtQuerySemaphore(
    SemaphoreHandle: xboxdef.HANDLE,
    SemaphoreInformation: PSEMAPHORE_BASIC_INFORMATION,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Queries the state of a mutant object.
///
/// @param `MutantHandle` A handle to a mutant object.
///
/// @param `MutantInformation` A pointer to a `MUTANT_BASIC_INFORMATION`-structure that receives the requested information.
///
/// @return The status of the operation.
pub extern fn NtQueryMutant(
    MutantHandle: xboxdef.HANDLE,
    MutantInformation: PMUTANT_BASIC_INFORMATION,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtQueryIoCompletion(
    IoCompletionHandle: xboxdef.HANDLE,
    IoCompletionInformation: PIO_COMPLETION_BASIC_INFORMATION,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtQueryInformationFile(
    FileHandle: xboxdef.HANDLE,
    IoStatusBlock: PIO_STATUS_BLOCK,
    FileInformation: xboxdef.PVOID,
    Length: xboxdef.ULONG,
    FileInformationClass: FILE_INFORMATION_CLASS,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtQueryFullAttributesFile(
    ObjectAttributes: *const OBJECT_ATTRIBUTES,
    FileInformation: PFILE_NETWORK_OPEN_INFORMATION,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtQueryEvent(
    EventHandle: xboxdef.HANDLE,
    EventInformation: PEVENT_BASIC_INFORMATION,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtQueryDirectoryObject(
    DirectoryHandle: xboxdef.HANDLE,
    Buffer: xboxdef.PVOID,
    Length: xboxdef.ULONG,
    RestartScan: xboxdef.BOOLEAN,
    Context: xboxdef.PULONG,
    ReturnLength: ?xboxdef.PULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtQueryDirectoryFile(
    FileHandle: xboxdef.HANDLE,
    Event: ?xboxdef.HANDLE,
    ApcRoutine: ?*const PIO_APC_ROUTINE,
    ApcContext: ?xboxdef.PVOID,
    IoStatusBlock: PIO_STATUS_BLOCK,
    FileInformation: xboxdef.PVOID,
    Length: xboxdef.ULONG,
    FileInformationClass: FILE_INFORMATION_CLASS,
    FileName: ?POBJECT_STRING,
    RestartScan: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Sets an event to the signaled state, and immediately resets it to the non-signaled state after waking all waiting threads.
///
/// @param `EventHandle` A HANDLE to the event object to be pulsed.
///
/// @param `PreviousState` An optional pointer to a variable that will get set to the previous state of the event object.
///
/// @return STATUS_SUCCESS on success, an NTSTATUS error code otherwise.
pub extern fn NtPulseEvent(
    EventHandle: xboxdef.HANDLE,
    PreviousState: ?xboxdef.PLONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtProtectVirtualMemory(
    BaseAddress: *xboxdef.PVOID,
    RegionSize: xboxdef.PSIZE_T,
    NewProtect: xboxdef.ULONG,
    OldProtect: xboxdef.PULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtOpenSymbolicLinkObject(
    LinkHandle: xboxdef.PHANDLE,
    ObjectAttributes: *const OBJECT_ATTRIBUTES,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtOpenFile(
    FileHandle: xboxdef.PHANDLE,
    DesiredAccess: ACCESS_MASK,
    ObjectAttributes: *const OBJECT_ATTRIBUTES,
    IoStatusBlock: PIO_STATUS_BLOCK,
    ShareAccess: xboxdef.ULONG,
    OpenOptions: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtOpenDirectoryObject(
    DirectoryHandle: xboxdef.PHANDLE,
    ObjectAttributes: *const OBJECT_ATTRIBUTES,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub inline fn CTL_CODE(DeviceType: u32, Function: u32, Method: u32, Access: u32) u32 {
    return (((DeviceType) << 16) | ((Access) << 14) | ((Function) << 2) | (Method));
}
pub const METHOD_BUFFERED = 0;
pub const METHOD_IN_DIRECT = 1;
pub const METHOD_OUT_DIRECT = 2;
pub const METHOD_NEITHER = 3;

pub const FILE_ANY_ACCESS = 0x00_00;
pub const FILE_READ_ACCESS = 0x00_01;
pub const FILE_WRITE_ACCESS = 0x00_02;

pub const FILE_DEVICE_FILE_SYSTEM = 0x00_00_00_09;
pub const FSCTL_DISMOUNT_VOLUME = CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 8, METHOD_BUFFERED, FILE_ANY_ACCESS);

pub extern fn NtFsControlFile(
    FileHandle: xboxdef.HANDLE,
    Event: ?xboxdef.HANDLE,
    ApcRoutine: ?*const PIO_APC_ROUTINE,
    ApcContext: ?xboxdef.PVOID,
    IoStatusBlock: PIO_STATUS_BLOCK,
    FsControlCode: xboxdef.ULONG,
    InputBuffer: ?xboxdef.PVOID,
    InputBufferLength: xboxdef.ULONG,
    OutputBuffer: ?xboxdef.PVOID,
    OutputBufferLength: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtFreeVirtualMemory(
    BaseAddress: *xboxdef.PVOID,
    RegionSize: xboxdef.PSIZE_T,
    FreeType: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtFlushBuffersFile(
    FileHandle: xboxdef.HANDLE,
    IoStatusBlock: PIO_STATUS_BLOCK,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtDuplicateObject(
    SourceHandle: xboxdef.HANDLE,
    TargetHandle: xboxdef.PHANDLE,
    Options: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub const _MEDIA_TYPE = enum(c_int) {
    Unknown,
    F5_1Pt2_512,
    F3_1Pt44_512,
    F3_2Pt88_512,
    F3_20Pt8_512,
    F3_720_512,
    F5_360_512,
    F5_320_512,
    F5_320_1024,
    F5_180_512,
    F5_160_512,
    RemovableMedia,
    FixedMedia,
    F3_120M_512,
    F3_640_512,
    F5_640_512,
    F5_720_512,
    F3_1Pt2_512,
    F3_1Pt23_1024,
    F5_1Pt23_1024,
    F3_128Mb_512,
    F3_230Mb_512,
    F8_256_128,
    F3_200Mb_512,
    F3_240M_512,
    F3_32M_512,
};
pub const MEDIA_TYPE = _MEDIA_TYPE;
pub const PMEDIA_TYPE = _MEDIA_TYPE;

pub const _DISK_GEOMETRY = extern struct {
    Cylinders: xboxdef.LARGE_INTEGER,
    MediaType: MEDIA_TYPE,
    TracksPerCylinder: xboxdef.DWORD,
    SectorsPerTrack: xboxdef.DWORD,
    BytesPerSector: xboxdef.DWORD,
};
pub const DISK_GEOMETRY = _DISK_GEOMETRY;
pub const PDISK_GEOMETRY = *_DISK_GEOMETRY;

pub const _PARTITION_INFORMATION = extern struct {
    StartingOffset: xboxdef.LARGE_INTEGER,
    PartitionLength: xboxdef.LARGE_INTEGER,
    HiddenSectors: xboxdef.DWORD,
    PartitionNumber: xboxdef.DWORD,
    PartitionType: xboxdef.BYTE,
    BootIndicator: xboxdef.BOOLEAN,
    RecognizedPartition: xboxdef.BOOLEAN,
    RewritePartition: xboxdef.BOOLEAN,
};
pub const PARTITION_INFORMATION = _PARTITION_INFORMATION;
pub const PPARTITION_INFORMATION = *_PARTITION_INFORMATION;

pub const IOCTL_DISK_BASE = 0x00_00_00_07;

pub const IOCTL_DISK_GET_DRIVE_GEOMETRY = CTL_CODE(IOCTL_DISK_BASE, 0x00_00, METHOD_BUFFERED, FILE_ANY_ACCESS);
pub const IOCTL_DISK_GET_PARTITION_INFO = CTL_CODE(IOCTL_DISK_BASE, 0x00_01, METHOD_BUFFERED, FILE_READ_ACCESS);

pub extern fn NtDeviceIoControlFile(
    FileHandle: xboxdef.HANDLE,
    Event: ?xboxdef.HANDLE,
    ApcRoutine: ?*const PIO_APC_ROUTINE,
    ApcContext: ?xboxdef.PVOID,
    IoStatusBlock: PIO_STATUS_BLOCK,
    IoControlCode: xboxdef.ULONG,
    InputBuffer: ?xboxdef.PVOID,
    InputBufferLength: xboxdef.ULONG,
    OutputBuffer: ?xboxdef.PVOID,
    OutputBufferLength: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtDeleteFile(
    ObjectAttributes: *const OBJECT_ATTRIBUTES,
) callconv(NTAPI) xboxdef.BOOLEAN;

pub extern fn NtCreateTimer(
    TimerHandle: xboxdef.PHANDLE,
    ObjectAttributes: *const OBJECT_ATTRIBUTES,
    TimerType: TIMER_TYPE,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Create a semaphore object with the specified initial and maximum count.
///
/// @param `SemaphoreHandle` A pointer to a variable that receives the value of the semaphore object handle.
///
/// @param `ObjectAttributes` An optional pointer to a structure that specifies the object's attributes.
///
/// @param `InitialCount` The initial count for the semaphore, this value must be positive and less than or equal to the maximum count.
///
/// @param `MaximumCount` The maximum count for the semaphore, this value must be greater than zero.
///
/// @return `STATUS_SUCCESS` on success or error code.
pub extern fn NtCreateSemaphore(
    SemaphoreHandle: xboxdef.PHANDLE,
    ObjectAttributes: ?POBJECT_ATTRIBUTES,
    InitialCount: xboxdef.LONG,
    MaximumCount: xboxdef.LONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Creates a mutant object (mutex), sets its initial count to one (which means "signaled"), and opens a handle to the object.
///
/// @param `MutantHandle` A pointer to a variable that receives the mutant object handle.
///
/// @param `ObjectAttributes` A pointer to a OBJECT_ATTRIBUTES-structure that specifies object attributes.
///
/// @param `InitialOwner` A boolean value that specifies whether the creator of the mutant object wants immediate ownership.
///
/// @return The status of the operation.
pub extern fn NtCreateMutant(
    MutantHandle: xboxdef.PHANDLE,
    ObjectAttributes: ?POBJECT_ATTRIBUTES,
    InitialOwner: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtCreateIoCompletion(
    IoCompletionHandle: xboxdef.PHANDLE,
    DesiredAccess: ACCESS_MASK,
    ObjectAttributes: ?POBJECT_ATTRIBUTES,
    Count: ?xboxdef.ULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtCreateFile(
    FileHandle: xboxdef.PHANDLE,
    DesiredAccess: ACCESS_MASK,
    ObjectAttributes: *const OBJECT_ATTRIBUTES,
    IoStatusBlock: PIO_STATUS_BLOCK,
    AllocationSize: ?xboxdef.PLARGE_INTEGER,
    FileAttributes: xboxdef.ULONG,
    ShareAccess: xboxdef.ULONG,
    CreateDisposition: xboxdef.ULONG,
    CreateOptions: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

// values for CreateDisposition
// pub const CREATE_NEW = 1;
// pub const CREATE_ALWAYS = 2;
// pub const OPEN_EXISTING = 3;
// pub const OPEN_ALWAYS = 4;
// pub const TRUNCATE_EXISTING = 5;

// values for DesiredAccess
pub const DELETE = 0x00_01_00_00;
pub const READ_CONTROL = 0x00_02_00_00;
pub const WRITE_DAC = 0x00_04_00_00;
pub const WRITE_OWNER = 0x00_08_00_00;
pub const SYNCHRONIZE = 0x00_10_00_00;
pub const STANDARD_RIGHTS_REQUIRED = 0x00_0F_00_00;
pub const STANDARD_RIGHTS_READ = READ_CONTROL;
pub const STANDARD_RIGHTS_WRITE = READ_CONTROL;
pub const STANDARD_RIGHTS_EXECUTE = READ_CONTROL;
pub const STANDARD_RIGHTS_ALL = 0x00_1F_00_00;
pub const SPECIFIC_RIGHTS_ALL = 0x00_00_FF_FF;
pub const ACCESS_SYSTEM_SECURITY = 0x01_00_00_00;
pub const MAXIMUM_ALLOWED = 0x02_00_00_00;
pub const GENERIC_READ = 0x80_00_00_00;
pub const GENERIC_WRITE = 0x40_00_00_00;
pub const GENERIC_EXECUTE = 0x20_00_00_00;
pub const GENERIC_ALL = 0x10_00_00_00;

pub const FILE_READ_DATA = 0x00_01;
pub const FILE_LIST_DIRECTORY = 0x00_01;
pub const FILE_WRITE_DATA = 0x00_02;
pub const FILE_ADD_FILE = 0x00_02;
pub const FILE_APPEND_DATA = 0x00_04;
pub const FILE_ADD_SUBDIRECTORY = 0x00_04;
pub const FILE_CREATE_PIPE_INSTANCE = 0x00_04;
pub const FILE_READ_EA = 0x00_08;
pub const FILE_WRITE_EA = 0x00_10;
pub const FILE_EXECUTE = 0x00_20;
pub const FILE_TRAVERSE = 0x00_20;
pub const FILE_DELETE_CHILD = 0x00_40;
pub const FILE_READ_ATTRIBUTES = 0x00_80;
pub const FILE_WRITE_ATTRIBUTES = 0x01_00;
pub const FILE_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED | SYNCHRONIZE | 0x01_FF);

pub const FILE_GENERIC_READ = (STANDARD_RIGHTS_READ | FILE_READ_DATA | FILE_READ_ATTRIBUTES | FILE_READ_EA | SYNCHRONIZE);
pub const FILE_GENERIC_WRITE = (STANDARD_RIGHTS_WRITE | FILE_WRITE_DATA | FILE_WRITE_ATTRIBUTES | FILE_WRITE_EA | FILE_APPEND_DATA | SYNCHRONIZE);
pub const FILE_GENERIC_EXECUTE = (STANDARD_RIGHTS_EXECUTE | FILE_READ_ATTRIBUTES | FILE_EXECUTE | SYNCHRONIZE);

pub const FILE_SHARE_READ = 0x00_00_00_01;
pub const FILE_SHARE_WRITE = 0x00_00_00_02;
pub const FILE_SHARE_DELETE = 0x00_00_00_04;

// values for CreateOptions
pub const FILE_DIRECTORY_FILE = 0x00_00_00_01;
pub const FILE_WRITE_THROUGH = 0x00_00_00_02;
pub const FILE_SEQUENTIAL_ONLY = 0x00_00_00_04;
pub const FILE_NO_INTERMEDIATE_BUFFERING = 0x00_00_00_08;
pub const FILE_SYNCHRONOUS_IO_ALERT = 0x00_00_00_10;
pub const FILE_SYNCHRONOUS_IO_NONALERT = 0x00_00_00_20;
pub const FILE_NON_DIRECTORY_FILE = 0x00_00_00_40;
pub const FILE_CREATE_TREE_CONNECTION = 0x00_00_00_80;
pub const FILE_COMPLETE_IF_OPLOCKED = 0x00_00_01_00;
pub const FILE_NO_EA_KNOWLEDGE = 0x00_00_02_00;
pub const FILE_OPEN_FOR_RECOVERY = 0x00_00_04_00;
pub const FILE_RANDOM_ACCESS = 0x00_00_08_00;
pub const FILE_DELETE_ON_CLOSE = 0x00_00_10_00;
pub const FILE_OPEN_BY_FILE_ID = 0x00_00_20_00;
pub const FILE_OPEN_FOR_BACKUP_INTENT = 0x00_00_40_00;
pub const FILE_NO_COMPRESSION = 0x00_00_80_00;
pub const FILE_RESERVE_OPFILTER = 0x00_10_00_00;
pub const FILE_OPEN_REPARSE_POINT = 0x00_20_00_00;
pub const FILE_OPEN_NO_RECALL = 0x00_40_00_00;
pub const FILE_OPEN_FOR_FREE_SPACE_QUERY = 0x00_80_00_00;
pub const FILE_COPY_STRUCTURED_STORAGE = 0x00_00_00_41;
pub const FILE_STRUCTURED_STORAGE = 0x00_00_04_41;
pub const FILE_VALID_OPTION_FLAGS = 0x00_FF_FF_FF;
pub const FILE_VALID_PIPE_OPTION_FLAGS = 0x00_00_00_32;
pub const FILE_VALID_MAILSLOT_OPTION_FLAGS = 0x00_00_00_32;
pub const FILE_VALID_SET_FLAGS = 0x00_00_00_36;

pub const FILE_SUPERSEDE = 0x00_00_00_00;
pub const FILE_OPEN = 0x00_00_00_01;
pub const FILE_CREATE = 0x00_00_00_02;
pub const FILE_OPEN_IF = 0x00_00_00_03;
pub const FILE_OVERWRITE = 0x00_00_00_04;
pub const FILE_OVERWRITE_IF = 0x00_00_00_05;
pub const FILE_MAXIMUM_DISPOSITION = 0x00_00_00_05;

// values of the IoStatusBlock
pub const FILE_SUPERSEDED = 0x00_00_00_00;
pub const FILE_OPENED = 0x00_00_00_01;
pub const FILE_CREATED = 0x00_00_00_02;
pub const FILE_OVERWRITTEN = 0x00_00_00_03;
pub const FILE_EXISTS = 0x00_00_00_04;
pub const FILE_DOES_NOT_EXIST = 0x00_00_00_05;

// Priority increment values for events
pub const ERESOURCE_INCREMENT = 4;
pub const EVENT_INCREMENT = 1;
pub const EVENT_PAIR_INCREMENT = 1;
pub const LPC_RELEASE_WAIT_INCREMENT = 1;
pub const IO_NO_INCREMENT = 0;
pub const IO_CD_ROM_INCREMENT = 1;
pub const IO_DISK_INCREMENT = 1;
pub const IO_PARALLEL_INCREMENT = 1;
pub const IO_VIDEO_INCREMENT = 1;
pub const IO_MAILSLOT_INCREMENT = 2;
pub const IO_NAMED_PIPE_INCREMENT = 2;
pub const IO_NETWORK_INCREMENT = 2;
pub const IO_SERIAL_INCREMENT = 2;
pub const IO_MOUSE_INCREMENT = 6;
pub const IO_KEYBOARD_INCREMENT = 6;
pub const IO_SOUND_INCREMENT = 8;
pub const MUTANT_INCREMENT = 1;
pub const SEMAPHORE_INCREMENT = 1;
pub const TIMER_APC_INCREMENT = 0;

/// Creates an event object, sets the initial state of the event to the specified value, and opens a handle to the object.
///
/// @param `EventHandle` A pointer to a variable that will receive the event object handle.
///
/// @param `ObjectAttributes` A pointer to the object attributes structure supplied by the caller to be used for the specified object.
///
/// @param `EventType` The type of the event, which can be SynchronizationEvent or a NotificationEvent.
///
/// @param `InitialState` The initial state of the event object.
/// - Set to `TRUE` to initialize the event object to the Signaled state.
/// - Set to `FALSE` to initialize the event object to the not-Signaled state.
///
/// @return `STATUS_SUCCESS` when the call is successfull, otherwise an NTSTATUS error code.
///         STATUS_OBJECT_NAME_EXISTS if an event object of the same name already exists and was opened instead of creating a new one.
pub extern fn NtCreateEvent(
    EventHandle: xboxdef.PHANDLE,
    ObjectAttributes: ?POBJECT_ATTRIBUTES,
    EventType: EVENT_TYPE,
    InitialState: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtCreateDirectoryObject(
    DirectoryHandle: xboxdef.PHANDLE,
    ObjectAttributes: *const OBJECT_ATTRIBUTES,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Closes an object handle.
///
/// @param `Handle` Handle to an object
///
/// @return `STATE_SUCCESS` on success, error code (e.g. `STATUS_INVALID_HANDLE`, `STATUS_HANDLE_NOT_CLOSABLE`) otherwise
pub extern fn NtClose(
    Handle: xboxdef.HANDLE,
) callconv(NTAPI) xboxdef.NTSTATUS;

/// Resets an even object to the non-signaled state.
///
/// @param `EventHandle` A HANDLE to the event object that is to be reset.
///
/// @return STATE_SUCCESS on success, an NTSTATUS error code otherwise.
pub extern fn NtClearEvent(
    EventHandle: xboxdef.HANDLE,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtCancelTimer(
    TimerHandle: xboxdef.HANDLE,
    CurrentState: ?xboxdef.PBOOLEAN,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn NtAllocateVirtualMemory(
    BaseAddress: *xboxdef.PVOID,
    ZeroBits: xboxdef.ULONG_PTR,
    RegionSize: xboxdef.PSIZE_T,
    AllocationType: xboxdef.ULONG,
    Protect: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.NTSTATUS;

// Flags for NtAllocateVirtualMemory
pub const PAGE_NOACCESS = 0x01;
pub const PAGE_READONLY = 0x02;
pub const PAGE_READWRITE = 0x04;
pub const PAGE_WRITECOPY = 0x08;
pub const PAGE_EXECUTE = 0x10;
pub const PAGE_EXECUTE_READ = 0x20;
pub const PAGE_EXECUTE_READWRITE = 0x40;
pub const PAGE_EXECUTE_WRITECOPY = 0x80;
pub const PAGE_GUARD = 0x01_00;
pub const PAGE_NOCACHE = 0x02_00;
pub const PAGE_WRITECOMBINE = 0x04_00;
pub const PAGE_VIDEO = 0x00;
pub const PAGE_OLD_VIDEO = 0x08_00;
pub const MEM_COMMIT = 0x10_00;
pub const MEM_RESERVE = 0x20_00;
pub const MEM_DECOMMIT = 0x40_00;
pub const MEM_RELEASE = 0x80_00;
pub const MEM_FREE = 0x01_00_00;
pub const MEM_PRIVATE = 0x02_00_00;
pub const MEM_MAPPED = 0x04_00_00;
pub const MEM_RESET = 0x08_00_00;
pub const MEM_TOP_DOWN = 0x10_00_00;
pub const MEM_NOZERO = 0x80_00_00;
pub const MEM_LARGE_PAGES = 0x20_00_00_00;
pub const MEM_4MB_PAGES = 0x80_00_00_00;

pub extern fn MmUnmapIoSpace(
    BaseAddress: xboxdef.PVOID,
    NumberOfBytes: xboxdef.SIZE_T,
) callconv(NTAPI) xboxdef.PVOID;

pub extern fn MmSetAddressProtect(
    BaseAddress: xboxdef.PVOID,
    NumberOfBytes: xboxdef.ULONG,
    NewProtect: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn MmQueryStatistics(
    MemoryStatistics: PMM_STATISTICS,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn MmQueryAllocationSize(
    BaseAddress: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.SIZE_T;

pub extern fn MmQueryAddressProtect(
    VirtualAddress: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.ULONG;

/// Marks a contiguous area of memory to be preserved across a quick reboot.
///
/// @param `BaseAddress` The virtual address of the memory area.
///
/// @param `NumberOfBytes` The number of bytes to be preserved.
///
/// @param `Persist` `TRUE` if the memory should be persistent, else `FALSE`.
pub extern fn MmPersistContiguousMemory(
    BaseAddress: xboxdef.PVOID,
    NumberOfBytes: xboxdef.SIZE_T,
    Persist: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn MmMapIoSpace(
    PhysicalAddress: xboxdef.ULONG_PTR,
    NumberOfBytes: xboxdef.SIZE_T,
    Protect: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.PVOID;

pub extern fn MmLockUnlockPhysicalPage(
    PhysicalAddress: xboxdef.ULONG_PTR,
    UnlockPage: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn MmLockUnlockBufferPages(
    BaseAddress: xboxdef.PVOID,
    NumberOfBytes: xboxdef.SIZE_T,
    UnlockPages: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.VOID;

/// Checks whether a page fault would occur for a read operation on a specified address.
///
/// @param `VirtualAddress` The virtual address to be checked.
///
/// @return `TRUE` if a page fault would occur, `FALSE` if not.
pub extern fn MmIsAddressValid(
    VirtualAddress: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.BOOLEAN;

pub extern var MmGlobalData: MMGLOBALDATA;

/// Returns the physical address for a virtual address.
///
/// @param `BaseAddress` A valid virtual address for which the physical address is to be returned.
///
/// @return The corresponding physical address.
pub extern fn MmGetPhysicalAddress(
    BaseAddress: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.ULONG_PTR;

pub extern fn MmFreeSystemMemory(
    BaseAddress: xboxdef.PVOID,
    NumberOfBytes: xboxdef.SIZE_T,
) callconv(NTAPI) xboxdef.ULONG;

pub extern fn MmFreeContiguousMemory(
    BaseAddress: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn MmDeleteKernelStack(
    KernelStackBase: xboxdef.PVOID,
    KernelStackLimit: xboxdef.PVOID,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn MmDbgWriteCheck(
    VirtualAddress: xboxdef.PVOID,
    Opaque: PHARDWARE_PTE,
) callconv(NTAPI) xboxdef.PVOID;

pub extern fn MmDbgReleaseAddress(
    VirtualAddress: xboxdef.PVOID,
    Opaque: PHARDWARE_PTE,
) callconv(NTAPI) xboxdef.VOID;

pub extern fn MmDbgQueryAvailablePages() callconv(NTAPI) PFN_COUNT;

pub extern fn MmDbgFreeMemory(
    BaseAddress: xboxdef.PVOID,
    NumberOfBytes: xboxdef.SIZE_T,
) callconv(NTAPI) xboxdef.ULONG;

pub extern fn MmDbgAllocateMemory(
    NumberOfBytes: xboxdef.SIZE_T,
    Protect: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.PVOID;

pub extern fn MmCreateKernelStack(
    NumberOfBytes: xboxdef.SIZE_T,
    DebuggerThread: xboxdef.BOOLEAN,
) callconv(NTAPI) xboxdef.PVOID;

pub extern fn MmClaimGpuInstanceMemory(
    NumberOfBytes: xboxdef.SIZE_T,
    NumberOfPaddingBytes: *xboxdef.SIZE_T,
) callconv(NTAPI) xboxdef.PVOID;

pub extern fn MmAllocateSystemMemory(
    NumberOfBytes: xboxdef.SIZE_T,
    Protect: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.PVOID;

pub extern fn MmAllocateContiguousMemoryEx(
    NumberOfBytes: xboxdef.SIZE_T,
    LowestAcceptableAddress: xboxdef.ULONG_PTR,
    HighestAcceptableAddress: xboxdef.ULONG_PTR,
    Alignment: xboxdef.ULONG_PTR,
    Protect: xboxdef.ULONG,
) callconv(NTAPI) xboxdef.PVOID;

pub extern fn MmAllocateContiguousMemory(
    NumberOfBytes: xboxdef.SIZE_T,
) callconv(NTAPI) xboxdef.PVOID;

pub extern var LaunchDataPage: PLAUNCH_DATA_PAGE;

pub extern var KiBugCheckData: [*c]xboxdef.ULONG;

pub extern fn KeWaitForSingleObject(
    Object: xboxdef.PVOID,
    WaitReason: KWAIT_REASON,
    WaitMode: KPROCESSOR_MODE,
    Alertable: xboxdef.BOOLEAN,
    Timeout: ?xboxdef.PLARGE_INTEGER,
) callconv(NTAPI) xboxdef.NTSTATUS;

pub extern fn KeWaitForMultipleObjects(
    Count: xboxdef.ULONG,
    Object: [*c]xboxdef.PVOID,
    WaitType: WAIT_TYPE,
    WaitReason: KWAIT_REASON,
    WaitMode: KPROCESSOR_MODE,
    Alertable: xboxdef.BOOLEAN,
    Timeout: ?xboxdef.PLARGE_INTEGER,
    WaitBlockArray: PKWAIT_BLOCK,
) callconv(NTAPI) xboxdef.NTSTATUS;

// TODO: Finish defining the rest.
