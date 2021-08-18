const std = @import("std");
const git = @import("git");

const repo_path = "./temp_repo";

pub fn main() !void {
    defer std.fs.cwd().deleteTree(repo_path) catch {};

    const handle = try git.init();
    defer handle.deinit();

    {
        var repo = try handle.initRepository(repo_path, false);
        defer repo.deinit();
    }

    {
        var repo = try handle.openRepository(repo_path);
        defer repo.deinit();
    }
}

comptime {
    std.testing.refAllDecls(@This());
}
