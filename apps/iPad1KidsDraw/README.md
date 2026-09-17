# KidsDraw v0.8 for iPad 1

## Platform
iPad 1 / iOS 5.1.1 / Apple A4 / 256 MB RAM / armv7 /
Objective-C / Theos / legacy iPhoneOS 6.1 SDK / non-ARC-MRC.

## v0.8 kalite geliştirmeleri
- Sprey yoğunluğu: Az / Orta / Çok
- Fosfor parlaklığı: Az / Orta / Çok
- Fosfor render: parlama + çekirdek güçlendirmesi
- Kurşun kalem dokusu daha ince/çift geçişli
- Keçeli kalem daha homojen yarı saydam
- Pastel dokusu iyileştirildi
- Tebeşir dokusu korunup hafif jitter ile zenginleştirildi
- Damga boyutu artık 6 seviye:
  XS / S / M / L / XL / XXL
- İki parmak serbest çizimde 1 pikselden küçük hareketler çizdirilmez;
  gereksiz bitmap yenilemeleri azaltılır
- Sprey parçacık sayısı 36 ile sınırlandırılır
- v0.7 özellikleri korunur

## Build
```bash
make clean
rm -rf packages
FINALPACKAGE=1 make package
```

Beklenen:
`packages/com.olap.kidsdraw_0.8.0_iphoneos-arm.deb`

## Fiziksel test önceliği
1. Sprey Az/Orta/Çok performansı
2. Fosfor Az/Orta/Çok görünümü
3. İki parmakla hızlı paralel çizim
4. Damga 6 boyut
5. Pencil/Marker/Pastel/Chalk ayrımı
6. RAM/crash gözlemi
