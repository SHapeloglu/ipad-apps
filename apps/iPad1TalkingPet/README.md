# iPad1TalkingPet v0.3

Talking-pet tarzı özgün sanal evcil hayvan oyunu.
Platform: iPad 1 / iOS 5.1.1 / armv7 / 256 MB RAM / Objective-C / Theos / non-ARC.

## v0.3 yenilikleri
- Food artık ayrı etkileşim ekranı
- Yiyeceği sürükleyip ağız bölgesine bırakma
- Coin harcama + hunger + XP entegrasyonu
- Bath artık ayrı etkileşim ekranı
- Sabunu karakter alanında gezdirerek köpürtme
- Duş kullanmadan hijyen artmıyor
- Sleep artık ayrı yatak odası
- Işık aç/kapat
- Işık kapanınca uyku/enerji artışı
- Mini oyun menüsü
- Pati Yakala
- Baloncuk Patlat
- Önceki v0.2: konuşma kaydı/tekrar, XP, seviye, daily reward, coin, offline decay, wardrobe kayıt sistemi

## Önemli görsel not
Onaylanan ana karakter hâlâ `home_bg.jpg` içine gömülü.
Kod mimarisi karakteri ayrı sprite katmanına taşımaya hazır olacak şekilde odalar ayrıştırıldı; ancak gerçek
`idle/blink/talk/eat/sleep/touch` sprite görselleri tek bir sabit fotoğraftan güvenilir biçimde üretilemez.
Bu sanat varlıkları hazır olduğunda UIImageView tabanlı animasyon katmanına takılacak.

## Derleme
```bash
cd ~/projects/iPad1TalkingPet-v0.3
rm -rf .theos packages
FINALPACKAGE=1 make package
```

## iPad'e gönderme
```bash
scp \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  packages/com.olapteknoloji.ipad1talkingpet_0.3.0_iphoneos-arm.deb \
  root@192.168.1.2:/var/mobile/
```
