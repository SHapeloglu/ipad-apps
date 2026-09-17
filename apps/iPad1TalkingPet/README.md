# iPad1TalkingPet v0.8 — Wardrobe Fit Update

## Bu sürümde
- Gardırop ekranı son onaylanan görsel yaklaşıma göre yenilendi
- Tişört:
  - Stil 1: mor kalpli
  - Stil 2: pembe çiçekli
- Pantolon/şort:
  - Stil 1: koyu denim
  - Stil 2: açık/distressed denim
- Crop:
  - Stil 1: pembe kalpli
  - Stil 2: mor düğmeli
- Etek:
  - Stil 1: pembe pileli
  - Stil 2: denim
- Kıyafetler karakter gövdesine ayrı üst/alt slotlarla oturtuluyor
- Üst ve alt kıyafet birbirinden bağımsız seçiliyor
- Önceki şapka/gözlük/ayakkabı slotları korunuyor
- Satın alma, seçim ve kalıcı kayıt korunuyor

## Derleme
```bash
cd ~/projects/iPad1TalkingPet-v0.8
rm -rf .theos packages
FINALPACKAGE=1 make package
```

## iPad'e gönderme
```bash
scp \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  packages/com.olapteknoloji.ipad1talkingpet_0.8.0_iphoneos-arm.deb \
  root@192.168.1.2:/var/mobile/
```
