# TASKS — iPad uygulamaları (2026-10-20)

Bu dosya yalnız **dizin**: her uygulama için sürüm, durum, ayrıntı nerede. Ayrıntılı iş listesi her uygulamanın kendi klasöründeki `TASK(S).md`'dedir.

## Önce karar bekleyenler
- [ ] **Dal kararları** (`dal/*`): hangileri `main`'e alınacak, hangisi silinecek?
  - `dal/iPad1PDFReader/wsl-feature-text-reader-v1` — WSL'de **102 commit** (metin okuyucu); sunucudaki GitHub kopyasında yok. Asıl güncel iş büyük olasılıkla bu. `main`'deki 7 doküman commit'i bu dalda yok → birleştirilecek.
  - `dal/iPad1Files/*` — ZIP CRC/boş arşiv düzeltmeleri, PDFReader dosya seçici, WSL'deki commit edilmemiş 12 değişiklik (`wsl-wip`).
  - `dal/iPad1Terminal/wsl-wip` (5 dosya), `dal/ipad1docx/wsl-wip` (2 dosya) — commit edilmemişti.
  - `dal/ipad1vnc/wsl-beta3` — WSL'deki 2.2.0-beta3 sunucudaki beta3'ten **farklı kod** içeriyor (TLS etiketi, `handleVNCURL`); `dal/ipad1vnc/sunucu-wip` — sunucuda commit edilmemiş `session.md`/`task.md`.
- [ ] GitHub: bu depo henüz uzağa gönderilmedi. Yeni özel depo (`SHapeloglu/ipad-apps`) açılıp push edilecek (kullanıcı). Eski tek tek depolar (`SHapeloglu/iPad1*`) arşivlenecek / salt-okunur.
- [ ] Yeni uygulamalar (TalkingPet, KidsDraw, Karaoke, PatiKasabasi, MehmetTurboChallenge, Ticket'ler) GitHub'da hiç yoktu; yalnız bu depoda.
- [ ] Derleme ortamı: Theos + iOS SDK sunucuda Docker imajı olarak kurulsun mu? (SDK'yı kullanıcı sağlar.)

## Uygulamalar
| Uygulama | Güncel sürüm | Eski sürüm etiketi | Ayrıntı (klasör içinde) |
|---|---|---|---|
| ipad1vnc | 2.2.0-beta3 | 15 | task.md, backlog.md, session.md |
| iPad1PDFReader | 3.1.0 (`main`); WSL dalı daha ileri | 5 | TASKS.md, BACKLOG.md |
| iPad1Files | 1.0.0-beta1 | 1 | TASKS.md, BACKLOG.md |
| iPad1Terminal | 0.2.1-alpha1 | 2 | TASKS.md, BACKLOG.md |
| ipad1docx | 0.1.0 | — | TASKS.md, BACKLOG.md |
| ipad1MailBox | 0.5-alpha1 | — | TASK.md, BACKLOG.md |
| iPad1WebBrowser | 0.1-alpha9 (alpha9 fiziksel test bekliyor) | 1 | TASK.md |
| iPad1FTPDownloader | 1.4.2 | 4 | TASK.md, BACKLOG.md |
| iPad1Player | 0.1-alpha18 (sıradaki: gerçek A/V senkronu) | — | TASK.md, BACKLOG.md |
| ipad1SystemInfo | 0.1-alpha1 (fiziksel iPad 1 doğrulaması bekliyor) | — | TASK.md |
| iPad1TalkingPet | 1.4.1 | 16 | SESSION.md |
| iPad1KidsDraw | 1.3.1 | 9 | — |
| PatiKasabasi | 0.7.0-alpha7 | 4 | TASKS.md, SESSION.md |
| iPad1Karaoke | 0.1 | 1 | — |
| MehmetTurboChallenge | 0.1 | 1 | — |
| iPad1Ticket (yerel iOS 5) | 0.1 | 1 | — |
| iPhone6sTicket | 0.1 | 1 | — |
| ipad1Ticket-expo (React Native) | — | — | AGENTS.md |
| iPhone6sNFCProbe | — | — | — |

Not: `control` dosyasındaki sürüm numarası bazı uygulamalarda güncellenmemiş olabilir; etiket numarası klasör adından değil `control`'den gelir. `iPad1PDFReader` dört klasörde aynı 3.1.0'ı taşıyor (etiket sonuna klasör adı eklendi).
Boş kalan GitHub depoları (aktarılmadı): `iPadPlayer`, `ipad1HTTPDownloader`.
