pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const RawTime = struct {
    secs: u32 = 0,
    subs: u32 = 0,
};

pub const Secs24p8 = u32;

pub fn RawSubsToMsecs(subs: u32) u32 {
    return ((subs >> 16) * 1000) / 65536;
}

pub fn RawTime_ZERO() RawTime {
    return .{ .secs = 0, .subs = 0 };
}

pub fn Secs24p8_initMsecs(msecs: u32) Secs24p8 {
    return (msecs * 32) / 125;
}

pub fn Secs24p8_ZERO() Secs24p8 {
    return 0;
}

//->> zigem publish #|05cd2faffe5dea87004327d564e79d8bdb22b73ae1ef76e66cbd42ebae44cdcc|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted
