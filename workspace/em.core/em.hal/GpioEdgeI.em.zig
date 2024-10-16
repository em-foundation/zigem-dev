pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{ .inherits = GpioI });

pub const GpioI = em.import.@"em.hal/GpioI";

pub const HandlerFxn = em.Fxn(HandlerArg);
pub const HandlerArg = struct {};

pub const EM__SPEC = struct {
    // GpioI
    clear: *const @TypeOf(GpioI.clear) = &GpioI.clear,
    functionSelect: *const @TypeOf(GpioI.functionSelect) = &GpioI.functionSelect,
    get: *const @TypeOf(GpioI.get) = &GpioI.get,
    isInput: *const @TypeOf(GpioI.isInput) = &GpioI.isInput,
    isOutput: *const @TypeOf(GpioI.isOutput) = &GpioI.isOutput,
    makeInput: *const @TypeOf(GpioI.makeInput) = &GpioI.makeInput,
    makeOutput: *const @TypeOf(GpioI.makeOutput) = &GpioI.makeOutput,
    pinId: *const @TypeOf(GpioI.pinId) = &GpioI.pinId,
    reset: *const @TypeOf(GpioI.reset) = &GpioI.reset,
    set: *const @TypeOf(GpioI.set) = &GpioI.set,
    setInternalPullup: *const @TypeOf(GpioI.setInternalPullup) = &GpioI.setInternalPullup,
    toggle: *const @TypeOf(GpioI.toggle) = &GpioI.toggle,
    //
    setDetectHandlerM: *const @TypeOf(setDetectHandlerM) = &setDetectHandlerM,
    clearDetect: *const @TypeOf(clearDetect) = &clearDetect,
    disableDetect: *const @TypeOf(disableDetect) = &disableDetect,
    enableDetect: *const @TypeOf(enableDetect) = &enableDetect,
    setDetectFallingEdge: *const @TypeOf(setDetectFallingEdge) = &setDetectFallingEdge,
    setDetectRisingEdge: *const @TypeOf(setDetectRisingEdge) = &setDetectRisingEdge,
};

pub fn setDetectHandlerM(h: HandlerFxn) void {
    _ = h;
    return;
}

pub fn clearDetect() void {
    return;
}

pub fn disableDetect() void {
    return;
}

pub fn enableDetect() void {
    return;
}

pub fn setDetectFallingEdge() void {
    return;
}

pub fn setDetectRisingEdge() void {
    return;
}
