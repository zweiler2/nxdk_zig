const xboxkrnl = @import("xboxkrnl");

// 4x4 matrix indices
pub const _11 = 0;
pub const _12 = 1;
pub const _13 = 2;
pub const _14 = 3;
pub const _21 = 4;
pub const _22 = 5;
pub const _23 = 6;
pub const _24 = 7;
pub const _31 = 8;
pub const _32 = 9;
pub const _33 = 10;
pub const _34 = 11;
pub const _41 = 12;
pub const _42 = 13;
pub const _43 = 14;
pub const _44 = 15;

// GPU subchannels
pub const SUBCH_3D = 0;
pub const SUBCH_2 = 2;
pub const SUBCH_3 = 3;
pub const SUBCH_4 = 4;
pub const NEXT_SUBCH = 5;

/// Push buffer size, must be >64Kb and a power of 2
pub const PBKIT_PUSHBUFFER_SIZE = 512 * 1024;

/// Start a block of pushbuffer commands.
///
/// There is a hard limit of PBKIT_PUSHBUFFER_SIZE between flushes, so avoid pushing more than PBKIT_PUSHBUFFER_SIZE /
/// 4096 DWORDs per block.
pub extern fn pb_begin() *u32;

/// Pushes the given command to the given subchannel with nparam following DWORDs as parameters.
pub extern fn pb_push_to(subchannel: xboxkrnl.xboxdef.DWORD, p: *u32, command: xboxkrnl.xboxdef.DWORD, nparam: xboxkrnl.xboxdef.DWORD) void;
/// Pushes the given command and param to the given subchannel, returning a pointer to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push1_to(subchannel: xboxkrnl.xboxdef.DWORD, p: *u32, command: xboxkrnl.xboxdef.DWORD, param1: xboxkrnl.xboxdef.DWORD) *u32;
/// Pushes the given command and params to the given subchannel, returning a pointer to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push2_to(subchannel: xboxkrnl.xboxdef.DWORD, p: *u32, command: xboxkrnl.xboxdef.DWORD, param1: xboxkrnl.xboxdef.DWORD, param2: xboxkrnl.xboxdef.DWORD) *u32;
/// Pushes the given command and params to the given subchannel, returning a pointer to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push3_to(subchannel: xboxkrnl.xboxdef.DWORD, p: *u32, command: xboxkrnl.xboxdef.DWORD, param1: xboxkrnl.xboxdef.DWORD, param2: xboxkrnl.xboxdef.DWORD, param3: xboxkrnl.xboxdef.DWORD) *u32;
/// Pushes the given command and params to the given subchannel, returning a pointer to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push4_to(subchannel: xboxkrnl.xboxdef.DWORD, p: *u32, command: xboxkrnl.xboxdef.DWORD, param1: xboxkrnl.xboxdef.DWORD, param2: xboxkrnl.xboxdef.DWORD, param3: xboxkrnl.xboxdef.DWORD, param4: xboxkrnl.xboxdef.DWORD) *u32;

/// Pushes the given command and floating point params to the given subchannel, returning a pointer to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push4f_to(subchannel: xboxkrnl.xboxdef.DWORD, p: *u32, command: xboxkrnl.xboxdef.DWORD, param1: f32, param2: f32, param3: f32, param4: f32) *u32;

/// Pushes the given command and floating point param to the subchannel assigned for 3D operations, returning a pointer
/// to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push1f(p: *u32, command: xboxkrnl.xboxdef.DWORD, param1: f32) *u32;
/// Pushes the given command and floating point params to the subchannel assigned for 3D operations, returning a pointer
/// to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push2f(p: *u32, command: xboxkrnl.xboxdef.DWORD, param1: f32, param2: f32) *u32;
/// Pushes the given command and floating point params to the subchannel assigned for 3D operations, returning a pointer
/// to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push3f(p: *u32, command: xboxkrnl.xboxdef.DWORD, param1: f32, param2: f32, param3: f32) *u32;
/// Pushes the given command and floating point params to the subchannel assigned for 3D operations, returning a pointer
/// to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push4f(p: *u32, command: xboxkrnl.xboxdef.DWORD, param1: f32, param2: f32, param3: f32, param4: f32) *u32;

