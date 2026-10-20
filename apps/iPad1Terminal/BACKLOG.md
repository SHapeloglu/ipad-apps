# BACKLOG.md — iPad1Terminal

Planlı işler: `TASKS.md` aşama 0–6 (başlangıç → yerel PTY → girdi/arayüz → ANSI/VT100 ekran modeli → PTY altında kurulu `ssh` ikilisiyle SSH → kullanılabilirlik → kararlılık). Bağlam: `PROJECT_CONTEXT.md`.

## Sıralama kısıtları (PROJECT_CONTEXT'ten)

- SSH çalışmasından önce yerel terminal donanımda kararlı olmalı.
- Ciddi SSH kullanımından önce ANSI/VT100 ekran modeli.
- SSH protokol yığınını asla sıfırdan yazma — PTY + kurulu `ssh`'i yeniden kullan.
- iPad1VNC'nin yerleşik terminali ancak bu uygulamada SSH çalışır hale geldikten sonra kaldırılacak (bkz. iPad1VNC beta4 dalındaki `RESPONSIBILITY_AUDIT.md`).

## Planlanmamış fikirler

- Temel renkler kararlı olduktan sonra 256 renk / kalın / altı çizili öznitelikler.
- Sınırlı geri kaydırma geçmişinde arama.
- `iPad1Files/Documents/` altına oturum günlüğü (isteğe bağlı, boyut sınırlı).
- Wi-Fi koptuğunda `mosh` tarzı yeniden bağlanma ipuçları (yalnızca deneyim, yeni protokol yok).
- iPad1VNC profilleriyle paylaşılan kısa komutlar (host/kullanıcı metadata'sı, asla şifre değil).

## Kapsam dışı

Tema sistemi (bilinçli), dosya yöneticisi özellikleri (iPad1Files), FTP/SFTP transferleri (iPad1FTPDownloader), VNC (iPad1VNC).
