pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    clear: *const @TypeOf(clear) = &clear,
    functionSelect: *const @TypeOf(functionSelect) = &functionSelect,
    get: *const @TypeOf(get) = &get,
    isInput: *const @TypeOf(isInput) = &isInput,
    isOutput: *const @TypeOf(isOutput) = &isOutput,
    makeInput: *const @TypeOf(makeInput) = &makeInput,
    makeOutput: *const @TypeOf(makeOutput) = &makeOutput,
    pinId: *const @TypeOf(pinId) = &pinId,
    reset: *const @TypeOf(reset) = &reset,
    set: *const @TypeOf(set) = &set,
    setInternalPullup: *const @TypeOf(setInternalPullup) = &setInternalPullup,
    toggle: *const @TypeOf(toggle) = &toggle,
};

pub fn clear() void {
    return;
}

pub fn functionSelect(select: u8) void {
    _ = select;
    return;
}

pub fn get() bool {
    return false;
}

pub fn isInput() bool {
    return false;
}

pub fn isOutput() bool {
    return false;
}

pub fn makeInput() void {
    return;
}

pub fn makeOutput() void {
    return;
}

pub fn pinId() i16 {
    return -1;
}

pub fn reset() void {
    return;
}

pub fn set() void {
    return;
}

pub fn setInternalPullup(enable: bool) void {
    _ = enable;
    return;
}

pub fn toggle() void {
    return;
}
