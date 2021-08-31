const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const AnnotatedCommit = opaque {
    pub fn deinit(self: *AnnotatedCommit) void {
        log.debug("AnnotatedCommit.deinit called", .{});

        raw.git_annotated_commit_free(internal.toC(self));

        log.debug("annotated commit freed successfully", .{});
    }

    /// Gets the commit ID that the given `AnnotatedCommit` refers to.
    pub fn getCommitId(self: *const AnnotatedCommit) !*const git.Oid {
        log.debug("AnnotatedCommit.getCommitId called", .{});

        const oid = internal.fromC(raw.git_annotated_commit_id(internal.toC(self)));

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            const slice = try oid.formatHex(&buf);
            log.debug("annotated commit id acquired: {s}", .{slice});
        }

        return oid;
    }

    /// Gets the refname that the given `AnnotatedCommit` refers to.
    pub fn getRefname(self: *const AnnotatedCommit) ![:0]const u8 {
        log.debug("AnnotatedCommit.getRefname called", .{});

        const slice = std.mem.sliceTo(raw.git_annotated_commit_ref(internal.toC(self)), 0);

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
