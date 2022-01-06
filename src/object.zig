const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Object = opaque {
    /// Close an open object
    ///
    /// This method instructs the library to close an existing object; note that `git.Object`s are owned and cached by
    /// the repository so the object may or may not be freed after this library call, depending on how aggressive is the
    /// caching mechanism used by the repository.
    ///
    /// IMPORTANT:
    /// It *is* necessary to call this method when you stop using an object. Failure to do so will cause a memory leak.
    pub fn deinit(self: *Object) void {
        log.debug("Object.deinit called", .{});

        c.git_object_free(@ptrCast(*c.git_object, self));

        log.debug("tree entry freed successfully", .{});
    }

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

/// Basic type (loose or packed) of any Git object.
pub const ObjectType = enum(c_int) {
    /// Object can be any of the following
    ANY = -2,
    /// Object is invalid.
    INVALID = -1,
    /// A commit object.
    COMMIT = 1,
    /// A tree (directory listing) object.
    TREE = 2,
    /// A file revision object.
    BLOB = 3,
    /// An annotated tag object.
    TAG = 4,
    /// A delta, base is given by an offset.
    OFS_DELTA = 6,
    /// A delta, base is given by object id.
    REF_DELTA = 7,
};

comptime {
    std.testing.refAllDecls(@This());
}
