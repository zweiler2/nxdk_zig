pub const WHITE = 0x00_FF_FF_FF;
pub const BLACK = 0x00_00_00_00;

pub const WHITE_16BPP = 0xFF_FF;
pub const BLACK_16BPP = 0x00_00;

pub const WHITE_15BPP = 0x7F_FF;
pub const BLACK_15BPP = 0x00_00;

pub extern fn debugPrint(format: [*c]const u8, ...) void;
pub extern fn debugPrintNum(i: c_int) void;
pub extern fn debugPrintBinary(num: c_int) void;
pub extern fn debugPrintHex(buffer: [*c]const u8, length: c_int) void;

pub extern fn debugClearScreen() void;
pub extern fn debugAdvanceScreen() void;
pub extern fn debugMoveCursor(x: c_int, y: c_int) void;
pub extern fn debugResetCursor() void;
