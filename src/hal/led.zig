pub const _XLEDColor = enum(c_int) {
    XLED_OFF = 0x00,
    XLED_GREEN = 0x01,
    XLED_RED = 0x10,
    XLED_ORANGE = 0x11,
};
pub const XLEDColor = _XLEDColor;

/// Restore system LED control.
pub extern fn XResetLED() void;

///  Set the LED color manually
///  t1-t4 are used to set the color for each segment
///  in a four step loop. For more details about front LED characteristics,
///  please see https://xboxdevwiki.net/LED
pub extern fn XSetCustomLED(t1: XLEDColor, t2: XLEDColor, t3: XLEDColor, t4: XLEDColor) void;
