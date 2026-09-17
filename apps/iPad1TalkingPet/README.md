# iPad1TalkingPet v0.4

iPad 1 / iOS 5.1.1 / armv7 / Apple A4 / 256 MB RAM / Objective-C / Theos / non-ARC.

## v0.4 ana geliştirmeleri
- Hafif karakter animasyon yöneticisi:
  - idle hareket
  - blink
  - happy bounce
  - touch wobble
  - konuşma sırasında ağız pulse efekti
- Gardırop seçiminin ana ekranda görsel aksesuar overlay olarak görünmesi
  - mavi şapka
  - yıldız/gözlük benzeri aksesuar
- Oda tema sistemi ve kalıcı seçim
- Yemek sistemi 6 çeşide çıkarıldı
  - Elma
  - Muz
  - Havuç
  - Tavuk
  - Pasta
  - Süt
- Yemek sürükle-bırak korunuyor
- Banyo köpük partikülleri
- Mini oyun sayısı 4:
  - Pati Yakala
  - Baloncuk Patlat
  - Hafıza Kartları
  - Yemek Yakala
- XP / seviye / coin / daily reward / offline decay korunuyor
- Konuş ve komik ses tekrar sistemi korunuyor

## Teknik not
Onaylanan karakter görseli hâlâ oda görüntüsünün içinde olduğu için v0.4'te gerçek tam sprite-sheet yerine
iPad 1'e çok hafif gelen UIKit/CGAffineTransform + overlay tabanlı karakter animasyonu kullanılıyor.
Bu, fiziksel cihaz performansını doğrulamak için güvenli ara mimaridir.

Gerçek şeffaf `idle/blink/talk/eat/sleep/touch` kareleri hazır olduğunda PetAnimator aynı API ile
UIImageView sprite animasyonuna geçirilebilir.

## Derleme

```bash
cd ~/projects/iPad1TalkingPet-v0.4
rm -rf .theos packages
FINALPACKAGE=1 make package
```

## iPad'e gönderme

```bash
scp \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  packages/com.olapteknoloji.ipad1talkingpet_0.4.0_iphoneos-arm.deb \
  root@192.168.1.2:/var/mobile/
```
