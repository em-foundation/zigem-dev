pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    clear: fn () void,
    functionSelect: fn (select: u8) void,
    get: fn () bool,
    isInput: fn () bool,
    isOutput: fn () bool,
    makeInput: fn () void,
    makeOutput: fn () void,
    pinId: fn () i16,
    reset: fn () void,
    set: fn () void,
    setInternalPullup: fn (enable: bool) void,
    toggle: fn () void,
};


//->> zigem publish #|6a6df936b4ba5605dbf7bbd1a43984da5603a9f7a7d454415330be2e162ba25a|#

pub fn clear () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn functionSelect (select: u8) void {
    // TODO
    _ = select;
    return em.std.mem.zeroes(void);
}

pub fn get () bool {
    // TODO
    return em.std.mem.zeroes(bool);
}

pub fn isInput () bool {
    // TODO
    return em.std.mem.zeroes(bool);
}

pub fn isOutput () bool {
    // TODO
    return em.std.mem.zeroes(bool);
}

pub fn makeInput () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn makeOutput () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn pinId () i16 {
    // TODO
    return em.std.mem.zeroes(i16);
}

pub fn reset () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn set () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn setInternalPullup (enable: bool) void {
    // TODO
    _ = enable;
    return em.std.mem.zeroes(void);
}

pub fn toggle () void {
    // TODO
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    clear: *const @TypeOf(em__Self.clear) = &em__Self.clear,
    functionSelect: *const @TypeOf(em__Self.functionSelect) = &em__Self.functionSelect,
    get: *const @TypeOf(em__Self.get) = &em__Self.get,
    isInput: *const @TypeOf(em__Self.isInput) = &em__Self.isInput,
    isOutput: *const @TypeOf(em__Self.isOutput) = &em__Self.isOutput,
    makeInput: *const @TypeOf(em__Self.makeInput) = &em__Self.makeInput,
    makeOutput: *const @TypeOf(em__Self.makeOutput) = &em__Self.makeOutput,
    pinId: *const @TypeOf(em__Self.pinId) = &em__Self.pinId,
    reset: *const @TypeOf(em__Self.reset) = &em__Self.reset,
    set: *const @TypeOf(em__Self.set) = &em__Self.set,
    setInternalPullup: *const @TypeOf(em__Self.setInternalPullup) = &em__Self.setInternalPullup,
    toggle: *const @TypeOf(em__Self.toggle) = &em__Self.toggle,
};

//->> zigem publish -- end of generated code
