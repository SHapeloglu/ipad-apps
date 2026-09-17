# PROJECT_CONTEXT

## Amaç
iPad 1 üzerinde çocukların kolayca kullanabileceği basit, renkli ve hızlı çizim uygulaması.

## Sabit platform kısıtları
- iPad 1
- iOS 5.1.1
- Apple A4
- 256 MB RAM
- armv7
- Objective-C
- Theos
- legacy iPhoneOS 6.1 SDK
- non-ARC / MRC

## Tasarım ilkeleri
- Büyük ve az sayıda buton.
- Tek dokunuşla renk seçimi.
- Karmaşık menü yok.
- Ağ bağlantısı gerektirmez.
- Çocuğun yanlışlıkla resmi silmesini önlemek için onay gerekir.
- RAM tüketimini düşük tut.

## v0.1
- Serbest çizim
- 7 renk
- İnce / Orta / Kalın fırça
- Silgi
- Temizle
- Fotoğraflar'a kaydet

## Sonraki mantıklı geliştirmeler
1. Undo (yalnızca 3-5 adım, RAM sınırı nedeniyle)
2. Fosforlu/neon çocuk renkleri
3. Damga şekilleri: yıldız, kalp, gülen yüz
4. Arka plan rengi seçimi
5. Boyama kitabı modu (küçük yerel PNG şablonları)
6. Ebeveyn kilidi ile ayarlara giriş
7. Ses efekti aç/kapat (çok küçük WAV dosyaları)

## Kaçınılacaklar
- Sınırsız undo
- Çok katmanlı çizim
- Yüksek çözünürlüklü filtreler
- OCR / AI / ML
- Metal / modern iOS API'leri
- ARC
