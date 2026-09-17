# KidsDraw v0.5 for iPad 1

Çocuklar için hafif çizim, boyama ve yaratıcı oyun uygulaması.

## Hedef platform
- iPad 1 / Apple A4
- iOS 5.1.1
- armv7
- 256 MB RAM
- Objective-C / Theos
- legacy iPhoneOS 6.1 SDK
- non-ARC / MRC

## v0.5
- Basit / Gelişmiş kullanım modu
- 5 Undo + 5 Redo
- Dolgu kovası
- Normal / Pastel / Fosforlu / Gökkuşağı fırçası
- Dikey simetri
- Şekiller ve metin
- 24 damga, kategori menüsü
- 20 boyama şablonu, kategori menüsü
- Otomatik taslak kayıt
- Çizimlerim galerisi
- Hafif çizim replay: en fazla 18 adet 256x192 önizleme karesi
- Yerel yıldız ödül sistemi
- Kaydetmede 1 yıldız
- Reklam, hesap ve internet gereksinimi yok

## iPad1Files entegrasyonu
KidsDraw kendi dosya seçicisini içermez. Dışarıdan gelen PNG/JPG için:
`kidsdraw://open?path=...`

## Build
```bash
make clean
rm -rf packages
FINALPACKAGE=1 make package
```

Beklenen paket:
`packages/com.olap.kidsdraw_0.5.0_iphoneos-arm.deb`

## Bellek yaklaşımı
Replay tam çözünürlüklü stroke geçmişi tutmaz. En fazla 18 küçük önizleme
saklar; böylece iPad 1'in 256 MB RAM sınırında kontrollü kalır.
