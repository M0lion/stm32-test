const vectors = @import("vectors.zig");
const main = @import("main.zig").main;
const rcc = @import("hal/rcc.zig");
const gpio = @import("hal/gpio.zig");
const uart = @import("hal/uart.zig");

comptime {
    const vectorTable = vectors.VectorTable{
        .initial_stack_pointer = 0x20003fff,
        .Reset = _start,
    };

    @export(vectorTable, .{
        .name = "vector_table",
        .section = "vectors",
        .linkage = .strong,
    });
}

export fn _start() callconv(.C) void {
    meminit();

    const tx = gpio.Pin.init(gpio.Port.A, gpio.PinEnum.Pin2, gpio.GpioMode.Alternate) catch return;
    const rx = gpio.Pin.init(gpio.Port.A, gpio.PinEnum.Pin3, gpio.GpioMode.Alternate) catch return;
    const print = uart.Uart.init(tx, rx) catch return;
    defer print.deinit();
    print.write("Foo");

    main();
    while (true) {
        asm volatile ("nop");
    }
}

const sections = struct {
    extern var _data_start: u8;
    extern var _data_end: u8;
    extern var _data_load_start: u8;
    extern var _bss_start: u8;
    extern var _bss_end: u8;
};

fn meminit() void {
    const bss_start: [*]u8 = @ptrCast(&sections._bss_start);
    const bss_end: [*]u8 = @ptrCast(&sections._bss_end);
    const bss_len = @intFromPtr(bss_end) - @intFromPtr(bss_start);
    for (0..bss_len) |i| {
        bss_start[i] = 0;
    }

    const data_start: [*]u8 = @ptrCast(&sections._data_start);
    const data_end: [*]u8 = @ptrCast(&sections._data_end);
    const data_len = @intFromPtr(data_end) - @intFromPtr(data_start);
    const data_load: [*]u8 = @ptrCast(&sections._data_load_start);
    for (0..data_len) |i| {
        data_start[i] = data_load[i];
    }
}
