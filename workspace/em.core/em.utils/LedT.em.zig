pub const em = @import("../../zigem/em.zig");
pub const em__T = em.template(@This(), .{});

pub const EM__CONFIG = struct {
    em__upath: []const u8,
    Pin: em.Proxy(GpioI),
    active_low: em.Param(bool),
};

pub const GpioI = em.import.@"em.hal/GpioI";

pub fn em__generateS(comptime name: []const u8) type {
    return struct {
        //
        pub const em__U = em.module(@This(), .{
            .inherits = LedI,
            .generated = true,
            .name = name,
        });
        pub const em__C = em__U.config(EM__CONFIG);

        pub const c_active_low = em__C.active_low;
        pub const x_Pin = em__C.Pin;

        pub const LedI = em.import.@"em.hal/LedI";
        pub const Poller = em.import.@"em.mcu/Poller";

        pub const off = EM__TARG.off;
        pub const on = EM__TARG.on;
        pub const toggle = EM__TARG.toggle;
        pub const wink = EM__TARG.wink;

        pub const EM__META = struct {
            //
            pub fn em__initH() void {
                em__C.active_low.set(false);
            }
        };

        pub const EM__TARG = struct {
            //
            const active_low = em__C.active_low.get();
            const Pin = if (em.IS_META) .{} else em__C.Pin.get(); // TODO Pin.default()

            pub fn em__startup() void {
                if (em.IS_META) return;
                Pin.makeOutput();
                EM__TARG.off();
            }

            fn off() void {
                if (em.IS_META) return;
                if (active_low) Pin.set() else Pin.clear();
            }

            fn on() void {
                if (em.IS_META) return;
                if (active_low) Pin.clear() else Pin.set();
            }

            fn toggle() void {
                if (em.IS_META) return;
                Pin.toggle();
            }

            fn wink(msecs: u32) void {
                if (em.IS_META) return;
                EM__TARG.on();
                Poller.pause(msecs);
                EM__TARG.off();
            }
        };
    };
}
