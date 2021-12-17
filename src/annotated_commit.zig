const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const AnnotatedCommit = opaque {
    pub fn deinit(self: *AnnotatedCommit) void {
        log.debug("AnnotatedCommit.deinit called", .{});

        raw.git_annotated_commit_free(@ptrCast(*raw.git_annotated_commit, self));

        log.debug("annotated commit freed successfully", .{});
    }

    /// Gets the commit ID that the given `AnnotatedCommit` refers to.
    pub fn commitId(self: *AnnotatedCommit) !*const git.Oid {
        log.debug("AnnotatedCommit.commitId called", .{});

        const oid = internal.fromC(raw.git_annotated_commit_id(@ptrCast(*raw.git_annotated_commit, self)));

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            const slice = try oid.formatHex(&buf);
            log.debug("annotated commit id acquired: {s}", .{slice});
        }

        return oid;
    }

    /// Gets the refname that the given `AnnotatedCommit` refers to.
    pub fn refname(self: *AnnotatedCommit) ![:0]const u8 {
        log.debug("AnnotatedCommit.refname called", .{});

        const slice = std.mem.sliceTo(raw.git_annotated_commit_ref(@ptrCast(*raw.git_annotated_commit, self)), 0);

        log.debug("annotated commit refname acquired: {s}", .{slice});

        return slice;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
