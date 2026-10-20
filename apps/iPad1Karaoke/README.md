# iPad1Karaoke v0.1

Hafif, çevrimdışı karaoke oynatıcı prototipi.

## Platform sınırları

- iPad 1
- iOS 5.1.1
- armv7
- Objective-C / UIKit / AVFoundation
- Theos + legacy iPhoneOS 6.1 SDK
- non-ARC / MRC
- 256 MB RAM

## İlk sürüm

- Paket içindeki MP3 dosyasını oynatır.
- Oynat / duraklat.
- İlerleme çubuğu ve süre göstergesi.
- LRC zaman etiketlerini okur.
- Aktif söz satırını büyük biçimde gösterir.

## Derleme

```bash
cd iPad1Karaoke-v0.1
rm -rf .theos packages
FINALPACKAGE=1 make package
```

## Cihaza gönderme

```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    packages/com.olap.ipad1karaoke_0.1.0_iphoneos-arm.deb \
    root@IPAD_IP:/var/mobile/
```

Cihazda:

```bash
dpkg -i /var/mobile/com.olap.ipad1karaoke_0.1.0_iphoneos-arm.deb
uicache
killall -9 SpringBoard
```

## Telif notu

Test MP3 dosyası kullanıcı tarafından sağlanmıştır. Herkese açık GitHub deposuna eklemeyin.
Gerçek sözler için aynı isimli `CRUSH-Karaoke.lrc` dosyasını yerel olarak düzenleyin.
