const xboxkrnl = @import("xboxkrnl");

/// Fills the rectangular region described by (x, y, x + w, y + h) with the given color.
pub extern fn pb_fill(x: c_int, y: c_int, w: c_int, h: c_int, color: xboxkrnl.xboxdef.DWORD) void;

pub extern fn pb_set_depth_stencil_buffer_region(
    depth_buffer_format: u32,
    depth_value: u32,
    stencil_value: u8,
    left: u32,
    top: u32,
    width: u32,
    height: u32,
) void;
