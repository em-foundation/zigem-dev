const std = @import("std");

pub fn build(b: *std.Build) void {
    //
    const target = b.host;
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "zigem",
        .root_source_file = std.Build.path(b, "src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    for (DEPS) |name| {
        const dep = b.dependency(name, .{
            .target = target,
            .optimize = optimize,
        });
        exe.root_module.addImport(name, dep.module(name));
    }

    exe.root_module.addImport("zls", b.dependency("zls-em", .{}).module("zls"));

    const chmod_step = b.addSystemCommand(&.{ "chmod", "-R", "777", "zig-out/tools" });
    exe.step.dependOn(&chmod_step.step);

    const tr = target.result;
    for (TOOLS) |name| {
        if (b.lazyDependency(b.fmt("{s}-{s}-{s}", .{ name, @tagName(tr.os.tag), tr.osArchName() }), .{})) |dep| {
            const install_step = b.addInstallDirectory(.{
                .source_dir = dep.path("."),
                .install_dir = std.Build.InstallDir{ .custom = "tools" },
                .install_subdir = name,
            });
            chmod_step.step.dependOn(&install_step.step);
        }
    }

    b.installDirectory(.{
        .source_dir = b.dependency("vscode-zigem", .{}).path("."),
        .install_dir = std.Build.InstallDir{ .custom = "tools" },
        .install_subdir = "",
    });
    b.installArtifact(b.dependency("zls-em", .{}).artifact("zls-em"));
    b.installArtifact(exe);

    const verify_exe = b.addRunArtifact(exe);
    verify_exe.setCwd(std.Build.LazyPath{ .src_path = .{ .owner = b, .sub_path = "workspace" } });
    verify_exe.addArgs(&.{ "compile", "-f", "em.core/em.examples.basic/BlinkerP.em.zig" });
    const verify_step = b.step("verify", "Verify ZigEM");
    verify_step.dependOn(&verify_exe.step);

    const zigem_exe = b.addRunArtifact(exe);
    if (b.args) |args| zigem_exe.addArgs(args);
    zigem_exe.setCwd(std.Build.LazyPath{ .src_path = .{ .owner = b, .sub_path = "workspace" } });
    const zigem_step = b.step("zigem", "Execute the ZigEM CLI");
    zigem_step.dependOn(&zigem_exe.step);
}

const DEPS = [_][]const u8{
    "ini",
    "zig-cli",
};

const TOOLS = [_][]const u8{
    "arm-binutils",
    "ti-uniflash",
};
