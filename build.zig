const std = @import("std");

pub fn build(b: *std.Build) void {
    //const cmd = b.addSystemCommand(&.{"ls"});
    b.verbose = true;
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m0plus },
        .os_tag = .freestanding,
        .abi = .eabi,
    });
    const optimize = std.builtin.OptimizeMode.ReleaseSmall;

    const exe = b.addExecutable(.{
        .name = "main.out",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.addCSourceFile(.{
        .file = .{ .path = "etc/startup.c" },

        // not sure if i need this???

        //    .flags = &.{
        //        "-mcpu=cortex-m0plus",
        //    },
    });
    //  exe.step.dependOn(&cmd.step);
    exe.setLinkerScript(.{ .path = "etc/linkcmd.ld" });
    exe.want_lto = false;
    exe.entry = .{ .symbol_name = "__em_program_start" };
    b.installArtifact(exe);
    //
    //    // This *creates* a Run step in the build graph, to be executed when another
    //    // step is evaluated that depends on it. The next line below will establish
    //    // such a dependency.
    //    const run_cmd = b.addRunArtifact(exe);
    //
    //    // By making the run step depend on the install step, it will be run from the
    //    // installation directory rather than directly from within the cache directory.
    //    // This is not necessary, however, if the application depends on other installed
    //    // files, this ensures they will be present and in the expected location.
    //    run_cmd.step.dependOn(b.getInstallStep());
    //
    //    // This allows the user to pass arguments to the application in the build
    //    // command itself, like this: `zig build run -- arg1 arg2 etc`
    //    if (b.args) |args| {
    //        run_cmd.addArgs(args);
    //    }
    //
    //    // This creates a build step. It will be visible in the `zig build --help` menu,
    //    // and can be selected like this: `zig build run`
    //    // This will evaluate the `run` step rather than the default, which is "install".
    //    const run_step = b.step("run", "Run the app");
    //    run_step.dependOn(&run_cmd.step);
    //
    //    // Creates a step for unit testing. This only builds the test executable
    //    // but does not run it.
    //    const unit_tests = b.addTest(.{
    //        .root_source_file = .{ .path = "src/main.zig" },
    //        .target = target,
    //        .optimize = optimize,
    //    });
    //
    //    const run_unit_tests = b.addRunArtifact(unit_tests);
    //
    //    // Similar to creating the run step earlier, this exposes a `test` step to
    //    // the `zig build --help` menu, providing a way for the user to request
    //    // running the unit tests.
    //    const test_step = b.step("test", "Run unit tests");
    //    test_step.dependOn(&run_unit_tests.step);
}
