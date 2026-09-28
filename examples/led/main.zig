const nxdk_hal = @import("nxdk_hal");
const winapi = @import("winapi");

pub export fn main() u8 {
    // Set front LEDs to shine green, red and then turned off in a repeating pattern.
    nxdk_hal.led.XSetCustomLED(.XLED_GREEN, .XLED_RED, .XLED_OFF, .XLED_OFF);

    // nxdk_hal.led.XResetLED() can be used to restore system control of the front LEDs

    // If we quit, the LED might get reset, so we loop forever
    while (true) {
        winapi.synchapi.Sleep(1000);
    }

    return 0;
}
