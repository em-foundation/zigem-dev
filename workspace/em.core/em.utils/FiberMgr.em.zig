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
    _link: ?Obj,
    _body: BodyFxn,
    _arg: usize = 0,
    pub fn post(self: *Fiber) void {
        EM__TARG.Fiber_post(self);
    }
};

pub const createM = EM__META.createM;

pub const run = EM__TARG.run;

pub const EM__META = struct {
    //
    pub fn createM(body: BodyFxn) Obj {
        const fiber = em__C.FiberOF.createM(.{ ._body = body });
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
                self.tail._link = elem;
            }
            self.tail = elem;
            elem._link = END;
        }
        fn take(self: *Self) *Fiber {
            const e = self.head;
            self.head = e._link.?;
            e._link = null;
            if (self.head == END) self.tail = END;
            return e;
        }
    }{};

    fn dispatch() void {
        while (!ready_list.empty()) {
            const fiber = ready_list.take();
            const body = fiber._body;
            Common.GlobalInterrupts.enable();
            body.?(.{ .arg = fiber._arg });
            _ = Common.GlobalInterrupts.disable();
        }
    }

    pub fn run() void {
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
        if (self._link == null) ready_list.give(self);
        Common.GlobalInterrupts.restore(key);
    }
};
