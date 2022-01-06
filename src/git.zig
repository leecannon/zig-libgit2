const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

pub const PATH_LIST_SEPARATOR = c.GIT_PATH_LIST_SEPARATOR;

pub usingnamespace @import("alloc.zig");
pub usingnamespace @import("annotated_commit.zig");
pub usingnamespace @import("attribute.zig");
pub usingnamespace @import("blame.zig");
pub usingnamespace @import("blob.zig");
pub usingnamespace @import("buffer.zig");
pub usingnamespace @import("certificate.zig");
pub usingnamespace @import("commit.zig");
pub usingnamespace @import("config.zig");
pub usingnamespace @import("credential.zig");
pub usingnamespace @import("describe.zig");
pub usingnamespace @import("diff.zig");
pub usingnamespace @import("errors.zig");
pub usingnamespace @import("filter.zig");
pub usingnamespace @import("handle.zig");
pub usingnamespace @import("index.zig");
pub usingnamespace @import("indexer.zig");
pub usingnamespace @import("mailmap.zig");
pub usingnamespace @import("merge.zig");
pub usingnamespace @import("message.zig");
pub usingnamespace @import("net.zig");
pub usingnamespace @import("notes.zig");
pub usingnamespace @import("object.zig");
pub usingnamespace @import("odb.zig");
pub usingnamespace @import("oid.zig");
pub usingnamespace @import("oidarray.zig");
pub usingnamespace @import("pack.zig");
pub usingnamespace @import("proxy.zig");
pub usingnamespace @import("ref_db.zig");
pub usingnamespace @import("reference.zig");
pub usingnamespace @import("remote.zig");
pub usingnamespace @import("repository.zig");
pub usingnamespace @import("signature.zig");
pub usingnamespace @import("status_list.zig");
pub usingnamespace @import("str_array.zig");
pub usingnamespace @import("transaction.zig");
pub usingnamespace @import("transport.zig");
pub usingnamespace @import("tree.zig");
pub usingnamespace @import("worktree.zig");
pub usingnamespace @import("writestream.zig");

const git = @This();

/// Initialize global state. This function must be called before any other function.
/// *NOTE*: This function can called multiple times.
pub fn init() !git.Handle {
    log.debug("init called", .{});

    const number = try internal.wrapCallWithReturn("git_libgit2_init", .{});

    if (number == 1) {
        log.debug("libgit2 initalization successful", .{});
    } else {
        log.debug("{} ongoing initalizations without shutdown", .{number});
    }

    return git.Handle{};
}

pub fn availableLibGit2Features() LibGit2Features {
    return @bitCast(LibGit2Features, c.git_libgit2_features());
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

comptime {
    std.testing.refAllDecls(@This());
}
