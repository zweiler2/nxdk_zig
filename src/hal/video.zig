const xboxkrnl = @import("xboxkrnl");

// Defines for frame buffer
pub const VIDEO_BASE = 0xFD_00_00_00;

// Hardware access macros
pub fn VIDEOREG(x: usize) c_uint {
    const ptr: *volatile c_uint = @ptrFromInt(VIDEO_BASE + x);
    return ptr.*;
}
pub fn VIDEOREG16(x: usize) c_ushort {
    const ptr: *volatile c_ushort = @ptrFromInt(VIDEO_BASE + x);
    return ptr.*;
}
pub fn VIDEOREG8(x: usize) u8 {
    const ptr: *volatile u8 = @ptrFromInt(VIDEO_BASE + x);
    return ptr.*;
}

// Defines for video encoder options
pub const VIDEO_ENC_GET_SETTINGS = 6;
pub const VIDEO_ENC_VIDEOENABLE = 9;
pub const VIDEO_ENC_FLICKERFILTER = 11;
pub const VIDEO_ENC_SOFTEN_FILTER = 14;

// Flags for video settings
pub const VIDEO_MODE_720P = 0x02_00_00;
pub const VIDEO_MODE_1080I = 0x04_00_00;
pub const VIDEO_MODE_480P = 0x08_00_00;
pub const VIDEO_60Hz = 0x40_00_00;
pub const VIDEO_50Hz = 0x80_00_00;
pub const VIDEO_WIDESCREEN = 0x01_00_00;
pub const VIDEO_LETTERBOX = 0x10_00_00;

pub const VIDEO_ADAPTER_MASK = 0x00_00_00_FF;
pub const VIDEO_STANDARD_MASK = 0x00_00_FF_00;

// Defines for refresh rates
pub const REFRESH_50HZ = 50;
pub const REFRESH_60HZ = 60;
pub const REFRESH_DEFAULT = 0;

/// Structure to hold details about a video mode;
pub const _VIDEO_MODE = struct {
    width: c_int,
    height: c_int,
    bpp: c_int,
    refresh: c_int,
};
pub const VIDEO_MODE = _VIDEO_MODE;

pub const _GAMMA_RAMP_ENTRY = struct {
    red: u8,
    green: u8,
    blue: u8,
};
pub const GAMMA_RAMP_ENTRY = _GAMMA_RAMP_ENTRY;

pub extern fn XVideoGetEncoderSettings() xboxkrnl.xboxdef.DWORD;
pub extern fn XVideoGetFB() [*c]u8;
pub extern fn XVideoSetFB(fb: [*c]u8) void;
pub extern fn XVideoGetMode() VIDEO_MODE;
pub extern fn XVideoFlushFB() void;

pub extern fn XVideoSetFlickerFilter(level: c_int) void;
pub extern fn XVideoSetMode(width: c_int, height: c_int, bpp: c_int, refresh: c_int) xboxkrnl.xboxdef.BOOL;
pub extern fn XVideoSetSoftenFilter(enable: xboxkrnl.xboxdef.BOOL) void;
pub extern fn XVideoSetVideoEnable(enable: xboxkrnl.xboxdef.BOOL) void;
pub extern fn XVideoSetGammaRamp(offset: c_uint, entries: [*]GAMMA_RAMP_ENTRY, count: c_uint) void;

/// Lists the video modes available at the given colour depth and refresh rate.
///
/// On the first call the argument p must be a pointer to a void pointer
/// initialized to NULL. This is used internally to maintain context between
/// successive calls. If a matching video mode is found then XVideoListModes will
/// return TRUE and the video mode details will be written to the VIDEO_MODE vm
/// structure. If no matching video mode is found the function will return FALSE.
///
/// Repeatedly calling the function allows all matching video modes to be read out.
///
/// If a value of 0 is provided for the refresh rate the current refresh rate is used.
///
/// If a value of 0 is provided for the bpp a default value of 32bpp is used.
pub extern fn XVideoListModes(vm: *VIDEO_MODE, bpp: c_int, refresh: c_int, p: [*c]?*anyopaque) xboxkrnl.xboxdef.BOOLEAN;

pub extern fn XVideoWaitForVBlank() void;
pub extern fn XVideoGetVideoBase() [*c]u8;
pub extern fn XVideoVideoMemorySize() c_int;
