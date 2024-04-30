pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Template(@This(), .{});

pub fn em__generateS(comptime name: []const u8) type {
    return struct {
        pub const EM__SPEC = {};

        pub const em__unit = em.Module(
            @This(),
            .{ .generated = true, .name = name },
        );

        pub const c_pin = @This().em__unit.Config("pin", i16);

        pub const EM__HOST = {};

        pub fn em__initH() void {
            c_pin.init(-1);
        }

        pub const EM__TARG = {};

        const hal = em.hal;
        const reg = em.reg;

        const pin = c_pin.unwrap();
        const is_def = (pin >= 0);
        const mask = init: {
            const p5 = @as(u5, @bitCast(@as(i5, @truncate(pin))));
            const m: u32 = @as(u32, 1) << p5;
            break :init m;
        };

        pub fn clear() void {
            if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOUTCLR31_0).* = mask;
        }

        pub fn functionSelect(select: u8) void {
            const off = @as(u32, hal.IOC_O_IOC0 + @as(u16, @bitCast(pin)) * 4);
            if (is_def) reg(@as(u32, hal.IOC_BASE) + off).* = select;
        }

        pub fn makeOutput() void {
            if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOESET31_0).* = mask;
            const off = @as(u32, hal.IOC_O_IOC0 + @as(u16, @bitCast(pin)) * 4);
            if (is_def) reg(@as(u32, hal.IOC_BASE) + off).* &= ~hal.IOC_IOC0_INPEN;
        }

        pub fn pinId() i16 {
            return c_pin.get();
        }

        pub fn set() void {
            if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOUTSET31_0).* = mask;
        }

        pub fn toggle() void {
            if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOUTTGL31_0).* = mask;
        }
    };
}
