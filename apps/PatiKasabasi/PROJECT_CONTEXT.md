# Proje Bağlamı

## Ürün

Pati Kasabası; ihtiyaç, kişilik, ilişki, beceri, meslek ve ev kurma sistemlerini sevimli hayvanlardan oluşan özgün bir dünyaya uyarlayan çocuk yaşam simülasyonudur.

## Değişmez teknik sınırlar

- iPad 1 / iOS 5.1.1 / armv7
- Apple A4 / 256 MB RAM
- Objective-C / UIKit / Foundation / Core Graphics / AudioToolbox / AVFoundation
- Theos / legacy iPhoneOS 6.1 SDK
- non-ARC / MRC
- Swift, Auto Layout, Storyboard, SpriteKit, Metal, SceneKit ve modern API yok
- Büyük bitmap, açık dünya simülasyonu ve sürekli zamanlayıcı yok

## Ürün kararları

- Yatay ekran, çevrimdışı ve tek oyunculu
- Reklam, gerçek para, enerji kilidi, sürpriz kutu, hesap ve çevrimiçi sohbet yok
- Hayvanlar ölmez, hastalıkla suçluluk yaratılmaz ve kalıcı kayıp yaşanmaz
- Zaman yalnızca oyuncu eylemleriyle ilerler; uygulama kapalıyken ihtiyaç azalmaz
- Mini oyunlar oynanmaya devam edebilir; yalnızca günlük para ödülü sınırlandırılır
- Etkinlikler tekrar döner ve kaçırıldığı için ceza vermez
- Aynı sahnede en fazla dört aktif hayvan

## Güncel kilometre taşı

`0.7.0-alpha7`: Evde baş, karın, pati ve kuyruk için ayrı dokunma tepkileri; göz kırpma, etrafa bakma, esneme, kulak oynatma ve el sallama mikro hareketleri var. Mama kabı normal mama, balık, havuç ve kurabiye arasında seçilebiliyor; dört türün sevdiği ve sevmediği yiyecekler farklı yüz, düşünce ve ihtiyaç sonucu üretiyor. Altı kısa eylem sesi, üç saniyeyle sınırlı yalnızca cihaz içi ses tekrar ve olay tabanlı `Top Yakala` mini oyunu eklendi. Hareketler kısa `UIView` dizileri; ses kaydı geçici dosyada, ağ aktarımı yok. Sürekli zamanlayıcı, GIF, kare dizisi veya SVG yorumlayıcı yok. Kayıt sürümü 3 ve eski kayıt anahtarı değişmedi.

## Immediate next action

Alpha7'yi legacy Theos ortamında derle. Fiziksel iPad 1'e yükleyip dört dokunma bölgesini, beş mikro hareketi, dört mama ve tür tercihlerini, ses seviyelerini, mikrofon kaydet/geri oynat akışını, `Top Yakala` tur zamanlamasını, ekran geçişinde gecikmiş çağrıların durmasını ve `TESTING.md` içindeki 15 dakikalık bellek testini uygula.
