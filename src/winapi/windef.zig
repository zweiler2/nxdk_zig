const std = @import("std");
const xboxkrnl = @import("xboxkrnl");

// #define far
// #define FAR far

pub const WINAPI: std.builtin.CallingConvention = .winapi;
pub const CALLBACK: std.builtin.CallingConvention = WINAPI;

pub const MAX_PATH = 260;

pub const HWND = xboxkrnl.xboxdef.HANDLE;
pub const HINSTANCE = xboxkrnl.xboxdef.HANDLE;
pub const HMODULE = HINSTANCE;

pub const FARPROC = ?*const fn () callconv(.winapi) c_int;
