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

//->> zigem publish #|88fbb179e500cc48c9c71906594849fc7aba96198a476637ca8cd1630750a30a|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted
