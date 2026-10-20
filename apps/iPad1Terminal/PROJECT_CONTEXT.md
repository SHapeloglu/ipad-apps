# iPad1Terminal — Proje Bağlamı

## Amaç

`iPad1Terminal`, jailbreak'li bir iPad 1 için hafif bir terminal uygulamasıdır.

Uygulamanın sağlaması amaçlananlar:

1. Sözde terminal (PTY) üzerinden iPad'de gerçek bir yerel kabuk.
2. Daha sonraki bir aşamada uzak Unix/Linux sistemlere SSH erişimi.
3. Özellikle iPad 1 / iOS 5.1.1 / 256 MB RAM için tasarlanmış bir terminal arayüzü.

SSH, `iPad1Terminal`'in bir özelliğidir; ayrı bir uygulama değildir.

---

## Değiştirilemez platform kısıtları

Bu kısıtlar kullanıcının açık onayı olmadan asla değiştirilmemelidir:

- Cihaz: iPad 1
- iOS: 5.1.1
- Mimari: armv7
- RAM: 256 MB
- Jailbreak ortamı
- Theos
- Objective-C
- non-ARC / MRC
- UIKit / Foundation
- Swift yok
- yalnızca yeni iOS'ta olan API'ler yok
- WebView tabanlı terminal yok
- ağır bağımlılık yığını yok

Güncel çalışan derleme hedefi:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

iPhoneOS9.3 SDK, simülatör `.tbd` dosyaları ve eksik armv7 `liblaunch.dylib` ile ilgili bağlayıcı sorunlarına yol açtı. Bu projede çalışan SDK iPhoneOS6.1 SDK'dır.

---

## Repo

GitHub reposu:

```text
https://github.com/SHapeloglu/iPad1Terminal
```

Varsayılan dal:

```text
main
```

Bu bağlam dosyası oluşturulduğunda repo vardı ama henüz boştu.

---

## Güncel geliştirme durumu

Hedeflenen güncel sürüm:

```text
0.2.1-alpha1
```

### Gerçek cihazda zaten ulaşılan kilometre taşı

Gerçek iPad 1'de kanıtlananlar:

- uygulama kuruluyor ve açılıyor
- `Local Terminal` ekranı açılıyor
- PTY oluşturma çalışıyor
- alt kabuk başlıyor
- `/bin/sh -i` istemi görünüyor
- PTY çıktısı UIKit terminal görünümüne ulaşıyor
- yerel kabuk gerçek cihazda çalışıyor

İlk ekran görüntüsünde şu vardı:

```text
sh-4.0$
[Ksh-4.0$
```

`[K` metni, ham ANSI `ESC[K` dizilerinin yorumlanmak yerine gösterilmesinden kaynaklanıyordu.

### v0.2 değişiklikleri

v0.2 şunları getirdi:

- terminale doğrudan klavye girdisi
- görünür beyaz komut `UITextField`'ının kaldırılması
- hafif ANSI filtreleme
- ham `ESC[K` / CSI metninin bastırılması
- temel `ESC[2J` ekran temizleme
- özel terminal tuş satırı
- sınırlı geri kaydırma geçmişi
- UTF-8 çıktı tamponlama
- `TIOCSWINSZ` ile PTY yeniden boyutlandırma

### Gerçek cihazda v0.2 bulguları

v0.2 gerçek cihaz testi şunları ortaya çıkardı:

1. Türkçe karakterler yazılamıyordu.
2. Backspace çalışmıyordu.
3. Yardımcı tuş satırı yazılım klavyesinin arkasında kalıyordu.

Ekran görüntüsü kabuğun kendisinin hâlâ çalıştığını doğruladı.

### Hazırlanan v0.2.1 düzeltmeleri

`0.2.1-alpha1` için hazırlanan düzeltmeler:

- `UIKeyboardTypeASCIICapable` -> `UIKeyboardTypeDefault`
- Türkçe/Unicode girdiye izin verildi
- PTY slave `VERASE` açıkça `0x7F` yapıldı
- Backspace DEL `0x7F` göndermeye devam ediyor
- özel terminal yardımcı satırı `inputAccessoryView`'a taşındı
- `UITextView.selectable` kullanılmayarak iOS 5 uyumluluğu korundu

Bu v0.2.1 girdi düzeltmeleri, daha sonraki bir SESSION kaydı aksini söylemedikçe hâlâ son yerel derleme/kurulum/cihaz doğrulamasını bekliyor.

---

## Güncel mimari

```text
iOS keyboard
    |
    v
TerminalInputView (UIKeyInput)
    |
    +------------------+
    |                  |
    v                  v
normal input      helper key row
                       |
                       v
                Esc / Ctrl+C / Tab
                arrows / ~ / |
    |
    v
TerminalViewController
    |
    +--> TerminalANSIParser
    |
    v
LocalTerminalSession
    |
    v
PTY master <--> PTY slave <--> /bin/sh -i
```

