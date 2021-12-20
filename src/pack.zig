const std = @import("std");
const c = @import("internal/c.zig");
const git = @import("git.zig");

pub const PackbuildStage = enum(c_uint) {
    ADDING_OBJECTS = 0,
    DELTAFICATION = 1,
};

comptime {
    std.testing.refAllDecls(@This());
}
