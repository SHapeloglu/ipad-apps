# CLAUDE

Bu repo, sıkı kısıtları olan eski bir iOS projesidir.

Değişiklik yapmadan önce `PROJECT_CONTEXT.md` ve `SESSION.md` dosyalarını oku.

## Kesin kısıtlar

```text
iPad 1
iOS 5.1.1
armv7
256 MB RAM
jailbreak
Theos
Objective-C
non-ARC / MRC
UIKit / Foundation
```

Dağıtım hedefini güncelleme.

Swift ekleme.

iOS 5.1.1'de bulunmayan iOS API'lerini kullanma.

WebView tabanlı terminal ekleme.

## Güncel derleme hedefi

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Bu bilinçli bir tercihtir.

iPhoneOS9.3 SDK yolu daha önce bu armv7 projesinde hatalı simülatör `.tbd` bağlayıcı davranışı üretti.

## Güncel proje aşaması

PTY / yerel kabuk gerçek iPad 1 donanımında zaten kanıtlandı.

Güncel çalışmanın odağı:

1. girdi doğruluğu
2. Türkçe/UTF-8 klavye girdisi
3. Backspace
4. yardımcı tuş arayüzü
5. ANSI/VT100 terminal doğruluğu

`SESSION.md` Yerel Terminal kilometre taşının geçtiğini söylemeden SSH'e atlama.

## Mimari

Bu kavramları ayrı tut:

```text
TerminalInputView
TerminalViewController
TerminalANSIParser
LocalTerminalSession
future TerminalScreen
future SSHSession
```

## Terminal yönü

Güncel ANSI ayrıştırıcı geçicidir.

İstenen bir sonraki büyük mimari:

```text
PTY bytes
-> ANSI parser
-> fixed-size terminal screen/cursor model
-> UIKit renderer
```

(PTY baytları → ANSI ayrıştırıcı → sabit boyutlu ekran/imleç modeli → UIKit görüntüleyici)

Terminal kaçış kodlarını hepsini silerek kalıcı olarak "çözme".

## Bellek

Her şey 256 MB RAM için tasarlanmalı.

Tüm geçmişler ve tamponlar sınırlı tutulmalı.

## MRC

Yalnızca manuel retain/release.

Dosyaları ARC'ye çevirme.

## Test

Belirleyici olan gerçek cihaz davranışıdır.

Başarılı derleme, bir API'nin iOS 5.1.1'de doğru çalıştığını kanıtlamaz.

Kod değişikliklerinden sonra `TESTING.md`'yi izle.

## Dokümantasyon

Oturum sonunda `SESSION.md`'yi, özellikle şu bölümü güncelle:

```text
Hemen yapılacak sonraki adım
```
