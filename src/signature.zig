const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Signature = extern struct {
    /// use `name`
    z_name: [*:0]const u8,
    /// use `email`
    z_email: [*:0]const u8,
    /// time when the action happened
    when: Time,

    pub fn name(self: Signature) [:0]const u8 {
        return std.mem.sliceTo(self.z_name, 0);
    }

    pub fn email(self: Signature) [:0]const u8 {
        return std.mem.sliceTo(self.z_email, 0);
    }

    pub const Time = extern struct {
        /// time in seconds from epoch, we use libgit2's exported time type as they handle interop with the target
        time: c.git_time_t,
        /// timezone offset, in minutes
        offset: c_int,
        /// indicator for questionable '-0000' offsets in signature
        sign: u8,

        test {
            try std.testing.expectEqual(@sizeOf(c.git_time), @sizeOf(Time));
            try std.testing.expectEqual(@bitSizeOf(c.git_time), @bitSizeOf(Time));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    test {
        try std.testing.expectEqual(@sizeOf(c.git_signature), @sizeOf(Signature));
        try std.testing.expectEqual(@bitSizeOf(c.git_signature), @bitSizeOf(Signature));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
