# iPad1Files Mimarisi

iPad1Files monolitik bir FTP/PDF uygulaması değildir; yerel dosya sistemi + ortak depolama + devir + hafif arşiv yönetimi katmanıdır.

Platform:
```text
iPad 1 / 256 MB / iOS 5.1.1 / armv7 / Theos / Objective-C / non-ARC-MRC
```

Çekirdek:
- `IP1SharedStorage`: standart klasörler
- `IP1FileManager`: yerel işlemler + sistem güvenliği + çakışmasız adlandırma
- `IP1FileItem`: metadata
- `IP1FileTypeDetector`: tür algılama
- `IP1FavoritesManager`: favoriler
- `IP1DiskInfo`: disk bilgisi
- `IP1AppRegistry`: uzantı -> uygulama eşlemesi
- `IP1AppLauncher`: URL ile devir
- `FolderPickerViewController`: ortak hedef klasör seçici
- `ArchiveManager`: ZIP listeleme / çıkarma / oluşturma
- `ArchiveViewController`: ZIP arayüzü
- `src/minizip/`: pakete gömülü klasik MiniZip

Arşiv akışı:
```text
FileBrowserViewController
        ↓ .zip
ArchiveViewController
        ↓
ArchiveManager
        ↓
MiniZip + libz
```

Kurallar:
- ZIP'in tamamı RAM'e alınmaz
- 32 KB akış tamponu
- öğe öğe çıkarma
- yol geçişi koruması
- mutlak yol reddi
- symlink reddi
- CRC doğrulaması
- önceden boş disk alanı kontrolü
- mevcut Klasör Seçici yeniden kullanılır
- `(2)` çakışma adlandırması korunur

1. aşama:
```text
ZIP list
Extract All
Create ZIP from multi-selection
```

Ertelenenler:
```text
single-entry extract
progress/cancel
ZIP64
encrypted ZIP
TAR/TGZ/GZ
RAR/7z
```

(tek öğe çıkarma, ilerleme/iptal, ZIP64, şifreli ZIP, TAR/TGZ/GZ, RAR/7z)

"Birlikte Aç":
```text
.pdf -> iPad1PDFReader
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Kapsam dışı:
```text
FTP/SFTP/SMB/WebDAV engines
PDF engine features
OCR
AI/ML
background indexing
```

(FTP/SFTP/SMB/WebDAV motorları, PDF motoru özellikleri, OCR, AI/ML, arka plan dizinleme)
