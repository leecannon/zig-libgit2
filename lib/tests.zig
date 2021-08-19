const std = @import("std");
const git = @import("git.zig");

test "simple repository init" {
    const repo_path = "./zig-cache/test_repos/simple_repository_init";

    defer std.fs.cwd().deleteTree(repo_path) catch {};

    const handle = try git.init();
    defer handle.deinit();

    var repo = try handle.repositoryInit(repo_path, false);
    defer repo.deinit();
}

test "extended repository init" {
    const repo_path = "./zig-cache/test_repos/extended_repository_init/very/nested/repo";

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

    try std.testing.expectError(git.GitError.UnbornBranch, test_handle.repo.head());
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

test "item paths" {
    var test_handle = try TestHandle.init("item_paths");
    defer test_handle.deinit();

    var buf = try test_handle.repo.itemPath(.CONFIG);
    defer buf.deinit();

    const expected = try std.fmt.allocPrint(std.testing.allocator, "{s}/.git/config", .{test_handle.repo_path[1..]});
    defer std.testing.allocator.free(expected);

    try std.testing.expectStringEndsWith(buf.slice(), expected);
}

const TestHandle = struct {
    handle: git.Handle,
    repo_path: [:0]const u8,
    repo: git.GitRepository,

    pub fn init(test_name: []const u8) !TestHandle {
        const repo_path = try std.fmt.allocPrintZ(std.testing.allocator, "./zig-cache/test_repos/{s}", .{test_name});
        errdefer std.testing.allocator.free(repo_path);

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
