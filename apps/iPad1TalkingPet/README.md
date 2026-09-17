# iPad1TalkingPet v0.1

iPad 1 / iOS 5.1.1 / armv7 / non-ARC sanal evcil hayvan prototipi.

## v0.1 kapsamı
- Onaylanan ana oda görseli
- Food / Bath / Sleep / Play / Wardrobe dokunma alanları
- Karakter dokunma tepkisi
- Hunger / Happiness / Hygiene / Energy değerleri
- Coin sistemi
- NSUserDefaults ile kalıcı kayıt
- Portrait-only
- Offline
- 256 MB RAM hedefi

## Derleme

```bash
cd ~/projects/iPad1TalkingPet-v0.1
rm -rf .theos packages
FINALPACKAGE=1 make package
```

## iPad'e gönderme

```bash
scp \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  packages/com.olapteknoloji.ipad1talkingpet_0.1.0_iphoneos-arm.deb \
  root@IPAD_IP:/var/mobile/
```

iPad:

```bash
dpkg -i /var/mobile/com.olapteknoloji.ipad1talkingpet_0.1.0_iphoneos-arm.deb
uicache
killall SpringBoard
```

## v0.2 hedefi
- Karakteri arka plandan ayırma
- Idle / blink / happy / touch sprite animasyonları
- Mikrofon kaydı
- Ses inceltme / tekrar oynatma
- Ağız animasyonu
- Gardırop ekranı
