pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const Utils = em.import.@"em.coremark/Utils";

pub const EM__SPEC = struct {
    dump: *const @TypeOf(dump) = &dump,
    kind: *const @TypeOf(dump) = &kind,
    print: *const @TypeOf(dump) = &print,
    run: *const @TypeOf(dump) = &run,
    setup: *const @TypeOf(dump) = &setup,
};

pub fn dump() void {
    // TODO
    return;
}

pub fn kind() Utils.Kind {
    // TODO
    return @enumFromInt(0);
}

pub fn print() void {
    // TODO
    return;
}

pub fn run(arg: i16) Utils.sum_t {
    // TODO
    _ = arg;
    return 0;
}

pub fn setup() void {
    // TODO
    return;
}
