const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const StatusList = opaque {
    pub fn deinit(self: *StatusList) void {
        log.debug("StatusList.deinit called", .{});

        c.git_status_list_free(@ptrCast(*c.git_status_list, self));

        log.debug("status list freed successfully", .{});
    }

    pub fn entryCount(self: *StatusList) usize {
        log.debug("StatusList.entryCount called", .{});

        const ret = c.git_status_list_entrycount(@ptrCast(*c.git_status_list, self));

        log.debug("status list entry count: {}", .{ret});

        return ret;
    }

    pub fn statusByIndex(self: *StatusList, index: usize) ?*const StatusEntry {
        log.debug("StatusList.statusByIndex called, index: {}", .{index});

        return @ptrCast(
            ?*const StatusEntry,
            c.git_status_byindex(@ptrCast(*c.git_status_list, self), index),
        );
    }

    /// Get performance data for diffs from a StatusList
    pub fn getPerfData(self: *const StatusList) !git.DiffPerfData {
        log.debug("StatusList.getPerfData called", .{});

        var c_ret = c.git_diff_perfdata{
            .version = c.GIT_DIFF_PERFDATA_VERSION,
            .stat_calls = 0,
            .oid_calculations = 0,
        };

        try internal.wrapCall("git_status_list_get_perfdata", .{
            &c_ret,
            @ptrCast(*const c.git_status_list, self),
        });

        const ret: git.DiffPerfData = .{
            .stat_calls = c_ret.stat_calls,
            .oid_calculations = c_ret.oid_calculations,
        };

        log.debug("perf data: {}", .{ret});

        return ret;
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
            try std.testing.expectEqual(@sizeOf(c.git_status_entry), @sizeOf(StatusEntry));
            try std.testing.expectEqual(@bitSizeOf(c.git_status_entry), @bitSizeOf(StatusEntry));
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
