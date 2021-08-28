const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Worktree = opaque {
    pub fn deinit(self: *Worktree) void {
        log.debug("Worktree.deinit called", .{});

        raw.git_worktree_free(internal.toC(self));

        log.debug("worktree freed successfully", .{});
    }

    pub fn repositoryOpen(self: *Worktree) !*git.Repository {
        log.debug("Worktree.repositoryOpen called", .{});

        var repo: ?*raw.git_repository = undefined;

        try internal.wrapCall("git_repository_open_from_worktree", .{ &repo, internal.toC(self) });

        log.debug("repository opened successfully", .{});

        return internal.fromC(repo.?);
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
