const std = @import("std");
const git = @import("git");

const repo_path = "./zig-cache/test_repo";

pub fn main() !void {
    defer std.fs.cwd().deleteTree(repo_path) catch {};

    const handle = try git.init();
    defer handle.deinit();

    var repo = try handle.repositoryInitExtended(repo_path, .{ .flags = .{ .mkdir = true, .mkpath = true } });
    defer repo.deinit();

    var git_buf = try handle.repositoryDiscover(repo_path, false, null);
    defer git_buf.deinit();
    std.log.info("found repo @ {s}", .{git_buf.slice()});
}

comptime {
    std.testing.refAllDecls(@This());
}
