const uart = @import("hal/uart.zig");
const gpio = @import("hal/gpio.zig");

var stdout: uart.Uart = undefined;
var initialized = false;

pub fn init() void {
    const tx = gpio.Pin.init(gpio.Port.A, gpio.EPin.Pin2, gpio.GpioMode.Alternate) catch return;
    const rx = gpio.Pin.init(gpio.Port.A, gpio.EPin.Pin3, gpio.GpioMode.Alternate) catch return;
    stdout = uart.Uart.init(uart.EUart.Uart2, tx, rx) catch return;
    initialized = true;
    stdout.write("stdout initialized\n\r");
}

pub fn printf(buffer: []const u8) void {
    if (!initialized) {
        init();
    }
    stdout.write(buffer);
}
