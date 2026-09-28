//! This sample provides a very basic demonstration of 3D rendering on the Xbox,
//! using pbkit. Based on the pbkit demo sources.

const std = @import("std");
const nxdk_hal = @import("nxdk_hal");
const winapi = @import("winapi");
const pbkit = @import("pbkit");
const xboxkrnl = @import("xboxkrnl");

var alloc_vertices: [*]u32 = &.{};
var num_vertices: u32 = 0;
var m_viewport: [4][4]f32 = @splat(@splat(0.0));

const ColoredVertex = struct {
    pos: [3]f32,
    color: [3]f32,
};

// zig fmt: off
const verts = [_]ColoredVertex{
    //  X     Y     Z       R     G     B
    .{ .pos = .{-1.0, -1.0, 1.0}, .color = .{0.1, 0.1, 0.6}}, // Background triangle 1
    .{ .pos = .{-1.0,  1.0, 1.0}, .color = .{0.0, 0.0, 0.0}},
    .{ .pos = .{1.0,   1.0, 1.0}, .color = .{0.0, 0.0, 0.0}},
    .{ .pos = .{-1.0, -1.0, 1.0}, .color = .{0.1, 0.1, 0.6}}, // Background triangle 2
    .{ .pos = .{1.0,   1.0, 1.0}, .color = .{0.0, 0.0, 0.0}},
    .{ .pos = .{1.0,  -1.0, 1.0}, .color = .{0.1, 0.1, 0.6}},
    .{ .pos = .{-1.0, -1.0, 1.0}, .color = .{1.0, 0.0, 0.0}}, // Foreground triangle
    .{ .pos = .{0.0,   1.0, 1.0}, .color = .{0.0, 1.0, 0.0}},
    .{ .pos = .{1.0,  -1.0, 1.0}, .color = .{0.0, 0.0, 1.0}},
};
// zig fmt: on

fn MASK(mask: xboxkrnl.xboxdef.DWORD, val: xboxkrnl.xboxdef.DWORD) xboxkrnl.xboxdef.DWORD {
    return ((val) << @as(u5, @intCast(@ctz(mask)))) & mask;
}

pub const panic = @import("panic").panic;

