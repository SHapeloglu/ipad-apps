# iPad1Terminal

Jailbreak'li **iOS 5.1.1 çalıştıran iPad 1** için hafif bir yerel kabuk ve SSH terminali projesi.

## Durum

Güncel geliştirme hattı:

```text
0.2.x alpha
```

Yerel Terminal PTY'si ve kabuk gerçek iPad 1 donanımında zaten gösterildi.

SSH eklenmeden önceki güncel odak terminal girdisinin doğruluğu ve ANSI/VT100 davranışıdır.

---

## Hedefler

- gerçek yerel terminal
- PTY destekli kabuk
- UTF-8 / Türkçe girdi ve çıktı
- terminale özgü klavye kontrolleri
- sınırlı RAM kullanımı
- kullanılabilir ANSI/VT100 terminal öykünmesi
- daha sonra SSH desteği
- daha sonra kayıtlı SSH profilleri
- hafif iPad1Files entegrasyonu

---

## Platform

```text
iPad 1
iOS 5.1.1
armv7
256 MB RAM
jailbreak
Theos
Objective-C
MRC / non-ARC
UIKit / Foundation
```

Güncel derleme yapılandırması:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

---

## Güncel mimari

```text
iOS keyboard
    |
TerminalInputView
    |
TerminalViewController
    |
TerminalANSIParser
    |
LocalTerminalSession
    |
PTY
    |
/bin/sh -i
```

SSH daha sonra aynı terminal sunum katmanını yeniden kullanacak.

---

## Bilinen güncel durum

Gerçek donanımda çalışanlar:

- uygulama açılışı
- Yerel Terminal'in açılması
- PTY ayırma
- `/bin/sh -i`
- kabuk istemi (prompt)
- terminal çıktısı
- sınırlı geri kaydırma geçmişi
- terminal yeniden boyutlandırma

Yakın zamanda ele alınanlar:

- ham `[K` ANSI kalıntıları
- doğrudan terminal klavye girdisi
- Türkçe klavye girdi yolu
- Backspace / PTY silme ayarı uyumu
- yardımcı tuş satırının yerleşimi

Belirleyici güncel durum için bkz.:

```text
PROJECT_CONTEXT.md
SESSION.md
```

---

## Derleme

```bash
make clean
make package
```

Üretilen paket şurada olur:

```text
packages/
```

---

## Geliştirme kuralı

Yerel Terminal ve ANSI/VT100 kilometre taşları gerçek iPad 1'de kararlı olmadan SSH'e başlama.

---

## Dokümantasyon

Yeni bir geliştirme sohbeti veya katkıda bulunan kişi için okuma sırası:

1. `PROJECT_CONTEXT.md`
2. `SESSION.md`
3. `ARCHITECTURE.md`
4. `TASKS.md`
5. `TESTING.md`
6. `INTEGRATION.md`
7. `AGENTS.md`

Doğru devam noktası `SESSION.md` içindeki "Hemen yapılacak sonraki adım" bölümüdür.
