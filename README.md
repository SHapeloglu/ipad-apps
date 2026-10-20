# ipad-apps

Tüm iPad 1 (iOS 5, Theos) uygulamaları tek depoda. Takip: [TASKS.md](TASKS.md)

## Düzen
- `apps/<uygulama>/` — uygulamanın **güncel** kaynağı (`main` dalı). Her uygulamanın kendi `TASK(S).md` / `SESSION.md` / `BACKLOG.md` dosyaları klasörünün içinde.
- Sürümler: etiket `<uygulama>/v<sürüm>` (kırık olanlar `-broken` ile biter). Eski sürümler `arsiv/<uygulama>` dalında.
  - İki sürümü karşılaştır: `git diff iPad1TalkingPet/v1.0.1 iPad1TalkingPet/v1.2.0`
  - Eski sürümü aç: `git worktree add ../eski iPad1TalkingPet/v1.0.1`
- `dal/<uygulama>/…` — WSL'de ya da GitHub'da ayrı dalda kalmış, `main`'e birleşmemiş işler (karar bekliyor, aşağıya bak).
- `paketler/<uygulama>/*.deb` — derlenmiş paketler, **git dışında** (`.gitignore`), yedekte.
- Derleme çıktıları (`.theos`, `obj`, `*.deb`, `node_modules`) git'e girmez.

## Yeni sürüm çıkarma
Normal git: `main`'de çalış, sürüm olunca `git tag <uygulama>/v<sürüm>`; `.deb`'i `paketler/<uygulama>/` altına koy. Sürüm için klasör kopyalama.

## Kaynaklar / ham yedek
İlk aktarım 2026-10-20: sunucudaki `/root/projects/ipad/*` GitHub klonları (`SHapeloglu/<ad>`) + WSL `~/projects` (ham kopya: `/root/ipad-arsiv/wsl-projects`, silinmez).
Eski sürüm klasörlerinin commit tarihleri hep 2026-09-17'dir (dosya zamanları toplu değişmişti); sıra sürüm numarasına göredir.
