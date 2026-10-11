const std = @import("std");
const nxdk_hal = @import("nxdk_hal");
const xboxkrnl = @import("xboxkrnl");
const winapi = @import("winapi");

const SelfInfo = @This();

debug_info: ?(std.debug.SelfInfoError!DebugInfo),

/// x86 has no unwinder on NXDK (`RtlVirtualUnwind` does not exist, and
/// `RtlCaptureStackBackTrace` only walks EBP chains, which release builds do not
/// necessarily maintain). NXDK is single threaded, so there is no such thing as a
/// foreign stack to unwind into anyway; stack traces are limited to the panic address.
pub const can_unwind: bool = false;

pub const init: SelfInfo = .{
    .debug_info = null,
};

pub fn deinit(si: *SelfInfo, io: std.Io) void {
    const gpa = std.debug.getDebugInfoAllocator();
    if (si.debug_info) |di_or_err| if (di_or_err) |*di| di.deinit(gpa, io) else |_| {};
}

pub fn getSymbols(
    si: *SelfInfo,
    io: std.Io,
    symbol_allocator: std.mem.Allocator,
    text_arena: std.mem.Allocator,
    address: usize,
    resolve_inline_callers: bool,
    symbols: *std.ArrayList(std.debug.Symbol),
) std.debug.SelfInfoError!void {
    // The image is mapped where `base_address` says it is, so the slide is zero and
    // the PDB addresses line up with the image as loaded. `offset` (the RVA) is only
    // for the bounds check below: `DebugInfo.getSymbols` expects the absolute VMA and
    // does the `- base_address` conversion itself -- handing it an already-converted
    // RVA subtracts the base twice and shifts every lookup deeper into the image
    // (e.g. a panic site in main.zig resolving to a function 64KB earlier).
    const header = xbeHeader();
    const offset = address -| header.base_address;
    if (offset >= header.size_of_image) return error.MissingDebugInfo;

    return (try si.getDebugInfo(io)).getSymbols(
        symbol_allocator,
        text_arena,
        address,
        resolve_inline_callers,
        symbols,
    );
}

/// The XBE is installed as `default.xbe` in the root of the generated ISO, and nothing
/// on NXDK reports the name of the running image, so this is simply what we know it to
/// be called.
pub fn getModuleName(si: *SelfInfo, io: std.Io, address: usize) std.debug.SelfInfoError![]const u8 {
    _ = .{ si, io, address };
    return "default.xbe";
}

/// `cxbe` refuses any image base other than 0x10000, which is also where the kernel
/// maps the XBE, so there is never a slide.
pub fn getModuleSlide(si: *SelfInfo, io: std.Io, address: usize) std.debug.SelfInfoError!usize {
    _ = .{ si, io, address };
    return 0;
}

/// Loads (cached) the debug info for the running image on first use; every
/// caller here reaches it through `getSymbols`.
pub fn getDebugInfo(si: *SelfInfo, io: std.Io) std.debug.SelfInfoError!*DebugInfo {
    if (si.debug_info == null) {
        si.debug_info = loadDebugInfo(io);
    }
    return if (si.debug_info.?) |*di| di else |err| err;
}

