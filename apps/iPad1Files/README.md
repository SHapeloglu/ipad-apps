# iPad1Files

iPad 1 / iOS 5.1.1 için ortak dosya sistemi omurgası ve hafif dosya/arşiv yöneticisi.

Canonical root:
```text
/var/mobile/Media/iPad1Files
```

Platform:
```text
iPad 1
256 MB RAM
iOS 5.1.1
armv7
Objective-C
Theos
non-ARC / MRC
```

Ecosystem:
```text
iPad1FTPDownloader -> Shared Downloads -> iPad1Files -> Open With -> iPad1PDFReader
```

Current capabilities:
- browser
- copy/move/rename/delete
- multi-select/select-all
- search/favorites/disk
- full path display
- root navigation
- text/image preview
- lightweight text editing
- sorting
- collision-safe naming
- protected-system safety
- registry-based Open With
- PDF absolute-path hand-off
- user-controlled Downloads classification
- ZIP content listing
- ZIP Extract All
- ZIP extraction via existing Folder Picker
- multi-select ZIP creation

ZIP architecture:
```text
FileBrowserViewController
        ↓
ArchiveViewController
        ↓
ArchiveManager
        ↓
bundled classic MiniZip + SDK libz
```

Memory policy:
```text
32 KB streaming buffer
entry-by-entry extraction
no whole ZIP in RAM
```

Safety:
- ZIP Slip/path traversal check
- absolute path rejection
- symlink rejection
- CRC validation
- disk-space pre-check
- collision-safe extraction root

Phase 1 excludes encrypted ZIP and ZIP64.

Build:
```bash
cd ~/projects/iPad1Files-v1.0.0-beta1
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

Device:
```text
192.168.1.100
```

Repo:
```text
https://github.com/SHapeloglu/iPad1Files
```

**Read `SESSION.md` first.** It is authoritative. Continue from `Immediate next action`.
