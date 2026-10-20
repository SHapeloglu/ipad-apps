# ENTEGRASYON

## Amaç

Bu doküman, `iPad1Terminal`'in sorumluluk sınırlarını ihlal etmeden diğer iPad 1 uygulamalarıyla nasıl etkileşebileceğini tanımlar.

---

## Uygulama sorumluluğu

```text
iPad1Terminal
= local shell + terminal emulation + SSH
```

(yerel kabuk + terminal öykünmesi + SSH)

Şunlar değildir:

- dosya yöneticisi
- VNC istemcisi
- PDF okuyucu
- FTP indirme motoru

---

## iPad1Files

Standart ortak dosya kökü:

```text
/var/mobile/Media/iPad1Files/
```

Olası terminal entegrasyonu:

### Hızlı dizin kısayolu

Bir `Files` hızlı komutu şunu gönderebilir:

```bash
cd /var/mobile/Media/iPad1Files/
```

Bu, iPad1Files mantığını kopyalamaya veya gömmeye tercih edilir.

### Terminali bir dizinde açma

İleride isteğe bağlı bir URL scheme, iPad1Files'ın şunu istemesine izin verebilir:

```text
Open iPad1Terminal at a selected directory
```

(iPad1Terminal'i seçilen dizinde aç)

Kavramsal örnek scheme:

```text
ipad1terminal://local?cwd=/var/mobile/Media/iPad1Files/Documents/
```

Yerel Terminal yaşam döngüsü ve URL ayrıştırma kararlı olmadan yazma.

Güvenlik kuralı:

- yolu doğrula
- başka bir uygulamanın gönderdiği keyfi komut metnini asla sessizce çalıştırma

Bu kullanım için yalnızca dizin yolu kabul edilmelidir.

---

## iPad1VNC

Sorumluluk ayrımı:

```text
iPad1Terminal
= CLI / PTY / SSH

iPad1VNC
= graphical remote desktop
```

(iPad1Terminal: komut satırı / PTY / SSH · iPad1VNC: grafik uzak masaüstü)

Terminale uzak masaüstü özellikleri ekleme.

---

## iPad1FTPDownloader

Ağ üzerinden dosya indirme FTPDownloader'ın sorumluluğunda kalır.

`iPad1Terminal` ikinci bir FTP indiriciye dönüşmemelidir.

Jailbreak'li cihazda komut satırı `ftp`, `scp` veya benzeri araçlar kuruluysa kullanıcılar bunları terminalde elle çalıştırabilir. Bu uygulama sahipliğini değiştirmez.

---

## iPad1PDFReader

Doğrudan bağımlılık gerekmez.

Kullanıcı ortak kök altındaki dosyalar üzerinde normal kabuk komutlarıyla işlem yapabilir.

PDF görüntüleme gömme.

---

## Gelecekteki SSH/SCP davranışı

SSH bu uygulamanın parçasıdır.

İlk v1 için SCP/SFTP grafik dosya yönetimi gerekli değildir.

İleride eklenirse ikinci bir genel amaçlı dosya gezgini yazmak yerine hedef seçimini iPad1Files üzerinden yönlendirmeyi tercih et.

---

## URL scheme güvenliği

Gelecekte olası scheme'ler:

```text
ipad1terminal://local
ipad1terminal://local?cwd=...
ipad1terminal://ssh?profile=...
```

Desteklenmeyecekler:

```text
?command=rm ...
```

veya URL scheme ile keyfi harici komut çalıştırma.

Bu, uygulamanın kazara bir komut çalıştırma aracına dönüşmesini önler.

---

## Ortak kod politikası

Şunlardan büyük kod parçaları kopyalama:

- iPad1Files
- iPad1VNC
- iPad1FTPDownloader
- iPad1PDFReader

Bunun yerine küçük, açık entegrasyon sözleşmeleri kullan.

---

## Ortak platform politikası

Tüm iPad 1 ailesi uygulamaları şunları hedeflemeye devam eder:

```text
iPad 1
iOS 5.1.1
armv7
256 MB RAM
non-ARC / MRC
Theos
```

Her proje yine de bağımsız olarak derlenebilir olmalıdır.
