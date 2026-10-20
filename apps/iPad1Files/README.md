# iPad1Files

iPad 1 / iOS 5.1.1 için ortak dosya sistemi omurgası ve hafif dosya/arşiv yöneticisi.

Standart kök:
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

Uygulama ailesindeki yeri:
```text
iPad1FTPDownloader -> Shared Downloads -> iPad1Files -> Open With -> iPad1PDFReader
```

Güncel yetenekler:
- dosya gezgini
- kopyala / taşı / yeniden adlandır / sil
- çoklu seçim / tümünü seç
- arama / favoriler / disk bilgisi
- tam yol gösterimi
- köke gitme
- metin / görsel önizleme
- hafif metin düzenleme
- sıralama
- çakışmaya karşı güvenli adlandırma
- korumalı sistem alanı güvenliği
- kayıt tabanlı "Birlikte Aç"
- PDF için mutlak yol devri
- kullanıcı kontrollü Downloads sınıflandırması
- ZIP içerik listeleme
- ZIP "Tümünü Çıkar"
- mevcut Klasör Seçici ile ZIP çıkarma
- çoklu seçimden ZIP oluşturma

ZIP mimarisi:
```text
FileBrowserViewController
        ↓
ArchiveViewController
        ↓
ArchiveManager
        ↓
bundled classic MiniZip + SDK libz
```

Bellek politikası:
```text
32 KB streaming buffer
entry-by-entry extraction
no whole ZIP in RAM
```

Yani 32 KB'lık akış tamponu, öğe öğe çıkarma ve ZIP'in tamamı asla RAM'de değil.

Güvenlik:
- ZIP Slip / yol geçişi kontrolü
- mutlak yol reddi
- sembolik bağlantı (symlink) reddi
- CRC doğrulaması
- önceden boş disk alanı kontrolü
- çakışmaya karşı güvenli çıkarma klasörü

1. aşama şifreli ZIP ve ZIP64'ü kapsamaz.

Derleme:
```bash
cd ~/projects/iPad1Files-v1.0.0-beta1
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

Cihaz:
```text
192.168.1.100
```

Repo:
```text
https://github.com/SHapeloglu/iPad1Files
```

**Önce `SESSION.md`'yi oku.** Belirleyici olan odur. "Hemen yapılacak sonraki adım" bölümünden devam et.
