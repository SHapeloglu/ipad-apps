# GÖREVLER

## Aşama 0 — Proje başlangıcı

- [x] Theos uygulama iskeletini oluştur
- [x] Hedef iPad
- [x] armv7
- [x] iOS 5.1 dağıtım hedefi
- [x] non-ARC / MRC
- [x] Ana ekran
- [x] Yerel Terminal'e gezinme

---

## Aşama 1 — Yerel PTY

- [x] PTY master ayırma
- [x] `grantpt`
- [x] `unlockpt`
- [x] `ptsname`
- [x] `fork`
- [x] `setsid`
- [x] PTY slave açma
- [x] `dup2` stdin/stdout/stderr
- [x] `/bin/sh -i`
- [x] başlangıç `chdir("/var/mobile")`
- [x] arka planda PTY okuma
- [x] PTY yazma
- [x] süreç temizliği
- [x] `TIOCSWINSZ`
- [x] gerçek cihazda kabuk istemi doğrulandı

---

## Aşama 2 — Temel terminal girdisi/arayüzü

- [x] görünür beyaz komut alanını kaldır
- [x] doğrudan klavye yakalama
- [x] Enter -> PTY
- [x] Esc
- [x] Ctrl+C
- [x] Tab
- [x] ok tuşları
- [x] `~`
- [x] `|`
- [x] sınırlı geri kaydırma geçmişi
- [x] temizle düğmesi
- [x] yardımcı tuş çubuğu
- [x] iOS 5'teki `UITextView.selectable` uyumsuzluğu kaldırıldı
- [x] Unicode destekli klavye düzeltmesi hazırlandı
- [x] PTY `VERASE` düzeltmesi hazırlandı
- [x] yardımcı satır `inputAccessoryView` düzeltmesi hazırlandı
- [ ] gerçek cihazda Türkçe girdiyi doğrula
- [ ] gerçek cihazda Backspace'i doğrula
- [ ] gerçek cihazda yardımcı tuş satırının klavyenin üstünde olduğunu doğrula
- [ ] v0.2.1 girdi değişikliklerinden sonra döndürmeyi doğrula
- [ ] A-/A+ yazı boyutu kontrolleri ekle
- [ ] kopyala/yapıştırı iyileştir
- [ ] yeniden kullanılabilir Ctrl tuşu durumu yaz

---

## Aşama 3 — ANSI/VT100 ekran modeli

### Ayrıştırıcı

- [x] ham `ESC[K`'yi bastır
- [x] yaygın CSI dizilerini tüket
- [x] temel `ESC[2J` algılama
- [x] ham kodları basmak yerine SGR'yi tüket
- [ ] bölünmüş kaçış dizileri için ayrıştırıcı durum makinesi
- [ ] sayısal CSI parametreleri
- [ ] çoklu CSI parametreleri
- [ ] gereken yerlerde özel mod işleme

### Ekran tamponu

- [ ] sabit satır/sütun ekran modeli oluştur
- [ ] imleç satır/sütunu oluştur
- [ ] yazdırılabilir karakter ekleme
- [ ] CR
- [ ] LF
- [ ] BS
- [ ] TAB
- [ ] imleç yukarı
- [ ] imleç aşağı
- [ ] imleç sola
- [ ] imleç sağa
- [ ] imleç mutlak konumu
- [ ] satırda silme
- [ ] ekranda silme
- [ ] ekranı temizle
- [ ] kaydırma bölgesi veya en az kaydırma davranışı
- [ ] imleci kaydet
- [ ] imleci geri yükle
- [ ] temel öznitelikler
- [ ] temel ön plan renkleri

### Görüntüleyici

- [ ] ekran modelini verimli görüntüle
- [ ] her baytta dev metni baştan oluşturmaktan kaçın
- [ ] sabit bellek kullanımını koru
- [ ] görünür imleç
- [ ] dikey boyutlandırma
- [ ] yatay boyutlandırma
- [ ] `TIOCSWINSZ` sonrası yeniden çiz

### Komutlar/programlar

- [ ] `clear`
- [ ] `printf` ANSI testleri
- [ ] `less`
- [ ] `nano`
- [ ] `top`
- [ ] `vim` temel kullanım

---

## Aşama 4 — SSH

Aşama 2 donanım testleri geçmeden ve Aşama 3 ekran modeli kullanılabilir olmadan başlama.

### Keşif

- [ ] cihazda `ssh` çalıştırılabilir dosyasını bul
- [ ] SSH sürümünü kaydet
- [ ] desteklenen algoritmaları incele

### Oturum

- [ ] `SSHSession` oluştur
- [ ] `ssh`'i PTY altında başlat
- [ ] host
- [ ] port
- [ ] kullanıcı adı
- [ ] bağlan
- [ ] bağlantıyı kes
- [ ] host anahtarı istemi
- [ ] şifre istemi
- [ ] alt sürecin çıkışını işleme

### Profiller

- [ ] profil modeli
- [ ] profil ekle
- [ ] profili düzenle
- [ ] profili sil
- [ ] son kullanılan profil
- [ ] şifreyi düz metin saklama

### Kimlik doğrulama

- [ ] mevcut SSH anahtarını kullanma
- [ ] isteğe bağlı kimlik dosyası seçimi
- [ ] eski algoritma seçenekleri yalnızca gerçekten gerekirse

---

## Aşama 5 — Kullanılabilirlik

- [ ] hızlı komutlar
- [ ] komut geçmişi deneyimi
- [ ] iPad1Files kısayolu
- [ ] büyük metin yapıştırma güvenliği
- [ ] yazı boyutunun hatırlanması
- [ ] profillerin kalıcılığı
- [ ] yeniden bağlanma deneyimi
- [ ] yatayda tuş çubuğu yerleşimi

Önerilen hızlı komutlar:

```text
Disk       -> df -h
Processes  -> ps
Files      -> cd /var/mobile/Media/iPad1Files/
```

Çok fazla sabit kodlanmış komut ekleme.

---

## Aşama 6 — Kararlılık

- [ ] Yerel Terminal'i tekrar tekrar aç/kapat
- [ ] zombi süreç kontrolü
- [ ] PTY tanımlayıcı sızıntısı kontrolü
- [ ] bellek baskısı testi
- [ ] uzun çıktı testi
- [ ] büyük yapıştırma testi
- [ ] tekrar tekrar döndür
- [ ] arka plan/ön plan testi
- [ ] alt kabuk beklenmedik şekilde çıkıyor
- [ ] PTY okuma hatası
- [ ] uygulamanın bellek uyarısı davranışı

---

## Ertelenen / ilk v1 için planlanmayan

- [ ] birden fazla eşzamanlı terminal sekmesi
- [ ] SFTP grafik gezgini
- [ ] Mosh
- [ ] Telnet
- [ ] tema mağazası/sistemi
- [ ] gömülü Web terminal
- [ ] grafik izleme paneli

Bunlar uygulanmadan önce açık onay gerektirir.
