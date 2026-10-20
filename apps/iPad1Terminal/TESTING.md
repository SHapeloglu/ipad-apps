# TEST

## Test ortamı

Birincil cihaz:

```text
iPad 1
iOS 5.1.1
armv7
jailbreak
256 MB RAM
```

Derleme ortamı:

```text
Theos
iPhoneOS6.1 SDK
deployment target 5.1
Objective-C MRC
```

---

## 1. Derleme testi

Çalıştır:

```bash
make clean
make package
```

Geçme ölçütleri:

- derleme hatası yok
- armv7 bağlayıcı hatası yok
- `.deb` üretildi
- iOS 5.1'in kullanımdan kalktığı uyarısı kabul edilebilir
- çalışan 6.1 SDK kullanılırken simülatör `.tbd` bağlayıcı uyarıları görünmemeli

---

## 2. Kurulum testi

Üretilen paketi normal jailbreak dağıtım akışıyla kur.

Geçme ölçütleri:

- `dpkg -i` başarılı
- `uicache` / SpringBoard yenilemesinden sonra simge görünüyor
- uygulama açılıyor

---

## 3. Yerel Terminal'in açılması

Aç:

```text
iPad1Terminal
-> Local Terminal
```

Geçme ölçütleri:

- siyah terminal ekranı görünüyor
- kabuk istemi görünüyor
- `[PTY ERROR]` yok
- uygulama çökmüyor

---

## 4. Temel kabuk komutları

Harici SSH kabuğunda değil, **iPad1Terminal'in kendisinde** çalıştır:

```bash
pwd
whoami
uname -a
ls
ls -la
df -h
ps
echo hello
```

Geçme ölçütleri:

- komutlar çalışıyor
- çıktı görünüyor
- arayüz donmuyor

Beklenen başlangıç dizini:

```text
/var/mobile
```

Gerçek süreç kullanıcısı cihaz çıktısından kaydedilmeli.

---

## 5. Türkçe / UTF-8 girdi

iPad1Terminal içinde yaz:

```text
Türkçe: ğüşiöç İĞÜŞÖÇ
```

Geçme ölçütleri:

- Türkçe klavye tüm karakterleri üretebiliyor
- yazılan metin kabuğa ulaşıyor
- görüntülenen metin bozulmuyor

Ayrıca çalıştır:

```bash
echo "Türkçe: ğüşiöç İĞÜŞÖÇ"
```

Geçme ölçütleri:

- UTF-8 çıktısı doğru

---

## 6. Backspace

Enter'a basmadan önce:

1. `abcdef` yaz
2. Backspace'e üç kez bas
3. `XYZ` yaz
4. Enter'a bas

Geçme ölçütleri:

- kabuk komut satırı karakterleri görünür şekilde siliyor
- `^?` veya tuhaf silme işaretleri yok
- beklenen düzenlenmiş girdi kabuğa ulaşıyor

Backspace çalışmazsa doğrula:

```text
TerminalInputView sends 0x7F
PTY VERASE is 0x7F
```

---

## 7. Enter

Yaz:

```text
echo test
```

Return'e bas.

Geçme ölçütleri:

- komut tam olarak bir kez çalışıyor
- kabuk istemine dönüyor

---

## 8. Özel yardımcı satır

Yazılım klavyesi görünürken üstünde şunları içeren bir satır olduğunu doğrula:

```text
Esc
Ctrl+C
Tab
<
^
v
>
~
|
```

Geçme ölçütleri:

- satır klavyenin üstünde
- etiketler okunabilir
- satıra dokunulabiliyor

---

## 9. Ctrl+C

Varsa bekleyen veya sürekli çalışan bir komut çalıştır.

Sonra dokun:

```text
Ctrl+C
```

Geçme ölçütleri:

- süreç kesiliyor
- kabuk istemi geri geliyor

---

## 10. Tab

Bir yolun/komutun bir kısmını yaz ve Tab'a dokun.

Geçme ölçütleri:

- Tab kabuğa ulaşıyor
- kabuk davranışı kurulu kabuğun yetenekleriyle tutarlı

`/bin/sh`'in zengin tamamlama desteklediğini varsayma.

---

## 11. Ok tuşları

Test et:

```text
Up
Down
Left
Right
```

Geçme ölçütleri:

- diziler kabuğa ulaşıyor
- son terminal mimarisinde ham `[A`, `[B`, `[C`, `[D` sıradan metin olarak görünmemeli

Not:

