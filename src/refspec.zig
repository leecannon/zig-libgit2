const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

/// A refspec specifies the mapping between remote and local reference names when fetch or pushing.
pub const Refspec = opaque {
    /// Free a refspec object which has been created by Refspec.parse.
    pub fn deinit(self: *Refspec) void {
        log.debug("Refspec.deinit called", .{});

        c.git_refspec_free(@ptrCast(*c.git_refspec, self));

        log.debug("refspec freed successfully", .{});
    }

    /// Get the source specifier.
    pub fn source(self: *const Refspec) [:0]const u8 {
        log.debug("Refspec.source called", .{});

        const slice = std.mem.sliceTo(
            c.git_refspec_src(@ptrCast(
                *const c.git_refspec,
                self,
            )),
            0,
        );

        log.debug("source specifier: {s}", .{slice});

        return slice;
    }

    /// Get the destination specifier.
    pub fn destination(self: *const Refspec) [:0]const u8 {
        log.debug("Refspec.destination called", .{});

        const slice = std.mem.sliceTo(
            c.git_refspec_dst(@ptrCast(
                *const c.git_refspec,
                self,
            )),
            0,
        );

        log.debug("destination specifier: {s}", .{slice});

        return slice;
    }

    /// Get the refspec's string.
    pub fn string(self: *const Refspec) [:0]const u8 {
        log.debug("Refspec.string called", .{});

        const slice = std.mem.sliceTo(
            c.git_refspec_string(@ptrCast(
                *const c.git_refspec,
                self,
            )),
            0,
        );

        log.debug("refspec string: {s}", .{slice});

        return slice;
    }

    /// Get the force update setting.
    pub fn isForceUpdate(self: *const Refspec) bool {
        log.debug("Refspec.isForceUpdate called", .{});

        const ret = c.git_refspec_force(@ptrCast(*const c.git_refspec, self)) != 0;

        log.debug("is force update: {}", .{ret});

        return ret;
    }

    /// Get the refspec's direction.
    pub fn direction(self: *const Refspec) git.Direction {
        log.debug("Refspec.direction called", .{});

        const ret = @intToEnum(
            git.Direction,
            c.git_refspec_direction(@ptrCast(
                *const c.git_refspec,
                self,
            )),
        );

        log.debug("refspec direction: {}", .{ret});

        return ret;
    }

    /// Check if a refspec's source descriptor matches a reference
    pub fn srcMatches(self: *const Refspec, refname: [:0]const u8) bool {
        log.debug("Refspec.srcMatches called, refname: {s}", .{refname});

        const ret = c.git_refspec_src_matches(
            @ptrCast(*const c.git_refspec, self),
            refname.ptr,
        ) != 0;

        log.debug("match: {}", .{ret});

        return ret;
    }

    /// Check if a refspec's destination descriptor matches a reference
    pub fn destMatches(self: *const Refspec, refname: [:0]const u8) bool {
        log.debug("Refspec.destMatches called, refname: {s}", .{refname});

        const ret = c.git_refspec_dst_matches(
            @ptrCast(*const c.git_refspec, self),
            refname.ptr,
        ) != 0;

        log.debug("match: {}", .{ret});

        return ret;
    }

    /// Transform a reference to its target following the refspec's rules
    ///
    /// # Parameters
    /// * `name` - The name of the reference to transform.
    pub fn transform(self: *const Refspec, name: [:0]const u8) !git.Buf {
        log.debug("Refspec.transform called, name: {s}", .{name});

        var ret: git.Buf = .{};

        try internal.wrapCall("git_refspec_transform", .{
            @ptrCast(*c.git_buf, &ret),
            @ptrCast(*const c.git_refspec, self),
            name.ptr,
        });

        log.debug("refspec transform completed, out: {s}", .{ret.toSlice()});

        return ret;
    }

    /// Transform a target reference to its source reference following the refspec's rules
    ///
    /// # Parameters
    /// * `name` - The name of the reference to transform.
    pub fn rtransform(self: *const Refspec, name: [:0]const u8) !git.Buf {
        log.debug("Refspec.rtransform called, name: {s}", .{name});

        var ret: git.Buf = .{};

        try internal.wrapCall("git_refspec_rtransform", .{
            @ptrCast(*c.git_buf, &ret),
            @ptrCast(*const c.git_refspec, self),
            name.ptr,
        });

        log.debug("refspec rtransform completed, out: {s}", .{ret.toSlice()});
        return ret;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