fn loadDebugInfo(io: std.Io) std.debug.SelfInfoError!DebugInfo {
    const gpa = std.debug.getDebugInfoAllocator();

    // Deliberately not `std.debug.assert`: everything reachable from here runs inside
    // the panic handler, and a failed assertion would re-enter it.
    const header = xbeHeader();
    if (header.magic != std.mem.readInt(u32, "XBEH", .little)) return error.MissingDebugInfo;

    const mapped = image();
    const debug_path_offset = header.pe_debug_path -| header.base_address;
    if (debug_path_offset >= mapped.len) return error.MissingDebugInfo;
    const after_path = mapped[debug_path_offset..];
    const terminator = std.mem.indexOfScalar(u8, after_path, 0) orelse return error.MissingDebugInfo;
    const path = after_path[0..terminator];
    if (path.len == 0) return error.MissingDebugInfo;

    const pdb_file = std.Io.Dir.cwd().openFile(io, path, .{}) catch |err| blk: {
        if (err != error.FileNotFound and err != error.IsDir) return error.ReadFailed;
        // `D:` is not yet a drive letter here (xemu at panic time mounts the DVD
        // disc but not its DOS alias); fall back to the boot image's own device
        // directory via `XeImageFileName`.
        break :blk openPdbOnBootDevice(path) catch return error.MissingDebugInfo;
    };
    errdefer pdb_file.close(io);

    var arena_instance: std.heap.ArenaAllocator = .init(gpa);
    errdefer arena_instance.deinit();
    const arena = arena_instance.allocator();

    const pdb_reader = try arena.create(std.Io.File.Reader);
    pdb_reader.* = pdb_file.reader(io, try arena.alloc(u8, 4096));

    var pdb = std.debug.Pdb.init(gpa, pdb_reader) catch |err| switch (err) {
        error.OutOfMemory, error.ReadFailed, error.Unexpected => |e| return e,
        else => return error.InvalidDebugInfo,
    };
    errdefer pdb.deinit();
    pdb.parseInfoStream() catch |err| switch (err) {
        error.UnknownPDBVersion => return error.UnsupportedDebugInfo,
        error.EndOfStream => return error.InvalidDebugInfo,

        error.InvalidDebugInfo,
        error.MissingDebugInfo,
        error.OutOfMemory,
        error.ReadFailed,
        => |e| return e,
    };
    pdb.parseDbiStream() catch |err| switch (err) {
        error.UnknownPDBVersion => return error.UnsupportedDebugInfo,

        error.EndOfStream,
        error.EOF,
        error.StreamTooLong,
        error.WriteFailed,
        => return error.InvalidDebugInfo,

        error.InvalidDebugInfo,
        error.OutOfMemory,
        error.ReadFailed,
        => |e| return e,
    };
    pdb.parseIpiStream() catch |err| switch (err) {
        error.UnknownPDBVersion => return error.UnsupportedDebugInfo,

        error.EndOfStream,
        => return error.InvalidDebugInfo,

        error.OutOfMemory,
        error.ReadFailed,
        => |e| return e,
    };

    if (!imageContainsCodeView(pdb.guid, pdb.age)) return error.MissingDebugInfo;

    const section_table = header.section_table -| header.base_address;
    const table_len = @as(usize, header.section_count) * @sizeOf(XbeSectionHeader);
    if (section_table > mapped.len or table_len > mapped.len - section_table) {
        return error.MissingDebugInfo;
    }

    return .{
        .arena = arena_instance.state,
        .pdb = pdb,
        .section_headers = @as([*]align(1) const XbeSectionHeader, @ptrCast(
            mapped.ptr + section_table,
        ))[0..header.section_count],
    };
}

