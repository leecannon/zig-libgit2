const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);
const old_version: bool = @import("build_options").old_version;

pub const Handle = @import("handle.zig").Handle;
pub const Reference = @import("reference.zig").Reference;
pub const Repository = @import("repository.zig").Repository;
pub const StatusList = @import("status_list.zig").StatusList;
pub const DiffDelta = @import("diff.zig").DiffDelta;
pub const Tree = @import("tree.zig").Tree;
pub const AnnotatedCommit = @import("annotated_commit.zig").AnnotatedCommit;
pub const Oid = @import("oid.zig").Oid;
pub const Index = @import("index.zig").Index;
pub const RefDb = @import("ref_db.zig").RefDb;
pub const Config = @import("config.zig").Config;
pub const Worktree = @import("worktree.zig").Worktree;
pub const Odb = @import("odb.zig").Odb;
pub usingnamespace @import("types.zig");

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

comptime {
    std.testing.refAllDecls(@This());
}
