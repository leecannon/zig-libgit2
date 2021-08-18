const std = @import("std");
const git = @import("git");

const repo_path = "./temp_repo";

pub fn main() !void {
    defer std.fs.cwd().deleteTree(repo_path) catch {};

    const handle = try git.init();
    defer handle.deinit();

    {
        var repo = try handle.repositoryInit(repo_path, false);
        defer repo.deinit();
    }

    var git_buf = try handle.repositoryDiscover(repo_path, false, null);
    defer git_buf.deinit();
    std.log.info("found repo @ path {s}", .{git_buf.slice()});

    {
        var repo = try handle.repositoryOpen(git_buf.slice());
        defer repo.deinit();
    }
}

comptime {
    std.testing.refAllDecls(@This());
}
