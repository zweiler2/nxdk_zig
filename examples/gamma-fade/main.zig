const nxdk_hal = @import("nxdk_hal");
const winapi = @import("winapi");
const xboxkrnl = @import("xboxkrnl");

pub const panic = @import("panic").panic;

fn remap(in_low: f32, in_high: f32, out_low: f32, out_high: f32, value: f32) f32 {
    var value_: f32 = value;
    // [in_low; in_high]
    value_ -= in_low; // [0.0; in_high-in_low]
    value_ /= in_high - in_low; // [0.0; 1.0]
    value_ *= out_high - out_low; // [0.0; out_high-out_low]
    value_ += out_low; // [out_low; out_high]
    return value_;
}

// This is also known as `lerp(a, b, t)`
fn mix(a: f32, b: f32, t: f32) f32 {
    return a * (1.0 - t) + b * t;
}

// This is also known as `mix(0.0, 1.0, x)`
fn linear(x: f32) f32 {
    return x;
}

// This is also known as `smoothstep(0.0, 1.0, x)`
fn smooth(x: f32) f32 {
    return x * x * (3.0 - 2.0 * x);
}

fn setMixFade(red: f32, green: f32, blue: f32, t: f32) void {
    var entries: [256]nxdk_hal.video.GAMMA_RAMP_ENTRY = undefined;
    for (0..entries.len) |i| {
        const f: f32 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(0xFF));

        entries[i].red = @trunc(@as(f32, @floatFromInt(0xFF)) * mix(f, red, t));
        entries[i].green = @trunc(@as(f32, @floatFromInt(0xFF)) * mix(f, green, t));
        entries[i].blue = @trunc(@as(f32, @floatFromInt(0xFF)) * mix(f, blue, t));
    }
    nxdk_hal.video.XVideoSetGammaRamp(0, &entries, @intCast(entries.len));
}

fn setCinematicFade(
    a_black_input: f32,
    a_white_input: f32,
    a_black_output: f32,
    a_white_output: f32,
    b_black_input: f32,
    b_white_input: f32,
    b_black_output: f32,
    b_white_output: f32,
    t: f32,
) void {
    var entries: [256]nxdk_hal.video.GAMMA_RAMP_ENTRY = undefined;
    for (0..entries.len) |i| {
        var f: f32 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(0xFF));

        // Interpolate the input and output levels
        const black_input: f32 = mix(a_black_input, b_black_input, t);
        const white_input: f32 = mix(a_white_input, b_white_input, t);
        const black_output: f32 = mix(a_black_output, b_black_output, t);
        const white_output: f32 = mix(a_white_output, b_white_output, t);

        // Remap our brightness
        if (f < black_input) {
            f = black_input;
        }
        if (f > white_input) {
            f = white_input;
        }
        f = remap(black_input, white_input, black_output, white_output, f);
        if (f < black_output) {
            f = black_output;
        }
        if (f > white_output) {
            f = white_output;
        }

        entries[i].red = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
        entries[i].green = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
        entries[i].blue = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
    }
    nxdk_hal.video.XVideoSetGammaRamp(0, &entries, @intCast(entries.len));
}

fn animateFrame(ts_start: xboxkrnl.xboxdef.DWORD, ts: xboxkrnl.xboxdef.DWORD, duration: f32) f32 {
    // Wait for the next frame
    nxdk_hal.video.XVideoWaitForVBlank();

    // Update timestamp
    const ts_delta: xboxkrnl.xboxdef.DWORD = ts - ts_start;
    const t: f32 = remap(0.0, duration, 0.0, 1.0, @floatFromInt(ts_delta));

    // Signal completion
    if (t >= 1.0) {
        return 1.0;
    }

    // Return time in range [0.0; 1.0]
    return t;
}

fn doMixFade(red: f32, green: f32, blue: f32, interpolator: fn (x: f32) f32, duration: f32) void {
    var ts_start: xboxkrnl.xboxdef.DWORD = 0;
    var t: f32 = 0.0;

    // Fade to color
    ts_start = winapi.sysinfoapi.GetTickCount();
    t = animateFrame(ts_start, winapi.sysinfoapi.GetTickCount(), duration / 2.0);
    setMixFade(red, green, blue, interpolator(t));
    while (t < 1.0) {
        t = animateFrame(ts_start, winapi.sysinfoapi.GetTickCount(), duration / 2.0);
        setMixFade(red, green, blue, interpolator(t));
    }

    // Fade to image
    ts_start = winapi.sysinfoapi.GetTickCount();
    t = animateFrame(ts_start, winapi.sysinfoapi.GetTickCount(), duration / 2.0);
    setMixFade(red, green, blue, interpolator(1.0 - t));
    while (t < 1.0) {
        t = animateFrame(ts_start, winapi.sysinfoapi.GetTickCount(), duration / 2.0);
        setMixFade(red, green, blue, interpolator(1.0 - t));
    }
}

