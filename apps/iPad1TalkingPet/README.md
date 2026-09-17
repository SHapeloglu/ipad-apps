# iPad1TalkingPet v0.6 — Polish + Animation

Platform:
- iPad 1 / iOS 5.1.1 / armv7
- Apple A4 / 256 MB RAM
- Objective-C / UIKit / CoreGraphics / AVFoundation
- Theos + legacy iPhoneOS 6.1 SDK
- non-ARC / MRC
- offline-first

## v0.6 yenilikleri

### Gerçek sprite-frame animasyon sistemi
`Resources/Animations/` altında önceden render edilmiş kareler:
- idle 6 kare
- blink 4 kare
- talk 4 kare
- happy 5 kare
- sad 4 kare
- touch 5 kare
- chew 4 kare
- sleep 4 kare

`PetSpriteAnimator` yalnızca gereken animasyonu oynatır; ağır 3D motor kullanılmaz.

### Ses paketi
`Resources/Sounds/`
- tap
- coin
- eat
- bath
- sleep
- level-up
- game
- photo
- hafif loop oda müziği

### Gardırop
- Şapka
- Yüz/gözlük
- Tişört
- Pantolon
- Ayakkabı
- Kalıcı satın alma ve seçim

### Gerçek mobilya PNG'leri
`Resources/Furniture/`
- 2 koltuk
- 2 halı
- 2 lamba
- 2 bitki

Oda ekranı artık bu PNG varlıklarını seçime göre çiziyor.

### Görevler ve Başarımlar
Günlük görevler:
- 3 kez yemek ver
- banyoyu tamamla
- 2 mini oyun oyna
- fotoğraf çek

Başarımlar:
- Arkadaş
- Lezzet Uzmanı
- Temizlikçi
- Oyun Ustası
- Gezgin

### Seviye atlama geri bildirimi
- level-up ses efekti
- ekranda tebrik bildirimi

## Korunan özellikler
- konuş ve tekrar et
- 4 ihtiyaç
- offline decay
- XP / level / coin
- günlük ödül
- 6 yemek
- sabun/köpük/duş
- uyku odası
- 6 mini oyun
- fotoğraf albümü
- seyahat
- oda temaları
- mobilya slotları

## Derleme

```bash
cd ~/projects/iPad1TalkingPet-v0.6
rm -rf .theos packages
FINALPACKAGE=1 make package
```

## iPad'e gönderme

```bash
scp \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  packages/com.olapteknoloji.ipad1talkingpet_0.6.0_iphoneos-arm.deb \
  root@192.168.1.2:/var/mobile/
```
