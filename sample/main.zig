const std = @import("std");
const git = @import("git");

pub fn main() !void {
    std.log.info("Hello World", .{});
}

comptime {
    std.testing.refAllDecls(@This());
}
