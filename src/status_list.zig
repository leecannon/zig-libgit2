const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const StatusList = opaque {
    pub fn deinit(self: *StatusList) void {
        log.debug("StatusList.deinit called", .{});

        raw.git_status_list_free(@ptrCast(*raw.git_status_list, self));

        log.debug("status list freed successfully", .{});
    }

    pub fn entryCount(self: *StatusList) usize {
        log.debug("StatusList.entryCount called", .{});

        const ret = raw.git_status_list_entrycount(@ptrCast(*raw.git_status_list, self));

        log.debug("status list entry count: {}", .{ret});

        return ret;
    }

    pub fn statusByIndex(self: *StatusList, index: usize) ?*const StatusEntry {
        log.debug("StatusList.statusByIndex called, index={}", .{index});

        const ret_opt = @ptrCast(
            ?*const StatusEntry,
            raw.git_status_byindex(@ptrCast(*raw.git_status_list, self), index),
        );

        if (ret_opt) |ret| {
            log.debug("successfully fetched status entry: {}", .{ret});

            return ret;
        } else {
            log.debug("index out of bounds", .{});
            return null;
        }
    }

    /// A status entry, providing the differences between the file as it exists in HEAD and the index, and providing the 
    /// differences between the index and the working directory.
    pub const StatusEntry = extern struct {
        /// The status for this file
        status: git.FileStatus,

        /// information about the differences between the file in HEAD and the file in the index.
        head_to_index: *git.DiffDelta,

        /// information about the differences between the file in the index and the file in the working directory.
        index_to_workdir: *git.DiffDelta,

        test {
            try std.testing.expectEqual(@sizeOf(raw.git_status_entry), @sizeOf(StatusEntry));
            try std.testing.expectEqual(@bitSizeOf(raw.git_status_entry), @bitSizeOf(StatusEntry));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
