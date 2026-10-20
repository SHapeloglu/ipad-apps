# iPad1Files — Authoritative Session / New Chat Handoff

> Bu dosya repository için authoritative handoff belgesidir. Başka bir Markdown dosyasıyla çelişirse `SESSION.md` esas alınır.

## Project

Repository:
```text
https://github.com/SHapeloglu/iPad1Files
```

Branch:
```text
main
```

Validated source commit before this docs update:
```text
3c5bce9 Add safe ZIP archive support and file manager enhancements
```

Local:
```text
~/projects/iPad1Files-v1.0.0-beta1
```

## Hard constraints

```text
iPad 1
256 MB RAM
iOS 5.1.1
armv7
Objective-C
Theos
non-ARC / MRC
```

No Swift, no modern-only iOS APIs, no ARC migration. Physical device behavior is final authority.

## Physical device

```text
IP: 192.168.1.100
SSH user: root
```

Legacy SSH flags:
```text
-o HostKeyAlgorithms=+ssh-rsa
-o PubkeyAcceptedAlgorithms=+ssh-rsa
```

## Mission

iPad1Files is the shared filesystem backbone of the iPad1 app family.

Canonical root:
```text
/var/mobile/Media/iPad1Files
```

Children:
```text
Downloads/
Documents/
PDFs/
Images/
Music/
Videos/
Archives/
Shared/
Temp/
AppData/
```

Owns:
```text
browser
copy/move/rename/delete
multi-select/select-all
search/favorites/disk info
folder picker
path navigation
lightweight preview/editing
collision-safe naming
Open With / URL hand-off
ZIP archive management
```

Does not own:
```text
FTP/SFTP/SMB/WebDAV engines
PDF rendering/annotation/search/reflow engines
OCR
AI/ML
background filesystem indexing
```

## Companion integration

FTPDownloader:
```text
/var/mobile/Media/iPad1Files/Downloads
```

PDF:
```text
.pdf -> iPad1PDFReader
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Use the same physical file whenever possible.

## Current file-manager capabilities

- shared storage bootstrap
- browser
- full path display
- root navigation to `/`
- copy/move/rename/delete
- multi-select and `Tümünü Seç`
- current-folder search
- hidden-file toggle
- favorites
- disk footer
- text/image preview
- lightweight text edit/save in normal areas
- create empty text file
- sort by name/date/size
- collision-safe `(2)`, `(3)` naming
- normal overwrite/new-name/cancel behavior
- protected system areas: no select-all, no overwrite, destructive warnings
- critical root delete/rename protection
- Open With registry
- user-controlled Downloads classification

## ZIP Phase 1 architecture

Modules:
```text
ArchiveManager
ArchiveViewController
src/minizip/
```

Implementation:
- classic MiniZip bundled into app
- SDK `libz`
- no runtime dependency on device `/usr/bin/zip`, `/usr/bin/unzip`, or `libzip`
- 32 KB streaming buffer
- entry-by-entry extraction
- no whole ZIP in RAM
- controlled autorelease pools

Supports:
```text
ZIP content listing
Extract All -> here
Extract All -> another folder using existing Folder Picker
multi-select -> Create ZIP
reopen/extract ZIPs created by iPad1Files
```

Safety:
- ZIP Slip/path traversal check
- absolute path rejection
- symlink rejection
- CRC validation
- disk-space pre-check
- collision-safe extraction root
- encrypted ZIP unsupported
- ZIP64 unsupported in Phase 1

## Physical PASS

Verified on physical iPad 1:
- clean armv7 build
- package install
- app launch
- copy/move/delete
- multi-select
- `Tümünü Seç`
- root navigation
- protected-area select-all hidden
- normal collision overwrite/new-name
- protected destination overwrite absent
- ZIP content screen
- ZIP list
- Extract All here
- repeated extraction -> `(2)`
- Extract All via Folder Picker
- multi-select ZIP creation
- created ZIP reopen
- created ZIP extraction
- `../` traversal ZIP rejected with controlled error; no outside write
- absolute-path ZIP rejected with controlled error; no outside write
- CRC-corrupt ZIP rejected with controlled error after MRC crash fix (`8ea31d7`)
- CRC failure leaves no partial output file or extraction directory
- core file-manager regression after ZIP integration

## Not yet proven / known failures

- Turkish ZIP filenames/paths
- empty ZIP: FAIL on physical iPad; valid empty ZIP currently shows `ZIP dosyası açılamadı.`
- truncated ZIP
- explicit symlink ZIP
- insufficient disk space
- many small entries
- large single entry
- memory pressure
- ZIP Phase 2: single-file extraction
- progress UI
- cancel support
- encrypted ZIP
- ZIP64
- large directory/image stress
- PDFReader receiver absolute-path hand-off

## Build

```bash
cd ~/projects/iPad1Files-v1.0.0-beta1
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

## Git hygiene

Never commit:
```text
.theos/
packages/
*.deb
obj/
*.dSYM/
local helper patch scripts
```

Before commit:
```bash
git status -sb
git diff --check
```

## Immediate next action

1. Read this file first.
2. Verify:
```bash
cd ~/projects/iPad1Files-v1.0.0-beta1
git status -sb
git log -5 --oneline
```
3. Run safe ZIP Phase 1 edge/security tests on physical iPad:
```text
Turkish filenames
corrupt/truncated ZIP
../ traversal ZIP
absolute-path ZIP
symlink ZIP
many small entries
large single entry
insufficient disk space
memory pressure
```
4. Record actual PASS/FAIL in `SESSION.md` and `TESTING.md`.
5. Only after Phase 1 is stable, begin Phase 2:
```text
single-file extract
progress UI
cancel support
```
6. Preserve existing file-manager regression behavior.
7. Do not add FTP/SFTP/SMB/WebDAV engines to iPad1Files.

## New chat bootstrap

```text
https://github.com/SHapeloglu/iPad1Files

SESSION.md dosyasını oku.
SESSION.md bu proje için authoritative handoff belgesidir.
Başka bir MD dosyasıyla çelişirse SESSION.md'yi esas al.
"Immediate next action" bölümünden devam et.
Güncel main branch ve kaynak kodu da kontrol et.
Mevcut mimari kararları bozma.
iPad 1 / 256 MB RAM / iOS 5.1.1 / armv7 / Objective-C / Theos / non-ARC-MRC sınırlarından sapma.
Fiziksel cihazda doğrulanmamış özellikleri çalışıyor kabul etme.
```
