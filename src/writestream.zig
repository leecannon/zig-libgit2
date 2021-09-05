const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const WriteStream = opaque {
    pub fn commit(self: *WriteStream) !git.Oid {
        log.debug("WriteStream.commit called", .{});

        var oid: raw.git_oid = undefined;

        try internal.wrapCall("git_blob_create_from_stream_commit", .{ &oid, internal.toC(self) });

        const ret = internal.fromC(oid);

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            const slice = try ret.formatHex(&buf);
            log.debug("successfully fetched blob id: {s}", .{slice});
        }

        return ret;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
