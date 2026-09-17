# KidsDraw v1.0 for iPad 1

## Platform
iPad 1 / iOS 5.1.1 / Apple A4 / 256 MB RAM / armv7 /
Objective-C / Theos / legacy iPhoneOS 6.1 SDK / non-ARC-MRC.

## v1.0
- Parmakla Dağıt (Smudge): Az / Orta / Çok
- Renk Karıştır: Az / Orta / Çok
- Gerçek pigment simülasyonu yok; hafif overlay yaklaşımı
- Fırça menüsünde Smudge + Mixer
- 28 boyama başlığı / 4 kategori
- Mevcut 20 procedural şablon güvenli şekilde yeniden kullanılır
- v0.9.x özellikleri korunur:
  - 16+ özel renkler
  - opacity
  - sprey boyutu/yoğunluğu
  - fosfor gücü
  - silgi boyutları
  - damga pinch
  - iki parmak bağımsız renk/fırça
  - autosave / galeri / replay / ödüller

## iPad 1 performans yaklaşımı
- Smudge tam convolution kullanmaz.
- Mixer gerçek pigment fiziği simüle etmez.
- Yeni araçlar mevcut bitmap render turunu kullanır.
- Multi-touch maksimum 2.
- Undo/Redo 5+5.

## Build
```bash
make clean
rm -rf packages
FINALPACKAGE=1 make package
```

Beklenen:
`packages/com.olap.kidsdraw_1.0.0_iphoneos-arm.deb`

## Fiziksel test
1. Dağıt Az/Orta/Çok
2. Karıştır Az/Orta/Çok
3. İki parmak + smudge
4. İki parmak + mixer
5. Boyama kategori menülerinde 7 seçenek
6. RAM / crash / gecikme
