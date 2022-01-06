const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

/// A refspec specifies the mapping between remote and local reference names when fetch or pushing.
pub const Refspec = opaque {
    /// Get the refspec's string.
    pub fn string(self: *const Refspec) [:0]const u8 {
        return std.mem.span(c.git_refspec_string(@ptrCast(*c.git_refspec, self)));
    }

    /// Get the source specifier.
    pub fn src(self: *const Refspec) [:0]const u8 {
        return std.mem.span(c.git_refspec_src(@ptrCast(*c.git_refspec, self)));
    }

    /// Get the destination specifier.
    pub fn dest(self: *const Refspec) [:0]const u8 {
        return std.mem.span(c.git_refspec_dest(@ptrCast(*c.git_refspec, self)));
    }

    /// Get the force update setting.
    pub fn force(refspec: *const Refspec) bool {
        return c.git_refspec_force(@ptrCast(*const c.git_refspec, refspec)) != 0;
    }

    /// Get the refspec's direction.
    pub fn direction(refspec: *const Refspec) git.Direction {
        return @intToEnum(git.Direction, c.git_refspec_direction(@ptrCast(*const c.git_refspec, refspec)));
    }

    /// Parse a given refspec string.
    ///
    /// ## Parameters
    /// * `input` the refspec string
    /// * `is_fetch` is this a refspec for a fetch
    pub fn parse(input: [:0]const u8, is_fetch: bool) !*Refspec {
        log.debug("Refspec.parse called, input: {s}, is_fetch={}", .{ input, is_fetch });

        var ret: *Refspec = undefined;
        try internal.wrapCall("git_refspec_parse", .{
            @ptrCast(**c.git_refspec, &ret),
            input.ptr,
            @boolToInt(is_fetch),
        });

        log.debug("refspec parsed");
        return ret;
    }

    /// Free a refspec object  which has been created by Refspec.parse.
    pub fn deinit(self: *const Refspec) void {
        c.git_refspec_free(@ptrCast(*c.git_refspec, self));
    }

    /// Check if a refspec's source descriptor matches a reference
    pub fn srcMatches(refspec: *const Refspec, refname: [:0]const u8) bool {
        return c.git_refspec_src_matches(@ptrCast(*const c.git_refspec, refspec), refname.ptr) != 0;
    }

    /// Check if a refspec's destination descriptor matches a reference
    pub fn destMatches(refspec: *const Refspec, refname: [:0]const u8) bool {
        return c.git_refspec_dst_matches(@ptrCast(*const c.git_refspec, refspec), refname.ptr) != 0;
    }

    /// Transform a reference to its target following the refspec's rules
    ///
    /// # Parameters
    /// * `name` - The name of the reference to transform.
    pub fn transform(refspec: *const Refspec, name: [:0]const u8) !git.Buf {
        log.debug("Refspec.transform called, name={s}", .{name});

        var ret: git.Buf = undefined;
        try internal.wrapCall("git_refspec_transform", .{
            @ptrCast(*git.Buf, &ret),
            @ptrCast(*const c.git_refspec, refspec),
            name.ptr,
        });

        log.debug("refspec transform completed, out={s}", .{ret.toSlice()});
        return ret;
    }

    /// Transform a target reference to its source reference following the refspec's rules
    ///
    /// # Parameters
    /// * `name` - The name of the reference to transform.
    pub fn rtransform(refspec: *const Refspec, name: [:0]const u8) !git.Buf {
        log.debug("Refspec.rtransform called, name={s}", .{name});

        var ret: git.Buf = undefined;
        try internal.wrapCall("git_refspec_rtransform", .{
            @ptrCast(*git.Buf, &ret),
            @ptrCast(*const c.git_refspec, refspec),
            name.ptr,
        });

        log.debug("refspec rtransform completed, out={s}", .{ret.toSlice()});
        return ret;
    }
};
