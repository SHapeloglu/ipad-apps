# iPad 1 FTP Downloader

Legacy iPad 1 / iOS 5.1.1 için hafif FTP dosya indirme uygulaması.

## Hedef
- iPad 1
- iOS 5.1.1
- ARMv7
- Jailbreak
- Theos
- Objective-C / UIKit / CFNetwork
- ARC kapalı

## Özellikler
- FTP sunucu/IP
- Port
- Kullanıcı adı
- Şifre
- Uzak dosya yolu
- Yerel dosya adı
- İndirilen byte/KB/MB göstergesi
- Dosyaları `/var/mobile/Media/iPad1FTPDownloads/` altına kaydeder

## Build

```bash
cd ~/projects/ipad1ftp/iPad1FTPDownloader
make clean
make package
```

Paket `packages/` altında oluşur.

## Kurulum

`.deb` dosyasını iPad'e örneğin `/var/mobile/` altına kopyala:

```bash
ssh root@IPAD_IP
dpkg -i /var/mobile/com.olap.ipad1ftpdownloader_1.0.0_iphoneos-arm.deb
killall SpringBoard
```

## Kullanım örneği

- Sunucu: `95.111.242.96`
- Port: `21`
- Kullanıcı: `ftpuser`
- Şifre: `********`
- Uzak yol: `/files/movie.mp4`
- Yerel ad: `movie.mp4`

İndirilen dosya:

`/var/mobile/Media/iPad1FTPDownloads/movie.mp4`

## Notlar

Bu ilk sürüm klasik FTP içindir. SFTP, FTPS, klasör listeleme, pause/resume ve indirme kuyruğu bu sürümde yoktur.
