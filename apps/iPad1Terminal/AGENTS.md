# AGENTS

## Zorunlu ilk okuma

Kodu değiştirmeden önce şu sırayla oku:

1. `PROJECT_CONTEXT.md`
2. `SESSION.md`
3. `ARCHITECTURE.md`
4. `TASKS.md`
5. `TESTING.md`
6. `INTEGRATION.md`
7. `README.md`

`PROJECT_CONTEXT.md` kalıcı proje kısıtlarını içerir.

`SESSION.md` en son gerçek durumu ve hemen yapılacak sonraki adımı içerir.

---

## Değiştirilemez kısıtlar

Bunları asla sessizce değiştirme:

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

Swift yok.

Güncel API'ye geçiş yok.

WebView tabanlı terminal yok.

Açık onay olmadan ağır bağımlılık eklenmez.

---

## Güncel SDK kuralı

Daha sonra belgelenmiş bir karar değiştirmedikçe şunu kullan:

```make
TARGET = iphone:clang:6.1:5.1
```

Simülatör `.tbd` / armv7 bağlayıcı sorunları üreten 9.3 SDK hedefine geri dönme.

---

## Güncel aşama kuralı

`SESSION.md` ve `TASKS.md`'de anlatılan güncel Yerel Terminal/girdi ve ANSI ekran tamponu kilometre taşları tamamlanmadan SSH'e başlama.

Kullanıcı açıkça yalnızca ince bir SSH başlatıcı değil, gerçek bir terminal uygulaması istiyor.

---

## Kod organizasyonu

Sorumlulukları ayrı tut:

```text
TerminalViewController
TerminalInputView
TerminalANSIParser
LocalTerminalSession
future TerminalScreen
future SSHSession
```

Tüm mantığı tek bir controller'a koyma.

---

## MRC kuralları

- her `alloc/init`, `copy`, `retain` için sahiplik açık olmalı
- sahip olunan ivar'ları `dealloc`'ta serbest bırak
- bu eski mimaride delegate'ler genelde `assign` olmalı
- retain döngülerinden kaçın
- uzun süren arka plan döngülerinde autorelease pool kullan

---

## Bellek kuralları

iPad 1'de 256 MB RAM var.

Gerekenler:

- sınırlı geri kaydırma geçmişi (scrollback)
- sınırlı ayrıştırıcı durumu
- sınırlı ekran tamponu
- küçük okuma tamponları
- sınırsız dizi/metinlerden kaçın
- varsayılan olarak birden fazla terminal oturumundan kaçın
- pahalı animasyonlu arayüz yok

---

## Uyumluluk kuralları

Bir API'nin iOS 5.1.1'de var olduğunu asla varsayma.

Daha önce karşılaşılan örnekler:

- `UITextView.selectable` mevcut değil
- yeni SDK enum tiplemesi hata sayılan uyarılar üretebiliyor

Güncel bir SDK başlığı derleniyor ama çalışma zamanı desteği belirsizse, kullanmadan önce iOS 5'te bulunduğunu doğrula.

---

## Terminal doğruluğu

ANSI davranışını tüm kaçış kodlarını kalıcı olarak silerek "düzeltme".

Güncel hafif ayrıştırıcı geçicidir.

Hedef, gerçek ve sınırlı bir terminal ekran modelidir.

---

## Güvenlik

Asla:

- şifreleri günlüğe yazma
- özel anahtarları günlüğe yazma
- SSH şifrelerini plist içinde düz metin saklama
- URL scheme'leri üzerinden keyfi harici komut çalıştırmaya izin verme

---

## Doküman güncelleme kuralı

Anlamlı bir kodlama/test oturumundan sonra güncelle:

- `SESSION.md`
- testler değiştiyse `TESTING.md`
- tasarım değiştiyse `ARCHITECTURE.md`
- yalnızca kalıcı proje düzeyi kararlar için `PROJECT_CONTEXT.md`
- `TASKS.md`

`SESSION.md` her zaman açık bir şekilde şu bölümle bitmelidir:

```text
Hemen yapılacak sonraki adım
```

böylece yeni bir sohbet tahmin yürütmeden devam edebilir.

---

## Git kuralı

Push'tan önce:

```bash
git status -sb
git diff --check
```

Commit etme:

- `.theos/`
- üretilen paket derleme klasörleri
- geçici dosyalar
- şifreler
- özel anahtarlar

Kaynak kodu ve proje dokümantasyonunu commit et.

Üretilen `.deb` paketleri yalnızca açıkça istenirse commit edilmelidir.

---

## Geliştirme önceliği

```text
stability
compatibility
terminal correctness
low RAM
usability
SSH
advanced features
```

(kararlılık → uyumluluk → terminal doğruluğu → düşük RAM → kullanılabilirlik → SSH → gelişmiş özellikler)
