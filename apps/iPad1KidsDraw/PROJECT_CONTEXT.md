# PROJECT_CONTEXT — KidsDraw v0.4

## Amaç
Eski iPad 1'i çocuk için hızlı, reklamsız, çevrimdışı çizim ve boyama tabletine dönüştürmek.

## Değişmeyecek platform sınırları
- iPad 1 / Apple A4 / 256 MB RAM
- iOS 5.1.1 / armv7
- Objective-C / Theos / iPhoneOS 6.1 SDK
- non-ARC / MRC

## Uygulama sorumluluğu
KidsDraw çizim/boyama uygulamasıdır. Dosya yöneticisi olmayacaktır.

### iPad1Files sorumluluğu
- PNG/JPG/JPEG seçmek
- “KidsDraw ile aç” eylemini sunmak
- `kidsdraw://open?path=<encoded-path>` ile KidsDraw'a yönlendirmek

### KidsDraw sorumluluğu
- Gelen görseli tuvale almak
- Üzerine çizmek
- Kendi çizim galerisini yönetmek
- Dosya picker/tarayıcı içermemek

## v0.4
- 5 Undo + 5 Redo
- Dolgu
- 4 fırça: Normal/Pastel/Fosforlu/Gökkuşağı
- Dikey simetri
- 4 şekil
- Metin ekleme
- 24 damga
- 20 boyama şablonu
- Otomatik taslak kayıt
- Çizimlerim
- dış-görsel URL giriş noktası

## Performans ilkeleri
- Sınırsız undo yok
- Katman sistemi yok
- Büyük bitmap filtreleri yok
- Damga ve şablonlar CoreGraphics ile çizilir
- Otomatik kayıt her touch-move'da değil, değişiklikten 2 saniye sonra tek PNG olarak yapılır
