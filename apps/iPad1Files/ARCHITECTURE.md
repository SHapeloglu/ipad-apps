# iPad1Files Architecture

iPad1Files monolitik FTP/PDF uygulaması değil; local filesystem + shared storage + hand-off + lightweight archive management katmanıdır.

Platform:
```text
iPad 1 / 256 MB / iOS 5.1.1 / armv7 / Theos / Objective-C / non-ARC-MRC
```

Core:
- `IP1SharedStorage`: canonical folders
- `IP1FileManager`: local ops + system safety + collision naming
- `IP1FileItem`: metadata
- `IP1FileTypeDetector`: type detection
- `IP1FavoritesManager`: favorites
- `IP1DiskInfo`: disk
- `IP1AppRegistry`: extension -> app
- `IP1AppLauncher`: URL hand-off
- `FolderPickerViewController`: shared destination picker
- `ArchiveManager`: ZIP list/extract/create
- `ArchiveViewController`: ZIP UI
- `src/minizip/`: bundled classic MiniZip

Archive flow:
```text
FileBrowserViewController
        ↓ .zip
ArchiveViewController
        ↓
ArchiveManager
        ↓
MiniZip + libz
```

Rules:
- no whole ZIP in RAM
- 32 KB streaming buffer
- entry-by-entry extraction
- path traversal protection
- absolute path rejection
- symlink rejection
- CRC validation
- disk-space pre-check
- reuse existing Folder Picker
- preserve `(2)` collision naming

Phase 1:
```text
ZIP list
Extract All
Create ZIP from multi-selection
```

Deferred:
```text
single-entry extract
progress/cancel
ZIP64
encrypted ZIP
TAR/TGZ/GZ
RAR/7z
```

Open With:
```text
.pdf -> iPad1PDFReader
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Out of scope:
```text
FTP/SFTP/SMB/WebDAV engines
PDF engine features
OCR
AI/ML
background indexing
```
