# KidsDraw v0.4 for iPad 1

Çocuklar için hafif, reklamsız ve çevrimdışı çizim/boyama uygulaması.

## Hedef
- iPad 1 / iOS 5.1.1 / armv7
- Apple A4 / 256 MB RAM
- Objective-C / Theos / legacy iPhoneOS 6.1 SDK
- non-ARC / MRC

## v0.4 özellikleri
- Serbest çizim
- 8 renk
- İnce / Orta / Kalın fırça
- Normal / Pastel / Fosforlu / Gökkuşağı fırçası
- 5 Undo + 5 Redo
- Dolgu kovası
- Silgi
- Dikey simetri modu
- Şekiller: çizgi, dikdörtgen, daire/oval, üçgen
- Metin ekleme
- 24 damga
- 20 boyama şablonu
- Çizimlerim galerisi
- Fotoğraflar'a ve uygulama galerisine kayıt
- Otomatik taslak kayıt + açılışta geri yükleme
- iPad1Files entegrasyonu için `kidsdraw://open?path=...` dış-görsel giriş noktası

## Mimari sınır
KidsDraw içinde Dosya Aç / dosya tarayıcı yoktur. Dosya seçimi iPad1Files uygulamasının sorumluluğudur. KidsDraw yalnızca kendisine dışarıdan gönderilen PNG/JPG/JPEG yolunu açar.

## Build
```bash
make clean
rm -rf packages
FINALPACKAGE=1 make package
```
