const std = @import("std");
const xboxkrnl = @import("xboxkrnl");

pub const page_allocator: std.mem.Allocator = .{
    .ptr = undefined,
    .vtable = &vtable,
};

const vtable: std.mem.Allocator.VTable = .{
    .alloc = alloc,
    .resize = resize,
    .remap = remap,
    .free = free,
};

fn alloc(ctx: *anyopaque, len: usize, alignment: std.mem.Alignment, ret_addr: usize) ?[*]u8 {
    _ = ctx;
    _ = ret_addr;
    std.debug.assert(len > 0);
    if (alignment.toByteUnits() > xboxkrnl.xboxkrnl.PAGE_SIZE) {
        return null;
    }
    const n: usize = std.mem.alignForward(usize, len, xboxkrnl.xboxkrnl.PAGE_SIZE);
    const mem = xboxkrnl.xboxkrnl.MmAllocateSystemMemory(n, xboxkrnl.xboxkrnl.PAGE_READWRITE);
    if (@intFromPtr(mem) == 0) {
        return null;
    }
    return @ptrCast(mem);
}

fn free(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, ret_addr: usize) void {
    _ = ctx;
    _ = alignment;
    _ = ret_addr;
    _ = xboxkrnl.xboxkrnl.MmFreeSystemMemory(@ptrCast(buf.ptr), 0);
}

fn resize(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) bool {
    _ = ctx;
    _ = ret_addr;
    if (alignment.toByteUnits() > xboxkrnl.xboxkrnl.PAGE_SIZE) {
        return false;
    }
    const old_size = std.mem.alignForward(usize, buf.len, xboxkrnl.xboxkrnl.PAGE_SIZE);
    const new_size = std.mem.alignForward(usize, new_len, xboxkrnl.xboxkrnl.PAGE_SIZE);
    // In-place only: shrinking, or growing within the same page block, can be
    // satisfied in place. Anything larger must go through remap.
    return new_size <= old_size;
}

fn remap(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
    const new_buf = alloc(ctx, new_len, alignment, ret_addr) orelse
        return null;
    @memcpy(new_buf[0..@min(buf.len, new_len)], buf);
    free(ctx, buf, alignment, ret_addr);
    return new_buf;
}
