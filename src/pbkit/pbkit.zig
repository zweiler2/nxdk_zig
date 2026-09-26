const xboxkrnl = @import("xboxkrnl");

///shows scene (allows VBL synced screen swapping)
pub extern fn pb_show_front_screen() void;
///shows debug screen (default openxdk+SDL buffer)
pub extern fn pb_show_debug_screen() void;
///shows depth screen (depth stencil buffer)
pub extern fn pb_show_depth_screen() void;

pub extern fn pb_get_vbl_counter() xboxkrnl.xboxdef.DWORD;
/// Waits for VBL, returns VBL counter value as bonus info
/// you can avoid calling it and try to draw a lot in advance
/// use it if you need strong synchronization with controls
pub extern fn pb_wait_for_vbl() xboxkrnl.xboxdef.DWORD;

/// ALWAYS use this at beginning of frame or you may lose one third of performance because
/// automatic compression algorithm for tile #1 can't afford any garbage left behind...
pub extern fn pb_erase_depth_stencil_buffer(x: c_int, y: c_int, w: c_int, h: c_int) void;

/// Forces a jump to push buffer head (do it at frame start)
pub extern fn pb_reset() void;
/// Prepare screen swapping at VBlank (do it at frame end)
/// if it returns 1 it failed (too early, just wait & retry)
/// that means you can draw more details in your scene
pub extern fn pb_finished() c_int;

pub extern fn pb_wait_until_gr_not_busy() void;
pub extern fn pb_wait_until_tiles_not_busy() xboxkrnl.xboxdef.DWORD;

/// Requests additional back buffers (default is 0) (call it before pb_init)
pub extern fn pb_extra_buffers(n: c_int) void;
/// Sets push buffer size (default is 512Kb) (call it before pb_init)
pub extern fn pb_size(size: xboxkrnl.xboxdef.DWORD) void;
/// Returns 0 if everything went well (starts Dma engine)
pub extern fn pb_init() c_int;
/// Stops Dma engine and releases push buffer
pub extern fn pb_kill() void;

/// To have rendering made into a static extra buffer
pub extern fn pb_target_extra_buffer(n: c_int) void;
/// To have rendering made into normal rotating back buffer
pub extern fn pb_target_back_buffer() void;

/// Returns a static extra buffer address
pub extern fn pb_extra_buffer(n: c_int) *xboxkrnl.xboxdef.DWORD;
/// Returns normal rotating back buffer address
pub extern fn pb_back_buffer() *xboxkrnl.xboxdef.DWORD;
pub extern fn pb_back_buffer_width() xboxkrnl.xboxdef.DWORD;
pub extern fn pb_back_buffer_height() xboxkrnl.xboxdef.DWORD;
pub extern fn pb_back_buffer_pitch() xboxkrnl.xboxdef.DWORD;

pub extern fn pb_set_viewport(dwx: c_int, dwy: c_int, width: c_int, height: c_int, zmin: f32, zmax: f32) void;

pub extern fn pb_busy() c_int;