/// Fallback for when `D:` isn't a drive letter yet (xemu at panic time): open
/// the PDB sibling of the boot image via the boot device path. The kernel
/// recorded the full NT path it used to launch us in `XeImageFileName` (e.g.
/// `\Device\CdRom0\default.xbe`); we take its directory and append the PDB
/// basename from the XBE header path (`D:\default.pdb` -> `default.pdb`), then
/// open with `RootDirectory=NULL` so the path is fully qualified with no DOS
/// drive-letter dependency. Returns an open std.Io.File; the rest of the PDB
/// pipeline (stat/reader/handle) goes through debug_io's Nt* bindings.
fn openPdbOnBootDevice(header_path: []const u8) std.Io.File.OpenError!std.Io.File {
    const image_file = xboxkrnl.xboxkrnl.XeImageFileName();
    const image_buf_ptr = image_file.*.Buffer orelse
        return error.FileNotFound;
    const image_path = std.mem.span(image_buf_ptr);

    const last_sep = std.mem.lastIndexOfScalar(u8, image_path, std.Io.Dir.path.sep_windows) orelse
        return error.BadPathName;
    const img_dir = image_path[0..last_sep]; // e.g. "\Device\CdRom0"

    // Basename of the header path, e.g. "D:\default.pdb" -> "default.pdb".
    const base = if (std.mem.lastIndexOfScalar(u8, header_path, '\\')) |sep|
        header_path[sep + 1 ..]
    else
        header_path;

    var full: [512:0]u8 = @splat(0);
    const path_len = img_dir.len + 1 + base.len;
    if (path_len + 1 >= full.len) return error.NameTooLong;
    @memcpy(full[0..img_dir.len], img_dir);
    full[img_dir.len] = '\\';
    @memcpy(full[img_dir.len + 1 .. path_len], base);
    full[path_len] = 0;

    var ansi_path: xboxkrnl.xboxdef.ANSI_STRING = .{
        .Length = @intCast(path_len),
        .MaximumLength = @intCast(path_len + 1),
        .Buffer = @ptrCast(&full),
    };

    const attributes: xboxkrnl.xboxkrnl.OBJECT_ATTRIBUTES = .{
        .RootDirectory = null, // fully qualified path: NULL root
        .ObjectName = &ansi_path,
        .Attributes = xboxkrnl.xboxkrnl.OBJ_CASE_INSENSITIVE,
    };

    var io_status_block: xboxkrnl.xboxkrnl.IO_STATUS_BLOCK = undefined;
    var handle: xboxkrnl.xboxdef.HANDLE = undefined;
    const status = xboxkrnl.xboxkrnl.NtCreateFile(
        &handle,
        xboxkrnl.xboxkrnl.FILE_GENERIC_READ, // includes SYNCHRONIZE
        &attributes,
        &io_status_block,
        null,
        xboxkrnl.xboxdef.FILE_ATTRIBUTE_NORMAL,
        xboxkrnl.xboxkrnl.FILE_SHARE_READ | xboxkrnl.xboxkrnl.FILE_SHARE_WRITE,
        xboxkrnl.xboxkrnl.FILE_OPEN,
        xboxkrnl.xboxkrnl.FILE_SYNCHRONOUS_IO_NONALERT |
            xboxkrnl.xboxkrnl.FILE_NON_DIRECTORY_FILE,
    );

    const status_bits: u32 = @bitCast(status);
    if (status_bits == xboxkrnl.ntstatus.STATUS_SUCCESS) {
        return .{
            .handle = handle,
            .flags = .{ .nonblocking = false }, // opened with FILE_SYNCHRONOUS_IO_NONALERT
        };
    }
    return switch (status_bits) {
        xboxkrnl.ntstatus.STATUS_OBJECT_NAME_NOT_FOUND,
        xboxkrnl.ntstatus.STATUS_OBJECT_PATH_NOT_FOUND,
        xboxkrnl.ntstatus.STATUS_OBJECT_NAME_INVALID,
        xboxkrnl.ntstatus.STATUS_OBJECT_PATH_SYNTAX_BAD,
        => error.FileNotFound,
        xboxkrnl.ntstatus.STATUS_ACCESS_DENIED => error.AccessDenied,
        else => error.Unexpected,
    };
}

/// Locates a CodeView `RSDS` record in the mapped image that names exactly this PDB.
/// `cxbe` strips the PE headers, so the image has no data directories left to point at
/// the debug directory and the record has to be found by scanning. Requiring a GUID and
/// age match rejects a stale `default.pdb` left on the ISO -- and, symmetrically, a
/// stale XBE -- rather than silently attributing line numbers from the wrong build.
fn imageContainsCodeView(guid: [16]u8, age: u32) bool {
    var rest = image();
    while (std.mem.indexOf(u8, rest, "RSDS")) |offset| {
        const record = rest[offset..];
        if (record.len >= 24 and
            std.mem.eql(u8, record[4..20], &guid) and
            std.mem.readInt(u32, record[20..24], .little) == age)
        {
            return true;
        }
        rest = record[1..];
    }
    return false;
}

fn xbeHeader() *align(1) const XbeHeader {
    return @ptrFromInt(winapi.winnt.XBE_DEFAULT_BASE);
}

fn image() []const u8 {
    const header = xbeHeader();
    const ptr: [*]const u8 = @ptrCast(header);
    return ptr[0..header.size_of_image];
}

