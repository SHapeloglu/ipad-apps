# iPad1Files — Belirleyici Oturum / Yeni Sohbet Devir Belgesi

> Bu dosya repo için belirleyici devir belgesidir. Başka bir Markdown dosyasıyla çelişirse `SESSION.md` esas alınır.

## Proje

Repo:
```text
https://github.com/SHapeloglu/iPad1Files
```

Dal:
```text
main
```

Bu doküman güncellemesinden önce doğrulanan kaynak commit'i:
```text
3c5bce9 Add safe ZIP archive support and file manager enhancements
```

Yerel klasör:
```text
~/projects/iPad1Files-v1.0.0-beta1
```

## Kesin kısıtlar

```text
iPad 1
256 MB RAM
iOS 5.1.1
armv7
Objective-C
Theos
non-ARC / MRC
```

Swift yok, yalnızca yeni iOS'ta olan API'ler yok, ARC'ye geçiş yok. Son söz fiziksel cihaz davranışınındır.

## Fiziksel cihaz

```text
IP: 192.168.1.100
SSH user: root
```

Eski SSH parametreleri:
```text
-o HostKeyAlgorithms=+ssh-rsa
-o PubkeyAcceptedAlgorithms=+ssh-rsa
```

## Görev

iPad1Files, iPad1 uygulama ailesinin ortak dosya sistemi omurgasıdır.

Standart kök:
```text
/var/mobile/Media/iPad1Files
```

Alt klasörler:
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

Sorumlu olduğu işler: gezgin; kopyala/taşı/yeniden adlandır/sil; çoklu seçim/tümünü seç; arama/favoriler/disk bilgisi; klasör seçici; yol gezinme; hafif önizleme/düzenleme; çakışmasız adlandırma; "Birlikte Aç" / URL devri; ZIP arşiv yönetimi.

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

Sorumlu olmadığı işler: FTP/SFTP/SMB/WebDAV motorları; PDF görüntüleme/notlandırma/arama/yeniden akış motorları; OCR; AI/ML; arka planda dosya sistemi dizinleme.

```text
FTP/SFTP/SMB/WebDAV engines
PDF rendering/annotation/search/reflow engines
OCR
AI/ML
background filesystem indexing
```

## Yardımcı uygulama entegrasyonu

FTPDownloader:
```text
/var/mobile/Media/iPad1Files/Downloads
```

PDF:
```text
.pdf -> iPad1PDFReader
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Mümkün olduğunca aynı fiziksel dosyayı kullan.

## Güncel dosya yöneticisi yetenekleri

- ortak depolamanın ilk kurulumu
- gezgin
- tam yol gösterimi
- `/` köküne gitme
- kopyala / taşı / yeniden adlandır / sil
- çoklu seçim ve `Tümünü Seç`
- bulunulan klasörde arama
- gizli dosyaları göster/gizle
- favoriler
- disk bilgisi alt çubuğu
- metin / görsel önizleme
- normal alanlarda hafif metin düzenleme/kaydetme
- boş metin dosyası oluşturma
- ada / tarihe / boyuta göre sıralama
- çakışmaya karşı güvenli `(2)`, `(3)` adlandırma
- normal üzerine yaz / yeni ad / iptal davranışı
- korumalı sistem alanları: tümünü seç yok, üzerine yazma yok, yıkıcı işlemde uyarı
- kritik köklerde silme/yeniden adlandırma koruması
- "Birlikte Aç" kaydı
- kullanıcı kontrollü Downloads sınıflandırması

## ZIP 1. aşama mimarisi

Modüller:
```text
ArchiveManager
ArchiveViewController
src/minizip/
```

Uygulama:
- klasik MiniZip uygulamaya gömülü
- SDK `libz`
- cihazdaki `/usr/bin/zip`, `/usr/bin/unzip` veya `libzip`'e çalışma zamanı bağımlılığı yok
- 32 KB akış tamponu
- öğe öğe çıkarma
- ZIP'in tamamı RAM'de değil
- kontrollü autorelease pool'lar

Desteklenenler:
```text
ZIP content listing
Extract All -> here
Extract All -> another folder using existing Folder Picker
multi-select -> Create ZIP
reopen/extract ZIPs created by iPad1Files
```

(ZIP içerik listeleme; buraya Tümünü Çıkar; mevcut Klasör Seçici ile başka klasöre Tümünü Çıkar; çoklu seçimden ZIP oluşturma; iPad1Files ile oluşturulan ZIP'leri yeniden açma/çıkarma)

Güvenlik:
- ZIP Slip / yol geçişi kontrolü
- mutlak yol reddi
- symlink reddi
- CRC doğrulaması
- önceden boş disk alanı kontrolü
- çakışmaya karşı güvenli çıkarma klasörü
- şifreli ZIP desteklenmez
- ZIP64 1. aşamada desteklenmez

## Fiziksel cihazda GEÇTİ

Fiziksel iPad 1'de doğrulananlar:
- temiz armv7 derleme
- paket kurulumu
- uygulamanın açılması
- kopyala / taşı / sil
- çoklu seçim
- `Tümünü Seç`
- köke gitme
- korumalı alanda "tümünü seç" gizli
- normal çakışmada üzerine yaz / yeni ad
- korumalı hedefte üzerine yazma seçeneği yok
- ZIP içerik ekranı
- ZIP listesi
- buraya "Tümünü Çıkar"
- tekrar çıkarma -> `(2)`
- Klasör Seçici ile "Tümünü Çıkar"
- çoklu seçimden ZIP oluşturma
- oluşturulan ZIP'i yeniden açma
- oluşturulan ZIP'i çıkarma
- ZIP entegrasyonu sonrası çekirdek dosya yöneticisi regresyonu

## Henüz kanıtlanmayanlar

- Türkçe ZIP dosya adları/yolları
- bozuk ZIP
- yarım kalmış ZIP
- açıkça kötü niyetli `../` içeren ZIP
- açıkça mutlak yollu ZIP
- açıkça symlink içeren ZIP
- yetersiz disk alanı
- çok sayıda küçük öğe
- tek büyük öğe
- bellek baskısı
- ZIP 2. aşama: tek dosya çıkarma
- ilerleme arayüzü
- iptal desteği
- şifreli ZIP
- ZIP64
- büyük dizin / görsel yük testi
- PDFReader alıcısına mutlak yol devri

## Derleme

```bash
cd ~/projects/iPad1Files-v1.0.0-beta1
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

## Git temizliği

Asla commit etme:
```text
.theos/
packages/
*.deb
obj/
*.dSYM/
local helper patch scripts
```

Commit öncesi:
```bash
git status -sb
git diff --check
```

## Hemen yapılacak sonraki adım

1. Önce bu dosyayı oku.
2. Doğrula:
```bash
cd ~/projects/iPad1Files-v1.0.0-beta1
git status -sb
git log -5 --oneline
```
3. Fiziksel iPad'de güvenli ZIP 1. aşama uç durum/güvenlik testlerini çalıştır:
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
4. Gerçek GEÇTİ/KALDI sonuçlarını `SESSION.md` ve `TESTING.md`'ye yaz.
5. 2. aşamaya ancak 1. aşama kararlı olduktan sonra başla:
```text
single-file extract
progress UI
cancel support
```
6. Mevcut dosya yöneticisi regresyon davranışını koru.
7. iPad1Files'a FTP/SFTP/SMB/WebDAV motorları ekleme.

## Yeni sohbet başlangıç metni

```text
https://github.com/SHapeloglu/iPad1Files

SESSION.md dosyasını oku.
SESSION.md bu proje için belirleyici devir belgesidir.
Başka bir MD dosyasıyla çelişirse SESSION.md'yi esas al.
"Hemen yapılacak sonraki adım" bölümünden devam et.
Güncel main dalını ve kaynak kodu da kontrol et.
Mevcut mimari kararları bozma.
iPad 1 / 256 MB RAM / iOS 5.1.1 / armv7 / Objective-C / Theos / non-ARC-MRC sınırlarından sapma.
Fiziksel cihazda doğrulanmamış özellikleri çalışıyor kabul etme.
```
