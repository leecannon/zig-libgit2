const std = @import("std");
const git = @import("lib.zig");

test "simple repository init" {
    const repo_path = "./zig-cache/test_repos/simple_repository_init";

    std.fs.cwd().deleteTree(repo_path) catch {};
    defer std.fs.cwd().deleteTree(repo_path) catch {};

    const handle = try git.init();
    defer handle.deinit();

    var repo = try handle.repositoryInit(repo_path, false);
    defer repo.deinit();
}

test "extended repository init" {
    const repo_path = "./zig-cache/test_repos/extended_repository_init/very/nested/repo";

    std.fs.cwd().deleteTree("./zig-cache/test_repos/extended_repository_init") catch {};
    defer std.fs.cwd().deleteTree("./zig-cache/test_repos/extended_repository_init") catch {};

    const handle = try git.init();
    defer handle.deinit();

    var repo = try handle.repositoryInitExtended(repo_path, .{ .flags = .{ .mkdir = true, .mkpath = true } });
    defer repo.deinit();
}

test "repository discover" {
    var test_handle = try TestHandle.init("repository_discover");
    defer test_handle.deinit();

    var repo = try test_handle.handle.repositoryDiscover(test_handle.repo_path, false, null);
    defer repo.deinit();
}

test "fresh repo has head reference to unborn branch" {
    var test_handle = try TestHandle.init("head_reference_unborn_error");
    defer test_handle.deinit();

    try std.testing.expectError(git.GitError.UnbornBranch, test_handle.repo.getHead());
}

test "fresh repo has unborn head reference" {
    var test_handle = try TestHandle.init("head_reference_unborn");
    defer test_handle.deinit();

    try std.testing.expect(try test_handle.repo.isHeadUnborn());
}

test "fresh repo is empty" {
    var test_handle = try TestHandle.init("fresh_repo_is_empty");
    defer test_handle.deinit();

    try std.testing.expect(try test_handle.repo.isEmpty());
}

test "bare repo is bare" {
    const repo_path = "./zig-cache/test_repos/bare_repo_is_bare";

    std.fs.cwd().deleteTree(repo_path) catch {};
    defer std.fs.cwd().deleteTree(repo_path) catch {};

    const handle = try git.init();
    defer handle.deinit();

    var repo = try handle.repositoryInitExtended(repo_path, .{ .flags = .{ .mkdir = true, .mkpath = true, .bare = true } });
    defer repo.deinit();

    try std.testing.expect(repo.isBare());
}

test "item paths" {
    var test_handle = try TestHandle.init("item_paths");
    defer test_handle.deinit();

    var buf = try test_handle.repo.getItemPath(.CONFIG);
    defer buf.deinit();

    const expected = try std.fmt.allocPrintZ(std.testing.allocator, "{s}/.git/config", .{test_handle.repo_path[1..]});
    defer std.testing.allocator.free(expected);

    try std.testing.expectStringEndsWith(buf.slice(), expected);
}

test "get config" {
    var test_handle = try TestHandle.init("get_config");
    defer test_handle.deinit();

    var config = try test_handle.repo.getConfig();
    defer config.deinit();
}

test "get config snapshot" {
    var test_handle = try TestHandle.init("get_config_snapshot");
    defer test_handle.deinit();

    var config = try test_handle.repo.getConfigSnapshot();
    defer config.deinit();
}

test "get odb" {
    var test_handle = try TestHandle.init("get_odb");
    defer test_handle.deinit();

    var odb = try test_handle.repo.getOdb();
    defer odb.deinit();
}

test "get ref db" {
    var test_handle = try TestHandle.init("get_refdb");
    defer test_handle.deinit();

    var ref_db = try test_handle.repo.getRefDb();
    defer ref_db.deinit();
}

test "get index" {
    var test_handle = try TestHandle.init("get_index");
    defer test_handle.deinit();

    var index = try test_handle.repo.getIndex();
    defer index.deinit();
}

fn dummyFetchHeadCallback(ref_name: [:0]const u8, remote_url: [:0]const u8, oid: git.Oid, is_merge: bool) c_int {
    _ = ref_name;
    _ = remote_url;
    _ = oid;
    _ = is_merge;
    return 0;
}

test "foreach fetch head fails on fresh repository" {
    var test_handle = try TestHandle.init("foreach_fetch_head_fails_on_fresh");
    defer test_handle.deinit();

    try std.testing.expectError(git.GitError.NotFound, test_handle.repo.foreachFetchHead(dummyFetchHeadCallback));
}

