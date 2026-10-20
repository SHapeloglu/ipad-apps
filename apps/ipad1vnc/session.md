# session.md — iPad1VNC Oturum Günlüğü

> Ayrıntılı devir notları `PROJECT_CONTEXT.md`'de tutulur.

---

## 2026-10-06

**Yapılanlar:** Canlı dosya sunucusu `/opt/ipad1vnc/ipad1vnc_fileserver.py` v2.0'dan repodaki v2.2'ye (`main`, `96e5d8f`) güncellendi, `ipad1vnc-fileserver.service` yeniden başlatıldı.
**Neden:** Uygulama (`src/AppDelegate.m`) v2.2 uç noktalarını kullanıyordu; canlıda `/api/upload-chunk` 404 dönüyordu, uygulama yanıt kodunu kontrol etmediği için yükleme başarılı görünüp dosya yazılmıyordu. `Range` desteklenmediği için yarım indirmeler baştan başlıyordu.
**Doğrulama (sunucuda, 127.0.0.1):** sürüm başlığı `iPad1VNCFiles/2.2`; tokensız istek 401; `../` kaçışı 400; iki parçalı yükleme birebir aynı dosya üretti (sahibi `desktop`); `Range` isteği 206 ve doğru içerik; test dosyası silindi.
**Açık sorunlar:** Uygulamanın yükleme döngüsü HTTP yanıt kodunu kontrol etmiyor — sunucu hata dönerse yine başarılı görünür (`task.md` ve `/root/ISLISTESI.md` Aktif #9'e eklendi). Fiziksel iPad'den deneme yapılmadı.
**Geri dönüş:** `cp -p /opt/ipad1vnc/ipad1vnc_fileserver.py.v2.0.yedek-20261006 /opt/ipad1vnc/ipad1vnc_fileserver.py && systemctl restart ipad1vnc-fileserver`

---

## 2026-10-05

- `main` dalındaki şablondan üretilmiş çalışma dosyaları kod ve `PROJECT_CONTEXT.md` okunarak yeniden yazıldı.
- Tespit: aktif iş `beta4-ui-security-polish` dalında ve `main`'den 10+ commit önde; o dalda bu beş dosya yok.

---

## Önceki Çalışmalar (git geçmişinden)

- **2026-08-29 (beta4 dalı)** — Remote Files düzeni ve TLS taşıma tanılaması kalıcı hale getirildi; güvenli harici VNC URL çağrısı.
- **2026-08-22** — Devir dokümanları `PROJECT_CONTEXT.md`'de birleştirildi, eskileri silindi.
- **2026-08-17** — v2.2.0-beta3 kaynağı; kurulum/sunucu/test matrisi/yol haritası dokümanları.

---

### Kayıt Şablonu

```markdown
## YYYY-AA-GG
**Yapılanlar:** ...
**Cihazda doğrulanan:** ...
**Açık sorunlar:** ...
**Sıradaki adım:** ...
```
