pub const em = @import("../../build/.gen/em.zig");
pub const em__T = em.template(@This(), .{});

pub const EM__CONFIG = struct {
    em__upath: []const u8,
    pin: em.Param(i16),
};

pub fn em__generateS(comptime name: []const u8) type {
    return struct {
        pub const em__U = em.module(
            @This(),
            .{
                .inherits = em.import.@"em.hal/GpioI",
                .generated = true,
                .name = name,
            },
        );
        pub const em__C = em__U.config(EM__CONFIG);

        pub const EM__HOST = struct {
            //
            pub const pin = em__C.pin;

            pub fn em__initH() void {
                pin.set(-1);
            }
        };

        pub const EM__TARG = struct {
            //

            const pin = em__C.pin;
            const is_def = (pin >= 0);
            const mask = init: {
                const p5 = @as(u5, @bitCast(@as(i5, @truncate(pin))));
                const m: u32 = @as(u32, 1) << p5;
                break :init m;
            };
            const off = @as(u32, hal.IOC_O_IOC0 + @as(u16, @bitCast(pin)) * 4);

            const hal = em.hal;
            const reg = em.reg;

            pub fn clear() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOUTCLR31_0).* = mask;
            }

            pub fn functionSelect(select: u8) void {
                if (is_def) reg(@as(u32, hal.IOC_BASE) + off).* = select;
            }

            pub fn get() bool {
                if (!is_def) return false;
                return if (isInput()) (reg(hal.GPIO_BASE + hal.GPIO_O_DIN31_0).* & mask) != 0 else (reg(hal.GPIO_BASE + hal.GPIO_O_DOUT31_0).* & mask) != 0;
            }

            pub fn isInput() bool {
                return is_def and (reg(hal.GPIO_BASE + hal.GPIO_O_DOE31_0).* & mask) == 0;
            }

            pub fn isOutput() bool {
                return is_def and (reg(hal.GPIO_BASE + hal.GPIO_O_DOE31_0).* & mask) != 0;
            }

            pub fn makeInput() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOECLR31_0).* = mask;
                if (is_def) reg(@as(u32, hal.IOC_BASE) + off).* |= hal.IOC_IOC0_INPEN;
            }

            pub fn makeOutput() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOESET31_0).* = mask;
                if (is_def) reg(@as(u32, hal.IOC_BASE) + off).* &= ~hal.IOC_IOC0_INPEN;
            }

            pub fn pinId() i16 {
                return pin;
            }

            pub fn reset() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOECLR31_0).* = mask;
                if (is_def) reg(@as(u32, hal.IOC_BASE) + off).* = 0;
            }

            pub fn set() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOUTSET31_0).* = mask;
            }

            pub fn setInternalPulldown(enable: bool) void {
                if (is_def) {
                    if (enable) {
                        reg(hal.IOC_BASE + off).* |= hal.IOC_IOC0_PULLCTL_PULL_DOWN;
                    } else {
                        reg(hal.IOC_BASE + off).* &= ~hal.IOC_IOC0_PULLCTL_PULL_DOWN;
                    }
                }
            }

            pub fn setInternalPullup(enable: bool) void {
                if (is_def) {
                    if (enable) {
                        reg(hal.IOC_BASE + off).* |= hal.IOC_IOC0_PULLCTL_PULL_UP;
                    } else {
                        reg(hal.IOC_BASE + off).* &= ~hal.IOC_IOC0_PULLCTL_PULL_UP;
                    }
                }
            }

            pub fn toggle() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOUTTGL31_0).* = mask;
            }
        };
    };
}
