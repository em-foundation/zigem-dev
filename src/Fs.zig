const std = @import("std");

const fatal = std.zig.fatal;
const fs = std.fs;

const Heap = @import("./Heap.zig");

const MAX_BYTES = 100_000;

pub fn basename(path: []const u8) []const u8 {
    return fs.path.basename(path);
}

pub fn chdir(path: []const u8) void {
    std.posix.chdir(path) catch unreachable;
}

pub fn cwd() []const u8 {
    const res = fs.cwd().realpathAlloc(Heap.get(), ".") catch unreachable;
    return res;
}

pub fn delete(abs_path: []const u8) void {
    fs.deleteTreeAbsolute(abs_path) catch return;
}

pub fn dirname(path: []const u8) []const u8 {
    return if (fs.path.dirname(path)) |dn| dn else "";
}

pub fn exists(path: []const u8) bool {
    fs.accessAbsolute(path, .{ .mode = .read_only }) catch return false;
    return true;
}

pub fn join(paths: []const []const u8) []const u8 {
    const res = fs.path.join(Heap.get(), paths) catch unreachable;
    return res;
}

pub fn mkdirs(root: []const u8, subpath: []const u8) void {
    var dir = openDir(root);
    dir.makePath(subpath) catch unreachable;
}

pub fn normalize(path: []const u8) ![]const u8 {
    return fs.cwd().realpathAlloc(Heap.get(), path);
}

pub fn openDir(path: []const u8) fs.Dir {
    const dir = fs.openDirAbsolute(path, .{ .iterate = true }) catch fatal("Path.openDir: {s}", .{path});
    return dir;
}

pub fn openFile(path: []const u8) fs.File {
    const file = fs.openFileAbsolute(path, .{ .mode = .read_only }) catch fatal("Path.openFile: {s}", .{path});
    return file;
}

pub fn readFile(path: []const u8) []const u8 {
    const file = openFile(path);
    defer file.close();
    const buf = file.readToEndAlloc(Heap.get(), MAX_BYTES) catch fatal("Path.readFile: {s}", .{path});
    return buf;
}

pub fn readFileZ(path: []const u8) [:0]const u8 {
    const file = openFile(path);
    defer file.close();
    const buf = file.readToEndAllocOptions(Heap.get(), MAX_BYTES, null, @alignOf(u8), 0) catch fatal("Path.readFile", .{});
    return buf;
}

pub fn slashify(path: []const u8) []const u8 {
    const dupe = Heap.get().dupe(u8, path) catch fatal("Path.slashify: {s}", .{path});
    std.mem.replaceScalar(u8, dupe, '\\', '/');
    return dupe;
}
