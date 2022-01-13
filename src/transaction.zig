const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Transaction = opaque {
    /// Free the resources allocated by this transaction
    ///
    /// If any references remain locked, they will be unlocked without any changes made to them.
    pub fn deinit(self: *Transaction) !void {
        log.debug("Transaction.deinit called", .{});

        c.git_transaction_free(@ptrCast(*c.git_transaction, self));

        log.debug("transaction freed successfully", .{});
    }

    /// Lock a reference
    ///
    /// Lock the specified reference. This is the first step to updating a reference
    ///
    /// ## Parameters
    /// * `refname` - The reference to lock
    pub fn lockReference(self: *Transaction, refname: [:0]const u8) !void {
        log.debug("Transaction.lockReference called, refname={s}", .{refname});

        try internal.wrapCall("git_transaction_lock_ref", .{
            @ptrCast(*c.git_transaction, self),
            refname.ptr,
        });

        log.debug("successfully locked reference", .{});
    }

    /// Set the target of a reference
    ///
    /// Set the target of the specified reference. This reference must be locked.
    ///
    /// ## Parameters
    /// * `refname` - The reference to lock
    /// * `target` - Target to set the reference to
    /// * `signature` - Signature to use in the reflog; pass `null` to read the identity from the config
    /// * `message` - Message to use in the reflog
    pub fn setTarget(
        self: *Transaction,
        refname: [:0]const u8,
        target: *const git.Oid,
        signature: ?*const git.Signature,
        message: [:0]const u8,
    ) !void {
        log.debug("Transaction.setTarget called, refname={s}, target={*}, signature={*}, message={s}", .{
            refname,
            target,
            signature,
            message,
        });

        try internal.wrapCall("git_transaction_set_target", .{
            @ptrCast(*c.git_transaction, self),
            refname.ptr,
            @ptrCast(*const c.git_oid, target),
            @ptrCast(?*const c.git_signature, signature),
            message.ptr,
        });

        log.debug("successfully set target", .{});
    }

    /// Set the target of a reference
    ///
    /// Set the target of the specified reference. This reference must be locked.
    ///
    /// ## Parameters
    /// * `refname` - The reference to lock
    /// * `target` - Target to set the reference to
    /// * `signature` - Signature to use in the reflog; pass `null` to read the identity from the config
    /// * `message` - Message to use in the reflog
    pub fn setSymbolicTarget(
        self: *Transaction,
        refname: [:0]const u8,
        target: [:0]const u8,
        signature: ?*const git.Signature,
        message: [:0]const u8,
    ) !void {
        log.debug("Transaction.setSymbolicTarget called, refname={s}, target={s}, signature={*}, message={s}", .{
            refname,
            target,
            signature,
            message,
        });

        try internal.wrapCall("git_transaction_set_symbolic_target", .{
            @ptrCast(*c.git_transaction, self),
            refname.ptr,
            target.ptr,
            @ptrCast(?*const c.git_signature, signature),
            message.ptr,
        });

        log.debug("successfully set target", .{});
    }

    /// Set the reflog of a reference
    ///
    /// Set the specified reference's reflog. If this is combined with setting the target, that update won't be written to the
    /// reflog.
    ///
    /// ## Parameters
    /// * `refname` - The reference to lock
    /// * `reflog` - The reflog as it should be written out
    pub fn setReflog(self: *Transaction, refname: [:0]const u8, reflog: *const git.Reflog) !void {
        log.debug("Transaction.setReflog called, refname={s}, reflog={*}", .{ refname, reflog });

        try internal.wrapCall("git_transaction_set_reflog", .{
            @ptrCast(*c.git_transaction, self),
            refname.ptr,
            @ptrCast(?*const c.git_reflog, reflog),
        });

        log.debug("successfully set reflog", .{});
    }

    /// Remove a reference
    ///
    /// ## Parameters
    /// * `refname` - The reference to remove
    pub fn remove(self: *Transaction, refname: [:0]const u8) !void {
        log.debug("Transaction.remove called, refname={s}", .{refname});

        try internal.wrapCall("git_transaction_remove", .{
            @ptrCast(*c.git_transaction, self),
            refname.ptr,
        });

        log.debug("successfully removed reference", .{});
    }

    /// Commit the changes from the transaction
    ///
    /// Perform the changes that have been queued. The updates will be made one by one, and the first failure will stop the
    /// processing.
    pub fn commit(self: *Transaction) !void {
        log.debug("Transaction.commit called", .{});

        try internal.wrapCall("git_transaction_commit", .{
            @ptrCast(*c.git_transaction, self),
        });

        log.debug("successfully commited transaction", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