/// Pushes the given command and 2-element vector of floating point params to the subchannel assigned for 3D operations,
/// returning a pointer to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push2fv(p: *u32, command: xboxkrnl.xboxdef.DWORD, vector2: [*]const f32) *u32;
/// Pushes the given command and 3-element vector of floating point params to the subchannel assigned for 3D operations,
/// returning a pointer to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push3fv(p: *u32, command: xboxkrnl.xboxdef.DWORD, vector3: [*]const f32) *u32;
/// Pushes the given command and 4-element vector of floating point params to the subchannel assigned for 3D operations,
/// returning a pointer to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push4fv(p: *u32, command: xboxkrnl.xboxdef.DWORD, vector4: [*]const f32) *u32;

/// Pushes the given command and 2-element vector of DWORD params to the subchannel assigned for 3D operations, returning
/// a pointer to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push2v(p: *u32, command: xboxkrnl.xboxdef.DWORD, vector2: [*]const xboxkrnl.xboxdef.DWORD) *u32;
/// Pushes the given command and 3-element vector of DWORD params to the subchannel assigned for 3D operations, returning
/// a pointer to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push3v(p: *u32, command: xboxkrnl.xboxdef.DWORD, vector3: [*]const xboxkrnl.xboxdef.DWORD) *u32;
/// Pushes the given command and 4-element vector of DWORD params to the subchannel assigned for 3D operations, returning
/// a pointer to the next pushbuffer index to facilitate chaining.
pub extern fn pb_push4v(p: *u32, command: xboxkrnl.xboxdef.DWORD, vector4: [*]const xboxkrnl.xboxdef.DWORD) *u32;

/// Pushes the given command to the subchannel assigned for 3D with nparam following DWORDs as parameters.
pub extern fn pb_push(p: *u32, command: xboxkrnl.xboxdef.DWORD, nparam: xboxkrnl.xboxdef.DWORD) void;
// Pushes the given command and param to the subchannel assigned for 3D operations, returning a pointer to the next
// pushbuffer index to facilitate chaining.
pub extern fn pb_push1(p: *u32, command: xboxkrnl.xboxdef.DWORD, param1: xboxkrnl.xboxdef.DWORD) *u32;
// Pushes the given command and params to the subchannel assigned for 3D operations, returning a pointer to the next
// pushbuffer index to facilitate chaining.
pub extern fn pb_push2(p: *u32, command: xboxkrnl.xboxdef.DWORD, param1: xboxkrnl.xboxdef.DWORD, param2: xboxkrnl.xboxdef.DWORD) *u32;
// Pushes the given command and params to the subchannel assigned for 3D operations, returning a pointer to the next
// pushbuffer index to facilitate chaining.
pub extern fn pb_push3(p: *u32, command: xboxkrnl.xboxdef.DWORD, param1: xboxkrnl.xboxdef.DWORD, param2: xboxkrnl.xboxdef.DWORD, param3: xboxkrnl.xboxdef.DWORD) *u32;
// Pushes the given command and params to the subchannel assigned for 3D operations, returning a pointer to the next
// pushbuffer index to facilitate chaining.
pub extern fn pb_push4(p: *u32, command: xboxkrnl.xboxdef.DWORD, param1: xboxkrnl.xboxdef.DWORD, param2: xboxkrnl.xboxdef.DWORD, param3: xboxkrnl.xboxdef.DWORD, param4: xboxkrnl.xboxdef.DWORD) *u32;

// Pushes the given command and 4x4 floating point matrix to the subchannel assigned for 3D operations, returning a
// pointer to the next pushbuffer index to facilitate chaining. The matrix is pushed in transposed order.
pub extern fn pb_push_transposed_matrix(p: *u32, command: xboxkrnl.xboxdef.DWORD, m: [*]const f32) *u32;

// Pushes a 4 column x 3 row matrix (used to push the inverse model view matrix which intentionally omits the 4th row
// and is not transposed).
pub extern fn pb_push_4x3_matrix(p: *u32, command: xboxkrnl.xboxdef.DWORD, m: [*]const f32) *u32;

// Pushes a 4x4 matrix without transposing it.
pub extern fn pb_push_4x4_matrix(p: *u32, command: xboxkrnl.xboxdef.DWORD, m: [*]const f32) *u32;

// Ends a block of pushbuffer commands that was started via pb_begin, sending queued data to the GPU.
pub extern fn pb_end(pEnd: *u32) void;
