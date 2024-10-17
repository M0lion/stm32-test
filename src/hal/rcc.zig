const Register = @import("register.zig").Register;

const RCC_REGISTER_BASE = 0x40021000;
const RCC_AHB2ENR_TYPE = packed struct {
    GPIOAEN: bool,
    GPIOBEN: bool,
    GPIOCEN: bool,
    GPIODEN: bool,
    GPIOEEN: bool,
    GPIOFEN: bool,
    GPIOGEN: bool,
    reservec1: u6,
    ADC12EN: bool,
    ADC345EN: bool,
    reserved2: u1,
    DAC1EN: bool,
    DAC2EN: bool,
    DAC3EN: bool,
    DAC4EN: bool,
    reserved3: u4,
    AESEN: bool,
    reserved4: u1,
    RNGEN: bool,
    reserved5: u5,
};
pub const RCC_AHB2ENR: *volatile Register(RCC_AHB2ENR_TYPE) = @ptrFromInt(RCC_REGISTER_BASE + 0x4c);
