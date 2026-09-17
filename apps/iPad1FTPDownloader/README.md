# iPad 1 FTP Client v1.2

Hedef: iPad 1, iOS 5.1.1, ARMv7, jailbreak, Theos.

## Yeni özellikler
- Kayıtlı FTP sunucuları
- FTP upload
- Dosya/boş klasör silme
- Dosya/klasör yeniden adlandırma
- Yeni klasör oluşturma
- Download/upload progress bar
- Yüzde ve KB/s / MB/s göstergesi
- KB / MB / GB dosya boyutları
- v1.1 klasör gezme ve dokunarak indirme korunur

## Kullanım
- Dosyaya dokun: indir
- Klasöre dokun: klasöre gir
- Sağdaki mavi ayrıntı düğmesi: yeniden adlandır
- Satırı sola kaydır: sil
- `+ Klasör`: sunucuda klasör oluştur
- `Yükle`: `/var/mobile/Media/iPad1FTPDownloads/` içindeki bir dosyayı mevcut FTP klasörüne gönder
- `Kaydet`: mevcut FTP bağlantısını profil olarak kaydet
- `Sunucular`: kayıtlı profilden bağlan

## Derleme
```bash
cd ~/projects/ipad1ftp/iPad1FTPDownloader_v1.2
make clean
make package FINALPACKAGE=1
```

Beklenen paket:
`packages/com.olap.ipad1ftpdownloader_1.2.0_iphoneos-arm.deb`

## iPad'e gönderme
Güncel iPad IP adresini kullan. Örnek:
```bash
scp -o HostKeyAlgorithms=+ssh-rsa packages/com.olap.ipad1ftpdownloader_1.2.0_iphoneos-arm.deb root@192.168.1.2:/var/mobile/
```

## Kurulum
```bash
ssh -o HostKeyAlgorithms=+ssh-rsa root@192.168.1.2
dpkg -i /var/mobile/com.olap.ipad1ftpdownloader_1.2.0_iphoneos-arm.deb
su mobile -c "/usr/bin/uicache"
killall SpringBoard
```

## Not
Bu sürüm klasik FTP içindir. SFTP/FTPS henüz eklenmedi. Silme/rename/yeni klasör işlemleri standart FTP komutları `DELE`, `RMD`, `RNFR/RNTO`, `MKD` ile yapılır; sunucu hesabında gerekli izinler bulunmalıdır.
