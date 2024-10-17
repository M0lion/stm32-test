const gpio = @import("hal/gpio.zig");

pub fn main() void {
    gpio.enablePort(gpio.Port.B);
    gpio.setPinMode(gpio.Port.B, 8, gpio.GpioMode.Output);
    gpio.enablePort(gpio.Port.A);
    gpio.setPinMode(gpio.Port.A, 0, gpio.GpioMode.Output);
    var value = true;
    var i: usize = 0;
    gpio.setPin(gpio.Port.B, 8, value);
    gpio.setPin(gpio.Port.A, 0, value);
    while (true) {
        asm volatile ("nop");
        i += 1;
        if (i >= 1000000) {
            value = !value;
            gpio.setPin(gpio.Port.B, 8, value);
            gpio.setPin(gpio.Port.A, 0, value);
            i = 0;
        }
    }
}
