# iPad1TalkingPet v0.2

iPad 1 / iOS 5.1.1 / armv7 / Objective-C / Theos / non-ARC sanal evcil hayvan prototipi.

## v0.2'de eklenenler
- Konuş / kaydet / daha hızlı oynatarak ince ses taklidi
- Mikrofon tabanlı Talking Pet özelliği
- XP ve seviye sistemi
- Günlük ödül
- Coin harcama / kazanma
- Offline ihtiyaç azalması
- Dakikalık ihtiyaç azalması
- Baş / gövde / ayak için farklı dokunma tepkileri
- Basit Gardırop ekranı
- Satın alınabilir aksesuarlar için kalıcı sahiplik
- "Pati Yakala" 20 saniyelik mini oyun
- Mini oyundan coin ve XP kazanma
- Tamamen offline çalışma

## Henüz görsel olarak tamamlanmayanlar
Ana kedi hâlâ arka plan görselinin bir parçası. Bu nedenle seçilen kıyafetler henüz karakterin üzerinde görünmez.
Bir sonraki görsel milestone:
- Kediyi ayrı şeffaf sprite olarak üretmek
- Idle / blink / talk / eat / happy / sleep animasyon kareleri
- Kıyafetleri ayrı overlay sprite'ları yapmak

## Derleme

```bash
cd ~/projects/iPad1TalkingPet-v0.2
rm -rf .theos packages
FINALPACKAGE=1 make package
```

## iPad'e gönderme

```bash
scp \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  packages/com.olapteknoloji.ipad1talkingpet_0.2.0_iphoneos-arm.deb \
  root@192.168.1.2:/var/mobile/
```
