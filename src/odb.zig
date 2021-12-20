const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Odb = opaque {
    pub fn deinit(self: *Odb) void {
        log.debug("Odb.deinit called", .{});

        c.git_odb_free(@ptrCast(*c.git_odb, self));

        log.debug("Odb freed successfully", .{});
    }

    pub fn repositoryOpen(self: *Odb) !*git.Repository {
        log.debug("Odb.repositoryOpen called", .{});

        var repo: *git.Repository = undefined;

        try internal.wrapCall("git_repository_wrap_odb", .{
            @ptrCast(*?*c.git_repository, &repo),
            @ptrCast(*c.git_odb, self),
        });

        log.debug("repository opened successfully", .{});

        return repo;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
