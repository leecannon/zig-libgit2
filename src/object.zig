const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Object = opaque {
    /// Describe a commit
    ///
    /// Perform the describe operation on the given committish object.
    pub fn describe(self: *Object, options: git.DescribeOptions) !*git.DescribeResult {
        log.debug("Object.describe called, options={}", .{options});

        var result: *git.DescribeResult = undefined;

        var c_options = options.makeCOptionObject();
        try internal.wrapCall("git_describe_commit", .{
            @ptrCast(*?*c.git_describe_result, &result),
            @ptrCast(*c.git_object, self),
            &c_options,
        });

        log.debug("successfully described commitish object", .{});

        return result;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
