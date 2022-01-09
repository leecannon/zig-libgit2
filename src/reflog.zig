const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

/// Representation of a reference log
pub const Reflog = opaque {
    /// Free the reflog
    pub fn deinit(self: *Reflog) void {
        log.debug("Reflog.deinit called", .{});

        c.git_reflog_free(@ptrCast(*c.git_reflog, self));

        log.debug("reflog freed successfully", .{});
    }

    /// Write an existing in-memory reflog object back to disk using an atomic file lock.
    pub fn write(self: *Reflog) !void {
        log.debug("Reflog.write called", .{});

        try internal.wrapCall("git_reflog_write", .{
            @ptrCast(*c.git_reflog, self),
        });

        log.debug("successfully wrote reflog", .{});
    }

    /// Add a new entry to the in-memory reflog.
    ///
    /// ## Parameters
    /// * `id` - The OID the reference is now pointing to
    /// * `signature` - The signature of the committer
    /// * `msg` - The reflog message, optional
    pub fn append(
        self: *Reflog,
        id: git.Oid,
        signature: git.Signature,
        msg: ?[:0]const u8,
    ) !void {
        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.hex_buffer_size]u8 = undefined;
            const slice = try id.formatHex(&buf);
            log.debug("Reflog.append called, id: {s}, signature: {}, msg: {s}", .{
                slice,
                signature,
                msg,
            });
        }

        const c_msg = if (msg) |s| s.ptr else null;

        try internal.wrapCall("git_reflog_append", .{
            @ptrCast(*c.git_reflog, self),
            @ptrCast(*const c.git_oid, &id),
            @ptrCast(*const c.git_signature, &signature),
            c_msg,
        });

        log.debug("appended successfully", .{});
    }

    /// Get the number of log entries in a reflog
    pub fn entryCount(self: *Reflog) usize {
        log.debug("Reflog.entryCount called", .{});

        const ret = c.git_reflog_entrycount(
            @ptrCast(*c.git_reflog, self),
        );

        log.debug("entry count: {}", .{ret});

        return ret;
    }

    /// Lookup an entry by its index
    ///
    /// Requesting the reflog entry with an index of 0 (zero) will return the most recently created entry.
    ///
    /// ## Parameters
    /// * `index` - The position of the entry to lookup. Should be less than `Reflog.entryCount()`
    pub fn getEntry(self: *const Reflog, index: usize) ?*const ReflogEntry {
        log.debug("Reflog.getEntry called, index: {}", .{index});

        return @ptrCast(
            ?*const ReflogEntry,
            c.git_reflog_entry_byindex(
                @ptrCast(*const c.git_reflog, self),
                index,
            ),
        );
    }

    /// Remove an entry from the reflog by its index
    ///
    /// To ensure there's no gap in the log history, set `rewrite_previous_entry` param value to `true`.
    /// When deleting entry `n`, member old_oid of entry `n-1` (if any) will be updated with the value of member new_oid of entry
    /// `n+1`.
    ///
    /// ## Parameters
    /// * `index` - The position of the entry to lookup. Should be less than `Reflog.entryCount()`
    /// * `rewrite_previous_entry` - `true` to rewrite the history; `false` otherwise
    pub fn removeEntry(self: *Reflog, index: usize, rewrite_previous_entry: bool) !void {
        log.debug("Reflog.removeEntry called, index: {}, rewrite_previous_entry: {}", .{ index, rewrite_previous_entry });

        try internal.wrapCall("git_reflog_drop", .{
            @ptrCast(*c.git_reflog, self),
            index,
            @boolToInt(rewrite_previous_entry),
        });

        log.debug("successfully removed entry", .{});
    }

    /// Representation of a reference log entry
    pub const ReflogEntry = opaque {
        /// Get the old oid
        pub fn oldId(self: *const ReflogEntry) *const git.Oid {
            log.debug("ReflogEntry.oldId called", .{});

            const ret = @ptrCast(*const git.Oid, c.git_reflog_entry_id_old(
                @ptrCast(*const c.git_reflog_entry, self),
            ));

            // This check is to prevent formating the oid when we are not going to print anything
            if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
                var buf: [git.Oid.hex_buffer_size]u8 = undefined;
                if (ret.formatHex(&buf)) |slice| {
                    log.debug("old id: {s}", .{slice});
                } else |_| {}
            }

            return ret;
        }

        /// Get the new oid
        pub fn newId(self: *const ReflogEntry) *const git.Oid {
            log.debug("ReflogEntry.newId called", .{});

            const ret = @ptrCast(*const git.Oid, c.git_reflog_entry_id_new(
                @ptrCast(*const c.git_reflog_entry, self),
            ));

            // This check is to prevent formating the oid when we are not going to print anything
            if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
                var buf: [git.Oid.hex_buffer_size]u8 = undefined;
                if (ret.formatHex(&buf)) |slice| {
                    log.debug("new id: {s}", .{slice});
                } else |_| {}
            }

            return ret;
        }

        /// Get the committer of this entry
        pub fn commiter(self: *const ReflogEntry) *const git.Signature {
            log.debug("ReflogEntry.commiter called", .{});

            const ret = @ptrCast(*const git.Signature, c.git_reflog_entry_committer(
                @ptrCast(*const c.git_reflog_entry, self),
            ));

            log.debug("commiter: {*}", .{ret});

            return ret;
        }

        /// Get the log message
        pub fn message(self: *const ReflogEntry) ?[:0]const u8 {
            log.debug("ReflogEntry.message called", .{});

            const opt_ret = @ptrCast(?[*:0]const u8, c.git_reflog_entry_message(
                @ptrCast(*const c.git_reflog_entry, self),
            ));

            if (opt_ret) |ret| {
                const slice = std.mem.sliceTo(ret, 0);

                log.debug("message: {s}", .{slice});

                return slice;
            }

            log.debug("no message", .{});
            return null;
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
