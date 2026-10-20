# task.md — iPad1VNC Görevleri

> Güncel görev listesi `beta4-ui-security-polish` dalındaki `PROJECT_CONTEXT.md`'dedir; bu dosya `main` dalının özetidir.

## 🔜 Sıradaki (beta4 kapsamı, öncelik sırasıyla)

- [ ] **Yükleme döngüsü HTTP yanıt kodunu kontrol etmiyor** — `src/AppDelegate.m` `/api/upload-chunk` döngüsü yalnızca bağlantı hatasında duruyor; sunucu 4xx/5xx (ör. 409 offset uyuşmazlığı, 400 disk dolu) dönerse yükleme yine başarılı görünür. Yanıtı `NSHTTPURLResponse` olarak kontrol et, 200 değilse dur ve hata göster; 409'da dönen `size`'dan devam et. (`/root/ISLISTESI.md` Aktif)
- [ ] Remote Files toolbar çakışması (`buildFilesPanel`) — beta4 dalında düzeltme yapıldı, **fiziksel iPad'de yatay/dikey doğrulama bekliyor**
- [ ] TLS/VeNCrypt tanılama: sunucu loglarında `VeNCrypt(19)` isteği görülüyor mu? (`VncAuth(2)` görülüyorsa önce bağlantı durumu yolu incelenecek)
- [ ] Direct / SSH Tunnel / TLS bağlantı modu göstergesi
- [ ] Transfer kuyruğu UI ve Pause/Resume anlamı
- [ ] Profil hızlı işlemleri, LAN tarama UX (ana thread dışında kalmalı)
- [ ] beta3 Disconnect → Connect düzeltmesinin korunduğunu doğrula
- [ ] beta4 derle, kur, `PROJECT_CONTEXT.md` §13 fiziksel cihaz kontrol listesini çalıştır
- [ ] beta4 doğrulanınca `main`'e birleştir; bu beş dosya ile beta4'teki `ARCHITECTURE.md` / `PROJECT_CONTEXT.md` arasında tek kaynak kararı ver

## 🚧 Devam Eden

- [ ] `beta4-ui-security-polish` (son commit 2026-08-29)

## ✅ Tamamlanan

- [x] 2026-10-06 — Canlı dosya sunucusu (`/opt/ipad1vnc`) v2.0 → v2.2 güncellendi; `/api/stat`, parça parça yükleme ve `Range` ile indirme sunucuda test edildi. Yedek: `ipad1vnc_fileserver.py.v2.0.yedek-20261006`
- [x] 2026-10-05 — Çalışma dosyaları kod ve PROJECT_CONTEXT okunarak yeniden yazıldı
- [x] 2026-08-22 — Devir dokümanları `PROJECT_CONTEXT.md`'de birleştirildi
- [x] 2026-08-17 — v2.2.0-beta3 kaynak kodu (Disconnect/Connect düzeltmesi dahil)
