# MİMARİ

## Genel bakış

`iPad1Terminal`, özellikle iOS 5.1.1 çalıştıran jailbreak'li bir iPad 1 için tasarlanmış yerel (native) UIKit terminal uygulamasıdır.

Mimari şunları ayırır:

- terminal arayüzü
- klavye girdisi
- ANSI ayrıştırma
- terminal oturumu
- PTY / süreç yönetimi

SSH daha sonra aynı terminal/PTY sunum katmanını yeniden kullanacak.

---

## Platform sözleşmesi

```text
iPad 1
iOS 5.1.1
armv7
256 MB RAM
Theos
Objective-C
non-ARC / MRC
UIKit / Foundation
```

Güncel çalışan Theos hedefi:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

---

## Güncel bileşen modeli

```text
AppDelegate
    |
    v
HomeViewController
    |
    v
TerminalViewController
    |
    +----------------------+
    |                      |
    v                      v
TerminalInputView     TerminalANSIParser
    |                      |
    +----------+-----------+
               |
               v
      LocalTerminalSession
               |
               v
           PTY master
               |
               v
           PTY slave
               |
               v
           /bin/sh -i
```

---

## AppDelegate

Sorumlulukları:

- pencereyi oluşturmak
- navigation controller oluşturmak
- `HomeViewController`'ı göstermek

En küçük haliyle kalmalı.

---

## HomeViewController

Güncel rolü:

- `Local Terminal`'i göstermek
- daha sonra SSH bağlantı profillerini göstermek

Buraya PTY mantığı koyma.

---

## TerminalViewController

Sorumlulukları:

- terminal görüntüsü
- terminal girdisini yönlendirme
- özel tuş işleme
- ANSI çıktısını yönlendirme
- geri kaydırma geçmişini gösterme
- terminal yeniden boyutlandırma hesabı
- oturum yaşam döngüsü koordinasyonu

Düşük seviye PTY ayırmayı doğrudan yapmamalı.

---

## TerminalInputView

Amaç:

Görünür beyaz bir form alanı olmadan doğrudan yazılım klavyesi girdisi sağlamak.

Uyguladığı protokol:

```objc
UIKeyInput
```

Önemli kararlar:

- first responder olabilmeli
- `UIKeyboardTypeDefault` kullanır
- Türkçe girdi gerektiği için yalnız ASCII klavyeyi zorlamamalı
- `deleteBackward` PTY silme girdisine eşlenir
- özel terminal yardımcı çubuğunu `inputAccessoryView` olarak döndürür

---

## Özel terminal tuş satırı

Hedef tuşlar:

```text
Esc
Ctrl+C
Tab
Left
Up
Down
Right
~
|
```

Daha sonra eklenebilecekler:

```text
Ctrl modifier state
/
\
-
_
:
```

Çubuğu ağır veya görsel olarak karmaşık yapma.

---

## LocalTerminalSession

Sorumlulukları:

- PTY ayırmak
- alt süreç oluşturmak
- slave terminali yapılandırmak
- kabuğu başlatmak
- çıktıyı okumak
- girdiyi yazmak
- terminali yeniden boyutlandırmak
- alt süreci temiz şekilde sonlandırmak

Güncel PTY stratejisi:

```text
posix_openpt
grantpt
unlockpt
ptsname
fork
setsid
open(slave)
dup2
execl
```

Uygulama bilinçli olarak `forkpty()`'yi zorunlu bağımlılık yapmaktan kaçınır.

---

## PTY termios

Backspace davranışı şunu kullanır:

```text
DEL = 0x7F
```

Slave PTY şu şekilde yapılandırılır:

```c
tio.c_cc[VERASE] = 0x7F;
```

Bu, `TerminalInputView`'un Backspace davranışıyla eşleşmelidir.

---

## Kabuk

Güncel kabuk başlatma:

```text
/bin/sh -i
```

Yedek olarak denenebilecek:

```text
/bin/bash -i
```

Başlangıç çalışma dizini:

```text
/var/mobile
```

Ortam değişkenleri:

```text
TERM=vt100
HOME=/var/mobile
SHELL=/bin/sh
```

Kabuk davranışının güncel bash ile aynı olduğunu varsayma.

---

## PTY çıktı iş parçacığı

Ana arayüz iş parçacığı PTY okumalarında asla bloklanmamalıdır.

Güncel model:

```text
NSThread
  |
  v
select()
  |
  v
read()
  |
  v
UTF-8 byte buffering
  |
  v
performSelectorOnMainThread
```

Bu bilinçli olarak eski iOS ile uyumludur.

---

## UTF-8 işleme

