const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Reference = opaque {
    pub fn deinit(self: *Reference) void {
        log.debug("Reference.deinit called", .{});

        c.git_reference_free(@ptrCast(*c.git_reference, self));

        log.debug("reference freed successfully", .{});
    }

    /// Delete an existing branch reference.
    ///
    /// Note that if the deletion succeeds, the reference will not be valid anymore, and should be freed immediately by the user
    /// using `deinit`.
    pub fn deleteBranch(self: *Reference) !void {
        log.debug("Reference.deleteBranch called", .{});

        try internal.wrapCall("git_branch_delete", .{@ptrCast(*c.git_reference, self)});

        log.debug("successfully deleted branch", .{});
    }

    pub fn annotatedCommitCreate(self: *const Reference, repository: *git.Repository) !*git.AnnotatedCommit {
        log.debug("Reference.annotatedCommitCreate called, repository: {*}", .{repository});

        var result: *git.AnnotatedCommit = undefined;

        try internal.wrapCall("git_annotated_commit_from_ref", .{
            @ptrCast(*?*c.git_annotated_commit, &result),
            @ptrCast(*c.git_repository, repository),
            @ptrCast(*const c.git_reference, self),
        });

        log.debug("successfully created annotated commit", .{});

        return result;
    }

    /// Move/rename an existing local branch reference.
    ///
    /// The new branch name will be checked for validity.
    ///
    /// Note that if the move succeeds, the old reference will not be valid anymore, and should be freed immediately by the user
    /// using `deinit`.
    pub fn move(self: *Reference, new_branch_name: [:0]const u8, force: bool) !*Reference {
        log.debug("Reference.move called, new_branch_name: {s}, force: {}", .{ new_branch_name, force });

        var ref: *Reference = undefined;

        try internal.wrapCall("git_branch_move", .{
            @ptrCast(*?*c.git_reference, &ref),
            @ptrCast(*c.git_reference, self),
            new_branch_name.ptr,
            @boolToInt(force),
        });

        log.debug("successfully moved branch", .{});

        return ref;
    }

    pub fn nameGet(self: *Reference) ![:0]const u8 {
        log.debug("Reference.nameGet called", .{});

        var name: ?[*:0]const u8 = undefined;

        try internal.wrapCall("git_branch_name", .{ &name, @ptrCast(*const c.git_reference, self) });

        const slice = std.mem.sliceTo(name.?, 0);
        log.debug("successfully fetched name: {s}", .{slice});
        return slice;
    }

    pub fn upstreamGet(self: *Reference) !*Reference {
        log.debug("Reference.upstreamGet called", .{});

        var ref: *Reference = undefined;

        try internal.wrapCall("git_branch_upstream", .{
            @ptrCast(*?*c.git_reference, &ref),
            @ptrCast(*const c.git_reference, self),
        });

        log.debug("successfully fetched reference: {*}", .{ref});

        return ref;
    }

    pub fn upstreamSet(self: *Reference, branch_name: [:0]const u8) !void {
        log.debug("Reference.upstreamSet called, branch_name: {s}", .{branch_name});

        try internal.wrapCall("git_branch_set_upstream", .{ @ptrCast(*c.git_reference, self), branch_name.ptr });

        log.debug("successfully set upstream branch", .{});
    }

    pub fn isHead(self: *const Reference) !bool {
        log.debug("Reference.isHead", .{});

        const ret = (try internal.wrapCallWithReturn("git_branch_is_head", .{@ptrCast(*const c.git_reference, self)})) == 1;

        log.debug("is head: {}", .{ret});

        return ret;
    }

    pub fn isCheckedOut(self: *const Reference) !bool {
        log.debug("Reference.isCheckedOut", .{});

        const ret = (try internal.wrapCallWithReturn("git_branch_is_checked_out", .{@ptrCast(*const c.git_reference, self)})) == 1;

        log.debug("is checked out: {}", .{ret});

        return ret;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
