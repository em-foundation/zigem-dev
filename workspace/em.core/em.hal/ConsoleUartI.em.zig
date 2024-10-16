pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    flush: *const @TypeOf(flush) = &flush,
    put: *const @TypeOf(put) = &put,
};

pub fn flush() void {
    return;
}

pub fn put(data: u8) void {
    _ = data;
    return;
}
