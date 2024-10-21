pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const TimeTypes = em.import.@"em.utils/TimeTypes";

pub const EM__SPEC = struct {
    read: *const @TypeOf(read) = &read,
};

pub fn read() TimeTypes.RawTime {
    return TimeTypes.RawTime_ZERO();
}

//->> zigem publish #|0fdde95c722ae422832579747cff61f7c0be45e003a0c4f8711538179c4ce571|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted
