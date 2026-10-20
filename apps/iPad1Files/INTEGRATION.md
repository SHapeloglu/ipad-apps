# iPad1Files Entegrasyon Yönergesi

iPad1Files ortak dosya sistemi omurgasıdır. FTP/PDF motorlarını içine almaz. ZIP arşiv yönetimi dosya yöneticisinin doğal özelliği olarak iPad1Files içinde kalır.

Platform:
```text
iPad 1 / 256 MB RAM / iOS 5.1.1 / armv7 / Theos / Objective-C / non-ARC-MRC
```

Standart kök:
```text
/var/mobile/Media/iPad1Files
Downloads/ Documents/ PDFs/ Images/ Music/ Videos/ Archives/ Shared/ Temp/ AppData/
```

PDF:
```text
.pdf -> iPad1PDFReader
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

FTPDownloader varsayılanı:
```text
/var/mobile/Media/iPad1Files/Downloads
```

FTPDownloader indirir; iPad1Files aynı fiziksel dosyayı yönetir.

ZIP akışı:
```text
iPad1FTPDownloader
    ↓ Downloads/*.zip
iPad1Files
    ↓ ArchiveViewController
ArchiveManager
```

ZIP 1. aşama:
- içerik listeleme
- buraya çıkar
- başka klasöre çıkar
- çoklu seçimden ZIP oluştur

Motor:
```text
bundled classic MiniZip + SDK libz
```

Cihazda kurulu `zip/unzip/libzip`'e çalışma zamanı bağımlılığı yoktur.

Downloads sınıflandırması yalnızca kullanıcı kontrolündedir:
```text
.pdf -> PDFs/
.jpg/.png -> Images/
.mp3 -> Music/
.zip -> Archives/
```

Sistem güvenliği:
```text
Normal area: overwrite / new-name / cancel
Protected system area: no overwrite, no select-all, destructive warnings
Critical roots: delete/rename blocked
```

(Normal alan: üzerine yaz / yeni ad / iptal · Korumalı sistem alanı: üzerine yazma yok, tümünü seç yok, yıkıcı işlemlerde uyarı · Kritik kökler: silme/yeniden adlandırma engelli)

Kapsam dışı:
```text
FTP/SFTP/SMB/WebDAV engines
PDF annotation/search/reflow/page editing
OCR
AI/ML
background indexing
```

(FTP/SFTP/SMB/WebDAV motorları, PDF notlandırma/arama/yeniden akış/sayfa düzenleme, OCR, AI/ML, arka plan dizinleme)
