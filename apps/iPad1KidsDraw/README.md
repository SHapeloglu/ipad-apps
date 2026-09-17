# KidsDraw for iPad 1

Çocuklar için hafif çizim uygulaması.

## Hedef platform
- iPad 1
- iOS 5.1.1
- armv7
- 256 MB RAM
- Objective-C
- Theos
- legacy iPhoneOS 6.1 SDK
- non-ARC / MRC

## v0.1 özellikleri
- Parmakla çizim
- 7 renk
- 3 fırça kalınlığı
- Silgi
- Tuvali temizleme
- Fotoğraflar'a kaydetme
- Yatay kullanım (büyük çocuk butonları için)

## Build
```bash
make clean
FINALPACKAGE=1 make package
```

## Kurulum örneği
```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    packages/com.olap.kidsdraw_0.1.0_iphoneos-arm.deb \
    root@IPAD_IP:/var/mobile/

ssh root@IPAD_IP
dpkg -i /var/mobile/com.olap.kidsdraw_0.1.0_iphoneos-arm.deb
uicache
killall SpringBoard
```

## Not
Bu ilk sürüm bilinçli olarak katmanlar, filtreler, undo geçmişi ve büyük bitmap işleme
gibi RAM tüketen özellikleri içermez.
