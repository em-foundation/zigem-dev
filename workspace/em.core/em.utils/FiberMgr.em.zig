pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    FiberOF: em.Factory(Fiber),
};

pub const Common = em.import.@"em.mcu/Common";

pub const Obj = em.Obj(Fiber);
pub const BodyFxn = em.Fxn(BodyArg);
pub const BodyArg = struct {
    arg: usize,
};

pub const FiberBody = struct {
    arg: usize,
};

pub const Fiber = struct {
    link: ?Obj,
    body: BodyFxn,
    arg: usize = 0,
    pub fn post(self: *Fiber) void {
        EM__TARG.Fiber_post(self);
    }
};

pub const createH = EM__META.createH;
pub const run = EM__TARG.run;

pub const EM__META = struct {
    //
    fn createH(body: BodyFxn) Obj {
        const fiber = em__C.FiberOF.createH(.{ .body = body });
        return fiber;
    }
};

pub const EM__TARG = struct {
    //
    var ready_list = struct {
        const Self = @This();
        const END: *Fiber = @ptrFromInt(4);
        head: *Fiber = END,
        tail: *Fiber = END,
        count: u8 = 0,
        fn empty(self: *Self) bool {
            return self.head == END;
        }
        fn give(self: *Self, elem: *Fiber) void {
            if (self.empty()) {
                self.head = elem;
            } else {
                self.tail.link = elem;
            }
            self.tail = elem;
            elem.link = END;
        }
        fn take(self: *Self) *Fiber {
            const e = self.head;
            self.head = e.link.?;
            e.link = null;
            if (self.head == END) self.tail = END;
            return e;
        }
    }{};

    fn dispatch() void {
        while (!ready_list.empty()) {
            const fiber = ready_list.take();
            const body = fiber.body;
            Common.GlobalInterrupts.enable();
            body.?(.{ .arg = fiber.arg });
            _ = Common.GlobalInterrupts.disable();
        }
    }

    fn run() void {
        Common.Idle.wakeup();
        Common.GlobalInterrupts.enable();
        while (true) {
            _ = Common.GlobalInterrupts.disable();
            dispatch();
            Common.Idle.exec();
        }
    }

    fn Fiber_post(self: *Fiber) void {
        const key = Common.GlobalInterrupts.disable();
        if (self.link == null) ready_list.give(self);
        Common.GlobalInterrupts.restore(key);
    }
};
