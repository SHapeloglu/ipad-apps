# iPad 1 FTP Downloader v1.1

iPad 1 / iOS 5.1.1 için FTP browser + downloader.

## v1.1
- FTP klasör listeleme
- Klasörlere dokunarak gezinme
- Üst klasöre çıkma
- Dosyaya dokunarak indirme
- KB/MB indirme göstergesi
- Kayıt: /var/mobile/Media/iPad1FTPDownloads/

## Derleme
```bash
cd ~/projects/ipad1ftp/iPad1FTPDownloader
make clean
make package FINALPACKAGE=1
```

## Kurulum
```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
packages/com.olap.ipad1ftpdownloader_1.1.0_iphoneos-arm.deb \
root@192.168.1.101:/var/mobile/
```

```bash
ssh -o HostKeyAlgorithms=+ssh-rsa root@192.168.1.101
dpkg -i /var/mobile/com.olap.ipad1ftpdownloader_1.1.0_iphoneos-arm.deb
su mobile -c "/usr/bin/uicache"
killall SpringBoard
```
