const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);
const old_version: bool = @import("build_options").old_version;

pub const PATH_LIST_SEPARATOR = raw.PATH_LIST_SEPARATOR;

pub usingnamespace @import("errors.zig");

pub const AnnotatedCommit = @import("annotated_commit.zig").AnnotatedCommit;
pub const Buf = @import("buffer.zig").Buf;
pub const Config = @import("config.zig").Config;
pub const DiffDelta = @import("diff.zig").DiffDelta;
pub const Handle = @import("handle.zig").Handle;
pub const Index = @import("index.zig").Index;
pub const Odb = @import("odb.zig").Odb;
pub const Oid = @import("oid.zig").Oid;
pub const RefDb = @import("ref_db.zig").RefDb;
pub const Reference = @import("reference.zig").Reference;
pub const Repository = @import("repository.zig").Repository;
pub const StatusList = @import("status_list.zig").StatusList;
pub const StrArray = @import("str_array.zig").StrArray;
pub const Tree = @import("tree.zig").Tree;
pub const Worktree = @import("worktree.zig").Worktree;

/// Initialize global state. This function must be called before any other function.
/// *NOTE*: This function can called multiple times.
pub fn init() !Handle {
    log.debug("init called", .{});

    const number = try internal.wrapCallWithReturn("git_libgit2_init", .{});

    if (number == 1) {
        log.debug("libgit2 initalization successful", .{});
    } else {
        log.debug("{} ongoing initalizations without shutdown", .{number});
    }

    return Handle{};
}

pub const FileStatus = packed struct {
    CURRENT: bool = false,
    INDEX_NEW: bool = false,
    INDEX_MODIFIED: bool = false,
    INDEX_DELETED: bool = false,
    INDEX_RENAMED: bool = false,
    INDEX_TYPECHANGE: bool = false,
    WT_NEW: bool = false,
    WT_MODIFIED: bool = false,
    WT_DELETED: bool = false,
    WT_TYPECHANGE: bool = false,
    WT_RENAMED: bool = false,
    WT_UNREADABLE: bool = false,
    IGNORED: bool = false,
    CONFLICTED: bool = false,

    z_padding1: u2 = 0,
    z_padding2: u16 = 0,

    pub fn format(
        value: FileStatus,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        return internal.formatWithoutFields(
            value,
            options,
            writer,
            &.{ "z_padding1", "z_padding2" },
        );
    }

    test {
        try std.testing.expectEqual(@sizeOf(c_uint), @sizeOf(FileStatus));
        try std.testing.expectEqual(@bitSizeOf(c_uint), @bitSizeOf(FileStatus));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
