const std = @import("std");

const Fs = @import("Fs.zig");
const Heap = @import("Heap.zig");

pub const File = struct {
    _file: std.fs.File,
    pub fn close(this: @This()) void {
        this._file.close();
    }
    pub fn print(this: @This(), comptime fmt: []const u8, args: anytype) void {
        this._file.writer().print(fmt, args) catch unreachable;
    }
};

pub fn sprint(comptime fmt: []const u8, args: anytype) []const u8 {
    return std.fmt.allocPrint(Heap.get(), fmt, args) catch unreachable;
}

pub const StringBuf = struct {
    txt: []const u8 = "",
    pub fn add(self: *StringBuf, txt: []const u8) void {
        self.txt = sprint("{s}{s}", .{ self.txt, txt });
    }
    pub fn get(self: StringBuf) []const u8 {
        return self.txt;
    }
};

pub fn open(path: []const u8) !*File {
    var res = try Heap.get().create(File);
    const file = try std.fs.createFileAbsolute(path, .{});
    res._file = file;
    return res;
}