// Main program function
pub export fn main() u8 {
    _ = nxdk_hal.video.XVideoSetMode(640, 480, 32, nxdk_hal.video.REFRESH_DEFAULT);

    const status: c_int = pbkit.pbkit.pb_init();
    if (status != 0) {
        nxdk_hal.debug.debugPrint("pb_init Error %d\n", status);
        winapi.synchapi.Sleep(2000);
        return 1;
    }

    pbkit.pbkit.pb_show_front_screen();

    // Basic setup
    const width = pbkit.pbkit.pb_back_buffer_width();
    const height = pbkit.pbkit.pb_back_buffer_height();

    // Load constant rendering things (shaders, geometry)
    initShader();
    alloc_vertices = @ptrCast(@alignCast(xboxkrnl.xboxkrnl.MmAllocateContiguousMemoryEx(@sizeOf(@TypeOf(verts)), 0, 0x03_FF_B0_00, 0, xboxkrnl.xboxkrnl.PAGE_READWRITE | xboxkrnl.xboxkrnl.PAGE_WRITECOMBINE)));
    @memcpy(alloc_vertices, std.mem.bytesAsSlice(u32, std.mem.sliceAsBytes(&verts)));
    num_vertices = verts.len;
    matrixViewport(&m_viewport, 0, 0, @floatFromInt(width), @floatFromInt(height), 0, 65_536.0);

    // Setup to determine frames rendered every second
    const start: xboxkrnl.xboxdef.DWORD = winapi.sysinfoapi.GetTickCount();
    var now: xboxkrnl.xboxdef.DWORD = start;
    var last: xboxkrnl.xboxdef.DWORD = start;
    var fps: usize = 0;
    var frames: usize = 0;
    var frames_total: usize = 0;

    var p: [*]u32 = undefined;
    while (true) {
        _ = pbkit.pbkit.pb_wait_for_vbl();
        pbkit.pbkit.pb_reset();
        pbkit.pbkit.pb_target_back_buffer();

        // Clear depth & stencil buffers
        pbkit.pbkit.pb_erase_depth_stencil_buffer(0, 0, @intCast(width), @intCast(height));
        pbkit.pbkit_draw.pb_fill(0, 0, @intCast(width), @intCast(height), 0x00_00_00_00);
        pbkit.pbkit_print.pb_erase_text_screen();

        while (pbkit.pbkit.pb_busy() != 0) {
            // Wait for completion...
        }

        // Send shader constants
        // WARNING: Changing shader source code may impact constant locations!
        // Check the intermediate file (*.inl) for the expected locations after
        // changing the code.
        p = pbkit.pbkit_pushbuffer.pb_begin();

        // Set shader constants cursor at C0
        p = pbkit.pbkit_pushbuffer.pb_push1(p, pbkit.nvregs.NV097_SET_TRANSFORM_CONSTANT_LOAD, 96);

        // Send the transformation matrix
        pbkit.pbkit_pushbuffer.pb_push(p, pbkit.nvregs.NV097_SET_TRANSFORM_CONSTANT, 16);
        p += 1;
        @memcpy(p, std.mem.bytesAsSlice(u32, std.mem.sliceAsBytes(&m_viewport)));
        p += 16;

        pbkit.pbkit_pushbuffer.pb_end(p);
        p = pbkit.pbkit_pushbuffer.pb_begin();

        // Clear all attributes
        pbkit.pbkit_pushbuffer.pb_push(p, pbkit.nvregs.NV097_SET_VERTEX_DATA_ARRAY_FORMAT, 16);
        p += 1;
        for (0..16) |_| {
            p[0] = pbkit.nvregs.NV097_SET_VERTEX_DATA_ARRAY_FORMAT_TYPE_F;
            p += 1;
        }
        pbkit.pbkit_pushbuffer.pb_end(p);

        // Set vertex position attribute
        setAttribPointer(0, pbkit.nvregs.NV097_SET_VERTEX_DATA_ARRAY_FORMAT_TYPE_F, 3, @sizeOf(ColoredVertex), &alloc_vertices[0]);

        // Set vertex diffuse color attribute
        setAttribPointer(3, pbkit.nvregs.NV097_SET_VERTEX_DATA_ARRAY_FORMAT_TYPE_F, 3, @sizeOf(ColoredVertex), &alloc_vertices[3]);

        // Begin drawing triangles
        drawArrays(pbkit.nvregs.NV097_SET_BEGIN_END_OP_TRIANGLES, 0, num_vertices);

        // Draw some text on the screen
        pbkit.pbkit_print.pb_print("Triangle Demo\n");
        pbkit.pbkit_print.pb_print("Frames: %d\n", frames_total);
        if (fps > 0) {
            pbkit.pbkit_print.pb_print("FPS: %d", fps);
        }
        pbkit.pbkit_print.pb_draw_text_screen();

        while (pbkit.pbkit.pb_busy() != 0) {
            // Wait for completion...
        }

        // Swap buffers (if we can)
        while (pbkit.pbkit.pb_finished() != 0) {
            // Not ready to swap yet
        }

        frames += 1;
        frames_total += 1;

        // Latch FPS counter every second
        now = winapi.sysinfoapi.GetTickCount();
        if (now - last > 1000) {
            fps = frames;
            frames = 0;
            last = now;
        }
    }

    // Unreachable cleanup code
    xboxkrnl.xboxkrnl.MmFreeContiguousMemory(alloc_vertices);
    pbkit.pbkit.pb_show_debug_screen();
    pbkit.pbkit.pb_kill();
    return 0;
}

/// Construct a viewport transformation matrix
fn matrixViewport(out: *[4][4]f32, x: f32, y: f32, width: f32, height: f32, z_min: f32, z_max: f32) void {
    @memset(out, @splat(0.0));
    out[0][0] = width / 2.0;
    out[1][1] = height / -2.0;
    out[2][2] = z_max - z_min;
    out[3][3] = 1.0;
    out[3][0] = x + width / 2.0;
    out[3][1] = y + height / 2.0;
    out[3][2] = z_min;
}