fn doCinematicFade(
    a_black_input: f32,
    a_white_input: f32,
    a_black_output: f32,
    a_white_output: f32,
    b_black_input: f32,
    b_white_input: f32,
    b_black_output: f32,
    b_white_output: f32,
    interpolator: fn (x: f32) f32,
    duration: f32,
) void {
    var ts_start: xboxkrnl.xboxdef.DWORD = 0;
    var t: f32 = 0.0;

    // Fade to color
    ts_start = winapi.sysinfoapi.GetTickCount();
    t = animateFrame(ts_start, winapi.sysinfoapi.GetTickCount(), duration / 2.0);
    setCinematicFade(a_black_input, a_white_input, a_black_output, a_white_output, b_black_input, b_white_input, b_black_output, b_white_output, interpolator(t));
    while (t < 1.0) {
        t = animateFrame(ts_start, winapi.sysinfoapi.GetTickCount(), duration / 2.0);
        setCinematicFade(a_black_input, a_white_input, a_black_output, a_white_output, b_black_input, b_white_input, b_black_output, b_white_output, interpolator(t));
    }

    // Fade to image
    ts_start = winapi.sysinfoapi.GetTickCount();
    t = animateFrame(ts_start, winapi.sysinfoapi.GetTickCount(), duration / 2.0);
    setCinematicFade(a_black_input, a_white_input, a_black_output, a_white_output, b_black_input, b_white_input, b_black_output, b_white_output, interpolator(1.0 - t));
    while (t < 1.0) {
        t = animateFrame(ts_start, winapi.sysinfoapi.GetTickCount(), duration / 2.0);
        setCinematicFade(a_black_input, a_white_input, a_black_output, a_white_output, b_black_input, b_white_input, b_black_output, b_white_output, interpolator(1.0 - t));
    }
}

fn drawTitle(title: [:0]const u8) void {
    nxdk_hal.debug.nextCol = 25;
    nxdk_hal.debug.nextRow = 25;
    nxdk_hal.debug.debugPrint("%s", title.ptr);
    var i: usize = title.len;
    while (i < 60) : (i += 1) {
        nxdk_hal.debug.debugPrint(" ");
    }
}

pub export fn main() u8 {
    const duration: f32 = 2000.0;

    _ = nxdk_hal.video.XVideoSetMode(640, 480, 32, nxdk_hal.video.REFRESH_DEFAULT);

    // Create test image in framebuffer
    var rgbx: *volatile u32 = @ptrCast(@alignCast(nxdk_hal.video.XVideoGetFB()));
    for (0..480) |y| {
        const stripe: usize = y / (480 / 3);

        // Border left
        for (0..((640 - 512) / 2)) |_| {
            rgbx.* = 0x80_80_80;
            rgbx = @ptrFromInt(@intFromPtr(rgbx) + @sizeOf(u32));
        }
        // 512 pixels gradient
        for (0..256) |x| {
            rgbx.* = @as(u32, @intCast(x)) << (16 - @as(u5, @intCast(stripe)) * 8);
            rgbx = @ptrFromInt(@intFromPtr(rgbx) + @sizeOf(u32));
            rgbx.* = x << (16 - @as(u5, @intCast(stripe)) * 8);
            rgbx = @ptrFromInt(@intFromPtr(rgbx) + @sizeOf(u32));
        }
        // Border right
        for (0..((640 - 512) / 2)) |_| {
            rgbx.* = 0x80_80_80;
            rgbx = @ptrFromInt(@intFromPtr(rgbx) + @sizeOf(u32));
        }
    }

    while (true) {
        drawTitle("Mix fade to black (Linear)");
        doMixFade(0.0, 0.0, 0.0, linear, duration);
        winapi.synchapi.Sleep(1000);

        drawTitle("Mix fade to black (Smooth)");
        doMixFade(0.0, 0.0, 0.0, smooth, duration);
        winapi.synchapi.Sleep(1000);

        drawTitle("Mix fade to white (Linear)");
        doMixFade(1.0, 1.0, 1.0, linear, duration);
        winapi.synchapi.Sleep(1000);

        drawTitle("Mix fade to white (Smooth)");
        doMixFade(1.0, 1.0, 1.0, smooth, duration);
        winapi.synchapi.Sleep(1000);

        drawTitle("Mix fade to pink (Linear)");
        doMixFade(1.0, 0.0, 1.0, linear, duration);
        winapi.synchapi.Sleep(1000);

        drawTitle("Mix fade to pink (Smooth)");
        doMixFade(1.0, 0.0, 1.0, smooth, duration);
        winapi.synchapi.Sleep(1000);

        drawTitle("Cinematic fade to black (Linear)");
        doCinematicFade(0.0, 1.0, 0.0, 1.0, 0.7, 1.0, 0.0, 0.0, linear, duration);
        winapi.synchapi.Sleep(1000);

        drawTitle("Cinematic fade to black (Smooth)");
        doCinematicFade(0.0, 1.0, 0.0, 1.0, 0.7, 1.0, 0.0, 0.0, smooth, duration);
        winapi.synchapi.Sleep(1000);

        drawTitle("Cinematic fade to white (Linear)");
        doCinematicFade(0.0, 1.0, 0.0, 1.0, 0.0, 0.3, 1.0, 1.0, linear, duration);
        winapi.synchapi.Sleep(1000);

        drawTitle("Cinematic fade to white (Smooth)");
        doCinematicFade(0.0, 1.0, 0.0, 1.0, 0.0, 0.3, 1.0, 1.0, smooth, duration);
        winapi.synchapi.Sleep(1000);
    }

    // Unreachable

    return 0;
}
