const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);
const old_version: bool = @import("build_options").old_version;
const git = @import("git.zig");

pub const Config = opaque {
    pub fn deinit(self: *Config) void {
        log.debug("Config.deinit called", .{});

        raw.git_config_free(internal.toC(self));

        log.debug("config freed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
