pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    start: *const @TypeOf(start) = &start,
    stop: *const @TypeOf(stop) = &stop,
};

pub fn start() void {
    return;
}

pub fn stop(o_raw: ?*u32) u32 {
    _ = o_raw;
    return 0;
}

//->> zigem publish #|b6b42c9068df99baef013d599f4368558128a0532d336b2503bc88d0a976edad|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted
