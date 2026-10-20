# iPad1Files Tasks

## Source

- [x] shared root
- [x] browser/file ops/multi-select/search/favorites/disk/preview
- [x] collision-safe naming
- [x] root navigation
- [x] full path display
- [x] select all
- [x] protected-system safety policy
- [x] sort by name/date/size
- [x] new text file
- [x] lightweight text editing
- [x] app registry / Open With
- [x] PDF absolute-path hand-off
- [x] user-controlled Downloads classification
- [x] ArchiveManager
- [x] ArchiveViewController
- [x] bundled MiniZip + libz
- [x] ZIP list
- [x] ZIP Extract All
- [x] ZIP extract through existing Folder Picker
- [x] multi-select ZIP creation
- [x] ZIP Slip guard
- [x] symlink rejection
- [x] disk-space pre-check

## Physical PASS

- [x] clean armv7 build/install/launch
- [x] copy/move/delete
- [x] multi-select/select-all
- [x] root navigation
- [x] protected area select-all hidden
- [x] protected destination overwrite absent
- [x] normal collision overwrite/new-name
- [x] ZIP content screen
- [x] Extract All here
- [x] repeated extraction -> `(2)`
- [x] extract via Folder Picker
- [x] multi-select ZIP create
- [x] created ZIP reopen/extract
- [x] core regression after ZIP integration

## ZIP Phase 1 edge/security tests

- [ ] Turkish ZIP filenames
- [ ] corrupt ZIP
- [ ] truncated ZIP
- [ ] `../` traversal ZIP
- [ ] absolute-path ZIP
- [ ] symlink ZIP
- [ ] many small files
- [ ] large single file
- [ ] insufficient disk space
- [ ] memory pressure

## ZIP Phase 2

- [ ] single-file extract
- [ ] progress UI
- [ ] cancel support

## Remaining integration

- [ ] favorites persistence stress/regression
- [ ] large directory/image memory
- [ ] PDFReader missing fallback
- [ ] PDFReader receiver absolute path
- [ ] classification only after user choice
- [ ] iPad1VNC AppData integration
