# iPad1Files Physical Device Testing

Target:
```text
iPad 1 / 256 MB / iOS 5.1.1 / armv7
IP: 192.168.1.100
```

Build:
```bash
cd ~/projects/iPad1Files-v1.0.0-beta1
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

## Core regression

- [x] compile/package/install/launch
- [x] copy/move/delete
- [x] multi-select/select-all
- [x] collision-safe naming
- [x] root navigation
- [x] protected area select-all hidden
- [x] protected destination overwrite blocked
- [x] normal overwrite/new-name flow
- [x] ZIP integration did not break core file operations
- [ ] Turkish paths
- [ ] favorites persistence
- [ ] large directory/image memory

## ZIP Phase 1 — PASS

- [x] ZIP opens to archive content screen
- [x] ZIP content list
- [x] folder-structured ZIP
- [x] Extract All to current folder
- [x] repeated extract creates `(2)`
- [x] extract via Folder Picker
- [x] multi-select ZIP creation
- [x] created ZIP reopen/extract
- [x] `../` traversal ZIP rejected; controlled error; no outside write
- [x] absolute-path ZIP rejected; controlled error; no outside write
- [x] CRC-corrupt ZIP rejected during extraction after `8ea31d7`
- [x] CRC failure: no crash, no partial output file, no leftover extraction directory

## ZIP Phase 1 — pending / failures

- [ ] Turkish-character ZIP filename
- [ ] Turkish-character entry name
- [ ] empty ZIP — FAIL: valid empty ZIP shows `ZIP dosyası açılamadı.`
- [x] CRC-corrupt ZIP
- [ ] truncated ZIP
- [x] `../` ZIP Slip sample
- [x] absolute path sample
- [ ] symlink sample
- [ ] many small entries
- [ ] large single entry
- [ ] insufficient disk space
- [ ] memory pressure
- [ ] encrypted ZIP rejection
- [ ] ZIP64 rejection

Expected:
```text
../ traversal -> reject
absolute path -> reject
symlink -> reject
encrypted ZIP -> unsupported
ZIP64 -> unsupported in Phase 1
```

## Open With

- [ ] PDFReader yokken crash yok
- [ ] receiver registry resolve
- [ ] percent-encoded absolute path
- [ ] no duplicate PDF

## Downloads

- [ ] PDF -> PDFs suggestion
- [ ] image -> Images
- [ ] audio -> Music
- [ ] archive -> Archives
- [ ] no auto-move
