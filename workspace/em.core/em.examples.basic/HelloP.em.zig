pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const EM__TARG = struct {
    //
    pub fn em__run() void {
        em.print("hello world\n", .{});
    }
};

//->> zigem publish #|256984b9bc125ca7a1e49c8c18ac5fc88475efdcdd609556a604b4b47f986526|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__TARG publics