fn dummyFetchMergeCallback(oid: git.Oid) c_int {
    _ = oid;
    return 0;
}

test "foreach file status on fresh repository" {
    var test_handle = try TestHandle.init("foreach_file_status_on_fresh");
    defer test_handle.deinit();

    var count: usize = 0;

    _ = try test_handle.repo.foreachFileStatusWithUserData(&count, dummyFileStatusCallback);

    try std.testing.expectEqual(@as(usize, 0), count);
}

test "foreach file status extended on fresh repository" {
    var test_handle = try TestHandle.init("foreach_file_status_extended_on_fresh");
    defer test_handle.deinit();

    var count: usize = 0;

    _ = try test_handle.repo.foreachFileStatusExtendedWithUserData(
        .{ .options = git.Repository.ForeachFileStatusExtendedOptions.Options.DEFAULT },
        &count,
        dummyFileStatusCallback,
    );

    try std.testing.expectEqual(@as(usize, 0), count);
}

fn dummyFileStatusCallback(path: [:0]const u8, status: git.FileStatus, count: *usize) c_int {
    _ = path;
    _ = status;
    count.* += 1;
    return 0;
}

test "foreach merge head fails on fresh repository" {
    var test_handle = try TestHandle.init("foreach_merge_head_fails_on_fresh");
    defer test_handle.deinit();

    try std.testing.expectError(git.GitError.NotFound, test_handle.repo.foreachMergeHead(dummyFetchMergeCallback));
}

test "fresh repo state is none" {
    var test_handle = try TestHandle.init("fresh_repo_state_none");
    defer test_handle.deinit();

    try std.testing.expectEqual(git.Repository.RepositoryState.NONE, test_handle.repo.getState());
}

test "fresh repo has no namespace" {
    var test_handle = try TestHandle.init("fresh_repo_no_namespace");
    defer test_handle.deinit();

    try std.testing.expect((try test_handle.repo.getNamespace()) == null);
}

test "set namespace" {
    var test_handle = try TestHandle.init("set_namespace");
    defer test_handle.deinit();

    try std.testing.expect((try test_handle.repo.getNamespace()) == null);

    try test_handle.repo.setNamespace("namespace");

    const result = try test_handle.repo.getNamespace();
    try std.testing.expect(result != null);

    try std.testing.expectEqualStrings("namespace", result.?);
}

test "fresh repo is not a shallow clone" {
    var test_handle = try TestHandle.init("fresh_not_shallow");
    defer test_handle.deinit();

    try std.testing.expect(!test_handle.repo.isShallow());
}

test "fresh repo has no identity set" {
    var test_handle = try TestHandle.init("fresh_no_identity");
    defer test_handle.deinit();

    const ident = try test_handle.repo.getIdentity();

    try std.testing.expect(ident.name == null);
    try std.testing.expect(ident.email == null);
}

test "set identity" {
    var test_handle = try TestHandle.init("set_identity");
    defer test_handle.deinit();

    {
        const ident = try test_handle.repo.getIdentity();

        try std.testing.expect(ident.name == null);
        try std.testing.expect(ident.email == null);
    }

    const name = "test name";
    const email = "test email";

    {
        const ident = git.Identity{
            .name = name,
            .email = email,
        };

        try test_handle.repo.setIdentity(ident);
    }

    {
        const ident = try test_handle.repo.getIdentity();

        try std.testing.expectEqualStrings(name, ident.name.?);
        try std.testing.expectEqualStrings(email, ident.email.?);
    }
}

const TestHandle = struct {
    handle: git.Handle,
    repo_path: [:0]const u8,
    repo: git.Repository,

    pub fn init(test_name: []const u8) !TestHandle {
        const repo_path = try std.fmt.allocPrintZ(std.testing.allocator, "./zig-cache/test_repos/{s}", .{test_name});
        errdefer std.testing.allocator.free(repo_path);

        std.fs.cwd().deleteTree(repo_path) catch {};

        const handle = try git.init();
        errdefer handle.deinit();

        var repo = try handle.repositoryInitExtended(repo_path, .{ .flags = .{ .mkdir = true, .mkpath = true } });

        return TestHandle{
            .handle = handle,
            .repo_path = repo_path,
            .repo = repo,
        };
    }

    pub fn deinit(self: *TestHandle) void {
        self.repo.deinit();
        self.handle.deinit();

        std.fs.cwd().deleteTree(self.repo_path) catch {};

        std.testing.allocator.free(self.repo_path);
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
