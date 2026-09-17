# KidsDraw v1.3 for iPad 1

## Platform
iPad 1 / iOS 5.1.1 / Apple A4 / 256 MB RAM / armv7 /
Objective-C / Theos / legacy iPhoneOS 6.1 SDK / non-ARC-MRC.

## v1.3

### Kritik düzeltme
- Flood Fill 180° dönme problemi kökten ele alındı.
- CGContext üzerinde yön dönüşümü artık yapılmıyor.
- Sadece UIKit dokunma Y koordinatı bitmap Y koordinatına çevriliyor.
- Ardışık 2., 3., 4. dolgularda orientation birikmemeli.

### Galeri
- Tümü / Favoriler / Son 10 akıllı klasörleri
- Favori çizimlerde ★
- Disk tabanlı 160x120 JPEG thumbnail cache
- Galeri açılırken tam boy PNG decode sayısı azaltıldı

### Fırça iş akışı
- Aktif fırçayı favoriye ekleme/çıkarma
- En fazla 5 favori fırça
- En son kullanılan 5 fırça
- Yeni üst buton eklenmedi:
  Önizle -> Fırça Araçları menüsü

### Boyama
- 40 başlığın tamamı artık 0..39 ayrı procedural şablona bağlı.
- 20 yeni özgün CoreGraphics şablon eklendi.
- Harici büyük PNG asset kullanılmadı.

## iPad 1 performans yaklaşımı
- Thumbnail cache küçük JPEG dosyalarıdır.
- Fırça geçmişi sadece 5 NSNumber tutar.
- Akıllı galeri klasörleri dosya kopyalamaz.
- Yeni boyama çizimleri procedural CoreGraphics'tir.
- Undo/Redo 5+5, multi-touch maksimum 2.

## Build
```bash
make clean
rm -rf packages
FINALPACKAGE=1 make package
```

Beklenen:
`packages/com.olap.kidsdraw_1.3.0_iphoneos-arm.deb`

## Fiziksel test önceliği
1. Aynı boyama sayfasında art arda 5 farklı dolgu
2. Dolgu sonrası Undo/Redo
3. Tümü/Favoriler/Son 10 galeri filtreleri
4. Galeriyi ikinci açışta thumbnail hızının artması
5. Fırça favorisi + son kullanılanlar
6. Yeni 20 boyama şablonu
7. RAM/crash/akıcılık
