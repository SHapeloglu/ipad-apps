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

`0.5.0-alpha5`: Park, Okul ve Meydan metin tabloları hafif Core Graphics sahnelerine ve büyük etkinlik kartlarına dönüştürüldü. Yavru ev eylemlerine, oda eşyalarına, ders/meslek kartlarına, komşulara ve meydan etkinliklerine sürüklenebiliyor. Okula `Evimiz` üst menüsü eklendi; yatak gerçek hayvan yatağı biçiminde yeniden çizildi. Sürekli ağır simülasyon yerine olay tabanlı kısa yolculuk/tepki ve tek katmanlı boşta hareket kullanılıyor. Kayıt sürümü 3 ve eski kayıt anahtarı değişmedi.

## Immediate next action

Projeyi legacy Theos ortamında derle. Fiziksel iPad 1'e yükleyip özellikle Ev/oda/okul/park/meydan sürüklemelerini, görsel kartların kırpılmamasını, okulun `Evimiz` düğmesini, hayvan yatağını, hareketlerin ekran geçişinde durmasını ve `TESTING.md` içindeki 15 dakikalık bellek testini uygula.
