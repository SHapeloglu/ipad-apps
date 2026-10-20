iPad1Files - Güncel Güncelleme Paketi
Tarih: 2026-09-06

ÖNEMLİ:
Bu ZIP tam kaynak ağacının birebir kopyası değildir.
Kullanıcının en güncel iPad1Files çalışma ağacı yerel WSL makinesindedir ve bu oturumdan
doğrudan erişilemiyor. GitHub main dalı da yerel değişikliklerin gerisindedir.

Bu paket, güncel konuşmada kesinleştirilen iPad1Files kapsam kurallarını ve lokal repoya
uygulanacak patch yardımcı dosyasını içerir.

Kapsam:
- iPad1Files: browse/search/sort/filter/copy/move/rename/delete, favorites, recents,
  file info, ZIP, picker, Open With, gelişmiş filesystem erişimi.
- iPad1PDFReader: PDF ve gerçek text reading/render/search/edit özellikleri.
- iPad1Player: media playback/decode ve subtitle discovery/matching.
- iPad1Downloader: HTTP/HTTPS/FTP, queue, pause/resume/retry/progress.
- iPad1Terminal: shell/script execution.

Güvenlik:
- /var/mobile/Media/iPad1Files normal çalışma alanıdır.
- Kritik sistem alanlarında destructive işlemler root doğrulaması gerektirir.
- Root parolası diske/plist/NSUserDefaults/log içine kaydedilmez.
- Doğrulama yoksa işlem fail-closed olur.
- Picker modunda destructive işlem açılmaz.

Tam güncel kaynak ZIP üretmek için:
1) Yerel repo ZIP olarak bu sohbete yüklenebilir; veya
2) Yerel değişiklikler GitHub'a push edilebilir.
Bunlardan biri olduğunda tam, tek parça ve güncel kaynak ZIP hazırlanabilir.
