pub const em = @import("../../zigem/em.zig");
pub const em__T = em.template(@This(), .{});

pub const EM__CONFIG = struct {
    em__upath: []const u8,
    Pin: em.Proxy(em.import.@"em.hal/GpioI"),
    active_low: em.Param(bool),
};

pub fn em__generateS(comptime name: []const u8) type {
    return struct {
        //
        pub const em__U = em.module(@This(), .{
            .inherits = em.import.@"em.hal/LedI",
            .generated = true,
            .name = name,
        });
        pub const em__C = em__U.config(EM__CONFIG);

        pub const Poller = em.import.@"em.mcu/Poller";

        pub const EM__META = struct {
            //
            pub const active_low = em__C.active_low;
            pub const Pin = em__C.Pin;

            pub fn em__initH() void {
                active_low.set(false);
            }
        };

        pub const EM__TARG = struct {
            //
            const active_low = em__C.active_low;
            const Pin = em__C.Pin.scope();

            pub fn em__startup() void {
                Pin.makeOutput();
                off();
            }

            pub fn off() void {
                if (active_low) Pin.set() else Pin.clear();
            }

            pub fn on() void {
                if (active_low) Pin.clear() else Pin.set();
            }

            pub fn toggle() void {
                Pin.toggle();
            }

            pub fn wink(msecs: u32) void {
                on();
                Poller.pause(msecs);
                off();
            }
        };
    };
}
