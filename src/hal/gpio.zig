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
const portCount: usize = 7;

pub const EPin = enum(usize) {
    Pin0,
    Pin1,
    Pin2,
    Pin3,
    Pin4,
    Pin5,
    Pin6,
    Pin7,
    Pin8,
    Pin9,
    Pin10,
    Pin11,
    Pin12,
    Pin13,
    Pin14,
    Pin15,
};
const pinCount: usize = 16;

var pinAllocations = [_]bool{false} ** (portCount * pinCount);

pub const GpioError = error{
    PinAlreadyAllocated,
};

pub const Pin = struct {
    port: Port,
    pin: EPin,
    mode: GpioMode,

    pub fn init(port: Port, pin: EPin, mode: GpioMode) !Pin {
        const index = pinIndex(port, pin);
        if (pinAllocations[index]) {
            //return GpioError.PinAlreadyAllocated;
        }

        pinAllocations[index] = true;

        enablePort(port);
        setPinMode(port, pin, mode);

        return Pin{
            .port = port,
            .pin = pin,
            .mode = mode,
        };
    }

    fn pinIndex(port: Port, pin: EPin) usize {
        return (portCount * @intFromEnum(port) - 'A') + @intFromEnum(pin);
    }

    pub fn setMode(self: Pin, mode: GpioMode) void {
        setPinMode(self.port, self.pin, mode);
    }

    pub fn write(self: Pin, value: bool) void {
        setPin(self.port, self.pin, value);
    }

    pub fn setAlternate(self: Pin, mode: u4) void {
        const reg = getGpioReg(self.port);
        switch (self.pin) {
            EPin.Pin0 => {
                var val = reg.AFRL.read();
                val.Pin0 = mode;
                reg.AFRL.write(val);
            },
            EPin.Pin1 => {
                var val = reg.AFRL.read();
                val.Pin1 = mode;
                reg.AFRL.write(val);
            },
            EPin.Pin2 => {
                var val = reg.AFRL.read();
                val.Pin2 = mode;
                reg.AFRL.write(val);
            },
            EPin.Pin3 => {
                var val = reg.AFRL.read();
                val.Pin3 = mode;
                reg.AFRL.write(val);
            },
            EPin.Pin4 => {
                var val = reg.AFRL.read();
                val.Pin4 = mode;
                reg.AFRL.write(val);
            },
            EPin.Pin5 => {
                var val = reg.AFRL.read();
                val.Pin5 = mode;
                reg.AFRL.write(val);
            },
            EPin.Pin6 => {
                var val = reg.AFRL.read();
                val.Pin6 = mode;
                reg.AFRL.write(val);
            },
            EPin.Pin7 => {
                var val = reg.AFRL.read();
                val.Pin7 = mode;
                reg.AFRL.write(val);
            },
            EPin.Pin8 => {
                var val = reg.AFRH.read();
                val.Pin8 = mode;
                reg.AFRH.write(val);
            },
            EPin.Pin9 => {
                var val = reg.AFRH.read();
                val.Pin9 = mode;
                reg.AFRH.write(val);
            },
            EPin.Pin10 => {
                var val = reg.AFRH.read();
                val.Pin10 = mode;
                reg.AFRH.write(val);
            },
            EPin.Pin11 => {
                var val = reg.AFRH.read();
                val.Pin11 = mode;
                reg.AFRH.write(val);
            },
            EPin.Pin12 => {
                var val = reg.AFRH.read();
                val.Pin12 = mode;
                reg.AFRH.write(val);
            },
            EPin.Pin13 => {
                var val = reg.AFRH.read();
                val.Pin13 = mode;
                reg.AFRH.write(val);
            },
            EPin.Pin14 => {
                var val = reg.AFRH.read();
                val.Pin14 = mode;
                reg.AFRH.write(val);
            },
            EPin.Pin15 => {
                var val = reg.AFRH.read();
                val.Pin15 = mode;
                reg.AFRH.write(val);
            },
        }
    }

    pub fn deinit(self: Pin) void {
        const index = pinIndex(self.port, self.pin);
        pinAllocations[index] = false;
    }
};

pub fn enablePort(port: Port) void {
    var enableRegister = rcc.RCC_AHB2ENR.read();
    switch (port) {
        Port.A => enableRegister.GPIOAEN = true,
        Port.B => enableRegister.GPIOBEN = true,
        Port.C => enableRegister.GPIOCEN = true,
        Port.D => enableRegister.GPIODEN = true,
        Port.E => enableRegister.GPIOEEN = true,
        Port.F => enableRegister.GPIOFEN = true,
        Port.G => enableRegister.GPIOGEN = true,
    }
    rcc.RCC_AHB2ENR.write(enableRegister);
}

