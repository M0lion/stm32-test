const rcc = @import("rcc.zig");
const std = @import("std");
const Register = @import("register.zig").Register;

pub const Port = enum(u8) {
    A = 'A',
    B = 'B',
    C = 'C',
    D = 'D',
    E = 'E',
    F = 'F',
    G = 'G',
};

pub fn enablePort(comptime port: Port) void {
    var enableRegister = rcc.RCC_AHB2ENR.read();
    @field(enableRegister, std.fmt.comptimePrint("GPIO{c}EN", .{@intFromEnum(port)})) = true;
    rcc.RCC_AHB2ENR.write(enableRegister);
}

pub fn setPinMode(comptime port: Port, comptime pin: u9, mode: GpioMode) void {
    const portReg = getGpioReg(port);
    var moder = portReg.MODER.read();
    @field(moder, std.fmt.comptimePrint("Mode{}", .{pin})) = mode;
    portReg.MODER.write(moder);
}

pub fn setPin(comptime port: Port, comptime pin: u9, value: bool) void {
    const portReg = getGpioReg(port);
    var bsrr = portReg.BSRR.read();
    if (value) {
        @field(bsrr, std.fmt.comptimePrint("BS{}", .{pin})) = true;
    } else {
        @field(bsrr, std.fmt.comptimePrint("BR{}", .{pin})) = true;
    }
    portReg.BSRR.write(bsrr);
}

inline fn getGpioReg(comptime port: Port) *volatile GpioRegister {
    return @field(gpioRegisters, std.fmt.comptimePrint("{c}", .{@intFromEnum(port)}));
}

pub const GpioMode = enum(u2) {
    Input,
    Output,
    Alternate,
    Analog,
};

const GpioRegisters = packed struct {
    A: *volatile GpioRegister,
    B: *volatile GpioRegister,
    C: *volatile GpioRegister,
    D: *volatile GpioRegister,
    E: *volatile GpioRegister,
    F: *volatile GpioRegister,
    G: *volatile GpioRegister,
};
const GPIO_BASE = 0x48000000;
const gpioRegisters = GpioRegisters{
    .A = @ptrFromInt(GPIO_BASE + (0x400 * 0)),
    .B = @ptrFromInt(GPIO_BASE + (0x400 * 1)),
    .C = @ptrFromInt(GPIO_BASE + (0x400 * 2)),
    .D = @ptrFromInt(GPIO_BASE + (0x400 * 3)),
    .E = @ptrFromInt(GPIO_BASE + (0x400 * 4)),
    .F = @ptrFromInt(GPIO_BASE + (0x400 * 5)),
    .G = @ptrFromInt(GPIO_BASE + (0x400 * 6)),
};

const GPIO_B = 0x48000400;
const MODERB: *volatile Register(MODER) = @ptrFromInt(GPIO_B);
const BSRRB: *volatile Register(BSRR) = @ptrFromInt(GPIO_B + 0x18);
const GPIOB: *volatile GpioRegister = @ptrFromInt(GPIO_B);

const GpioRegister = packed struct {
    MODER: Register(MODER),
    OTYPER: u32,
    OSPEEDR: u32,
    PUPDR: u32,
    IDR: u32,
    ODR: u32,
    BSRR: Register(BSRR),
    LCKR: u32,
    AFRL: u32,
    AFRH: u32,
    BRR: u32,
};

const MODER = packed struct {
    Mode0: GpioMode,
    Mode1: GpioMode,
    Mode2: GpioMode,
    Mode3: GpioMode,
    Mode4: GpioMode,
    Mode5: GpioMode,
    Mode6: GpioMode,
    Mode7: GpioMode,
    Mode8: GpioMode,
    Mode9: GpioMode,
    Mode10: GpioMode,
    Mode11: GpioMode,
    Mode12: GpioMode,
    Mode13: GpioMode,
    Mode14: GpioMode,
    Mode15: GpioMode,
};

const BSRR = packed struct {
    BS0: bool,
    BS1: bool,
    BS2: bool,
    BS3: bool,
    BS4: bool,
    BS5: bool,
    BS6: bool,
    BS7: bool,
    BS8: bool,
    BS9: bool,
    BS10: bool,
    BS11: bool,
    BS12: bool,
    BS13: bool,
    BS14: bool,
    BS15: bool,
    BR0: bool,
    BR1: bool,
    BR2: bool,
    BR3: bool,
    BR4: bool,
    BR5: bool,
    BR6: bool,
    BR7: bool,
    BR8: bool,
    BR9: bool,
    BR10: bool,
    BR11: bool,
    BR12: bool,
    BR13: bool,
    BR14: bool,
    BR15: bool,
};
