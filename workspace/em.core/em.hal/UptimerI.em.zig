pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const TimeTypes = em.import.@"em.utils/TimeTypes";

pub const EM__SPEC = struct {
    read: *const @TypeOf(read) = &read,
};

pub fn read() TimeTypes.RawTime {
    return TimeTypes.RawTime_ZERO();
}
