# OTURUM

## Güncel durum

Proje: `iPad1Terminal`

Hedeflenen güncel derleme:

```text
0.2.1-alpha1
```

Platform:

```text
iPad 1
iOS 5.1.1
armv7
256 MB RAM
jailbreak
Objective-C / MRC
Theos
```

Çalışan derleme hedefi:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

---

## Tamamlananlar

### Proje başlangıcı

- Theos uygulama iskeleti
- yalnız iPad uygulama yapılandırması
- armv7 hedefi
- iOS 5.1 dağıtım hedefi
- MRC / ARC yok
- Ana ekran
- Yerel Terminal ekranı

### PTY / yerel kabuk

- POSIX PTY ayırma
- `posix_openpt`
- `grantpt`
- `unlockpt`
- `ptsname`
- `fork`
- `setsid`
- slave PTY açma
- stdin/stdout/stderr `dup2`
- `/bin/sh -i`
- başlangıç dizini `/var/mobile`
- PTY arka plan okuyucu iş parçacığı
- `select()` + `read()`
- ana iş parçacığında arayüze teslim
- PTY yazma API'si
- `TIOCSWINSZ` ile PTY yeniden boyutlandırma
- süreç temizliği
- sınırlı UTF-8 kuyruk tamponu
- sınırlı terminal geri kaydırma geçmişi

### Gerçek cihaz doğrulaması

Gerçek iPad 1 testi şunları kanıtladı:

- uygulama açılıyor
- Yerel Terminal açılıyor
- PTY oluşturma çalışıyor
- kabuk başlıyor
- istem görünüyor
- çıktı ekrana ulaşıyor

### Terminal arayüzü v0.2

- görünür komut `UITextField`'ı kaldırıldı
- doğrudan terminal klavye yakalama eklendi
- temel ANSI ayrıştırıcı eklendi
- ham `[K` sorunu CSI filtrelemeyle ele alındı
- temel ekran temizleme eylemi
- özel terminal tuşları eklendi

### v0.2.1 girdi düzeltmeleri hazırlandı

- Unicode destekli varsayılan klavye
- Türkçe girdi yolu açıldı
- `VERASE = 0x7F`
- Backspace DEL uyumu
- yardımcı satır `inputAccessoryView`'a taşındı
- iOS 5'te olmayan `UITextView.selectable` kaldırıldı

---

## Önemli test geçmişi

### Derleme sorunu 1

`UIReturnKeyReturn` geçersizdi.

Şununla düzeltildi:

```objc
UIReturnKeyDefault
```

### Derleme sorunu 2

`UITextAlignmentCenter`, yeni SDK başlıklarında hata sayılan bir enum dönüşüm uyarısına yol açtı.

Eski sürüm uyumluluğu için çözüldü.

### Bağlayıcı sorunu

Şunu kullanmak:

```make
TARGET = iphone:clang:9.3:5.1
```

simülatör `.tbd` uyarılarına ve şuna yol açtı:

```text
ld: file not found: /usr/lib/system/liblaunch.dylib for architecture armv7
```

Şuna geçilerek çözüldü:

```make
TARGET = iphone:clang:6.1:5.1
```

iPhoneOS6.1 SDK şunu içerir:

```text
/usr/lib/system/liblaunch.dylib
```

### Derleme sorunu 3

`UITextView.selectable` iOS 5.1.1'de yok.

Satır kaldırıldı.

---

## Gerçek cihaz arayüz bulguları

v0.1 ekran görüntüsü ham ANSI metni gösterdi:

```text
[Ksh-4.0$
```

v0.2 ekran görüntüsü istem gösteriminin iyileştiğini gösterdi, ancak:

- Türkçe karakterler yazılamıyordu
- Backspace silmiyordu
- yardımcı tuş çubuğu yazılım klavyesinin arkasında kalıyordu

v0.2.1'in nedenleri bunlar.

---

## Kararlar

1. Yerel terminal girdisi kararlı olmadan SSH'e başlama.
2. Başlangıçta SSH kriptografisini uygulama içinde yazma.
3. Gelecekteki SSH, kurulu `ssh` ikilisini PTY altında çalıştırmalı.
4. Ciddi uzak kabuk kullanımından önce tam ANSI/VT100 ekran tamponu çalışması gelir.
5. Geri kaydırma geçmişini sınırlı tut.
6. MRC'yi koru.
7. Doğrulanmış bir uyumluluk nedeni gerektirmedikçe SDK 6.1 / dağıtım hedefi 5.1'i koru.
8. iOS 5.1.1'de bulunmayan yeni UIKit özelliklerini kullanma.
9. Ağır bağımlılıklar ekleme.
10. Uygulamayı terminal/SSH sorumluluklarına odaklı tut.

---

## Bilinen sorunlar

- v0.2.1 düzeltmeleri, daha sonraki bir kayıtla geçersiz kılınmadıkça hâlâ son donanım doğrulamasını bekliyor.
- ANSI ayrıştırıcı gerçek bir terminal ekran öykünücüsü değil.
- imleç satır/sütun modeli henüz yok.
- `vim`, `nano`, `top`, `less`, `htop` henüz kabul ölçütü değil.
- SSH yok.
- bağlantı profilleri yok.

---

## Hemen yapılacak sonraki adım

`0.2.1-alpha1`'i derle ve kur.

Uygulama içinde test et:

```text
Türkçe: ğüşiöç İĞÜŞÖÇ
```

Enter'dan önce Backspace'i test et.

Yardımcı tuşların klavyenin üstünde göründüğünü doğrula:

```text
Esc | Ctrl+C | Tab | < | ^ | v | > | ~ | |
```

Ardından test et:

```bash
pwd
whoami
ls -la
clear
```

Hepsi geçerse:

**sonraki uygulama aşaması = gerçek ANSI/VT100 ekran tamponu ve imleç modeli.**

Doğrudan SSH'e atlama.
