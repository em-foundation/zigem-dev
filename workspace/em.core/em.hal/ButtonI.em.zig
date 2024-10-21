pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const DurationMs = struct {
    min: u16 = 100,
    max: u16 = 4000,
};

pub const OnPressedCbFxn = em.Fxn(OnPressedCbArg);
pub const OnPressedCbArg = struct {};

pub const EM__SPEC = struct {
    isPressed: *const @TypeOf(isPressed) = &isPressed,
    onPressed: *const @TypeOf(onPressed) = &onPressed,
};

pub fn isPressed() bool {
    return false;
}

pub fn onPressed(cb: OnPressedCbFxn, dur: DurationMs) void {
    _ = cb;
    _ = dur;
}

//->> zigem publish #|605df5f273cde1465b99d2152afe0ca98b758f6eac5d5499101122bf7f36920c|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted
