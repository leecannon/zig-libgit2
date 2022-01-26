const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Config = opaque {
    pub fn deinit(self: *Config) void {
        log.debug("Config.deinit called", .{});

        c.git_config_free(@ptrCast(*c.git_config, self));

        log.debug("config freed successfully", .{});
    }

    pub fn getEntry(self: *const Config, name: [:0]const u8) !*ConfigEntry {
        log.debug("Config.getEntry called, name: {s}", .{name});

        var entry: *ConfigEntry = undefined;

        try internal.wrapCall("git_config_get_entry", .{
            @ptrCast(*?*c.git_config_entry, &entry),
            @ptrCast(*const c.git_config, self),
            name.ptr,
        });

        log.debug("got entry: {*}", .{entry});

        return entry;
    }

    pub fn getInt(self: *const Config, name: [:0]const u8) !i32 {
        log.debug("Config.getInt called, name: {s}", .{name});

        var value: i32 = undefined;

        try internal.wrapCall("git_config_get_int32", .{ &value, @ptrCast(*const c.git_config, self), name.ptr });

        log.debug("got int value: {}", .{value});

        return value;
    }

    pub fn setInt(self: *Config, name: [:0]const u8, value: i32) !void {
        log.debug("Config.setInt called, name: {s}, value: {}", .{ name, value });

        try internal.wrapCall("git_config_set_int32", .{ @ptrCast(*c.git_config, self), name.ptr, value });

        log.debug("successfully set int value", .{});
    }

    pub fn getInt64(self: *const Config, name: [:0]const u8) !i64 {
        log.debug("Config.getInt64 called, name: {s}", .{name});

        var value: i64 = undefined;

        try internal.wrapCall("git_config_get_int64", .{ &value, @ptrCast(*const c.git_config, self), name.ptr });

        log.debug("got int value: {}", .{value});

        return value;
    }

    pub fn setInt64(self: *Config, name: [:0]const u8, value: i64) !void {
        log.debug("Config.setInt64 called, name: {s}, value: {}", .{ name, value });

        try internal.wrapCall("git_config_set_int64", .{ @ptrCast(*c.git_config, self), name.ptr, value });

        log.debug("successfully set int value", .{});
    }

    pub fn getBool(self: *const Config, name: [:0]const u8) !bool {
        log.debug("Config.getBool called, name: {s}", .{name});

        var value: c_int = undefined;

        try internal.wrapCall("git_config_get_bool", .{ &value, @ptrCast(*const c.git_config, self), name.ptr });

        const ret = value != 0;

        log.debug("got bool value: {}", .{ret});

        return ret;
    }

    pub fn setBool(self: *Config, name: [:0]const u8, value: bool) !void {
        log.debug("Config.setBool called, name: {s}, value: {}", .{ name, value });

        try internal.wrapCall("git_config_set_bool", .{ @ptrCast(*c.git_config, self), name.ptr, @boolToInt(value) });

        log.debug("successfully set bool value", .{});
    }

    pub fn getPath(self: *const Config, name: [:0]const u8) !git.Buf {
        log.debug("Config.getPath called, name: {s}", .{name});

        var buf: git.Buf = .{};

        try internal.wrapCall("git_config_get_path", .{
            @ptrCast(*c.git_buf, &buf),
            @ptrCast(*const c.git_config, self),
            name.ptr,
        });

        log.debug("got path value: {s}", .{buf.toSlice()});

        return buf;
    }

    pub fn getString(self: *const Config, name: [:0]const u8) ![:0]const u8 {
        log.debug("Config.getString called, name: {s}", .{name});

        var str: ?[*:0]const u8 = undefined;

        try internal.wrapCall("git_config_get_string", .{
            &str,
            @ptrCast(*const c.git_config, self),
            name.ptr,
        });

        const slice = std.mem.sliceTo(str.?, 0);

        log.debug("got string value: {s}", .{slice});

        return slice;
    }

    pub fn setString(self: *Config, name: [:0]const u8, value: [:0]const u8) !void {
        log.debug("Config.setString called, name: {s}, value: {s}", .{ name, value });

        try internal.wrapCall("git_config_set_string", .{ @ptrCast(*c.git_config, self), name.ptr, value.ptr });

        log.debug("successfully set string value", .{});
    }

    pub fn setMultivar(self: *Config, name: [:0]const u8, regex: [:0]const u8, value: [:0]const u8) !void {
        log.debug("Config.setMultivar called, name: {s},regex: {s}, value: {s}", .{ name, regex, value });

        try internal.wrapCall("git_config_set_multivar", .{ @ptrCast(*c.git_config, self), name.ptr, regex.ptr, value.ptr });

        log.debug("successfully set multivar value", .{});
    }

    pub fn getStringBuf(self: *const Config, name: [:0]const u8) !git.Buf {
        log.debug("Config.getStringBuf called, name: {s}", .{name});

        var buf: git.Buf = .{};

        try internal.wrapCall("git_config_get_string_buf", .{
            @ptrCast(*c.git_buf, &buf),
            @ptrCast(*const c.git_config, self),
            name.ptr,
        });

        log.debug("got string value: {s}", .{buf.toSlice()});

        return buf;
    }

    pub fn foreachMultivar(
        self: *const Config,
        name: [:0]const u8,
        regex: ?[:0]const u8,
        user_data: anytype,
        comptime callback_fn: fn (entry: *const ConfigEntry, user_data_ptr: @TypeOf(user_data)) c_int,
    ) !c_int {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(
                entry: *const c.git_config_entry,
                payload: ?*anyopaque,
            ) callconv(.C) c_int {
                return callback_fn(
                    @ptrCast(*const ConfigEntry, entry),
                    @ptrCast(UserDataType, payload),
                );
            }
        }.cb;

        log.debug("Config.foreachMultivar called, name: {s}, regex: {s}", .{ name, regex });

        const regex_c = if (regex) |str| str.ptr else null;

        const ret = try internal.wrapCallWithReturn("git_config_get_multivar_foreach", .{
            @ptrCast(*const c.git_config, self),
            name.ptr,
            regex_c,
            cb,
            user_data,
        });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    pub fn foreachConfig(
        self: *const Config,
        user_data: anytype,
        comptime callback_fn: fn (entry: *const ConfigEntry, user_data_ptr: @TypeOf(user_data)) c_int,
    ) !c_int {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(
                entry: *const c.git_config_entry,
                payload: ?*anyopaque,
            ) callconv(.C) c_int {
                return callback_fn(
                    @ptrCast(*const ConfigEntry, entry),
                    @ptrCast(UserDataType, payload),
                );
            }
        }.cb;

        log.debug("Config.foreachConfig called", .{});

        const ret = try internal.wrapCallWithReturn("git_config_foreach", .{
            @ptrCast(*const c.git_config, self),
            cb,
            user_data,
        });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    pub fn foreachConfigMatch(
        self: *const Config,
        regex: [:0]const u8,
        user_data: anytype,
        comptime callback_fn: fn (entry: *const ConfigEntry, user_data_ptr: @TypeOf(user_data)) c_int,
    ) !c_int {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(
                entry: *const c.git_config_entry,
                payload: ?*anyopaque,
            ) callconv(.C) c_int {
                return callback_fn(
                    @ptrCast(*const ConfigEntry, entry),
                    @ptrCast(UserDataType, payload),
                );
            }
        }.cb;

        log.debug("Config.foreachConfigMatch called, regex: {s}", .{regex});

        const ret = try internal.wrapCallWithReturn("git_config_foreach_match", .{
            @ptrCast(*const c.git_config, self),
            regex.ptr,
            cb,
            user_data,
        });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    pub fn deleteEntry(self: *Config, name: [:0]const u8) !void {
        log.debug("Config.deleteEntry called, name: {s}", .{name});

        try internal.wrapCall("git_config_delete_entry", .{ @ptrCast(*c.git_config, self), name.ptr });

        log.debug("successfully deleted entry", .{});
    }

    pub fn deleteMultivar(self: *Config, name: [:0]const u8, regex: [:0]const u8) !void {
        log.debug("Config.deleteMultivar called, name: {s}, regex: {s}", .{ name, regex });

        try internal.wrapCall("git_config_delete_multivar", .{ @ptrCast(*c.git_config, self), name.ptr, regex.ptr });

        log.debug("successfully deleted multivar", .{});
    }

    pub fn addFileOnDisk(self: *Config, path: [:0]const u8, level: ConfigLevel, repo: *const git.Repository, force: bool) !void {
        log.debug("Config.addFileOnDisk called, path: {s}, level: {}, repo: {*}, force: {}", .{ path, level, repo, force });

        try internal.wrapCall("git_config_add_file_ondisk", .{
            @ptrCast(*c.git_config, self),
            path.ptr,
            @enumToInt(level),
            @ptrCast(*const c.git_repository, self),
            @boolToInt(force),
        });

        log.debug("", .{});
    }

    pub fn openLevel(self: *const Config, level: ConfigLevel) !*Config {
        log.debug("Config.openLevel called, level: {}", .{level});

        var config: *Config = undefined;

        try internal.wrapCall("git_config_open_level", .{
            @ptrCast(*?*c.git_config, &config),
            @ptrCast(*const c.git_config, self),
            @enumToInt(level),
        });

        log.debug("opened config for level", .{});

        return config;
    }

    pub fn openGlobal(self: *git.Config) !*Config {
        log.debug("Config.openGlobal called", .{});

        var config: *Config = undefined;

        try internal.wrapCall("git_config_open_global", .{
            @ptrCast(*?*c.git_config, &config),
            @ptrCast(*c.git_config, self),
        });

        log.debug("opened global config", .{});

        return config;
    }

    pub fn snapshot(self: *git.Config) !*Config {
        log.debug("Config.snapshot called", .{});

        var config: *Config = undefined;

        try internal.wrapCall("git_config_snapshot", .{
            @ptrCast(*?*c.git_config, &config),
            @ptrCast(*c.git_config, self),
        });

        log.debug("created snapshot of config", .{});

        return config;
    }

    pub fn lock(self: *Config) !*git.Transaction {
        log.debug("Config.lock called", .{});

        var transaction: *git.Transaction = undefined;

        try internal.wrapCall("git_config_lock", .{
            @ptrCast(*?*c.git_transaction, &transaction),
            @ptrCast(*c.git_config, self),
        });

        log.debug("successfully locked config", .{});

        return transaction;
    }

    pub fn iterateMultivar(self: *const Config, name: [:0]const u8, regex: ?[:0]const u8) !*ConfigIterator {
        log.debug("Config.iterateMultivar called, name: {s}, regex: {s}", .{ name, regex });

        var iterator: *ConfigIterator = undefined;

        const regex_c = if (regex) |str| str.ptr else null;

        try internal.wrapCall("git_config_multivar_iterator_new", .{
            @ptrCast(*?*c.git_config_iterator, &iterator),
            @ptrCast(*const c.git_config, self),
            name.ptr,
            regex_c,
        });

        log.debug("multivar config iterator created successfully", .{});

        return iterator;
    }

    pub fn iterate(self: *const Config) !*ConfigIterator {
        log.debug("Config.iterate called", .{});

        var iterator: *ConfigIterator = undefined;

        try internal.wrapCall("git_config_iterator_new", .{
            @ptrCast(*?*c.git_config_iterator, &iterator),
            @ptrCast(*const c.git_config, self),
        });

        log.debug("config iterator created successfully", .{});

        return iterator;
    }

    pub fn iterateGlob(self: *const Config, regex: [:0]const u8) !*ConfigIterator {
        log.debug("Config.iterateGlob called", .{});

        var iterator: *ConfigIterator = undefined;

        try internal.wrapCall("git_config_iterator_glob_new", .{
            @ptrCast(*?*c.git_config_iterator, &iterator),
            @ptrCast(*const c.git_config, self),
            regex.ptr,
        });

        log.debug("config iterator created successfully", .{});

        return iterator;
    }

    pub const ConfigIterator = opaque {
        pub fn next(self: *ConfigIterator) !?*ConfigEntry {
            log.debug("ConfigIterator.next called", .{});

            var entry: *ConfigEntry = undefined;

            internal.wrapCall("git_config_next", .{
                @ptrCast(*?*c.git_config_entry, &entry),
                @ptrCast(*c.git_config_iterator, self),
            }) catch |err| switch (err) {
                git.GitError.IterOver => return null,
                else => |e| return e,
            };

            log.debug("successfully fetched config entry: {*}", .{entry});

            return entry;
        }

        pub fn deinit(self: *ConfigIterator) void {
            log.debug("ConfigIterator.deinit called", .{});

            c.git_config_iterator_free(@ptrCast(*c.git_config_iterator, self));

            log.debug("config iterator freed successfully", .{});
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    pub fn getMapped(self: *const Config, name: [:0]const u8, maps: []const ConfigMap) !c_int {
        log.debug("Config.getMapped called, name: {s}", .{name});

        var value: c_int = undefined;

        try internal.wrapCall("git_config_get_mapped", .{
            &value,
            @ptrCast(*const c.git_config, self),
            name.ptr,
            @ptrCast([*]const c.git_configmap, maps.ptr),
            maps.len,
        });

        log.debug("mapped to: {}", .{value});

        return value;
    }

    pub fn parseBool(value: [:0]const u8) !bool {
        var res: c_int = undefined;
        try internal.wrapCall("git_config_parse_bool", .{ &res, value.ptr });
        return res != 0;
    }

    pub fn parseInt(value: [:0]const u8) !i32 {
        var res: i32 = undefined;
        try internal.wrapCall("git_config_parse_int32", .{ &res, value.ptr });
        return res;
    }

    pub fn parseInt64(value: [:0]const u8) !i64 {
        var res: i64 = undefined;
        try internal.wrapCall("git_config_parse_int64", .{ &res, value.ptr });
        return res;
    }

    pub fn parsePath(value: [:0]const u8) !git.Buf {
        var buf: git.Buf = .{};
        try internal.wrapCall("git_config_parse_path", .{ @ptrCast(*c.git_buf, &buf), value.ptr });
        return buf;
    }

    pub const ConfigMap = extern struct {
        map_type: MapType,
        str_match: [*:0]const u8,
        map_value: c_int,

        pub const MapType = enum(c_int) {
            @"false" = 0,
            @"true" = 1,
            int32 = 2,
            string = 3,
        };

        pub fn lookupMapValue(maps: []const ConfigMap, value: [:0]const u8) !c_int {
            log.debug("ConfigMap.lookupMapValue called, value: {s}", .{value});

            var result: c_int = undefined;

            try internal.wrapCall("git_config_lookup_map_value", .{
                &result,
                @ptrCast([*]const c.git_configmap, maps.ptr),
                maps.len,
                value.ptr,
            });

            log.debug("mapped to: {}", .{result});

            return result;
        }

        test {
            try std.testing.expectEqual(@sizeOf(c.git_configmap), @sizeOf(ConfigMap));
            try std.testing.expectEqual(@bitSizeOf(c.git_configmap), @bitSizeOf(ConfigMap));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    pub const ConfigEntry = extern struct {
        /// Name of the entry (normalised)
        name: [*:0]const u8,
        /// String value of the entry
        value: [*:0]const u8,
        /// Depth of includes where this variable was found
        include_depth: u32,
        /// Which config file this was found in
        level: ConfigLevel,
        /// Free function for this entry 
        free_fn: ?fn (?*ConfigEntry) callconv(.C) void,
        /// Opaque value for the free function. Do not read or write
        payload: *anyopaque,

        pub fn deinit(self: *ConfigEntry) void {
            log.debug("ConfigEntry.deinit called", .{});

            c.git_config_entry_free(@ptrCast(*c.git_config_entry, self));

            log.debug("config entry freed successfully", .{});
        }

        test {
            try std.testing.expectEqual(@sizeOf(c.git_config_entry), @sizeOf(ConfigEntry));
            try std.testing.expectEqual(@bitSizeOf(c.git_config_entry), @bitSizeOf(ConfigEntry));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const ConfigBackend = opaque {
    pub fn foreachConfigBackendMatch(
        self: *const ConfigBackend,
        regex: [:0]const u8,
        user_data: anytype,
        comptime callback_fn: fn (entry: *const Config.ConfigEntry, user_data_ptr: @TypeOf(user_data)) c_int,
    ) !c_int {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(
                entry: *const c.git_config_entry,
                payload: ?*anyopaque,
            ) callconv(.C) c_int {
                return callback_fn(
                    @ptrCast(*const Config.ConfigEntry, entry),
                    @ptrCast(UserDataType, payload),
                );
            }
        }.cb;

        log.debug("Config.foreachConfigBackendMatch called, regex: {s}", .{regex});

        const ret = try internal.wrapCallWithReturn("git_config_backend_foreach_match", .{
            @ptrCast(*const c.git_config_backend, self),
            regex.ptr,
            cb,
            user_data,
        });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Priority level of a config file.
pub const ConfigLevel = enum(c_int) {
    /// System-wide on Windows, for compatibility with portable git
    programdata = 1,
    /// System-wide configuration file; /etc/gitconfig on Linux systems
    system = 2,
    /// XDG compatible configuration file; typically ~/.config/git/config
    xdg = 3,
    /// User-specific configuration file (also called Global configuration file); typically ~/.gitconfig
    global = 4,
    /// Repository specific configuration file; $WORK_DIR/.git/config on non-bare repos
    local = 5,
    /// Application specific configuration file; freely defined by applications
    app = 6,
    /// Represents the highest level available config file (i.e. the most specific config file available that actually is 
    /// loaded)
    highest = -1,
};

comptime {
    std.testing.refAllDecls(@This());
}
