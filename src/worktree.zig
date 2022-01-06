const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Worktree = opaque {
    pub fn deinit(self: *Worktree) void {
        log.debug("Worktree.deinit called", .{});

        c.git_worktree_free(@ptrCast(*c.git_worktree, self));

        log.debug("worktree freed successfully", .{});
    }

    /// Check if worktree is valid
    ///
    /// A valid worktree requires both the git data structures inside the linked parent repository and the linked working
    /// copy to be present.
    pub fn valid(self: *const Worktree) !void {
        log.debug("Worktree.valid called", .{});

        try internal.wrapCall("git_worktree_validate", .{
            @ptrCast(*const c.git_worktree, self),
        });

        log.debug("worktree is valid", .{});
    }

    /// Lock worktree if not already locked
    ///
    /// Lock a worktree, optionally specifying a reason why the linked
    /// working tree is being locked.
    ///
    /// ## Parameters
    /// * `reason` - Reason why the working tree is being locked
    pub fn lock(self: *Worktree, reason: ?[:0]const u8) !void {
        log.debug("Worktree.lock called", .{});

        const c_reason: [*c]const u8 = if (reason) |s| s.ptr else null;

        internal.wrapCall("git_worktree_lock", .{
            @ptrCast(*c.git_worktree, self),
            c_reason,
        }) catch |err| {
            if (err == error.Locked) {
                log.err("worktree is already locked", .{});
            }
            return err;
        };

        log.debug("worktree locked", .{});
    }

    /// Unlock a locked worktree
    ///
    /// Returns `true` if the worktree was no locked
    pub fn unlock(self: *Worktree) !bool {
        log.debug("Worktree.unlock called", .{});

        const not_locked = (try internal.wrapCallWithReturn("git_worktree_unlock", .{@ptrCast(*c.git_worktree, self)})) != 0;

        if (not_locked) {
            log.debug("worktree was not locked", .{});
        } else {
            log.debug("worktree unlocked", .{});
        }

        return not_locked;
    }

    /// Check if worktree is locked
    //
    /// A worktree may be locked if the linked working tree is stored on a portable device which is not available.
    ///
    /// Returns `null` if the worktree is *not* locked, returns the reason for the lock if it is locked.
    pub fn is_locked(self: *const Worktree) !?git.Buf {
        log.debug("Worktree.is_locked called", .{});

        var ret: git.Buf = .{};

        const locked = (try internal.wrapCallWithReturn("git_worktree_is_locked", .{
            @ptrCast(*c.git_buf, &ret),
            @ptrCast(*const c.git_worktree, self),
        })) != 0;

        if (locked) {
            log.debug("worktree is locked, reason: {s}", .{ret.toSlice()});
            return ret;
        }

        log.debug("worktree is not locked", .{});
        return null;
    }

    /// Retrieve the name of the worktree
    ///
    /// The slice returned is valid for the lifetime of the `Worktree`
    pub fn name(self: *Worktree) ![:0]const u8 {
        log.debug("Worktree.name called", .{});

        const ptr = c.git_worktree_name(@ptrCast(*c.git_worktree, self));

        const slice = std.mem.sliceTo(ptr, 0);

        log.debug("worktree name: {s}", .{slice});

        return slice;
    }

    /// Retrieve the path of the worktree
    ///
    /// The slice returned is valid for the lifetime of the `Worktree`
    pub fn path(self: *Worktree) ![:0]const u8 {
        log.debug("Worktree.path called", .{});

        const ptr = c.git_worktree_path(@ptrCast(*c.git_worktree, self));

        const slice = std.mem.sliceTo(ptr, 0);

        log.debug("worktree path: {s}", .{slice});

        return slice;
    }

    pub fn repositoryOpen(self: *Worktree) !*git.Repository {
        log.debug("Worktree.repositoryOpen called", .{});

        var repo: *git.Repository = undefined;

        try internal.wrapCall("git_repository_open_from_worktree", .{
            @ptrCast(*?*c.git_repository, &repo),
            @ptrCast(*c.git_worktree, self),
        });

        log.debug("repository opened successfully", .{});

        return repo;
    }

    pub const PruneOptions = packed struct {
        /// Prune working tree even if working tree is valid
        valid: bool = false,
        /// Prune working tree even if it is locked
        locked: bool = false,
        /// Prune checked out working tree
        working_tree: bool = false,

        z_padding: u29 = 0,

        pub fn makeCOptionsObject(self: PruneOptions) c.git_worktree_prune_options {
            return .{
                .version = c.GIT_WORKTREE_PRUNE_OPTIONS_VERSION,
                .flags = @bitCast(u32, self),
            };
        }

        pub fn format(
            value: PruneOptions,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            return internal.formatWithoutFields(
                value,
                options,
                writer,
                &.{"z_padding"},
            );
        }

        test {
            try std.testing.expectEqual(@sizeOf(u32), @sizeOf(PruneOptions));
            try std.testing.expectEqual(@bitSizeOf(u32), @bitSizeOf(PruneOptions));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    /// Is the worktree prunable with the given options?
    ///
    /// A worktree is not prunable in the following scenarios:
    ///
    /// - the worktree is linking to a valid on-disk worktree. The `valid` member will cause this check to be ignored.
    /// - the worktree is locked. The `locked` flag will cause this check to be ignored.
    ///
    /// If the worktree is not valid and not locked or if the above flags have been passed in, this function will return a
    /// `true`
    pub fn isPruneable(self: *Worktree, options: PruneOptions) !bool {
        log.debug("Worktree.isPruneable called, options={}", .{options});

        var c_options = options.makeCOptionsObject();

        const ret = (try internal.wrapCallWithReturn("git_worktree_is_prunable", .{
            @ptrCast(*c.git_worktree, self),
            &c_options,
        })) != 0;

        log.debug("worktree is pruneable: {}", .{ret});

        return ret;
    }

    /// Prune working tree
    ///
    /// Prune the working tree, that is remove the git data structures on disk. The repository will only be pruned of
    /// `Worktree.isPruneable` succeeds.    
    pub fn prune(self: *Worktree, options: PruneOptions) !void {
        log.debug("Worktree.prune called, options={}", .{options});

        var c_options = options.makeCOptionsObject();

        try internal.wrapCall("git_worktree_prune", .{
            @ptrCast(*c.git_worktree, self),
            &c_options,
        });

        log.debug("successfully pruned worktree", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