düz `/bin/sh` bash tarzı geçmiş davranışı sağlamayabilir. Kabuk sınırlamalarını terminal hatalarından ayır.

---

## 12. ANSI kalıntı regresyonu

Geçme ölçütleri:

Sıradan kabuk kullanımı sırasında istemde şu görünmemeli:

```text
[K
```

veya diğer ham CSI parçaları.

---

## 13. Clear

Çalıştır:

```bash
clear
```

Güncel temel ayrıştırıcı için geçme ölçütleri:

- ham kaçış dizileri görünmüyor
- ekran temizleniyor veya kabul edilebilir şekilde sıfırlanıyor

Tam ekran tamponu yazıldıktan sonra:

- imleç doğru mantıksal konumda olmalı
- eski ekran içeriği doğru şekilde kaldırılmalı

---

## 14. ANSI SGR testi

Çalıştır:

```bash
printf '\033[31mRED\033[0m\n'
```

Güncel geçici ayrıştırıcı için geçme ölçütleri:

- ham `ESC[31m` / `ESC[0m` metni görüntülenmiyor

Gelecekteki ekran tamponu için geçme ölçütleri:

- `RED` desteklenen temel ön plan rengiyle görüntüleniyor
- sonraki metin varsayılan özniteliklere dönüyor

---

## 15. Geri kaydırma geçmişi

Cihazda bulunan komutlarla büyük çıktı üret.

Örnekler:

```bash
find /usr 2>/dev/null
```

veya varsa:

```bash
seq 1 5000
```

Geçme ölçütleri:

- uygulama yanıt vermeye devam ediyor
- geçmiş sınırsız büyümüyor
- çökme yok
- belirgin kontrolsüz bellek artışı yok

---

## 16. Döndürme

Test et:

- dikey
- yatay
- tekrar dikey

Geçme ölçütleri:

- oturum canlı kalıyor
- kabuk yeniden başlamıyor
- terminal boyutu güncelleniyor
- klavye/yardımcı satırla çakışma yok

---

## 17. Tekrarlı aç/kapat

Yerel Terminal'i en az 10 kez aç ve çık.

Geçme ölçütleri:

- çökme yok
- sahipsiz alt kabuk yok
- zombi süreç yok
- PTY dosya tanımlayıcı sızıntısı yok

Gerekirse sistem süreç durumunu incelemek için yalnızca harici SSH kullan.

---

## 18. Alt sürecin çıkışı

Yerel Terminal içinde çalıştır:

```bash
exit
```

Geçme ölçütleri:

- alt süreç sonlanıyor
- arayüz süreç çıkışını bildiriyor
- uygulamanın kendisi çökmüyor

---

## 19. Bellek baskısı

Uzun çıktı sırasında:

- uygulama kararlılığını gözlemle
- gerçekçi kullanımla normal cihaz bellek baskısı oluştur

Geçme ölçütleri:

- sınırlı geri kaydırma geçmişi etkili kalıyor
- uygulama sınırsız tampon ayırmıyor

---

## 20. Gelecekteki ANSI/VT100 kabulü

Ekran tamponu yazıldıktan sonra test et:

```text
less
nano
top
vim
```

SSH kilometre taşından önce en az kabul:

- `less` kullanılabilir
- `nano` gezinme/düzenleme için yeterince kullanılabilir
- `top` çöp biriktirmeden yeniden çiziyor
- imleç hareketi çalışıyor
- temizleme/silme davranışı çalışıyor

---

## 21. Gelecekteki SSH testleri

Yalnızca SSH yazıldıktan sonra.

Test et:

- geçerli host
- geçersiz host
- yanlış port
- host anahtarı istemi
- şifre istemi
- kimlik doğrulama hatası
- başarılı giriş
- bağlantıyı kesme
- yeniden bağlanma
- sunucunun bağlantıyı kapatması
- SSH anahtarı
- karşılaşılırsa eski algoritma hatası

Test şifrelerini/özel anahtarlarını asla saklama veya yayımlama.

---

## 22. Regresyon kontrol listesi

Her sürümden önce:

- [ ] Yerel kabuk açılıyor
- [ ] yazma çalışıyor
- [ ] Türkçe girdi çalışıyor
- [ ] Backspace çalışıyor
- [ ] Enter çalışıyor
- [ ] Ctrl+C çalışıyor
- [ ] yardımcı satır görünüyor
- [ ] `[K` yok
- [ ] döndürme çalışıyor
- [ ] clear çalışıyor
- [ ] sınırlı bellek davranışı
- [ ] kapat/yeniden aç kararlılığı
