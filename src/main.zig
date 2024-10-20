const gpio = @import("hal/gpio.zig");

pub fn main() void {
    const led = gpio.Pin.init(gpio.Port.B, gpio.PinEnum.Pin8, gpio.GpioMode.Output) catch return;
    defer led.deinit();
    var value = true;
    var i: usize = 0;
    while (true) {
        asm volatile ("nop");
        i += 1;
        if (i >= 800000) {
            value = !value;
            led.write(value);
            i = 0;
        }
    }
}
