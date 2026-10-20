# iPad1Files Fiziksel Cihaz Testleri

Hedef:
```text
iPad 1 / 256 MB / iOS 5.1.1 / armv7
IP: 192.168.1.100
```

Derleme:
```bash
cd ~/projects/iPad1Files-v1.0.0-beta1
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

## Çekirdek regresyon

- [x] derleme / paketleme / kurulum / açılış
- [x] kopyala / taşı / sil
- [x] çoklu seçim / tümünü seç
- [x] çakışmaya karşı güvenli adlandırma
- [x] köke gitme
- [x] korumalı alanda "tümünü seç" gizli
- [x] korumalı hedefte üzerine yazma engelli
- [x] normal üzerine yaz / yeni ad akışı
- [x] ZIP entegrasyonu çekirdek dosya işlemlerini bozmadı
- [ ] Türkçe yollar
- [ ] favorilerin kalıcılığı
- [ ] büyük dizin / görsel bellek kullanımı

## ZIP 1. aşama — GEÇTİ

- [x] ZIP arşiv içerik ekranında açılıyor
- [x] ZIP içerik listesi
- [x] klasör yapılı ZIP
- [x] bulunulan klasöre "Tümünü Çıkar"
- [x] tekrar çıkarma `(2)` oluşturuyor
- [x] Klasör Seçici ile çıkarma
- [x] çoklu seçimden ZIP oluşturma
- [x] oluşturulan ZIP'i yeniden açma / çıkarma

## ZIP 1. aşama — bekleyen

- [ ] Türkçe karakterli ZIP dosya adı
- [ ] Türkçe karakterli öğe adı
- [ ] boş ZIP
- [ ] bozuk ZIP
- [ ] yarım kalmış ZIP
- [ ] `../` ZIP Slip örneği
- [ ] mutlak yol örneği
- [ ] symlink örneği
- [ ] çok sayıda küçük öğe
- [ ] tek büyük öğe
- [ ] yetersiz disk alanı
- [ ] bellek baskısı
- [ ] şifreli ZIP'in reddedilmesi
- [ ] ZIP64'ün reddedilmesi

Beklenen:
```text
../ traversal -> reject
absolute path -> reject
symlink -> reject
encrypted ZIP -> unsupported
ZIP64 -> unsupported in Phase 1
```

(`../` yol geçişi, mutlak yol ve symlink reddedilir; şifreli ZIP ve ZIP64 1. aşamada desteklenmez.)

## "Birlikte Aç"

- [ ] PDFReader yokken çökme yok
- [ ] alıcı uygulama kayıttan çözümleniyor
- [ ] yüzde-kodlanmış mutlak yol
- [ ] yinelenen PDF yok

## Downloads

- [ ] PDF -> PDFs önerisi
- [ ] görsel -> Images
- [ ] ses -> Music
- [ ] arşiv -> Archives
- [ ] otomatik taşıma yok
