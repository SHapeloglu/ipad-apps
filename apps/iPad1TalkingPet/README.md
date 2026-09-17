# iPad1TalkingPet v1.0 — Emotion & Polish

## v1.0 yenilikleri

### Duygu / ihtiyaç davranış sistemi
Kedi artık yalnızca rastgele değil, ihtiyaçlarına göre davranır:
- Enerji düşük: uyku/esneme davranışı
- Açlık düşük: üzgün/bakınma davranışı
- Hijyen düşük: rahatsız/gerinme davranışı
- Mutluluk düşük: oyun/ilgi isteyen davranış
- Tüm ihtiyaçlar yüksek: gülme/dans/mutlu davranış

Ana ekranda aktif ruh hali ve kısa ipucu gösterilir.

### Rekor ve combo
- Yerel `HighScoreManager`
- `Rekorlar` ekranı
- 8 mini oyun için rekor alanı
- Koşu oyununda gerçek high-score + combo çarpanı
- Eşleştir oyununda high-score entegrasyonu
- Pazartesi 2x mini oyun ödülü ile birlikte çalışır

### İçerik
- Yemek sistemi 10 ürüne genişletildi
- Yeni koltuk / halı / lamba PNG varyasyonları
- v0.8 gardırop sistemi korunuyor
- v0.9 spontane animasyonlar korunuyor

### Platform
iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1 / armv7 / non-ARC.

## Derleme
```bash
cd ~/projects/iPad1TalkingPet-v1.0
rm -rf .theos packages
FINALPACKAGE=1 make package
```

## iPad'e gönderme
```bash
scp \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  packages/com.olapteknoloji.ipad1talkingpet_1.0.0_iphoneos-arm.deb \
  root@192.168.1.2:/var/mobile/
```
