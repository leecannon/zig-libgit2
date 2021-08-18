const std = @import("std");
const git = @import("git");

pub fn main() !void {
    const handle = try git.init();
    defer handle.deinit();
}

comptime {
    std.testing.refAllDecls(@This());
}
