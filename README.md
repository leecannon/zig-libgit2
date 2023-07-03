# zig-libgit2

## Warning
This project is not currently in a good state and is not 100% compatible with any of libgit2's releases.

Work on this project stalled at step one in [TODO](TODO.md)

---

Zig bindings to [libgit2](https://github.com/libgit2/libgit2)

This is an in-progress zig binding to libgit2, unfortunately libgit2 doesn't full document all possible errors so every errorable function returns the full errorset.

There is currently no plan to port all the headers within "include/git2/sys", if anyone requires any of that functionailty raise an issue.

## Files fully wrapped (others maybe partially complete)

- [X] annotated_commit.h
- [X] apply.h
- [X] attr.h
- [X] blame.h
- [X] blob.h
- [X] branch.h**This project has turned out to be more work than it is worth.**
**I have projects that just use `@cImport({@cInclude("git2.h");});` directly without too much friction.**
**Due to this my work on this project has stopped.**

- [X] buffer.h
- [X] cert.h
- [X] checkout.h
- [X] cherrypick.h
- [X] clone.h
- [X] commit.h
- [X] common.h
- [X] config.h
- [X] credential.h
- [X] describe.h
- [ ] diff.h
- [X] errors.h
- [X] filter.h
- [X] global.h
- [X] graph.h
- [X] ignore.h
- [X] index.h
- [X] indexer.h
- [X] mailmap.h
- [ ] merge.h
- [X] message.h
- [X] notes.h
- [X] object.h
- [ ] odb.h
- [X] oid.h
- [X] oidarray.h
- [X] pack.h
- [X] patch.h
- [X] pathspec.h
- [X] proxy.h
- [X] rebase.h
- [X] refdb.h
- [X] reflog.h
- [ ] refs.h
- [X] refspec.h
- [X] remote.h
- [X] repository.h
- [X] reset.h
- [X] revert.h
- [X] revparse.h
- [X] revwalk.h
- [X] signature.h
- [X] stash.h
- [X] status.h
- [X] strarray.h
- [ ] submodule.h
- [X] tag.h
- [X] trace.h
- [X] transaction.h
- [X] tree.h
- [X] worktree.h
- [X] sys/alloc.h
- [X] sys/credential.h
- [X] sys/diff.h
- [X] sys/hashsig.h
- [X] sys/path.h
- [X] sys/repository.h
