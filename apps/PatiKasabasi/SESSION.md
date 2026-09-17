# Oturum Devri

## Current state

- Hedef sürüm `0.4.0-alpha4`.
- Sahiplenme, isim/kişilik, ev bakım döngüsü ve çevrimdışı kayıt korunuyor.
- Kayıt modeli büyüme, beceriler, meslek, arkadaşlıklar, envanter, yerleşen eşyalar, sahip olunan/takılan aksesuarlar, görev, anı, koleksiyon, ses ve günlük ödülleri içeriyor.
- Evden Harita, Odam, Dolap, Okul, Oyunlar ve Albüm ekranlarına geçiliyor.
- Harita Ev, Pati Okulu, Dostluk Parkı ve Kasaba Meydanı arasında geçiş sağlıyor; doğru günlük görev konumunu işaretliyor.
- İki mini oyun, dört komşu için toplam 12 konumlu istek, dört etkinlik, dört mevsim, sekiz eşya, sekiz aksesuar ve beş meslek var.
- Oda ekranında yerleştirilen eşyalara dokunmak bakım veya ilgili beceri eylemini doğrudan tetikliyor.
- Avatar dokunma/eylem tepkileri, kısa WAV efektleri ve yarım çözünürlüklü JPEG anı fotoğrafları eklendi.
- Bütün hayvan çizimleri önceki görsel ölçeğin dörtte birine indirildi; en az 54×54 dokunma alanı korunuyor.
- Mama kabı gölge, gövde, üst kenar, mama taneleri ve pati işaretiyle yeniden çizildi.
- Haritadaki yavru bölgelere sürüklenebiliyor; düğmeye dokunarak geçiş alternatifi devam ediyor.
- Üç Core Graphics ortam nesnesi ile ev/oda/dolap yavrularına zamanlayıcısız, ekran dışındayken durdurulan hafif hareket eklendi.
- Eski `PatiKasabasiSavedGameV1` anahtarı korunuyor; 0.1/0.2 kayıtlarında eksik dolap alanları başlangıç hediyeleriyle tamamlanıyor.

## Verified

- `scripts/validate_project.sh` ile Info.plist, legacy hedef, yasak API taraması, sürükleme/hareket kaynakları, 8 aksesuar/12 görev katalog sayıları, ses dosyaları ve 27 sınıf bütünlüğü doğrulanmalı.
- Bu çalışma ortamında Theos ve iPhoneOS 6.1 SDK bulunmadığı için Objective-C armv7 paketi üretilmedi.
- Fiziksel iPad 1 doğrulaması yapılmadı.

## Immediate next action

Legacy Theos ortamında `make clean package` çalıştır. Başarılı paketi iPad 1'e yükle; özellikle dörtte bir hayvan çizimlerini, yeni mama kabını, harita sürüklemesini, hareketlerin durup başlamasını, fotoğraf belleğini ve 0.1/0.2 kayıt geçişini test et.

## Do not assume

- Statik kontroller gerçek derleme değildir.
- Simülatör veya yeni cihaz sonucu iPad 1 bellek/performance doğrulaması sayılmaz.
- Fiziksel cihazda görülmeden ekranların kırpılmadığı veya seslerin uygun seviyede olduğu kabul edilmemelidir.
