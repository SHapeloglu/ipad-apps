# iPad1TalkingPet v0.5 — Character 2.0

Platform:
- iPad 1
- iOS 5.1.1
- armv7
- Apple A4
- 256 MB RAM
- Objective-C / UIKit
- Theos + legacy iPhoneOS 6.1 SDK
- non-ARC / MRC

## v0.5 ile gelen büyük değişiklik

Ana karakter artık oda JPG'sinin içine gömülü değil.

`Resources/pet_base.png` gerçek şeffaf karakter katmanıdır ve `PetCharacterView`
üzerinde oda arka planından bağımsız çizilir.

Bu sayede:
- karakter animasyonu odadan bağımsız
- kıyafetler karakterin üzerine bindirilebilir
- konuşma/ağız animasyonu karakterle beraber hareket eder
- oda değişse bile karakter aynı kalır

## Karakter animasyonları
- idle
- blink
- talking mouth
- happy
- sad
- head touch
- body touch
- feet touch
- chew helper

## Gardırop 2.0
Slotlar:
- şapka
- yüz/gözlük
- tişört
- pantolon
- ayakkabı

Satın alma ve seçim `NSUserDefaults` ile kalıcıdır.

## Oda & Mobilya
- 4 oda teması
- koltuk
- halı
- lamba
- dolap
- bitki slotları
- seçimler kalıcı

## Mini oyunlar
1. Pati Yakala
2. Baloncuk Patlat
3. Hafıza Kartları
4. Yemek Yakala
5. Labirent
6. Topu Sepete At

## Diğer
- 6 yemek
- sabun + köpük + duş
- uyku odası + ışık
- konuşma kaydı ve tekrar
- XP/seviye/coin
- günlük ödül
- offline ihtiyaç azalması
- fotoğraf çekip yerel albüme kaydetme
- hafif seyahat haritası

## Derleme

```bash
cd ~/projects/iPad1TalkingPet-v0.5
rm -rf .theos packages
FINALPACKAGE=1 make package
```

## iPad'e gönderme

```bash
scp \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  packages/com.olapteknoloji.ipad1talkingpet_0.5.0_iphoneos-arm.deb \
  root@192.168.1.2:/var/mobile/
```
