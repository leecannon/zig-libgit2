const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Config = opaque {
    pub fn deinit(self: *Config) void {
        log.debug("Config.deinit called", .{});

        raw.git_config_free(internal.toC(self));

        log.debug("config freed successfully", .{});
    }

    /// Priority level of a config file.
    pub const Level = enum(c_int) {
        /// System-wide on Windows, for compatibility with portable git
        PROGRAMDATA = 1,
        /// System-wide configuration file; /etc/gitconfig on Linux systems
        SYSTEM = 2,
        /// XDG compatible configuration file; typically ~/.config/git/config
        XDG = 3,
        /// User-specific configuration file (also called Global configuration file); typically ~/.gitconfig
        GLOBAL = 4,
        /// Repository specific configuration file; $WORK_DIR/.git/config on non-bare repos
        LOCAL = 5,
        /// Application specific configuration file; freely defined by applications
        APP = 6,
        /// Represents the highest level available config file (i.e. the most specific config file available that actually is 
        /// loaded)
        HIGHEST = -1,
    };

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
