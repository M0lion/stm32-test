const Register = @import("register.zig").Register;
const gpio = @import("gpio.zig");
const rcc = @import("rcc.zig");

pub const EUart = enum(u3) {
    Uart1,
    Uart2,
    Uart3,
    Uart4,
    Uart5,
};

const uartError = error{
    NotImplemented,
};

pub const Uart = struct {
    uart: EUart,
    tx: gpio.Pin,
    rx: gpio.Pin,

    pub fn init(uart: EUart, tx: gpio.Pin, rx: gpio.Pin) !Uart {
        var apbEn = rcc.RCC_APB1ENR1.read();
        apbEn.USART2EN = true;
        rcc.RCC_APB1ENR1.write(apbEn);

        tx.setMode(gpio.GpioMode.Alternate);
        tx.setAlternate(0b0111);
        rx.setMode(gpio.GpioMode.Alternate);
        rx.setAlternate(0b0111);

        const reg = getUart(uart);

        var brr = reg.BRR.read();
        brr.BRR = 16000000 / 115200;
        reg.BRR.write(brr);

        var cr1 = reg.CR1.read();
        cr1.UE = false;
        reg.CR1.write(cr1);

        // Set word length
        cr1.M1 = false;
        cr1.M0 = false;
        reg.CR1.write(cr1);

        // Set stop bits
        var cr2 = reg.CR2.read();
        cr2.STOP = 0;
        reg.CR2.write(cr2);

        // Disable hardware/software(?) control
        var cr3 = reg.CR3.read();
        cr3.CTSE = false;
        cr3.RTSE = false;
        reg.CR3.write(cr3);

        // Enable uart and tx/rx
        cr1.TE = true;
        cr1.RE = true;
        reg.CR1.write(cr1);
        cr1.UE = true;
        reg.CR1.write(cr1);

        return Uart{
            .uart = uart,
            .tx = tx,
            .rx = rx,
        };
    }

    pub fn deinit(self: Uart) void {
        self.tx.deinit();
        self.rx.deinit();
    }

    pub fn write(self: Uart, buffer: []const u8) void {
        const reg = getUart(self.uart);
        for (buffer) |char| {
            reg.TDR.raw = @as(u32, char);
            while (!reg.ISR.read().TXFNF) {
                asm volatile ("nop");
            }
        }
    }
};

fn getUart(uart: EUart) *volatile UART {
    return switch (uart) {
        EUart.Uart1 => @ptrFromInt(0x40013800),
        EUart.Uart2 => @ptrFromInt(0x40004400),
        EUart.Uart3 => @ptrFromInt(0x40004800),
        EUart.Uart4 => @ptrFromInt(0x40004c00),
        EUart.Uart5 => @ptrFromInt(0x40005000),
    };
}

const UART = packed struct {
    CR1: Register(USART_CR1),
    CR2: Register(USART_CR2),
    CR3: Register(USART_CR3),
    BRR: Register(USART_BRR),
    GTPR: u32,
    RTOR: u32,
    RQR: u32,
    ISR: Register(USART_ISR),
    ICR: u32,
    RDR: u32,
    TDR: Register(u32),
    PRESC: u32,
};

const USART_CR1 = packed struct {
    UE: bool,
    UESM: bool,
    RE: bool,
    TE: bool,
    IDLEIE: bool,
    RXFNEIE: bool,
    TCIE: bool,
    TXFNFIE: bool,
    PEIE: bool,
    PS: bool,
    PCE: bool,
    WAKE: bool,
    M0: bool,
    MME: bool,
    CMIE: bool,
    OVER8: bool,
    DEDT: u5,
    DEAT: u5,
    RTOIE: bool,
    EOBIE: bool,
    M1: bool,
    FIFOEN: bool,
    TXFEIE: bool,
    RXFFIE: bool,
};

const USART_CR2 = packed struct {
    SLVEN: bool,
    reserved1: u2,
    DIS_NSS: bool,
    ADDM7: bool,
    LBDL: bool,
    LBDIE: bool,
    reserved0: u1,
    LBCL: bool,
    CPHA: bool,
    CPOL: bool,
    CLKEN: bool,
    STOP: u2,
    LINEN: bool,
    SWAP: bool,
    RXINV: bool,
    TXINV: bool,
    DATAINV: bool,
    MSBFIRST: bool,
    ABREN: bool,
    ABRMOD: u2,
    RTOEN: bool,
    ADD: u8,
};

const USART_CR3 = packed struct {
    EIE: bool,
    IREN: bool,
    IRLP: bool,
    HDSEL: bool,
    NACK: bool,
    SCEN: bool,
    DMAR: bool,
    DMAT: bool,
    RTSE: bool,
    CTSE: bool,
    CTSIE: bool,
    ONEBIT: bool,
    OVRDIS: bool,
    DDRE: bool,
    DEM: bool,
    DEP: bool,
    reserved: u1,
    SCARCNT: u3,
    WUS: u2,
    WUFIE: bool,
    TXFTIE: bool,
    TCBGTIE: bool,
    RXFTCFG: u3,
    RXFTIE: bool,
    TXFTCFG: u3,
};

const USART_BRR = packed struct {
    BRR: u16,
    reserved: u16,
};

const USART_ISR = packed struct {
    PR: bool,
    FE: bool,
    NE: bool,
    ORE: bool,
    IDLE: bool,
    RXFNE: bool,
    TC: bool,
    TXFNF: bool,
    LBDF: bool,
    CTSIF: bool,
    CTS: bool,
    RTOF: bool,
    EOBF: bool,
    UDR: bool,
    ABRE: bool,
    ABRF: bool,
    BUSY: bool,
    CMF: bool,
    SBKF: bool,
    RWU: bool,
    WUF: bool,
    TEACK: bool,
    REACK: bool,
    TXFE: bool,
    RXFF: bool,
    TCBGT: bool,
    RXFT: bool,
    TXFT: bool,
    reservec: u4,
};
