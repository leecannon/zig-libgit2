# Plans

- [ ] Implement entire API from commit `3f02b5b95e90d6be25aedf3f861e173182e815d7`
- [ ] Replace any `const slice = try id.formatHex(&buf);` type Oid formating with no try version
- [ ] Update with all API changes up to latest master
- [ ] Build against each version from latest to oldest and mark added APIs using `@hasDecl`
- [ ] Option to disable logging
- [ ] Add documentation to *every* function and type
- [ ] Add functionality to build.zig to include package as either static or dynamic
- [ ] Package with zigmod/gyro

135 odb_backend.h
180 sys/repository.h
182 sys/index.h
182 sys/merge.h
260 stash.h
282 patch.h
299 revwalk.h
332 sys/filter.h
367 rebase.h
382 tag.h
559 odb.h
606 merge.h
663 submodule.h
771 refs.h
1525 diff.h
