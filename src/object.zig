const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Object = opaque {
    /// Describe a commit
    ///
    /// Perform the describe operation on the given committish object.
    pub fn describe(self: *Object, options: git.DescribeOptions) !*git.DescribeResult {
        log.debug("Object.describe called, options={}", .{options});

        var result: ?*raw.git_describe_result = undefined;

        var c_options = options.toC();
        try internal.wrapCall("git_describe_commit", .{ &result, internal.toC(self), &c_options });

        const ret = internal.fromC(result.?);

        log.debug("successfully described commitish object", .{});

        return ret;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
