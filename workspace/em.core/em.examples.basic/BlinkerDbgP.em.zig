pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    dbg_flag: em.Param(bool),
    min_cnt: em.Param(u16),
    max_cnt: em.Param(u16),
};

pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";

pub const EM__META = struct {
    //
    pub fn em__initH() void {
        em__C.dbg_flag.set(true);
        em__C.min_cnt.set(1000);
        em__C.max_cnt.set(1020);
    }
};

pub const EM__TARG = struct {
    //
    const dbg_flag = em__C.dbg_flag.get();
    const min_cnt = em__C.min_cnt.get();
    const max_cnt = em__C.max_cnt.get();

    pub fn em__run() void {
        AppLed.on();
        for (min_cnt..max_cnt) |cnt| {
            em.@"%%[d+]"();
            Common.BusyWait.wait(250_000);
            em.@"%%[d-]"();
            AppLed.toggle();
            if (!dbg_flag) continue;
            //if (cnt > ((min_cnt + max_cnt) / 2)) em.fail();
            const bits11: u8 = @intCast(cnt & 0b0011);
            em.@"%%[c:]"(bits11);
            em.@"%%[>]"(bits11);
            em.print("cnt = {d} (0x{x:0>4}), bits11 = {d}", .{ cnt, cnt, bits11 });
        }
        AppLed.off();
    }
};
