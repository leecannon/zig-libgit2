# Plans

- [ ] Implement entire API from commit `3f02b5b95e90d6be25aedf3f861e173182e815d7`
- [ ] Replace any `const slice = try id.formatHex(&buf);` type Oid formating with no try version
- [ ] Any `extern struct` passed as `*const` should be passed by value 
- [ ] Update with all API changes up to latest master
- [ ] Build against each version from latest to oldest and mark added APIs using `@hasDecl`
- [ ] Option to disable logging
- [ ] Add documentation to *every* function and type
- [ ] Check all functions that dont take a "self" pointer to a libgit2 type and decide if they should be moved to `Handle`
- [ ] Match zig language style, e.g. enum style should be snake_case
- [ ] Add functionality to build.zig to include package as either static or dynamic
- [ ] Package with zigmod/gyro

68 refdb.h
91 revert.h
98 proxy.h
103 signature.h
111 reset.h
121 transaction.h
135 odb_backend.h
260 stash.h
282 patch.h
299 revwalk.h
367 rebase.h
382 tag.h
559 odb.h
606 merge.h
663 submodule.h
771 refs.h
1525 diff.h
