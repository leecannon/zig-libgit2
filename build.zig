const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const old_version = b.option(bool, "old_version", "Is the available version of libgit2 older than v1.0.0") orelse false;

    // Tests
    {
        const lib_test = b.addTest("src/tests.zig");
        lib_test.setTarget(target);
        lib_test.setBuildMode(mode);
        linkLibGit(lib_test, target);

        if (@hasDecl(std.build.Builder, "addBuildOptions")) {
            const build_options = b.addBuildOptions(b.fmt("libgit2_build_options_{s}", .{lib_test.name}));
            build_options.addBuildOption(bool, "old_version", old_version);
            lib_test.addPackage(.{ .name = "build_options", .path = build_options.getSource() });
        } else {
            lib_test.addBuildOptions(bool, "old_version", old_version);
        }

        const lib_test_step = b.step("test_lib", "Run the lib tests");
        lib_test_step.dependOn(&lib_test.step);

        const sample_test = b.addTest("sample.zig");
        sample_test.setTarget(target);
        sample_test.setBuildMode(mode);
        addLibGit(sample_test, target, "", old_version);
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
        addLibGit(sample_exe, target, "", old_version);

        if (@hasDecl(std.build.Builder, "addBuildOptions")) {
            const build_options = b.addBuildOptions(b.fmt("libgit2_build_options_{s}", .{sample_exe.name}));
            build_options.addBuildOption(bool, "old_version", old_version);
            sample_exe.addPackage(.{ .name = "build_options", .path = build_options.getSource() });
        } else {
            sample_exe.addBuildOptions(bool, "old_version", old_version);
        }

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
    target: std.build.Target,
    comptime prefix_path: []const u8,
    old_version_of_libgit: bool,
) void {
    if (prefix_path.len > 0 and !std.mem.endsWith(u8, prefix_path, "/")) @panic("prefix-path must end with '/' if it is not empty");

    const pkg: std.build.Pkg = if (@hasDecl(std.build.Builder, "addBuildOptions")) blk: {
        const build_options = exe.builder.addBuildOptions(exe.builder.fmt("libgit2_build_options_{s}", .{exe.name}));
        build_options.addBuildOption(bool, "old_version", old_version_of_libgit);

        break :blk .{
            .name = "git",
            .path = .{ .path = prefix_path ++ "src/git.zig" },
            .dependencies = &[_]std.build.Pkg{
                .{ .name = "build_options", .path = build_options.getSource() },
            },
        };
    } else blk: {
        const build_option_file = std.fmt.allocPrint(exe.builder.allocator, "zig-cache/{s}_build_options.zig", .{exe.name}) catch unreachable;
        break :blk .{
            .name = "git",
            .path = .{ .path = prefix_path ++ "src/git.zig" },
            .dependencies = &[_]std.build.Pkg{
                .{ .name = "build_options", .path = .{ .path = build_option_file } },
            },
        };
    };

    exe.addPackage(pkg);
    linkLibGit(exe, target);
}

fn linkLibGit(exe: *std.build.LibExeObjStep, target: std.build.Target) void {
    _ = target;

    // TODO: Handle non-linux

    exe.linkLibC();
    exe.linkSystemLibrary("git2");
}