const DebugInfo = struct {
    arena: std.heap.ArenaAllocator.State,
    pdb: std.debug.Pdb,
    /// Borrowed from the mapped image rather than owned by `arena`. `align(1)` because
    /// the table is not guaranteed to land on an `extern struct`'s natural alignment.
    section_headers: []align(1) const XbeSectionHeader,

    fn deinit(di: *DebugInfo, gpa: std.mem.Allocator, io: std.Io) void {
        // `Pdb.deinit` frees its own allocations but does not close the file.
        di.pdb.file_reader.file.close(io);
        di.pdb.deinit();

        var arena = di.arena.promote(gpa);
        arena.deinit();
    }

    fn getSymbols(
        di: *DebugInfo,
        symbol_allocator: std.mem.Allocator,
        text_arena: std.mem.Allocator,
        vaddr: usize,
        resolve_inline_callers: bool,
        symbols: *std.ArrayList(std.debug.Symbol),
    ) std.debug.SelfInfoError!void {
        const base_address = xbeHeader().base_address;

        const pdb = &di.pdb;
        var section_rva: u32 = undefined;
        const mod_index = for (pdb.sect_contribs) |sect_contrib| {
            if (sect_contrib.section > di.section_headers.len) continue;
            // Remember that SectionContribEntry.Section is 1-based.
            section_rva = di.section_headers[sect_contrib.section - 1].virtual_address - base_address;

            const vaddr_start = section_rva + sect_contrib.offset;
            const vaddr_end = vaddr_start + sect_contrib.size;
            // `vaddr` is an absolute VMA, but XBE section `virtual_address` is also
            // absolute, so `section_rva` and the contribution range live in RVA space.
            // Convert before comparing.
            const vaddr_rva = vaddr -| base_address;
            if (vaddr_rva >= vaddr_start and vaddr_rva < vaddr_end) {
                break sect_contrib.module_index;
            }
        } else {
            // we have no information to add to the address
            return error.MissingDebugInfo;
        };
        const module = pdb.getModule(mod_index) catch |err| switch (err) {
            error.InvalidDebugInfo,
            error.MissingDebugInfo,
            error.OutOfMemory,
            => |e| return e,

            error.ReadFailed,
            error.EndOfStream,
            => return error.InvalidDebugInfo,
        } orelse {
            return error.InvalidDebugInfo; // bad module index
        };

        // C13 line/proc data is written relative to the module section start
        // (reloc_offset/offset fields), not to the image RVA: adding the section
        // RVA gets back to image space, so `getProcSym`/`getLineNumberInfo` must
        // be given `vaddr` converted to section-relative coordinates.
        const addr = vaddr -| base_address -| section_rva;
        const maybe_proc = pdb.getProcSym(module, addr);
        const compile_unit_name = std.fs.path.basename(module.obj_file_name);
        const symbols_top = symbols.items.len;
        if (maybe_proc) |proc| {
            const offset_in_func = addr - proc.code_offset;
            var last_inlinee: ?u32 = null;
            var iter = pdb.getInlinees(module, proc);
            while (iter.next(module)) |inline_site| {
                // Filter out duplicate inline sites. Tools like llvm-addr2line output
                // duplicate sites in the same cases as us if we elide this check,
                // implying that they exist in the underlying data and are not indicative
                // of a parser bug. No useful information is lost here since an inline site
                // can't actually reference itself.
                if (inline_site.inlinee == last_inlinee) continue;

                // If our address points into this site, get the source location(s) it
                // points at
                for (pdb.getInlineeSourceLines(
                    module,
                    inline_site.inlinee,
                )) |inlinee_src_line| {
                    const maybe_loc = pdb.getInlineSiteSourceLocation(
                        text_arena,
                        module,
                        inline_site,
                        inlinee_src_line.info,
                        offset_in_func,
                    ) catch continue;
                    var loc = maybe_loc orelse continue;
                    // The PDB records absolute build-host paths; on the console
                    // only the file name is meaningful (`main.zig:10`), and the
                    // directory part can never be opened there anyway.
                    loc.file_name = std.fs.path.basename(loc.file_name);

                    // If we aren't trying to resolve inline callers, and we've matched a
                    // new inline site, we want to overwrite the previously appended
                    // results.
                    if (!resolve_inline_callers and inline_site.inlinee != last_inlinee) {
                        symbols.items.len = symbols_top;
                    }

                    // Only resolve the name if we're resolving inline callers, otherwise
                    // wait until we're done to avoid duplicated work.
                    const name = if (resolve_inline_callers)
                        pdb.findInlineeName(inline_site.inlinee)
                    else
                        null;

                    try symbols.append(symbol_allocator, .{
                        .name = name,
                        .compile_unit_name = compile_unit_name,
                        .source_location = loc,
                    });

                    last_inlinee = inline_site.inlinee;
                }
            }

            if (resolve_inline_callers) {
                // Inline sites are stored in the pdb in reverse order, so we reverse the
                // matching sites here. We could alternatively use the parent fields to
                // determine the order, but this would introduce seemingly unecessary
                // complexity.
                std.mem.reverse(std.debug.Symbol, symbols.items);
            } else if (last_inlinee) |inlinee| {
                // If we aren't resolving inline callers, then all results will have the
                // same inline site, and we resolve its name once at the end.
                const name = pdb.findInlineeName(inlinee);
                for (symbols.items) |*symbol| symbol.name = name;
            }
        }

        // If there's room for another symbol, add the actual proc
        if (resolve_inline_callers or symbols.items.len == 0) {
            var loc = pdb.getLineNumberInfo(text_arena, module, addr) catch null;
            if (loc) |*sl| sl.file_name = std.fs.path.basename(sl.file_name);
            try symbols.append(symbol_allocator, .{
                .name = if (maybe_proc) |proc| pdb.getSymbolName(proc) else null,
                .compile_unit_name = compile_unit_name,
                .source_location = loc,
            });
        }
    }
};

