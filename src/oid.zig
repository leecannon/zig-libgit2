const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

/// Unique identity of any object (commit, tree, blob, tag).
pub const Oid = extern struct {
    id: [20]u8,

    /// Size (in bytes) of a hex formatted oid
    pub const HEX_BUFFER_SIZE = raw.GIT_OID_HEXSZ;

    /// Format a git_oid into a hex string.
    ///
    /// ## Parameters
    /// * `buf` - Slice to format the oid into, must be atleast `HEX_BUFFER_SIZE` long.
    pub fn formatHex(self: Oid, buf: []u8) ![]const u8 {
        if (buf.len < HEX_BUFFER_SIZE) return error.BufferTooShort;

        try internal.wrapCall("git_oid_fmt", .{ buf.ptr, internal.toC(&self) });

        return buf[0..HEX_BUFFER_SIZE];
    }

    /// Format a git_oid into a zero-terminated hex string.
    ///
    /// ## Parameters
    /// * `buf` - Slice to format the oid into, must be atleast `HEX_BUFFER_SIZE` + 1 long.
    pub fn formatHexZ(self: Oid, buf: []u8) ![:0]const u8 {
        if (buf.len < (HEX_BUFFER_SIZE + 1)) return error.BufferTooShort;

        try internal.wrapCall("git_oid_fmt", .{ buf.ptr, internal.toC(&self) });
        buf[HEX_BUFFER_SIZE] = 0;

        return buf[0..HEX_BUFFER_SIZE :0];
    }

    test {
        try std.testing.expectEqual(@sizeOf(raw.git_oid), @sizeOf(Oid));
        try std.testing.expectEqual(@bitSizeOf(raw.git_oid), @bitSizeOf(Oid));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
