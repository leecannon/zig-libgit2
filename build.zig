const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("git", .{
        .source_file = .{ .path = "src/git.zig" },
    });

    // Tests
    {
        const lib_test = b.addTest(.{
            .root_source_file = .{ .path = "src/tests.zig" },
            .target = target,
            .optimize = optimize,
        });
        addLibGit(lib_test, module);

        const lib_test_step = b.step("test_lib", "Run the lib tests");
        lib_test_step.dependOn(&lib_test.step);

        const sample_test = b.addTest(.{
            .root_source_file = .{ .path = "sample.zig" },
            .target = target,
            .optimize = optimize,
        });
        addLibGit(sample_test, module);

        const sample_test_step = b.step("test_sample", "Run the sample tests");
        sample_test_step.dependOn(&sample_test.step);

        const test_step = b.step("test", "Run all the tests");
        test_step.dependOn(&lib_test.step);
        test_step.dependOn(&sample_test.step);

        b.default_step = test_step;
    }

    // Sample
    {
        const sample_exe = b.addExecutable(.{
            .name = "sample",
            .root_source_file = .{ .path = "sample.zig" },
            .target = target,
            .optimize = optimize,
        });
        addLibGit(sample_exe, module);
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

// TODO: Support optionally adding libgit2 source directly
pub fn addLibGit(exe: *std.Build.CompileStep, module: *std.Build.Module) void {
    exe.addModule("git", module);
    exe.linkLibC();

    // TODO: Don't hard code this...
    exe.addIncludePath("../libgit2/include");
    exe.addLibraryPath("../libgit2/build");
    exe.linkSystemLibraryName("git2");
}
