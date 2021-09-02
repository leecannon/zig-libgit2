const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

pub const PATH_LIST_SEPARATOR = raw.GIT_PATH_LIST_SEPARATOR;

pub usingnamespace @import("errors.zig");

pub const GitAllocator = @import("alloc.zig").GitAllocator;
pub const AnnotatedCommit = @import("annotated_commit.zig").AnnotatedCommit;
pub const Attribute = @import("attribute.zig").Attribute;
pub const Blame = @import("blame.zig").Blame;
pub const BlameHunk = @import("blame.zig").BlameHunk;
pub const Blob = @import("blob.zig").Blob;
pub const Buf = @import("buffer.zig").Buf;
pub const Config = @import("config.zig").Config;
pub const Diff = @import("diff.zig").Diff;
pub const DiffDelta = @import("diff.zig").DiffDelta;
pub const DiffHunk = @import("diff.zig").DiffHunk;
pub const Handle = @import("handle.zig").Handle;
pub const Index = @import("index.zig").Index;
pub const Odb = @import("odb.zig").Odb;
pub const Oid = @import("oid.zig").Oid;
pub const OidShortener = @import("oid.zig").OidShortener;
pub const RefDb = @import("ref_db.zig").RefDb;
pub const Reference = @import("reference.zig").Reference;
pub const Repository = @import("repository.zig").Repository;
pub const Signature = @import("signature.zig").Signature;
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

pub fn availableLibGit2Features() LibGit2Features {
    return @bitCast(LibGit2Features, raw.git_libgit2_features());
}

pub const LibGit2Features = packed struct {
    /// If set, libgit2 was built thread-aware and can be safely used from multiple threads.
    THREADS: bool = false,
    /// If set, libgit2 was built with and linked against a TLS implementation.
    /// Custom TLS streams may still be added by the user to support HTTPS regardless of this.
    HTTPS: bool = false,
    /// If set, libgit2 was built with and linked against libssh2. A custom transport may still be added by the user to support
    /// libssh2 regardless of this.
    SSH: bool = false,
    /// If set, libgit2 was built with support for sub-second resolution in file modification times.
    NSEC: bool = false,

    z_padding: u28 = 0,

    pub fn format(
        value: LibGit2Features,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        return internal.formatWithoutFields(value, options, writer, &.{"z_padding"});
    }

    test {
        try std.testing.expectEqual(@sizeOf(c_uint), @sizeOf(LibGit2Features));
        try std.testing.expectEqual(@bitSizeOf(c_uint), @bitSizeOf(LibGit2Features));
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
