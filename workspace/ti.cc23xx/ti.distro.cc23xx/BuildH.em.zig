pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .meta_only = true,
});

pub const BoardC = em.import.@"em__distro/BoardC";
pub const IntrVec = em.import.@"em.arch.arm/IntrVec";
pub const LinkerH = em.import.@"em.build.misc/LinkerH";
pub const StartupH = em.import.@"em.arch.arm/StartupH";

pub fn em__configureH() void {
    const nvic_intrs = [_][]const u8{
        "CPUIRQ0",
        "CPUIRQ1",
        "CPUIRQ2",
        "CPUIRQ3",
        "CPUIRQ4",
        "GPIO_COMB",
        "LRFD_IRQ0",
        "LRFD_IRQ1",
        "DMA_DONE_COMB",
        "AES_COMB",
        "SPI0_COMB",
        "UART0_COMB",
        "I2C0_IRQ",
        "LGPT0_COMB",
        "LGPT1_COMB",
        "ADC0_COMB",
        "CPUIRQ16",
        "LGPT2_COMB",
        "LGPT3_COMB",
    };
    for (nvic_intrs) |n| {
        IntrVec.addIntrH(n);
    }
}
