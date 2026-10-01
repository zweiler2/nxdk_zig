pub extern fn _chdir(path: [*c]const u8) c_int;
pub extern fn _chdrive(drive: c_int) c_int;
/// If buffer is specified as NULL, _getcwd will allocate,
/// using the malloc function, at least length bytes of memory.
pub extern fn _getcwd(buffer: ?[*]u8, length: usize) ?[*]u8;
pub extern fn _getwd(path_name: [*c]u8) ?[*]u8;
pub extern fn _getdrive() c_int;
pub extern fn _mkdir(pathname: [*c]const u8) c_int;
pub extern fn _rmdir(pathname: [*c]const u8) c_int;