/// Load the shader we will render with
fn initShader() void {
    // Setup vertex shader
    const vs_program: []const u32 = &@import("vs.zig").bytes;

    var p: [*]u32 = pbkit.pbkit_pushbuffer.pb_begin();

    // Set run address of shader
    p = pbkit.pbkit_pushbuffer.pb_push1(p, pbkit.nvregs.NV097_SET_TRANSFORM_PROGRAM_START, 0);

    // Set execution mode
    p = pbkit.pbkit_pushbuffer.pb_push1(p, pbkit.nvregs.NV097_SET_TRANSFORM_EXECUTION_MODE, MASK(pbkit.nvregs.NV097_SET_TRANSFORM_EXECUTION_MODE_MODE, pbkit.nvregs.NV097_SET_TRANSFORM_EXECUTION_MODE_MODE_PROGRAM) |
        MASK(pbkit.nvregs.NV097_SET_TRANSFORM_EXECUTION_MODE_RANGE_MODE, pbkit.nvregs.NV097_SET_TRANSFORM_EXECUTION_MODE_RANGE_MODE_PRIV));

    p = pbkit.pbkit_pushbuffer.pb_push1(p, pbkit.nvregs.NV097_SET_TRANSFORM_PROGRAM_CXT_WRITE_EN, 0);

    pbkit.pbkit_pushbuffer.pb_end(p);

    // Set cursor for program upload
    p = pbkit.pbkit_pushbuffer.pb_begin();
    p = pbkit.pbkit_pushbuffer.pb_push1(p, pbkit.nvregs.NV097_SET_TRANSFORM_PROGRAM_LOAD, 0);
    pbkit.pbkit_pushbuffer.pb_end(p);

    // Copy program instructions (16-bytes each)
    for (0..(vs_program.len / 4)) |i| {
        p = pbkit.pbkit_pushbuffer.pb_begin();
        pbkit.pbkit_pushbuffer.pb_push(p, pbkit.nvregs.NV097_SET_TRANSFORM_PROGRAM, 4);
        p += 1;
        @memcpy(p, vs_program[(i * 4)..(i * 4 + 4)]);
        p += 4;
        pbkit.pbkit_pushbuffer.pb_end(p);
    }

    // Setup fragment shader
    p = pbkit.pbkit_pushbuffer.pb_begin();
    @import("ps.zig").run(&p);
    pbkit.pbkit_pushbuffer.pb_end(p);
}

/// Set an attribute pointer
fn setAttribPointer(
    index: xboxkrnl.xboxdef.DWORD,
    format: xboxkrnl.xboxdef.DWORD,
    size: xboxkrnl.xboxdef.DWORD,
    stride: xboxkrnl.xboxdef.DWORD,
    data: *const u32,
) void {
    var p: [*]u32 = pbkit.pbkit_pushbuffer.pb_begin();
    {
        p = pbkit.pbkit_pushbuffer.pb_push1(
            p,
            pbkit.nvregs.NV097_SET_VERTEX_DATA_ARRAY_FORMAT + index * 4,
            MASK(pbkit.nvregs.NV097_SET_VERTEX_DATA_ARRAY_FORMAT_TYPE, format) |
                MASK(pbkit.nvregs.NV097_SET_VERTEX_DATA_ARRAY_FORMAT_SIZE, size) |
                MASK(pbkit.nvregs.NV097_SET_VERTEX_DATA_ARRAY_FORMAT_STRIDE, stride),
        );
        p = pbkit.pbkit_pushbuffer.pb_push1(
            p,
            pbkit.nvregs.NV097_SET_VERTEX_DATA_ARRAY_OFFSET + index * 4,
            @intFromPtr(data) & 0x03_FF_FF_FF,
        );
    }
    pbkit.pbkit_pushbuffer.pb_end(p);
}

/// Send draw commands for the triangles
fn drawArrays(mode: xboxkrnl.xboxdef.DWORD, start: xboxkrnl.xboxdef.DWORD, count: xboxkrnl.xboxdef.DWORD) void {
    var p: [*]u32 = pbkit.pbkit_pushbuffer.pb_begin();
    {
        p = pbkit.pbkit_pushbuffer.pb_push1(
            p,
            pbkit.nvregs.NV097_SET_BEGIN_END,
            mode,
        );

        p = pbkit.pbkit_pushbuffer.pb_push1(
            p,
            0x40000000 | pbkit.nvregs.NV097_DRAW_ARRAYS, // bit 30 means all params go
            // to same register 0x1810
            MASK(pbkit.nvregs.NV097_DRAW_ARRAYS_COUNT, (count - 1)) |
                MASK(pbkit.nvregs.NV097_DRAW_ARRAYS_START_INDEX, start),
        );

        p = pbkit.pbkit_pushbuffer.pb_push1(
            p,
            pbkit.nvregs.NV097_SET_BEGIN_END,
            pbkit.nvregs.NV097_SET_BEGIN_END_OP_END,
        );
    }
    pbkit.pbkit_pushbuffer.pb_end(p);
}
