const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // Tests
    {
        const lib_test = b.addTest("src/tests.zig");
        lib_test.setTarget(target);
        lib_test.setBuildMode(mode);
        addLibGit(lib_test);

        const lib_test_step = b.step("test_lib", "Run the lib tests");
        lib_test_step.dependOn(&lib_test.step);

        const sample_test = b.addTest("sample.zig");
        sample_test.setTarget(target);
        sample_test.setBuildMode(mode);
        addLibGit(sample_test);

        const sample_test_step = b.step("test_sample", "Run the sample tests");
        sample_test_step.dependOn(&sample_test.step);

        const test_step = b.step("test", "Run all the tests");
        test_step.dependOn(&lib_test.step);
        test_step.dependOn(&sample_test.step);

        b.default_step = test_step;
    }

    // Sample
    {
        const sample_exe = b.addExecutable("sample", "sample.zig");
        sample_exe.setTarget(target);
        sample_exe.setBuildMode(mode);
        addLibGit(sample_exe);
        sample_exe.install();

        const run_cmd = sample_exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the sample");
        run_step.dependOn(&run_cmd.step);
    }
}

pub fn addLibGit(exe: *std.build.LibExeObjStep) void {
    const prefix_path = comptime std.fs.path.dirname(@src().file) orelse unreachable;

    const path = exe.builder.pathJoin(&.{
        prefix_path,
        "src",
        "git.zig",
    });

    exe.addPackagePath("git", path);
    exe.linkLibC();
    exe.linkSystemLibrary("git2");
}
