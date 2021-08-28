const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Odb = opaque {
    pub fn deinit(self: *Odb) void {
        log.debug("Odb.deinit called", .{});

        raw.git_odb_free(internal.toC(self));

        log.debug("Odb freed successfully", .{});
    }

    pub fn repositoryOpen(self: *Odb) !*git.Repository {
        log.debug("Odb.repositoryOpen called", .{});

        var repo: ?*raw.git_repository = undefined;

        try internal.wrapCall("git_repository_wrap_odb", .{ &repo, internal.toC(self) });

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
