pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{ .inherits = ConsoleUartI });
pub const em__C = em__U.config(EM__CONFIG);

pub const ConsoleUartI = em.import.@"em.hal/ConsoleUartI";
pub const Idle = em.import.@"ti.mcu.cc23xx/Idle";
pub const GpioI = em.import.@"em.hal/GpioI";

pub const EM__CONFIG = struct {
    TxPin: em.Proxy(GpioI),
};

pub const EM__META = struct {
    //
    pub const x_TxPin = em__C.TxPin;

    pub fn em__configureM() void {
        Idle.addSleepEnterCbM(em__U.fxn("sleepEnter", Idle.SleepCbArg));
        Idle.addSleepLeaveCbM(em__U.fxn("sleepLeave", Idle.SleepCbArg));
    }
};

pub const EM__TARG = struct {
    //
    const TxPin = em__C.TxPin.unwrap();

    const hal = em.hal;
    const reg = em.reg;

    pub fn em__startup() void {
        EM__TARG.sleepLeave(.{});
    }

    pub fn flush() void {
        while ((reg(hal.UART0_BASE + hal.UART_O_FR).* & hal.UART_FR_BUSY) != 0) {}
    }

    pub fn put(data: u8) void {
        reg(hal.UART0_BASE + hal.UART_O_DR).* = data;
        EM__TARG.flush();
    }

    pub fn sleepEnter(_: Idle.SleepCbArg) void {
        reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENCLR0).* = hal.CLKCTL_CLKENCLR0_UART0;
        TxPin.reset();
    }

    pub fn sleepLeave(_: Idle.SleepCbArg) void {
        reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENSET0).* = hal.CLKCTL_CLKENSET0_UART0;
        TxPin.makeOutput();
        TxPin.set();
        TxPin.functionSelect(2);
        reg(hal.UART0_BASE + hal.UART_O_CTL).* &= ~hal.UART_CTL_UARTEN;
        reg(hal.UART0_BASE + hal.UART_O_IBRD).* = 26; // 115200 baud
        reg(hal.UART0_BASE + hal.UART_O_FBRD).* = 3;
        reg(hal.UART0_BASE + hal.UART_O_LCRH).* = hal.UART_LCRH_WLEN_BITL8;
        reg(hal.UART0_BASE + hal.UART_O_CTL).* |= hal.UART_CTL_UARTEN;
    }
};

//->> zigem publish #|23088d3ec420f88e5f8d765e10272b527e8cc26ccc99921b9682990d886ace75|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__META publics
pub const x_TxPin = EM__META.x_TxPin;

//->> EM__TARG publics
pub const flush = EM__TARG.flush;
pub const put = EM__TARG.put;
pub const sleepEnter = EM__TARG.sleepEnter;
pub const sleepLeave = EM__TARG.sleepLeave;
