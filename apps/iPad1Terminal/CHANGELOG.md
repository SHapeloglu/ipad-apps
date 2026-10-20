# DEĞİŞİKLİK GÜNLÜĞÜ

## 0.2.1-alpha1 — hazırlandı

v0.2 gerçek cihaz testinden sonra hazırlanan girdi/arayüz düzeltmeleri:

- yalnız ASCII klavye yerine varsayılan/Unicode iOS klavyesine izin verildi
- Türkçe karakter girdi yolu açıldı
- PTY `VERASE` değeri DEL (`0x7F`) yapıldı
- Backspace, PTY silme yapılandırmasıyla uyumlu hale getirildi
- terminal yardımcı satırı klavyenin `inputAccessoryView`'una taşındı
- iOS 5 uyumluluğu korundu

Daha sonraki `SESSION.md` kayıtları aksini söylemedikçe donanım doğrulaması hâlâ gerekli.

---

## 0.2.0-alpha1

- ayrı beyaz komut giriş alanı kaldırıldı
- doğrudan klavye yakalama eklendi
- hafif ANSI/CSI filtreleme eklendi
- görünür `[K` terminal kalıntıları ele alındı
- temel ekran temizleme eklendi
- terminal yardımcı tuş arayüzü iyileştirildi
- sınırlı geri kaydırma geçmişi korundu
- PTY yeniden boyutlandırma desteği korundu

Gerçek cihaz bulguları:

- klavye yalnız ASCII olduğu için Türkçe girdi başarısızdı
- Backspace çalışmıyordu
- yardımcı çubuk klavyenin arkasında kalıyordu

---

## 0.1.0-alpha1

İlk Yerel Terminal prototipi:

- Theos iskeleti
- Ana ekran
- Yerel Terminal
- POSIX PTY
- fork/setsid/dup2/exec
- `/bin/sh -i`
- arka planda PTY okuyucu
- doğrudan PTY'ye yazma
- UTF-8 çıktı tamponlama
- sınırlı geri kaydırma geçmişi
- terminal yeniden boyutlandırma

Büyük kilometre taşı:

**gerçek iPad 1 etkileşimli bir kabuk istemini başarıyla gösterdi.**
