const std = @import("std");
pub const LibraryVersion = @import("src/internal/version.zig").LibraryVersion;

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // We assume the latest stable version of libgit2 is available if none is given
    const version = b.option(LibraryVersion, "library_version", "Available version of libgit2") orelse LibraryVersion.@"1.1.1";

    const build_options = b.addOptions();
    build_options.addOption(u8, "raw_version", @enumToInt(version));

    // Tests
    {
        const lib_test = b.addTest("src/tests.zig");
        lib_test.setTarget(target);
        lib_test.setBuildMode(mode);
        lib_test.linkLibC();
        lib_test.linkSystemLibrary("git2");
        lib_test.addOptions("build_options", build_options);

        const lib_test_step = b.step("test_lib", "Run the lib tests");
        lib_test_step.dependOn(&lib_test.step);

        const sample_test = b.addTest("sample.zig");
        sample_test.setTarget(target);
        sample_test.setBuildMode(mode);
        addLibGit(sample_test, "", version);
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
        sample_exe.install();
        addLibGit(sample_exe, "", version);
        sample_exe.addOptions("build_options", build_options);

        const run_cmd = sample_exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the sample");
        run_step.dependOn(&run_cmd.step);
    }
}

pub fn addLibGit(
    exe: *std.build.LibExeObjStep,
    comptime prefix_path: []const u8,
    version_of_libgit: LibraryVersion,
) void {
    if (prefix_path.len > 0 and !std.mem.endsWith(u8, prefix_path, "/")) @panic("prefix-path must end with '/' if it is not empty");

    const build_options = exe.builder.addOptions();
    build_options.addOption(u8, "raw_version", @enumToInt(version_of_libgit));
    exe.addPackage(.{
        .name = "git",
        .path = .{ .path = prefix_path ++ "src/git.zig" },
        .dependencies = &[_]std.build.Pkg{build_options.getPackage("build_options")},
    });

    exe.linkLibC();
    exe.linkSystemLibrary("git2");
}
