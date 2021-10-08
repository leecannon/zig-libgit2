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

    pub fn new() !*Config {
        log.debug("Config.new called", .{});

        var config: ?*raw.git_config = undefined;

        try internal.wrapCall("git_config_new", .{&config});

        const ret = internal.fromC(config.?);

        log.debug("created new config", .{});

        return ret;
    }

    pub fn getEntry(self: *const Config, name: [:0]const u8) !*ConfigEntry {
        log.debug("Config.getEntry called, name={s}", .{name});

        var entry: ?*raw.git_config_entry = undefined;

        try internal.wrapCall("git_config_get_entry", .{ &entry, internal.toC(self), name.ptr });

        const ret = internal.fromC(entry.?);

        log.debug("got entry: {*}", .{ret});

        return ret;
    }

    pub fn getInt(self: *const Config, name: [:0]const u8) !i32 {
        log.debug("Config.getInt called, name={s}", .{name});

        var value: i32 = undefined;

        try internal.wrapCall("git_config_get_int32", .{ &value, internal.toC(self), name.ptr });

        log.debug("got int value: {}", .{value});

        return value;
    }

    pub fn setInt(self: *Config, name: [:0]const u8, value: i32) !void {
        log.debug("Config.setInt called, name={s}, value={}", .{ name, value });

        try internal.wrapCall("git_config_set_int32", .{ internal.toC(self), name.ptr, value });

        log.debug("successfully set int value", .{});
    }

    pub fn getInt64(self: *const Config, name: [:0]const u8) !i64 {
        log.debug("Config.getInt64 called, name={s}", .{name});

        var value: i64 = undefined;

        try internal.wrapCall("git_config_get_int64", .{ &value, internal.toC(self), name.ptr });

        log.debug("got int value: {}", .{value});

        return value;
    }

    pub fn setInt64(self: *Config, name: [:0]const u8, value: i64) !void {
        log.debug("Config.setInt64 called, name={s}, value={}", .{ name, value });

        try internal.wrapCall("git_config_set_int64", .{ internal.toC(self), name.ptr, value });

        log.debug("successfully set int value", .{});
    }

    pub fn getBool(self: *const Config, name: [:0]const u8) !bool {
        log.debug("Config.getBool called, name={s}", .{name});

        var value: c_int = undefined;

        try internal.wrapCall("git_config_get_bool", .{ &value, internal.toC(self), name.ptr });

        const ret = value != 0;

        log.debug("got bool value: {}", .{ret});

        return ret;
    }

    pub fn setBool(self: *Config, name: [:0]const u8, value: bool) !void {
        log.debug("Config.setBool called, name={s}, value={}", .{ name, value });

        try internal.wrapCall("git_config_set_bool", .{ internal.toC(self), name.ptr, @boolToInt(value) });

        log.debug("successfully set bool value", .{});
    }

    pub fn getPath(self: *const Config, name: [:0]const u8) !git.Buf {
        log.debug("Config.getPath called, name={s}", .{name});

        var buf: git.Buf = undefined;

        try internal.wrapCall("git_config_get_path", .{ internal.toC(&buf), internal.toC(self), name.ptr });

        log.debug("got path value: {s}", .{buf.toSlice()});

        return buf;
    }

    pub fn getString(self: *const Config, name: [:0]const u8) ![:0]const u8 {
        log.debug("Config.getString called, name={s}", .{name});

        var str: [*c]const u8 = undefined;

        try internal.wrapCall("git_config_get_string", .{ &str, internal.toC(self), name.ptr });

        const slice = std.mem.sliceTo(str, 0);

        log.debug("got string value: {s}", .{slice});

        return slice;
    }

    pub fn setString(self: *Config, name: [:0]const u8, value: [:0]const u8) !void {
        log.debug("Config.setString called, name={s}, value={s}", .{ name, value });

        try internal.wrapCall("git_config_set_string", .{ internal.toC(self), name.ptr, value.ptr });

        log.debug("successfully set string value", .{});
    }

    pub fn setMultivar(self: *Config, name: [:0]const u8, regex: [:0]const u8, value: [:0]const u8) !void {
        log.debug("Config.setMultivar called, name={s},regex={s}, value={s}", .{ name, regex, value });

        try internal.wrapCall("git_config_set_multivar", .{ internal.toC(self), name.ptr, regex.ptr, value.ptr });

        log.debug("successfully set multivar value", .{});
    }

    pub fn getStringBuf(self: *const Config, name: [:0]const u8) !git.Buf {
        log.debug("Config.getStringBuf called, name={s}", .{name});

        var buf: git.Buf = undefined;

        try internal.wrapCall("git_config_get_string_buf", .{ internal.toC(&buf), internal.toC(self), name.ptr });

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
                entry: [*c]const raw.git_config_entry,
                payload: ?*c_void,
            ) callconv(.C) c_int {
                return callback_fn(
                    internal.fromC(entry.?),
                    @ptrCast(UserDataType, payload),
                );
            }
        }.cb;

        log.debug("Config.foreachMultivar called, name={s}, regex={s}", .{ name, regex });

        const regex_c = if (regex) |str| str.ptr else null;

        const ret = try internal.wrapCallWithReturn("git_config_get_multivar_foreach", .{
            internal.toC(self),
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
                entry: [*c]const raw.git_config_entry,
                payload: ?*c_void,
            ) callconv(.C) c_int {
                return callback_fn(
                    internal.fromC(entry.?),
                    @ptrCast(UserDataType, payload),
                );
            }
        }.cb;

        log.debug("Config.foreachConfig called", .{});

        const ret = try internal.wrapCallWithReturn("git_config_foreach", .{
            internal.toC(self),
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
                entry: [*c]const raw.git_config_entry,
                payload: ?*c_void,
            ) callconv(.C) c_int {
                return callback_fn(
                    internal.fromC(entry.?),
                    @ptrCast(UserDataType, payload),
                );
            }
        }.cb;

        log.debug("Config.foreachConfigMatch called, regex={s}", .{regex});

        const ret = try internal.wrapCallWithReturn("git_config_foreach_match", .{
            internal.toC(self),
            regex.ptr,
            cb,
            user_data,
        });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    pub fn deleteEntry(self: *Config, name: [:0]const u8) !void {
        log.debug("Config.deleteEntry called, name={s}", .{name});

        try internal.wrapCall("git_config_delete_entry", .{ internal.toC(self), name.ptr });

        log.debug("successfully deleted entry", .{});
    }

    pub fn deleteMultivar(self: *Config, name: [:0]const u8, regex: [:0]const u8) !void {
        log.debug("Config.deleteMultivar called, name={s}, regex={s}", .{ name, regex });

        try internal.wrapCall("git_config_delete_multivar", .{ internal.toC(self), name.ptr, regex.ptr });

        log.debug("successfully deleted multivar", .{});
    }

    pub fn addFileOnDisk(self: *Config, path: [:0]const u8, level: Level, repo: *const git.Repository, force: bool) !void {
        log.debug("Config.addFileOnDisk called, path={s}, level={}, repo={*}, force={}", .{ path, level, repo, force });

        try internal.wrapCall("git_config_add_file_ondisk", .{
            internal.toC(self),
            path.ptr,
            @enumToInt(level),
            internal.toC(repo),
            @boolToInt(force),
        });

        log.debug("", .{});
    }

    pub fn openOnDisk(path: [:0]const u8) !*Config {
        log.debug("Config.openOnDisk called, path={s}", .{path});

        var config: ?*raw.git_config = undefined;

        try internal.wrapCall("git_config_open_ondisk", .{ &config, path.ptr });

        const ret = internal.fromC(config.?);

        log.debug("opened config from file", .{});

        return ret;
    }

    pub fn openLevel(self: *const git.Config, level: Level) !*git.Config {
        log.debug("Config.openLevel called, level={}", .{level});

        var config: ?*raw.git_config = undefined;

        try internal.wrapCall("git_config_open_level", .{ &config, internal.toC(self), @enumToInt(level) });

        const ret = internal.fromC(config.?);

        log.debug("opened config for level", .{});

        return ret;
    }

    pub fn openGlobal(self: *const git.Config) !*Config {
        log.debug("Config.openGlobal called", .{});

        var config: ?*raw.git_config = undefined;

        try internal.wrapCall("git_config_open_global", .{ &config, internal.toC(self) });

        const ret = internal.fromC(config.?);

        log.debug("opened global config", .{});

        return ret;
    }

    pub fn snapshot(self: *const git.Config) !*Config {
        log.debug("Config.snapshot called", .{});

        var config: ?*raw.git_config = undefined;

        try internal.wrapCall("git_config_snapshot", .{ &config, internal.toC(self) });

        const ret = internal.fromC(config.?);

        log.debug("created snapshot of config", .{});

        return ret;
    }

    pub fn openDefault() !*Config {
        log.debug("Config.openDefault called", .{});

        var config: ?*raw.git_config = undefined;

        try internal.wrapCall("git_config_open_default", .{&config});

        const ret = internal.fromC(config.?);

        log.debug("opened default config", .{});

        return ret;
    }

    pub fn findGlobal() ?git.Buf {
        log.debug("Config.findGlobal called", .{});

        var buf: raw.git_buf = undefined;

        if (raw.git_config_find_global(&buf) == 0) return null;

        const ret = internal.fromC(buf);

        log.debug("global config path: {s}", .{ret.toSlice()});

        return ret;
    }

    pub fn findXdg() ?git.Buf {
        log.debug("Config.findXdg called", .{});

        var buf: raw.git_buf = undefined;

        if (raw.git_config_find_xdg(&buf) == 0) return null;

        const ret = internal.fromC(buf);

        log.debug("xdg config path: {s}", .{ret.toSlice()});

        return ret;
    }

    pub fn findSystem() ?git.Buf {
        log.debug("Config.findSystem called", .{});

        var buf: raw.git_buf = undefined;

        if (raw.git_config_find_system(&buf) == 0) return null;

        const ret = internal.fromC(buf);

        log.debug("system config path: {s}", .{ret.toSlice()});

        return ret;
    }

    pub fn findProgramdata() ?git.Buf {
        log.debug("Config.findProgramdata called", .{});

        var buf: raw.git_buf = undefined;

        if (raw.git_config_find_programdata(&buf) == 0) return null;

        const ret = internal.fromC(buf);

        log.debug("programdata config path: {s}", .{ret.toSlice()});

        return ret;
    }

    pub fn lock(self: *Config) !*git.Transaction {
        log.debug("Config.lock called", .{});

        var transaction: ?*raw.git_transaction = undefined;

        try internal.wrapCall("git_config_lock", .{ &transaction, internal.toC(self) });

        log.debug("successfully locked config", .{});

        return internal.fromC(transaction.?);
    }

    pub fn iterateMultivar(self: *const Config, name: [:0]const u8, regex: ?[:0]const u8) !*ConfigIterator {
        log.debug("Config.iterateMultivar called, name={s}, regex={s}", .{ name, regex });

        var iterator: ?*raw.git_config_iterator = undefined;

        const regex_c = if (regex) |str| str.ptr else null;

        try internal.wrapCall("git_config_multivar_iterator_new", .{
            &iterator,
            internal.toC(self),
            name.ptr,
            regex_c,
        });

        log.debug("multivar config iterator created successfully", .{});

        return internal.fromC(iterator.?);
    }

    pub fn iterate(self: *const Config) !*ConfigIterator {
        log.debug("Config.iterate called", .{});

        var iterator: ?*raw.git_config_iterator = undefined;

        try internal.wrapCall("git_config_iterator_new", .{
            &iterator,
            internal.toC(self),
        });

        log.debug("config iterator created successfully", .{});

        return internal.fromC(iterator.?);
    }

    pub fn iterateGlob(self: *const Config, regex: [:0]const u8) !*ConfigIterator {
        log.debug("Config.iterateGlob called", .{});

        var iterator: ?*raw.git_config_iterator = undefined;

        try internal.wrapCall("git_config_iterator_glob_new", .{
            &iterator,
            internal.toC(self),
            regex.ptr,
        });

        log.debug("config iterator created successfully", .{});

        return internal.fromC(iterator.?);
    }

    pub const ConfigIterator = opaque {
        pub fn next(self: *ConfigIterator) !?*ConfigEntry {
            log.debug("ConfigIterator.next called", .{});

            var entry: [*c]raw.git_config_entry = undefined;

            internal.wrapCall("git_config_next", .{ &entry, internal.toC(self) }) catch |err| switch (err) {
                git.GitError.IterOver => {
                    log.debug("end of iteration reached", .{});
                    return null;
                },
                else => return err,
            };

            const ret = internal.fromC(entry);

            log.debug("successfully fetched config entry: {}", .{ret});

            return ret;
        }

        pub fn deinit(self: *ConfigIterator) void {
            log.debug("ConfigIterator.deinit called", .{});

            raw.git_config_iterator_free(internal.toC(self));

            log.debug("config iterator freed successfully", .{});
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    pub fn getMapped(self: *Config, name: [:0]const u8, maps: []const ConfigMap) !c_int {
        log.debug("Config.getMapped called, name={s}", .{name});

        var value: c_int = undefined;

        try internal.wrapCall("git_config_get_mapped", .{ &value, internal.toC(self), name.ptr, internal.toC(maps.ptr), maps.len });

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
        var buf: git.Buf = undefined;
        try internal.wrapCall("git_config_parse_path", .{ internal.toC(&buf), value.ptr });
        return buf;
    }

    pub const ConfigMap = extern struct {
        map_type: MapType,
        str_match: [*:0]const u8,
        map_value: c_int,

        pub const MapType = enum(c_int) {
            FALSE = 0,
            TRUE = 1,
            INT32 = 2,
            STRING = 3,
        };

        pub fn lookupMapValue(maps: []const ConfigMap, value: [:0]const u8) !c_int {
            log.debug("ConfigMap.lookupMapValue called, value={s}", .{value});

            var result: c_int = undefined;

            try internal.wrapCall("git_config_lookup_map_value", .{ &result, internal.toC(maps.ptr), maps.len, value.ptr });

            log.debug("mapped to: {}", .{result});

            return result;
        }

        test {
            try std.testing.expectEqual(@sizeOf(raw.git_configmap), @sizeOf(ConfigMap));
            try std.testing.expectEqual(@bitSizeOf(raw.git_configmap), @bitSizeOf(ConfigMap));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

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

    pub const ConfigEntry = extern struct {
        /// Name of the entry (normalised)
        name: [*:0]const u8,
        /// String value of the entry
        value: [*:0]const u8,
        /// Depth of includes where this variable was found
        include_depth: u32,
        /// Which config file this was found in
        level: Level,
        /// Free function for this entry 
        free_fn: ?fn ([*c]ConfigEntry) callconv(.C) void,
        /// Opaque value for the free function. Do not read or write
        payload: *c_void,

        pub fn deinit(self: *ConfigEntry) void {
            log.debug("ConfigEntry.deinit called", .{});

            raw.git_config_entry_free(internal.toC(self));

            log.debug("config entry freed successfully", .{});
        }

        test {
            try std.testing.expectEqual(@sizeOf(raw.git_config_entry), @sizeOf(ConfigEntry));
            try std.testing.expectEqual(@bitSizeOf(raw.git_config_entry), @bitSizeOf(ConfigEntry));
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
                entry: [*c]const raw.git_config_entry,
                payload: ?*c_void,
            ) callconv(.C) c_int {
                return callback_fn(
                    internal.fromC(entry.?),
                    @ptrCast(UserDataType, payload),
                );
            }
        }.cb;

        log.debug("Config.foreachConfigBackendMatch called, regex={s}", .{regex});

        const ret = try internal.wrapCallWithReturn("git_config_backend_foreach_match", .{
            internal.toC(self),
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

comptime {
    std.testing.refAllDecls(@This());
}
