pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    crc_tab: em.Table(sum_t, .RW),
    seed_tab: em.Table(seed_t, .RO),
};

pub const NUM_SEEDS: usize = 5;

pub const Kind = enum { FINAL, LIST, MATRIX, STATE, ZZZ_ };

pub const seed_t = u16;
pub const sum_t = u16;

pub const bindSeedM = EM__META.bindSeedM;

pub const bindCrc = EM__TARG.bindCrc;
pub const getCrc = EM__TARG.getCrc;
pub const getSeed = EM__TARG.getSeed;
pub const setCrc = EM__TARG.setCrc;

pub const EM__META = struct {
    //
    pub fn em__initM() void {
        em__C.crc_tab.setLenM(@intFromEnum(Kind.ZZZ_));
        em__C.seed_tab.setLenM(NUM_SEEDS);
    }

    pub fn bindSeedM(idx: u8, val: seed_t) void {
        em__C.seed_tab.itemsM()[idx - 1] = val;
    }
};

pub const EM__TARG = struct {
    //
    var crc_tab = em__C.crc_tab.items();
    const seed_tab = em__C.seed_tab.items();

    pub fn bindCrc(kind: Kind, crc: sum_t) void {
        const p = &crc_tab[@intFromEnum(kind)];
        if (p.* == 0) p.* = crc;
    }

    pub fn getCrc(kind: Kind) sum_t {
        return crc_tab[@intFromEnum(kind)];
    }

    pub fn getSeed(idx: u8) seed_t {
        const p: *volatile u16 = @constCast(&seed_tab[idx - 1]);
        return p.*;
    }

    pub fn setCrc(kind: Kind, crc: sum_t) void {
        crc_tab[@intFromEnum(kind)] = crc;
    }
};
