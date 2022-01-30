const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

/// Parsed representation of a tag object.
pub const Tag = opaque {
    pub fn deinit(self: *Tag) void {
        if (internal.trace_log) log.debug("Tag.deinit called", .{});

        c.git_tag_free(@ptrCast(*c.git_tag, self));
    }

    /// Get the id of a tag.
    pub fn id(self: *const Tag) *const git.Oid {
        if (internal.trace_log) log.debug("Tag.id called", .{});

        return @ptrCast(*const git.Oid, c.git_tag_id(
            @ptrCast(*const c.git_tag, self),
        ));
    }

    /// Get the repository that contains the tag.
    pub fn owner(self: *const Tag) *git.Repository {
        if (internal.trace_log) log.debug("Tag.owner called", .{});

        return @ptrCast(*git.Repository, c.git_tag_owner(
            @ptrCast(*const c.git_tag, self),
        ));
    }

    /// Get the tagged object of a tag,
    /// This method performs a repository lookup for the given object and returns it.
    pub fn target(self: *const Tag) !*git.Object {
        if (internal.trace_log) log.debug("Repository.target called", .{});

        var ret: *git.Object = undefined;

        try internal.wrapCall("git_tag_target", .{
            @ptrCast(*?*c.git_object, &ret),
            @ptrCast(*const c.git_tag, self),
        });

        return ret;
    }

    /// Get the OID of the tagged object of a tag.
    pub fn targetId(self: *const Tag) *const git.Oid {
        if (internal.trace_log) log.debug("Tag.targetId called", .{});

        return @ptrCast(*const git.Oid, c.git_tag_target_id(
            @ptrCast(*const c.git_tag, self),
        ));
    }

    /// Get the type of a tag's tagged object,
    pub fn targetType(self: *const Tag) git.ObjectType {
        if (internal.trace_log) log.debug("Tag.targetType called", .{});

        return @intToEnum(git.ObjectType, c.git_tag_target_type(
            @ptrCast(*const c.git_tag, self),
        ));
    }

    /// Get the name of a tag.
    pub fn name(self: *const Tag) [:0]const u8 {
        if (internal.trace_log) log.debug("Tag.name called", .{});

        return std.mem.sliceTo(c.git_tag_name(
            @ptrCast(*const c.git_tag, self),
        ), 0);
    }

    /// Get the tagger (author) of a tag.
    pub fn author(self: *const Tag) ?*const git.Signature {
        if (internal.trace_log) log.debug("Tag.author called", .{});

        return @ptrCast(?*const git.Signature, c.git_tag_tagger(
            @ptrCast(*const c.git_tag, self),
        ));
    }

    /// Get the message of a tag.
    pub fn message(self: *const Tag) ?[:0]const u8 {
        if (internal.trace_log) log.debug("Tag.message called", .{});

        return if (c.git_tag_message(@ptrCast(*const c.git_tag, self))) |s| std.mem.sliceTo(s, 0) else null;
    }

    /// Recursively peel a tag until a non tag git_object is found
    ///
    /// The retrieved `git.Object` object is owned by the repository and should be closed with the `Object.deinit` method.
    pub fn peel(self: *Tag) !*git.Object {
        if (internal.trace_log) log.debug("Tag.peel called", .{});

        var ret: *git.Object = undefined;

        try internal.wrapCall("git_tag_peel", .{
            @ptrCast(*?*c.git_object, &ret),
            @ptrCast(*const c.git_tag, self),
        });

        return ret;
    }

    /// Create an in-memory copy of a tag. The copy must be explicitly deinit'd or it will leak.
    pub fn duplicate(self: *Tag) !*Tag {
        if (internal.trace_log) log.debug("Tag.duplicate called", .{});

        var tag: *Tag = undefined;

        try internal.wrapCall("git_tag_dup", .{
            @ptrCast(*?*c.git_tag, &tag),
            @ptrCast(*c.git_tag, self),
        });

        return tag;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
