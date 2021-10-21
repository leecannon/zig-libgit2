const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const DescribeOptions = struct {
    max_candidate_tags: c_uint = 10,
    describe_strategy: DescribeStrategy = .default,

    pattern: ?[:0]const u8,

    /// When calculating the distance from the matching tag or reference, only walk down the first-parent ancestry.
    only_follow_first_parent: bool = false,

    // If no matching tag or reference is found, the describe operation would normally fail. If this option is set, it will
    // instead fall back to showing the full id of the commit.
    show_commit_oid_as_fallback: bool = false,

    /// Reference lookup strategy
    ///
    /// These behave like the --tags and --all options to git-describe, namely they say to look for any reference in either
    /// refs/tags/ or refs/ respectively.
    pub const DescribeStrategy = enum(c_uint) {
        default = 0,
        tags,
        all,
    };

    pub fn toC(self: DescribeOptions) raw.git_describe_options {
        return .{
            .version = raw.GIT_DESCRIBE_OPTIONS_VERSION,
            .max_candidates_tags = self.max_candidate_tags,
            .describe_strategy = @enumToInt(self.describe_strategy),
            .pattern = if (self.pattern) |slice| slice.ptr else null,
            .only_follow_first_parent = @boolToInt(self.only_follow_first_parent),
            .show_commit_oid_as_fallback = @boolToInt(self.show_commit_oid_as_fallback),
        };
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const DescribeFormatOptions = struct {
    /// Size of the abbreviated commit id to use. This value is the lower bound for the length of the abbreviated string.
    abbreviated_size: c_uint = 7,

    /// Set to use the long format even when a shorter name could be used.
    always_use_long_format: bool = false,

    /// If the workdir is dirty and this is set, this string will be appended to the description string.
    dirty_suffix: ?[:0]const u8 = null,

    pub fn toC(self: DescribeFormatOptions) raw.git_describe_format_options {
        return .{
            .version = raw.GIT_DESCRIBE_FORMAT_OPTIONS_VERSION,
            .abbreviated_size = self.abbreviated_size,
            .always_use_long_format = @boolToInt(self.always_use_long_format),
            .dirty_suffix = if (self.dirty_suffix) |slice| slice.ptr else null,
        };
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const DescribeResult = opaque {
    pub fn format(self: *const DescribeResult, options: DescribeFormatOptions) !git.Buf {
        var buf: git.Buf = undefined;

        try internal.wrapCall("git_describe_format", .{ internal.toC(&buf), internal.toC(self), &options.toC() });

        log.debug("successfully formatted describe", .{});

        return buf;
    }

    pub fn deinit(self: *DescribeResult) void {
        log.debug("DescribeResult.deinit called", .{});

        raw.git_describe_result_free(internal.toC(self));

        log.debug("describe result freed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