---

## Önemli mimari kararlar

### 1. Önce PTY

SSH çalışmasına başlamadan önce yerel terminal kararlı olmalı.

### 2. SSH PTY katmanını yeniden kullanacak

SSH protokol yığınını sıfırdan yazma.

Tercih edilen gelecek mimari:

```text
Terminal UI
   |
   v
PTY
   |
   v
installed ssh binary
   |
   v
remote server
```

### 3. Ciddi SSH kullanımından önce ANSI/VT100

Güncel ANSI ayrıştırıcı bilinçli olarak eksiktir.

Yaygın ham CSI dizilerini bastırabilir ama henüz gerçek bir terminal ekran modeli değildir.

Terminali şunlar için yeterince olgun saymadan önce:

```text
vim
nano
top
htop
less
```

gerçek bir terminal ekran tamponu ve imleç modeli yaz.

### 4. Bellek sınırlı kalmalı

iPad 1'de yalnızca 256 MB RAM var.

İzin verme:

- sınırsız terminal geçmişi
- sınırsız metin ekleme
- devasa terminal tamponları
- varsayılan olarak birden fazla ağır terminal oturumu

Güncel geri kaydırma geçmişi sınırlıdır.

### 5. Yalnızca MRC

Tüm Objective-C bellek sahipliği manuel retain/release kurallarına uymalıdır.

---

## Bilinen güncel sınırlamalar

- ANSI/VT100 desteği eksik.
- İmleç hareketi henüz doğru modellenmiyor.
- Tam ekran terminal uygulamaları henüz desteklenen bir kilometre taşı değil.
- SSH henüz yok.
- SSH profilleri henüz yok.
- SSH anahtarları henüz yok.
- birden fazla terminal oturumu yok.
- SFTP/SCP arayüzü yok.
- tema sistemi bilinçli olarak kapsam dışı.
- Unicode girdi düzeltmesi, daha sonra belgelenmedikçe hâlâ son donanım doğrulamasını bekliyor.

---

## Ürün yönü

Hedef deneyim:

```text
MobileTerminal local-shell strength
        +
Prompt-style SSH usability
        +
iPad 1 / iOS 5.1.1 optimization
        +
iPad1Files integration
        =
iPad1Terminal
```

(MobileTerminal'in yerel kabuk gücü + Prompt tarzı SSH kullanılabilirliği + iPad 1 / iOS 5.1.1 optimizasyonu + iPad1Files entegrasyonu)

Güncel terminallerin özellik sayısının peşinden koşma.

Öncelikler:

```text
stability
> compatibility
> low RAM
> correct terminal behavior
> usability
> SSH
> advanced features
```

---

## Planlanan v1 yetenekleri

Hedef v1 kapsamı:

- Yerel Terminal
- kullanılabilir ANSI/VT100 alt kümesi
- UTF-8 / Türkçe girdi ve çıktı
- Esc / Ctrl / Tab / ok tuşları
- kopyala/yapıştır
- sınırlı geri kaydırma geçmişi
- dikey/yatay
- SSH
- kayıtlı SSH bağlantı profilleri
- SSH anahtarı kullanımı
- hızlı komutlar
- iPad1Files kısayolu

Açıkça onaylanmadıkça ilk v1 kapsamı dışında:

- Mosh
- Telnet
- SFTP arayüzü
- birden fazla eşzamanlı sekme
- temalar
- grafik sistem izleyici
- Web terminal
- gömülü güncel SSH kripto kütüphanesi

---

## Hemen yapılacak sonraki adım

SSH'e başlama.

Önce hazırlanan `0.2.1-alpha1` girdi düzeltmelerini gerçek iPad 1'de doğrula.

Derleme:

```bash
cd ~/projects/iPad1Terminal-v0.2.1-input-fix
make clean
make package
```

Üretilen paketi bu geliştirme oturumunda kullanılan güncel yerel ağ adresindeki iPad'e kur.

**iPad1Terminal -> Local Terminal** içinde test et:

```text
Türkçe: ğüşiöç İĞÜŞÖÇ
```

Return'e basmadan önce:

- birkaç karakteri Backspace ile sil
- tekrar yaz
- yardımcı tuşların iOS klavyesinin üstünde göründüğünü doğrula

Ardından doğrula:

```bash
pwd
whoami
ls -la
clear
```

Bir sonraki terminal motoru kilometre taşına ancak bu testler geçtikten sonra başlanmalı.

Bir sonraki büyük motor kilometre taşı SSH değil, şu olmalı:

```text
real ANSI/VT100 screen buffer + cursor model
```

(gerçek ANSI/VT100 ekran tamponu + imleç modeli)
