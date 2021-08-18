const std = @import("std");

comptime {
    std.testing.refAllDecls(@This());
}
