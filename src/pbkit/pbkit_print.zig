/// Adds the given printf-style string to the text overlay. advancing the cursor
/// past the end of the string.
pub extern fn pb_print(format: [*c]const u8, ...) void;

/// Sets the cursor to the given row and column, then adds the given
/// printf-style string to the text overlay, advancing the cursor past the end of
/// the string.
///
/// Note: If the provided row or column are invalid, they are ignored and the
/// current cursor row and/or column are used instead.
pub extern fn pb_printat(row: c_int, col: c_int, format: [*c]const u8, ...) void;

/// Clears the text overlay.
pub extern fn pb_erase_text_screen() void;

/// Renders the text overlay to the current framebuffer.
pub extern fn pb_draw_text_screen() void;

/// Adds the given character to the text overlay at the current cursor position,
/// then shifts the cursor position by one column, wrapping if needed.
pub extern fn pb_print_char(c: c_char) void;
