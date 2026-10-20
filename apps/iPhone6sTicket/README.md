# iPhone6sTicket v0.1

iPhone 6s icin Theos + Objective-C ile gelistirilen etkinlik QR katilim dogrulama uygulamasi.

## Mimari
- Native AVFoundation QR tarama
- ZBar bagimliligi yok
- QR -> token -> v15 check-in API
- Ad/soyad, sira no, etkinlik, tarih ve konum gosterimi
- `checked_in`, `already_used`, gecersiz QR durumlari
- Manuel token test ekrani

`AVCaptureMetadataOutput` eski SDK header'inda olmadigi icin runtime uzerinden kullanilir. iPhone 6s'in iOS surumlerinde API cihazda mevcuttur.

## Once iPhone'un iOS surumunu kontrol edin
SSH ile iPhone'a baglanip:

```sh
sw_vers
sysctl hw.machine
```

- iOS 9/10: varsayilan `Makefile` (armv7, eski 6.1 SDK ile build)
- iOS 11-15: `Makefile.arm64` gerekir ve Theos'a yeni iOS SDK eklenmelidir

## API ayari
`APIClient.m`:

```objc
static NSString * const IP1APIURL = @"https://SITENIZ.example/api/checkin-mobile.php";
static NSString * const IP1APIToken = @"BURAYA_CHECKIN_WRITE_API_TOKEN";
```

## Derleme - iOS 9/10

```bash
make clean
make package
```

## Derleme - iOS 11+

```bash
cp Makefile Makefile.legacy
cp Makefile.arm64 Makefile
make clean
make package
```
