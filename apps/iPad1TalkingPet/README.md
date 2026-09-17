# iPad1TalkingPet v0.9 — Living Pet

## Yeni
- Spontane karakter davranışları:
  - sola bak
  - sağa bak
  - el salla
  - gül
  - şaşır
  - gerin
  - dans et
  - zıpla
- LivingPetManager: belirli aralıklarla rastgele davranış
- HighScoreManager:
  - yerel high score
  - combo çarpanı altyapısı
- Haftalık offline etkinlik sistemi:
  - Pazartesi: mini oyun coin 2x
  - Salı: yemek indirimi
  - Çarşamba: gardırop indirimi
  - Perşembe: fotoğraf günü
  - Cuma: gezi günü
  - Cumartesi: bonus coin
  - Pazar: bakım/uyku odaklı
- Etkinlik ekranı
- Mobilya içeriği genişletildi
- v0.8 gardırop ve kıyafet fit sistemi korunuyor
- v0.6/v0.7 sprite, ses, görev, başarımlar ve 8 mini oyun korunuyor

## Derleme
```bash
cd ~/projects/iPad1TalkingPet-v0.9
rm -rf .theos packages
FINALPACKAGE=1 make package
```

## Gönderme
```bash
scp \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  packages/com.olapteknoloji.ipad1talkingpet_0.9.0_iphoneos-arm.deb \
  root@192.168.1.2:/var/mobile/
```
