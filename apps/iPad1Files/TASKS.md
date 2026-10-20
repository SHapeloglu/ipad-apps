# iPad1Files Görevleri

## Kaynak kod

- [x] ortak kök
- [x] gezgin / dosya işlemleri / çoklu seçim / arama / favoriler / disk / önizleme
- [x] çakışmaya karşı güvenli adlandırma
- [x] köke gitme
- [x] tam yol gösterimi
- [x] tümünü seç
- [x] korumalı sistem alanı güvenlik politikası
- [x] ada / tarihe / boyuta göre sıralama
- [x] yeni metin dosyası
- [x] hafif metin düzenleme
- [x] uygulama kaydı / "Birlikte Aç"
- [x] PDF için mutlak yol devri
- [x] kullanıcı kontrollü Downloads sınıflandırması
- [x] ArchiveManager
- [x] ArchiveViewController
- [x] pakete gömülü MiniZip + libz
- [x] ZIP listeleme
- [x] ZIP "Tümünü Çıkar"
- [x] mevcut Klasör Seçici ile ZIP çıkarma
- [x] çoklu seçimden ZIP oluşturma
- [x] ZIP Slip koruması
- [x] symlink reddi
- [x] önceden boş disk alanı kontrolü

## Fiziksel cihazda GEÇTİ

- [x] temiz armv7 derleme / kurulum / açılış
- [x] kopyala / taşı / sil
- [x] çoklu seçim / tümünü seç
- [x] köke gitme
- [x] korumalı alanda "tümünü seç" gizli
- [x] korumalı hedefte üzerine yazma seçeneği yok
- [x] normal çakışmada üzerine yaz / yeni ad
- [x] ZIP içerik ekranı
- [x] buraya "Tümünü Çıkar"
- [x] tekrar çıkarma -> `(2)`
- [x] Klasör Seçici ile çıkarma
- [x] çoklu seçimden ZIP oluşturma
- [x] oluşturulan ZIP'i yeniden açma / çıkarma
- [x] ZIP entegrasyonu sonrası çekirdek regresyon

## ZIP 1. aşama uç durum / güvenlik testleri

- [ ] Türkçe ZIP dosya adları
- [ ] bozuk ZIP
- [ ] yarım kalmış (truncated) ZIP
- [ ] `../` yol geçişi içeren ZIP
- [ ] mutlak yollu ZIP
- [ ] symlink içeren ZIP
- [ ] çok sayıda küçük dosya
- [ ] tek büyük dosya
- [ ] yetersiz disk alanı
- [ ] bellek baskısı

## ZIP 2. aşama

- [ ] tek dosya çıkarma
- [ ] ilerleme arayüzü
- [ ] iptal desteği

## Kalan entegrasyon

- [ ] favorilerin kalıcılığı için yük / regresyon testi
- [ ] büyük dizin / görsel bellek kullanımı
- [ ] PDFReader yokken yedek davranış
- [ ] PDFReader alıcısının mutlak yolu
- [ ] sınıflandırmanın yalnızca kullanıcı seçiminden sonra yapılması
- [ ] iPad1VNC AppData entegrasyonu
