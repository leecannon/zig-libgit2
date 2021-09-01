const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Reference = opaque {
    pub fn deinit(self: *Reference) void {
        log.debug("Reference.deinit called", .{});

        raw.git_reference_free(internal.toC(self));

        log.debug("reference freed successfully", .{});
    }

    pub fn annotatedCommitCreate(self: *const Reference, repository: *git.Repository) !*git.AnnotatedCommit {
        log.debug("Reference.annotatedCommitCreate called, repository={*}", .{repository});

        var result: ?*raw.git_annotated_commit = undefined;
        try internal.wrapCall("git_annotated_commit_from_ref", .{ &result, internal.toC(repository), internal.toC(self) });

        log.debug("successfully created annotated commit", .{});

        return internal.fromC(result.?);
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
