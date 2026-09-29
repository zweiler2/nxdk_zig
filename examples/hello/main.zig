const nxdk_hal = @import("nxdk_hal");
const winapi = @import("winapi");

pub fn main() !void {
    _ = nxdk_hal.video.XVideoSetMode(640, 480, 32, nxdk_hal.video.REFRESH_DEFAULT);

    while (true) {
        nxdk_hal.debug.debugPrint("Hello there!\n");
        winapi.synchapi.Sleep(1000);
    }

    return 0;
}
