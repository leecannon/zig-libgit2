const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Note = opaque {
    pub fn deinit(self: *Note) void {
        log.debug("Note.deinit called", .{});

        c.git_note_free(@ptrCast(*c.git_note, self));

        log.debug("note freed successfully", .{});
    }

    /// Get the note author
    pub fn author(self: *const Note) *const git.Signature {
        log.debug("Note.author called", .{});

        return @ptrCast(
            *const git.Signature,
            c.git_note_author(@ptrCast(*const c.git_note, self)),
        );
    }

    /// Get the note committer
    pub fn committer(self: *const Note) *const git.Signature {
        log.debug("Note.committer called", .{});

        return @ptrCast(
            *const git.Signature,
            c.git_note_committer(@ptrCast(*const c.git_note, self)),
        );
    }

    /// Get the note message
    pub fn message(self: *const Note) [:0]const u8 {
        log.debug("Note.message called", .{});

        const ret = c.git_note_message(@ptrCast(*const c.git_note, self));

        return std.mem.sliceTo(ret, 0);
    }

    /// Get the note id
    pub fn id(self: *const Note) *const git.Oid {
        log.debug("Note.id called", .{});

        return @ptrCast(
            *const git.Oid,
            c.git_note_id(@ptrCast(*const c.git_note, self)),
        );
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const NoteIterator = opaque {
    /// Return the current item and advance the iterator internally to the next value
    pub fn next(self: *NoteIterator) !?NextItem {
        log.debug("NoteIterator.next called", .{});

        var ret: NextItem = undefined;

        internal.wrapCall("git_note_next", .{
            @ptrCast(*c.git_oid, &ret.note_id),
            @ptrCast(*c.git_oid, &ret.annotated_id),
            @ptrCast(*c.git_note_iterator, self),
        }) catch |err| switch (err) {
            git.GitError.IterOver => return null,
            else => |e| return e,
        };

        return ret;
    }

    pub fn deinit(self: *NoteIterator) void {
        log.debug("NoteIterator.deinit called", .{});

        c.git_note_iterator_free(@ptrCast(*c.git_note_iterator, self));

        log.debug("note iterator freed successfully", .{});
    }

    pub const NextItem = struct {
        note_id: git.Oid,
        annotated_id: git.Oid,
    };

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
