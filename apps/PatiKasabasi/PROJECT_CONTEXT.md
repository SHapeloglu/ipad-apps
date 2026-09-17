# Proje Bağlamı

## Ürün

Pati Kasabası; ihtiyaç, kişilik, ilişki, beceri, meslek ve ev kurma sistemlerini sevimli hayvanlardan oluşan özgün bir dünyaya uyarlayan çocuk yaşam simülasyonudur.

## Değişmez teknik sınırlar

- iPad 1 / iOS 5.1.1 / armv7
- Apple A4 / 256 MB RAM
- Objective-C / UIKit / Foundation / Core Graphics / AudioToolbox
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

`0.4.0-alpha4`: hayvan çizimleri ortak olarak dörtte bir ölçeğe indirildi, mama kabı yeniden çizildi, harita bölgelerine yavru sürükleme eklendi ve ana ekranlardaki durağanlık düşük maliyetli Core Graphics/katman animasyonlarıyla azaltıldı. Büyük harita düğmeleri dokunma alternatifi olarak korundu; kayıt sürümü 3 ve eski kayıt anahtarı değişmedi.

## Immediate next action

Projeyi legacy Theos ortamında derle. Fiziksel iPad 1'e yükleyip özellikle dörtte bir hayvan ölçeğinin okunaklılığını, mama kabını, harita sürüklemesini/dokunma alternatifini, hareketlerin ekran geçişinde durmasını ve `TESTING.md` içindeki 15 dakikalık bellek testini uygula.
