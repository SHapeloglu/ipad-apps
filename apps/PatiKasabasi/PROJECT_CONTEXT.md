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

`0.3.0-alpha3`: sekiz parçalı dolap, eşyaya dokunarak doğrudan kullanım, dört bölgeli kasaba haritası ve her komşuya üç tane düşen 12 konumlu görev mevcut yaşam simülasyonuna bağlandı. Kayıt sürümü 3; eski kayıt anahtarı korunuyor.

## Immediate next action

Projeyi legacy Theos ortamında derle. Uyarıları temizledikten sonra fiziksel iPad 1'e yükleyip özellikle dolap çizimlerini, eşya dokunma alanlarını, harita geçişlerini, 12 günlük görev döngüsünü ve `TESTING.md` içindeki bellek testini uygula.
