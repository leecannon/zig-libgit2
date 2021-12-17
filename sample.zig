const std = @import("std");
const git = @import("git");

const repo_path = "./zig-cache/test_repo";

pub fn main() !void {
    defer std.fs.cwd().deleteTree(repo_path) catch {};

    const handle = try git.init();
    defer handle.deinit();

    const repo = try handle.repositoryInitExtended(repo_path, .{ .flags = .{ .mkdir = true, .mkpath = true } });
    defer repo.deinit();

    var git_buf = try handle.repositoryDiscover(repo_path, false, null);
    defer git_buf.deinit();
    std.log.info("found repo @ {s}", .{git_buf.toSlice()});

    const t = try handle.optionGetSearchPath(.SYSTEM);
    std.log.info("search path: {s}", .{t.toSlice()});
}

comptime {
    std.testing.refAllDecls(@This());
}
