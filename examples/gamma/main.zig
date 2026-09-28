const std = @import("std");
const nxdk_hal = @import("nxdk_hal");
const winapi = @import("winapi");

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
        var entries: [256]nxdk_hal.video.GAMMA_RAMP_ENTRY = undefined;

        drawTitle("Linear");
        for (0..entries.len) |i| {
            entries[i].red = @intCast(i);
            entries[i].green = @intCast(i);
            entries[i].blue = @intCast(i);
        }
        nxdk_hal.video.XVideoSetGammaRamp(0, &entries, @intCast(entries.len));
        winapi.synchapi.Sleep(1000);

        drawTitle("Gamma correction (Simplified 2.2)");
        for (0..entries.len) |i| {
            var f: f32 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(0xFF));

            f = std.math.pow(f32, f, 1.0 / 2.2);

            entries[i].red = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
            entries[i].green = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
            entries[i].blue = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
        }
        nxdk_hal.video.XVideoSetGammaRamp(0, &entries, @intCast(entries.len));
        winapi.synchapi.Sleep(1000);

        drawTitle("Gamma correction (Accurate sRGB)");
        for (0..entries.len) |i| {
            var f: f32 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(0xFF));

            // https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf (Listing 30)
            const flo: f32 = f * 12.92;
            const fhi: f32 = std.math.pow(f32, f, 1.0 / 2.4) * 1.055 - 0.055;
            f = if (f <= 0.0031308) flo else fhi;

            entries[i].red = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
            entries[i].green = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
            entries[i].blue = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
        }
        nxdk_hal.video.XVideoSetGammaRamp(0, &entries, @intCast(entries.len));
        winapi.synchapi.Sleep(1000);

        drawTitle("Tonemap (Reinhard) + Gamma correction (Simplified 2.2)");
        for (0..entries.len) |i| {
            var f: f32 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(0xFF));

            // http://filmicworlds.com/blog/why-reinhard-desaturates-your-blacks/
            f = f / (f + 1.0);
            f = std.math.pow(f32, f, 1.0 / 2.2);

            entries[i].red = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
            entries[i].green = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
            entries[i].blue = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
        }
        nxdk_hal.video.XVideoSetGammaRamp(0, &entries, @intCast(entries.len));
        winapi.synchapi.Sleep(1000);

        drawTitle("Tonemap (Filmic) + Gamma correction (Simplified 2.2)");
        for (0..entries.len) |i| {
            var f: f32 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(0xFF));

            // http://filmicworlds.com/blog/why-a-filmic-curve-saturates-your-blacks/
            f = f - 0.004;
            if (f < 0.0) {
                f = 0.0;
            }
            f = (f * (6.2 * f + 0.5)) / (f * (6.2 * f + 1.7) + 0.06);

            entries[i].red = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
            entries[i].green = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
            entries[i].blue = @trunc(@as(f32, @floatFromInt(0xFF)) * f);
        }
        nxdk_hal.video.XVideoSetGammaRamp(0, &entries, @intCast(entries.len));
        winapi.synchapi.Sleep(1000);

        drawTitle("Inverse");
        for (0..entries.len) |i| {
            entries[i].red = 0xFF - @as(u8, @intCast(i));
            entries[i].green = 0xFF - @as(u8, @intCast(i));
            entries[i].blue = 0xFF - @as(u8, @intCast(i));
        }
        nxdk_hal.video.XVideoSetGammaRamp(0, &entries, @intCast(entries.len));
        winapi.synchapi.Sleep(1000);

        drawTitle("Red only");
        for (0..entries.len) |i| {
            entries[i].red = @intCast(i);
            entries[i].green = 0;
            entries[i].blue = 0;
        }
        nxdk_hal.video.XVideoSetGammaRamp(0, &entries, @intCast(entries.len));
        winapi.synchapi.Sleep(1000);

        drawTitle("Green only");
        for (0..entries.len) |i| {
            entries[i].red = 0;
            entries[i].green = @intCast(i);
            entries[i].blue = 0;
        }
        nxdk_hal.video.XVideoSetGammaRamp(0, &entries, @intCast(entries.len));
        winapi.synchapi.Sleep(1000);

        drawTitle("Blue only");
        for (0..entries.len) |i| {
            entries[i].red = 0;
            entries[i].green = 0;
            entries[i].blue = @intCast(i);
        }
        nxdk_hal.video.XVideoSetGammaRamp(0, &entries, @intCast(entries.len));
        winapi.synchapi.Sleep(1000);
    }

    // Unreachable

    return 0;
}
