# BACKLOG.md — iPad1Files

Planlı işler: `TASKS.md` (ZIP 1. aşama uç durum/güvenlik testleri → ZIP 2. aşama → kalan entegrasyon). Bu dosya henüz planlanmamış maddeleri tutar. `INTEGRATION.md`'ye uy: iPad1Files ortak dosya sistemi omurgasıdır; FTP ve PDF motorları kendi uygulamalarında kalır.

## Arşiv formatları (`ARCHITECTURE.md`'de ertelenenler)

- ZIP64 (4 GB'tan büyük dosyalar / 65 535'ten fazla öğe) — önce MiniZip desteğini ve RAM maliyetini kontrol et.
- Şifreli ZIP (okuma) — şifre sorulur, şifre asla önbelleğe alınmaz.
- TAR / TGZ / GZ — akış tabanlı, arşivin tamamı tamponlanmaz.
- RAR / 7z — yalnızca küçük, iOS 5 uyumlu bir kütüphane varsa ve fiziksel RAM profili geçerse; aksi halde reddet.

## Planlanmamış fikirler

- Standart klasör başına (`Downloads/ Documents/ PDFs/ Images/ Music/ Videos/ Archives/ Shared/ Temp/ AppData/`) kademeli hesaplanan depolama kullanımı görünümü.
- Kullanıcı onaylı, yaşa göre `Temp/` otomatik temizlik politikası.
- Kardeş uygulamalarla küçük bir plist üzerinden paylaşılan son dosyalar listesi (diğerleri için salt okunur).
- Kesin üst sınırı olan, bellek baskısına duyarlı görsel küçük resim önbelleği.
- iPad1VNC'nin beta4 sürümü çıktığında AppData entegrasyonu ayrıntıları.

## Kapsam dışı

FTP/HTTP transfer motorları (iPad1FTPDownloader), PDF görüntüleme (iPad1PDFReader), medya oynatma (iPad1Player), kabuk (iPad1Terminal).
