pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    handler_info_tab: em.Table(HandlerInfo, .RO),
};

pub const EdgeI = em.import.@"em.hal/EdgeI";
pub const IntrVec = em.import.@"em.arch.arm/IntrVec";

pub const HandlerInfo = struct {
    mask: u32,
    handler: EdgeI.HandlerFxn,
};

pub const EM__META = struct {
    //
    pub fn em__constructM() void {
        IntrVec.useIntrM("GPIO_COMB");
    }

    pub fn addHandlerInfoM(hi: HandlerInfo) void {
        em__C.handler_info_tab.addM(hi);
    }
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    pub fn em__startup() void {
        hal.NVIC_EnableIRQ(hal.GPIO_COMB_IRQn);
    }

    export fn GPIO_COMB_isr() void {
        if (em.IS_META) return;
        const mis = reg(hal.GPIO_BASE + hal.GPIO_O_MIS).*;
        for (em__C.handler_info_tab.items()) |hi| {
            if ((mis & hi.mask) != 0 and hi.handler != null) {
                hi.handler.?(.{});
            }
        }
        reg(hal.GPIO_BASE + hal.GPIO_O_ICLR).* = 0xffffffff; // TODO: use `mis`
    }
};


//->> zigem publish #|16f4832dafc516134185fa5138e55ba877c2dedb7c45b2b27555f1f2ca7161d9|#

//->> EM__META publics
pub const addHandlerInfoM = EM__META.addHandlerInfoM;

//->> EM__TARG publics

//->> zigem publish -- end of generated code