PTY okumaları bayt odaklıdır.

Çok baytlı bir UTF-8 karakteri iki `read()` çağrısı arasında bölünebilir.

Bu yüzden oturum tamamlanmamış UTF-8 kuyruk baytlarını tutar ve bir sonraki okumayla birleştirir.

Tamponlar sınırlı kalmalıdır.

---

## TerminalANSIParser

Güncel ayrıştırıcı tam bir terminal öykünücüsü değil, geçici bir uyumluluk katmanıdır.

Güncel sorumlulukları:

- ham `ESC[K` metninin görünmesini engellemek
- yaygın CSI dizilerini tüketmek
- temel ekran temizleme dizilerini algılamak
- SGR kodlarını harfiyen basmak yerine tüketmek

Güncel hedef dışı:

- doğru imleç/durum görüntüleme

---

## Gereken sonraki mimari: terminal ekran tamponu

Bir sonraki büyük terminal motoru aşaması gerçek bir ekran modeli eklemelidir.

Önerilen gelecekteki sınıflar:

```text
TerminalScreen
TerminalCell
TerminalCursorState
TerminalANSIParser
TerminalRenderer
```

Olası kavramsal model:

```text
PTY bytes
   |
   v
ANSI parser
   |
   v
TerminalScreen [rows x columns]
   |
   +--> cursor row/column
   +--> character cells
   +--> attributes
   |
   v
UIKit renderer
```

Ekran tamponu sabit boyutlu veya sıkı şekilde sınırlı olmalıdır.

---

## ANSI/VT100 hedef alt kümesi

SSH olgun sayılmadan önce en az şunlar desteklenmeli:

- CR
- LF
- BS
- TAB
- imleç yukarı/aşağı/sol/sağ
- imleç konumu
- satırda silme
- ekranda silme
- ekranı temizleme
- imleci kaydet/geri yükle
- temel SGR sıfırlama
- temel ön plan renkleri
- terminal yeniden boyutlandırma

Kabul ölçütü zamanla şunları içermeli:

```text
clear
less
nano
top
```

Temel model kararlı olunca `vim` gelebilir.

---

## SSH mimarisi

Gelecek hedef:

```text
TerminalViewController
        |
        v
SSHSession
        |
        v
PTY
        |
        v
installed ssh executable
        |
        v
remote host
```

SSH için terminal görüntülemeyi çoğaltma.

Yerel ve SSH oturumları aynı terminal arayüzünü paylaşmalıdır.

---

## SSH profil modeli

Gelecekteki alanlar:

```text
Name
Host
Port
Username
Authentication mode
Optional identity file
```

(Ad, Host, Port, Kullanıcı adı, Kimlik doğrulama modu, İsteğe bağlı kimlik dosyası)

Şifreler düz metin plist dosyalarında saklanmamalıdır.

İlk SSH sürümü, şifre istemini doğrudan `ssh` sürecinin göstermesine izin verebilir.

---

## iPad1Files entegrasyonu

Gelecekteki hafif entegrasyon:

```text
/var/mobile/Media/iPad1Files/
```

Olası hızlı kısayol:

```text
Files
```

bu şunu gönderir:

```bash
cd /var/mobile/Media/iPad1Files/
```

iPad1Files kaynak kodunu bu projeye kopyalama.

---

## Bellek politikası

Cihaz RAM'i:

```text
256 MB
```

Kurallar:

- sınırlı geri kaydırma geçmişi
- sabit/sınırlı ekran tamponu
- sabit PTY okuma tamponu
- sınırsız geçmiş yok
- WebView terminal yok
- büyük görsel varlıklar yok
- başlangıçta birden fazla aktif oturumdan kaçın
- uzun süren arka plan döngülerinde autorelease pool'ları boşalt

---

## Yaşam döngüsü

Terminal ekranı kapanınca:

- delegate bağlantısını kes
- gerekiyorsa alt süreci sonlandır
- PTY tanımlayıcısını kapat
- `waitpid` çağır
- zombi süreçlerden kaçın

Arka planda kalıcılık v1 gereksinimi değildir.

---

## Güvenlik

Asla günlüğe yazma:

- şifreler
- özel anahtarlar
- hassas terminal girdisi

SSH özel anahtarları uygun izinlerle dosya olarak kalmalıdır.

---

## Mimari öncelikler

```text
correctness
compatibility
bounded memory
simple ownership
testability
usability
```

(doğruluk → uyumluluk → sınırlı bellek → basit sahiplik → test edilebilirlik → kullanılabilirlik)

iOS 5 uyumluluğunu azaltan güncel soyutlamalardan kaçın.