/// The XBE image header as written by `cxbe`; see `XBE_FILE_HEADER` in NXDK's
/// winnt.h. Only the leading fields are modelled. `cxbe` writes no PE or optional
/// header into the image, so this is the only description of the loaded image we
/// have -- there are no data directories to consult.
const XbeHeader = extern struct {
    magic: u32,
    signature: [256]u8,
    base_address: u32,
    size_of_headers: u32,
    size_of_image: u32,
    size_of_image_header: u32,
    time_date_stamp: u32,
    certificate_header: u32,
    section_count: u32,
    section_table: u32,
    init_flags: u32,
    entry_point: u32,
    tls_directory: u32,
    stack_reserve: u32,
    heap_reserve: u32,
    heap_commit: u32,
    pe_image_base: u32,
    pe_size_of_image: u32,
    pe_image_checksum: u32,
    pe_time_date_stamp: u32,
    /// Address of the NUL-terminated PDB path recorded by `cxbe -DEBUGPATH:`, or zero
    /// when no path was given.
    pe_debug_path: u32,
    pe_debug_filename: u32,
    pe_debug_filename_unicode: u32,

    comptime {
        std.debug.assert(@offsetOf(XbeHeader, "base_address") == 0x104);
        std.debug.assert(@offsetOf(XbeHeader, "size_of_image") == 0x10c);
        std.debug.assert(@offsetOf(XbeHeader, "section_count") == 0x11c);
        std.debug.assert(@offsetOf(XbeHeader, "section_table") == 0x120);
        std.debug.assert(@offsetOf(XbeHeader, "pe_debug_path") == 0x14c);
    }
};

/// One entry of the XBE section table as written by `cxbe`; see `Xbe::SectionHeader` in
/// cxbe's Xbe.h. This is *not* `std.coff.SectionHeader` -- different fields, 56 bytes
/// rather than 40 -- but `cxbe` emits one entry per COFF section in the same order, so
/// `std.pdb.SectionContribEntry.section` (which is 1-based) indexes this directly.
/// `virtual_address` is an absolute address rather than an RVA, and `virtual_size` is
/// rounded up to the allocation granularity, so it is never smaller than the COFF
/// virtual size.
const XbeSectionHeader = extern struct {
    flags: u32,
    virtual_address: u32,
    virtual_size: u32,
    raw_address: u32,
    raw_size: u32,
    name_address: u32,
    section_ref_count: u32,
    head_shared_ref_count_address: u32,
    tail_shared_ref_count_address: u32,
    section_digest: [20]u8,

    comptime {
        std.debug.assert(@sizeOf(XbeSectionHeader) == 56);
    }
};
