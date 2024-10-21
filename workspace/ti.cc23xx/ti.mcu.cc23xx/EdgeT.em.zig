pub const em = @import("../../zigem/em.zig");
pub const em__T = em.template(@This(), .{});

pub const EM__CONFIG = struct {
    em__upath: []const u8,
    Pin: em.Proxy(GpioI),
    pin: em.Param(i16),
};

pub const GpioI = em.import.@"em.hal/GpioI";

pub fn em__generateS(comptime name: []const u8) type {
    return struct {
        pub const em__U = em.module(
            @This(),
            .{
                .inherits = EdgeI,
                .generated = true,
                .name = name,
            },
        );
        pub const em__C = em__U.config(EM__CONFIG);

        pub const Aux = em.import.@"ti.mcu.cc23xx/EdgeAux";
        pub const EdgeI = em.import.@"em.hal/EdgeI";
        pub const GpioT = em.import.@"ti.mcu.cc23xx/GpioT";

        pub const Pin = em__U.Generate("Pin", GpioT);

        pub const HandlerArg = EdgeI.HandlerArg;
        pub const HandlerFxn = EdgeI.HandlerFxn;

        pub const EM__META = struct {
            //
            pub const c_pin = em__C.pin;

            pub fn em__initM() void {
                em__C.pin.setM(-1);
            }

            pub fn em__constructM() void {
                Pin.c_pin.setM(em__C.pin.getM());
            }

            pub fn setDetectHandlerM(h: HandlerFxn) void {
                Aux.addHandlerInfoM(.{ .handler = h, .mask = mkMask(em__C.pin.getM()) });
            }
        };

        pub const EM__TARG = struct {
            //
            const pin = em__C.pin.unwrap();
            const is_def = (pin >= 0);
            const mask = mkMask(pin);
            const off = @as(u32, hal.IOC_O_IOC0 + @as(u16, @bitCast(pin)) * 4);

            const hal = em.hal;
            const reg = em.reg;

            pub fn clearDetect() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_ICLR).* = mask;
            }

            pub fn disableDetect() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_IMCLR).* = mask;
                if (is_def) reg(hal.IOC_BASE + off).* &= ~hal.IOC_IOC0_WUENSB;
            }

            pub fn enableDetect() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_IMSET).* = mask;
                if (is_def) reg(hal.IOC_BASE + off).* |= hal.IOC_IOC0_WUENSB;
            }

            pub fn getState() bool {
                return Pin.get();
            }

            pub fn init(pullup: bool) void {
                Pin.makeInput();
                Pin.setInternalPullup(pullup);
            }

            pub fn setDetectFallingEdge() void {
                if (is_def) reg(hal.IOC_BASE + off).* &= ~hal.IOC_IOC0_EDGEDET_M;
                if (is_def) reg(hal.IOC_BASE + off).* |= hal.IOC_IOC0_EDGEDET_EDGE_NEG;
            }

            pub fn setDetectRisingEdge() void {
                if (is_def) reg(hal.IOC_BASE + off).* &= ~hal.IOC_IOC0_EDGEDET_M;
                if (is_def) reg(hal.IOC_BASE + off).* |= hal.IOC_IOC0_EDGEDET_EDGE_POS;
            }
        };

        fn mkMask(p16: i16) u32 {
            const p5 = @as(u5, @bitCast(@as(i5, @truncate(p16))));
            const m: u32 = @as(u32, 1) << p5;
            return m;
        }

        
        //->> zigem publish #|bab45af6847c3103f58e3bbda24483b3fb1cb8323a0444d19d762eb5ab40f0df|#

        //->> EM__META publics
        pub const c_pin = EM__META.c_pin;
        pub const setDetectHandlerM = EM__META.setDetectHandlerM;

        //->> EM__TARG publics
        pub const clearDetect = EM__TARG.clearDetect;
        pub const disableDetect = EM__TARG.disableDetect;
        pub const enableDetect = EM__TARG.enableDetect;
        pub const getState = EM__TARG.getState;
        pub const init = EM__TARG.init;
        pub const setDetectFallingEdge = EM__TARG.setDetectFallingEdge;
        pub const setDetectRisingEdge = EM__TARG.setDetectRisingEdge;

        //->> zigem publish -- end of generated code
    };
}
