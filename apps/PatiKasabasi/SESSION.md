# Oturum Devri

## Current state

- Hedef sürüm `0.7.0-alpha7`.
- Sahiplenme, isim/kişilik, ev bakım döngüsü ve çevrimdışı kayıt korunuyor.
- Kayıt modeli büyüme, beceriler, meslek, arkadaşlıklar, envanter, yerleşen eşyalar, sahip olunan/takılan aksesuarlar, görev, anı, koleksiyon, ses ve günlük ödülleri içeriyor.
- Evden Harita, Odam, Dolap, Okul, Oyunlar ve Albüm ekranlarına geçiliyor.
- Harita Ev, Pati Okulu, Dostluk Parkı ve Kasaba Meydanı arasında geçiş sağlıyor; doğru günlük görev konumunu işaretliyor.
- Üç mini oyun, dört komşu için toplam 12 konumlu istek, dört etkinlik, dört mevsim, sekiz eşya, sekiz aksesuar ve beş meslek var.
- Oda ekranında yerleştirilen eşyalara dokunmak bakım veya ilgili beceri eylemini doğrudan tetikliyor.
- Avatar dokunma/eylem tepkileri, kısa WAV efektleri ve yarım çözünürlüklü JPEG anı fotoğrafları eklendi.
- Bütün hayvan çizimleri önceki görsel ölçeğin dörtte birine indirildi; en az 54×54 dokunma alanı korunuyor.
- Mama kabı gölge, gövde, üst kenar, mama taneleri ve pati işaretiyle yeniden çizildi.
- Haritadaki yavru bölgelere sürüklenebiliyor; düğmeye dokunarak geçiş alternatifi devam ediyor.
- Üç Core Graphics ortam nesnesi ile ev/oda/dolap yavrularına zamanlayıcısız, ekran dışındayken durdurulan hafif hareket eklendi.
- Park, okul ve meydan metin tabloları Core Graphics sahnesi ve büyük etkinlik kartlarına dönüştürüldü; yavru her üç ekranda görünür.
- Ev bakım düğmeleri, oda eşyaları, okul kartları, park komşuları ve meydan hedefleri yavru sürüklemeyi kabul ediyor; dokunma alternatifi korunuyor.
- Okulda `Evimiz` üst menüsü ve Dersler/Meslekler bölümlü denetimi var; yatak yükseltilmiş kenarlı hayvan yatağı olarak çiziliyor.
- Evde mama, top ve fırça ayrı Core Graphics nesneleri olarak yavrunun üzerine sürüklenebiliyor; tek dokunma alternatifi var.
- Besleme, oyun, uyku, temizlik ve sevgi ayrı kısa görsel diziler kullanıyor; uyuyan yavrunun gözleri kapanıyor, mama azalıyor ve top gerçek bir yol üzerinde yuvarlanıyor.
- Ev ve odada kısa düşünce balonları ihtiyacı veya tepkiyi simgeyle gösteriyor.
- Oda eşyaları yavrunun hedefe gidip sonucu oynamasını sağlıyor; her üçüncü başarılı eylemde kişiliğe bağlı görsel özerk davranış çalışıyor.
- Ev avatarında baş, karın, pati ve kuyruk ayrı dokunma bölgeleri; göz kırpma, bakma, esneme, kulak oynatma ve el sallama kısa mikro tepkileri var.
- Normal mama, balık, havuç ve kurabiye seçilebiliyor; türün favori/sevmediği yiyecek farklı ihtiyaç artışı, yüz ve düşünce üretiyor.
- Yeme, uyku, top, köpük, kahkaha ve şaşırma için altı yeni kısa mono WAV eklendi.
- `Konuş` akışı en fazla üç saniye kaydedip aynı geçici yerel dosyadan geri oynatıyor; internet veya sunucu kullanmıyor.
- Üçüncü mini oyun `Top Yakala`, sekiz kısa turda beş isabetle mevcut günlük ödül kuralını kullanıyor.
- Eski `PatiKasabasiSavedGameV1` anahtarı korunuyor; 0.1/0.2 kayıtlarında eksik dolap alanları başlangıç hediyeleriyle tamamlanıyor.

## Verified

- `scripts/validate_project.sh` Info.plist, legacy hedef, yasak API taraması, sürükleme ve Alpha7 tepki kaynakları, 8 aksesuar/12 görev katalog sayıları, sekiz ses dosyası ve 31 sınıf bütünlüğünü denetliyor.
- Kullanıcı önceki alpha5 paketini kendi legacy Theos ortamında üretip iPad'e aktardı. Bu çalışma ortamında Theos ve iPhoneOS 6.1 SDK bulunmadığı için yeni alpha7 Objective-C armv7 paketi üretilmedi.
- Fiziksel iPad 1 doğrulaması yapılmadı.

## Immediate next action

Legacy Theos ortamında `make clean package` çalıştır. Başarılı alpha7 paketini iPad 1'e yükle; özellikle dört dokunma bölgesini, mama tercihlerini, beş mikro tepkiyi, altı eylem sesini, üç saniyelik yerel ses tekrarı ve `Top Yakala` akışını; ardından ekran geçişinde bütün gecikmiş dizilerin iptalini, bellek kullanımını ve eski kayıt geçişini test et.

## Do not assume

- Statik kontroller gerçek derleme değildir.
- Simülatör veya yeni cihaz sonucu iPad 1 bellek/performance doğrulaması sayılmaz.
- Fiziksel cihazda görülmeden ekranların kırpılmadığı veya seslerin uygun seviyede olduğu kabul edilmemelidir.
