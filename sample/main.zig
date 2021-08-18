const std = @import("std");
const git = @import("git");

pub fn main() !void {
    const handle = try git.init();
    defer handle.deinit();

    const repo = try handle.openRepository("/home/lee/empty_repo");
    defer repo.deinit();
}

comptime {
    std.testing.refAllDecls(@This());
}