pub fn setPinMode(port: Port, pin: EPin, mode: GpioMode) void {
    const portReg = getGpioReg(port);
    var moder = portReg.MODER.read();
    moder.setPinMode(pin, mode);
    portReg.MODER.write(moder);
}

pub fn setPin(port: Port, pin: EPin, value: bool) void {
    const portReg = getGpioReg(port);
    var bsrr = portReg.BSRR.read();
    if (value) {
        bsrr.set(pin);
    } else {
        bsrr.clear(pin);
    }
    portReg.BSRR.write(bsrr);
}

inline fn getGpioReg(port: Port) *volatile GpioRegister {
    return switch (port) {
        Port.A => gpioRegisters.A,
        Port.B => gpioRegisters.B,
        Port.C => gpioRegisters.C,
        Port.D => gpioRegisters.D,
        Port.E => gpioRegisters.E,
        Port.F => gpioRegisters.F,
        Port.G => gpioRegisters.G,
    };
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
    AFRL: Register(AFRL),
    AFRH: Register(AFRH),
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

    pub fn setPinMode(self: *MODER, pin: EPin, mode: GpioMode) void {
        switch (pin) {
            EPin.Pin0 => self.Mode0 = mode,
            EPin.Pin1 => self.Mode1 = mode,
            EPin.Pin2 => self.Mode2 = mode,
            EPin.Pin3 => self.Mode3 = mode,
            EPin.Pin4 => self.Mode4 = mode,
            EPin.Pin5 => self.Mode5 = mode,
            EPin.Pin6 => self.Mode6 = mode,
            EPin.Pin7 => self.Mode7 = mode,
            EPin.Pin8 => self.Mode8 = mode,
            EPin.Pin9 => self.Mode9 = mode,
            EPin.Pin10 => self.Mode10 = mode,
            EPin.Pin11 => self.Mode11 = mode,
            EPin.Pin12 => self.Mode12 = mode,
            EPin.Pin13 => self.Mode13 = mode,
            EPin.Pin14 => self.Mode14 = mode,
            EPin.Pin15 => self.Mode15 = mode,
        }
    }
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

    pub fn set(self: *BSRR, pin: EPin) void {
        switch (pin) {
            EPin.Pin0 => self.BS0 = true,
            EPin.Pin1 => self.BS1 = true,
            EPin.Pin2 => self.BS2 = true,
            EPin.Pin3 => self.BS3 = true,
            EPin.Pin4 => self.BS4 = true,
            EPin.Pin5 => self.BS5 = true,
            EPin.Pin6 => self.BS6 = true,
            EPin.Pin7 => self.BS7 = true,
            EPin.Pin8 => self.BS8 = true,
            EPin.Pin9 => self.BS9 = true,
            EPin.Pin10 => self.BS10 = true,
            EPin.Pin11 => self.BS11 = true,
            EPin.Pin12 => self.BS12 = true,
            EPin.Pin13 => self.BS13 = true,
            EPin.Pin14 => self.BS14 = true,
            EPin.Pin15 => self.BS15 = true,
        }
    }

    pub fn clear(self: *BSRR, pin: EPin) void {
        switch (pin) {
            EPin.Pin0 => self.BR0 = true,
            EPin.Pin1 => self.BR1 = true,
            EPin.Pin2 => self.BR2 = true,
            EPin.Pin3 => self.BR3 = true,
            EPin.Pin4 => self.BR4 = true,
            EPin.Pin5 => self.BR5 = true,
            EPin.Pin6 => self.BR6 = true,
            EPin.Pin7 => self.BR7 = true,
            EPin.Pin8 => self.BR8 = true,
            EPin.Pin9 => self.BR9 = true,
            EPin.Pin10 => self.BR10 = true,
            EPin.Pin11 => self.BR11 = true,
            EPin.Pin12 => self.BR12 = true,
            EPin.Pin13 => self.BR13 = true,
            EPin.Pin14 => self.BR14 = true,
            EPin.Pin15 => self.BR15 = true,
        }
    }
};

const AFRL = packed struct {
    Pin0: u4,
    Pin1: u4,
    Pin2: u4,
    Pin3: u4,
    Pin4: u4,
    Pin5: u4,
    Pin6: u4,
    Pin7: u4,
};

const AFRH = packed struct {
    Pin8: u4,
    Pin9: u4,
    Pin10: u4,
    Pin11: u4,
    Pin12: u4,
    Pin13: u4,
    Pin14: u4,
    Pin15: u4,
};
