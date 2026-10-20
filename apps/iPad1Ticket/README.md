# iPad1Ticket v0.1

iPad 1 / iOS 5.1.1 (armv7) icin Theos + Objective-C etkinlik katilim dogrulama uygulamasi.

## Ozellikler
- QR/token dogrulama
- Uye adi ve sira/uye numarasi
- Etkinlik adi, tarihi ve konumu
- Katilim onaylandi / daha once okutuldu / gecersiz durumlari
- iOS 5.1.1 uyumlu non-ARC kod
- ZBarSDK varsa kamera ile QR; yoksa manuel token test modu
- v15 icin `checkin-mobile.php` API yamasi

## Ubuntu'ya kurulum
```bash
cd ~/projects
unzip iPad1Ticket_v0.1.zip
cd iPad1Ticket_v0.1
```

## API ayari
`APIClient.m` icinde su iki sabiti degistirin:
```objc
static NSString * const IP1APIURL = @"https://alanadiniz/api/checkin-mobile.php";
static NSString * const IP1APIToken = @"API_TOKEN";
```

Sunucuda `server-patch/checkin-mobile.php` dosyasini v15 ana dizinine `checkin-mobile.php` adi ile kopyalayin. Dosya mevcut `checkin.php` ile ayni seviyede durmalidir.

API token kaydinin scopes alaninda `checkin.write` bulunmalidir.

## Derleme
```bash
make clean package
```
Cihaza SSH/Theos kurulumunuz hazirsa:
```bash
make install
```

## QR kamera notu
Apple, iOS 5.1.1'de yerlesik QR decoder sunmuyor. Bu proje ZBarSDK basliklarini bulursa kamera tarayicisini otomatik derler. ZBar yoksa proje yine derlenir ve `Token Gir (Test)` ile tum API/check-in akisi test edilir.

## Guvenlik
- QR icindeki ham token SHA-256 hash ile sunucuda eslestirilir.
- API Bearer tokeninda `checkin.write` scope zorunludur.
- Tek kullanımlı QR ayni anda iki cihazdan okutulsa bile atomik `used_at IS NULL` guncellemesi ile ikinci giris reddedilir.
- Uretimde HTTPS kullanin.
