const em = @import("../../.gen/em.zig");

pub const BoardC = em.import.em__distro.BoardC;

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "gist.cc23xx/Gist00_Min",
    .self = @This(),
};

const Hal: type = BoardC.Hal;
const REG = em.REG;

pub fn em__run() void {
    const pin = 15;
    const mask = (1 << pin);
    REG(Hal.GPIO_BASE + Hal.GPIO_O_DOESET31_0).* = mask;
    REG(Hal.IOC_BASE + Hal.IOC_O_IOC0 + pin * 4).* &= ~Hal.IOC_IOC0_INPEN;
    REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTSET31_0).* = mask;
}
