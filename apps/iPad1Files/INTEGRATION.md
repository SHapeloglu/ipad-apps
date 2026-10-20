# iPad1Files Entegrasyon Yönergesi

iPad1Files ortak dosya sistemi omurgasıdır. FTP/PDF motorlarını içine almaz. ZIP arşiv yönetimi dosya yöneticisinin doğal özelliği olarak iPad1Files içinde kalır.

Platform:
```text
iPad 1 / 256 MB RAM / iOS 5.1.1 / armv7 / Theos / Objective-C / non-ARC-MRC
```

Canonical root:
```text
/var/mobile/Media/iPad1Files
Downloads/ Documents/ PDFs/ Images/ Music/ Videos/ Archives/ Shared/ Temp/ AppData/
```

PDF:
```text
.pdf -> iPad1PDFReader
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

FTPDownloader default:
```text
/var/mobile/Media/iPad1Files/Downloads
```

FTPDownloader indirir; iPad1Files aynı fiziksel dosyayı yönetir.

ZIP flow:
```text
iPad1FTPDownloader
    ↓ Downloads/*.zip
iPad1Files
    ↓ ArchiveViewController
ArchiveManager
```

ZIP Phase 1:
- content listing
- extract here
- extract to another folder
- multi-select ZIP create

Engine:
```text
bundled classic MiniZip + SDK libz
```

No runtime dependency on device-installed `zip/unzip/libzip`.

Downloads classification is user-controlled only:
```text
.pdf -> PDFs/
.jpg/.png -> Images/
.mp3 -> Music/
.zip -> Archives/
```

System safety:
```text
Normal area: overwrite / new-name / cancel
Protected system area: no overwrite, no select-all, destructive warnings
Critical roots: delete/rename blocked
```

Out of scope:
```text
FTP/SFTP/SMB/WebDAV engines
PDF annotation/search/reflow/page editing
OCR
AI/ML
background indexing
```
