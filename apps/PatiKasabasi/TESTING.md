# Test Planı

## Derleme kapısı

- `ARCHS=armv7`, deployment target 5.1, iPhoneOS 6.1 SDK, ARC kapalı.
- `./scripts/validate_project.sh` geçmeli.
- Derleyici uyarıları incelenmeli; modern API veya sahiplik uyarısı kalmamalı.
- Üretilen paketin mimarisi ve sürümü `iphoneos-arm / 0.7.0-alpha7` olmalı.

## Sahiplenme ve kayıt geçişi

1. Barınaktan yeni oyun başlat; dört türü, boş isim engelini ve beş kişiliği dene.
2. Evde 500 pati, yatak ve mama kabını doğrula.
3. Pet shop yolunda 300 pati, top sahipliği ve topun odada olduğunu doğrula.
4. Uygulamayı kapat/aç; Devam Et ile tüm değerlerin korunduğunu doğrula.
5. 0.1.0-alpha1 ile 0.6.0-alpha6 arasındaki kayıtları ayrı ayrı 0.7'de aç; eski yavru, ekonomi, ihtiyaç, oda ve dolap verilerinin korunduğunu doğrula.
6. Kaydet, uygulamayı yeniden aç ve eşya yerleşimi ile takılan aksesuarların aynı kaldığını doğrula.
7. Yeni Oyun seçeneğinde onaydan sonra eski kayıt ve fotoğraf klasörünün temizlendiğini doğrula.

## Ev, bakım ve tepki

- Besle 5 pati harcamalı; mama kabı yerleştirilmişse ek bonus vermeli.
- Para yetersizse besleme ve tur ilerlemesi olmamalı.
- Oyna, Uyut, Temizle ve Sev beklenen ihtiyaçları değiştirmeli; bütün değerler 0–100 kalmalı.
- Baş, karın, pati ve kuyruğa ayrı ayrı dokun; sırasıyla okşanma, gıdıklanma, el sallama ve şaşırma tepkisi görülmeli. Bu dokunuşlar para, ihtiyaç, gün veya eylem sayısını değiştirmemeli.
- Eylem simgeleri yaklaşık 0,4 saniyede temizlenmeli; ekran kapanınca gecikmiş çağrı çökmemeli.
- Evdeki yavru önceki görünür boyutun dörtte biri olmalı; buna rağmen merkezdeki dokunma hedefi en az 54×54 çalışmalı.
- Evdeki yavru yavaşça en fazla yaklaşık 5 punto hareket etmeli; başka ekrana geçildiğinde katman animasyonu kalmamalı.
- Yavru beş bakım düğmesinin her birine sürüklenebilmeli; geçerli bırakma tek eylem çalıştırmalı, boş alana bırakma değer veya para değiştirmemeli.
- Mama, top ve fırça hem tek dokunmayla hem yavrunun üzerine sürüklenerek çalışmalı; hedefte nesne çerçevesi sarıya dönmeli ve yavru hafif büyümeli.
- Nesne geçersiz alana bırakılınca başlangıç yuvasına dönmeli; para, ihtiyaç, eylem sayısı veya gün değişmemeli.
- Beslemede mama kabı yavruya yaklaşmalı, yavru çiğnemeli, mama görünür biçimde azalmalı ve nesne yuvasına dolu dönmeli.
- Oyunda top iki yönde yuvarlanmalı ve yavru kısa süre topun peşinden gitmeli.
- Uyut eyleminde yavru varsa odadaki yatağa doğru gitmeli, küçülüp yatmalı ve iki gözü çizgi olarak kapanmalı.
- Temizle eyleminde fırça yavruya gitmeli, yavru silkelenmeli ve birden çok köpük görünmeli; Sev eyleminde yavru yaklaşmalı ve kalpler görünmeli.
- Ev düşünce balonu en düşük ihtiyaca uygun simgeyi ve kısa metni göstermeli; uzun görev/ödül satırları balonu taşırmamalı.
- Ses anahtarı anında çalışmalı ve yeniden açılışta korunmalı.
- Normal mama, balık, havuç ve kurabiye seçimi kabın çizimini/etiketini yenilemeli; kap hem dokunma hem sürüklemeyle çalışmalı.
- Kedi balığı, köpek normal mamayı, tavşan havucu, panda kurabiyeyi favori saymalı; favori tokluğu daha fazla artırıp mutlu tepki, sevilmeyen seçenek daha küçük artış ve komik yüz buruşturma üretmeli.
- Bakım sonrasında göz kırpma, etrafa bakma, esneme, kulak oynatma ve el sallama eylem sayısına göre görülmeli; her tepki bitmeli ve ikinci etkileşimi kalıcı olarak kilitlememeli.
- Yeme, uyku, top, köpük, kahkaha ve şaşırma sesleri birbirinden ayırt edilmeli; Ses Kapalı iken hiçbiri çalmamalı.
- `Konuş` en fazla üç saniye kayıt almalı, `Durdur` ile erken bitirilebilmeli ve sesi aynı cihazda geri oynatmalı. Uygulama dosyalarında kalıcı ses birikmemeli; ekran değiştirince kayıt/oynatma durmalı.
- Her dört anlamlı eylemde gün +1 ve para +20 olmalı.
- Her üçüncü başarılı eylemde seçilen kişiliğe uygun özgür irade düşüncesi ve kısa hedef yolculuğu görülmeli; başarısız besleme üçüncü eylem sayılmamalı.
- Özerk an tamamlanmadan ikinci bakım eylemi başlamamalı; tamamlanınca bütün nesne/yavru dönüşümleri başlangıç değerine dönmeli.

## Rehber, büyüme ve zaman

- Rehber sırayla Besle → Oyna → Temizle → Kasaba → Ders → Oda yerleştirme istemeli.
- İlk beş adım 15, son adım 50 pati vermeli; sıra dışı eylem adımı atlamamalı.
- Büyüme puanı 8'de Genç, 24'te Yetişkin olmalı; avatar ölçeği ve profil metni değişmeli.
- Günün bölümü dört eylemde Sabah/Öğle/Akşam/Gece dönmeli.
- Mevsim üç günde bir değişmeli; oda renkleri yenilenmeli.

## Oda ve ekonomi

- Sekiz katalog satırının adı, fiyatı ve etkisi görünmeli.
- Yetersiz para alımı engellemeli; aynı eşya ikinci kez alınamamalı.
- Satın alınan eşya yerleştirilmeli/kaldırılmalı ve yeniden açılışta korunmalı.
- Altı yerleşik eşya sınırı aşılmamalı.
- Top, yatak ve mama kabı bakım bonusu; bitki, kitaplık, piyano ve sanat masası ders bonusu vermeli.
- Odam ekranında yalnızca yerleştirilmiş eşyalara dokunulabilmeli; boş zemine dokunmak tur veya para harcamamalı.
- Yatak Uyut, mama kabı Besle, top Oyna, halı Sev eylemini doğrudan başlatmalı.
- Mama kabı gövde, koyu üst kenar, görünür mama taneleri ve ön pati işaretiyle ilk bakışta ayırt edilmeli.
- Yatak oval dış çeper, iç minder, yükseltilmiş ön kenar ve pati motifiyle gerçek hayvan yatağı olarak ayırt edilmeli.
- Yavru yatak, mama kabı, top, halı ve dört beceri mobilyasına sürüklenebilmeli; hedef sarı halka göstermeli ve geçerli bırakma yalnızca bir etkileşim çalıştırmalı.
- Mama kabı kullanıldığında yavru kaba gitmeli, hareketli mama kabı yaklaşmalı ve içindeki mama azalmalı; sabit oda resmi değişmeden kalmalı.
- Top kullanıldığında hareketli top oda içinde yuvarlanmalı ve yavru peşinden gitmeli; yatakta yavru hedefe gidip kapalı gözle kısa süre yatmalı.
- Halıda sevgi/kalp, piyano ve diğer beceri mobilyalarında ilgili simge ve kısa hedef hareketi görünmeli.
- Oda düşünce balonu tepki sırasında eylem simgesini, boşta beklerken ihtiyaca uygun simgeyi göstermeli.
- Her üçüncü başarılı oda etkileşiminde kişilik uygun yerleştirilmiş eşyayı seçmeli; eşya yoksa yavru ekran içindeki güvenli hedefe gidip geri dönmeli.
- Bitki, kitaplık, piyano ve sanat masası ilgili dersi doğrudan başlatmalı; 10 pati ve yerleşik eşya bonusu uygulanmalı.
- Üst üste gelen halı/eşya dokunma alanlarında görünür küçük eşya halıdan önce seçilmeli.

## Dolap ve avatar

- Baş, Gözlük, Boyun ve Kostüm bölümlerinin her birinde iki; toplam sekiz parça görünmeli.
- Yeni oyunda Kırmızı Kurdele ve Yeşil Tasma sahip olunmuş ve takılmış gelmeli.
- Yetersiz para alımı engellemeli; başarılı alım parayı düşürüp parçayı hemen takmalı.
- Aynı bölgeden ikinci parça giyilince ilki otomatik çıkmalı; Giy/Çıkar durumu doğru yenilenmeli.
- Takılan parçalar dolap önizlemesinde, evde ve etkileşimli odada görünmeli; kayıt sonrası korunmalı.
- Dört hayvan türü ve üç büyüme aşamasında dörtte bir çizim ölçeği, aksesuar katmanları ve en az 54×54 dokunma alanı kontrol edilmeli.
- Dolap önizlemesindeki yavru yavaşça hareket etmeli ve ekran kapanınca animasyon durmalı.

## Harita, kasaba, ilişkiler ve etkinlik

- Haritada Ev, Okul, Dostluk Parkı ve Kasaba Meydanı büyük dokunma alanlarıyla görünmeli.
- Ortadaki yavru dört bölgenin her birine sürüklenince doğru ekran açılmalı; geçersiz alana bırakılınca başlangıç noktasına dönmeli.
- Sürükleme sırasında hedef bölgenin beyaz çerçevesi kalınlaşıp hafif büyümeli; düğmeye tek dokunma aynı geçişi yapmaya devam etmeli.
- Bayrak ve ağaç hafif sallanmalı, fener yavaşça parlamalı; haritadan çıkınca animasyon katmanları temizlenmeli.
- Günlük isteğin bölgesinde sarı çerçeve ve `İstek burada!` metni olmalı; her bölge doğru ekrana gitmeli.
- Dostluk Parkında aynı anda yalnızca dört komşu büyük görsel kartlarda görünmeli; yavru her karta dokunma veya sürüklemeyle gidebilmeli.
- Her ziyaret arkadaşlığı +8 ve komşunun becerisini +1 artırmalı.
- Günün komşu isteği yanlış bölgede tamamlanamamalı ve ödül/tur ilerlemesi olmamalı.
- Doğru bölgede yalnızca bir kez 20 pati, +12 arkadaşlık ve +1 ilgili beceri vermeli.
- 12 gün boyunca sırayla Luna, Zeytin, Mira, Fındık üç kez gelmeli; görev kimlikleri tekrarlanmadan 12 farklı olmalı ve 13. günde ilk görev yeniden başlamalı.
- Park, meydan ve okul görevlerinin her biri dört kez görülmeli; harita işareti gün değişince yenilenmeli.
- Arkadaşlık 40'a ulaştığında dostluk koleksiyonu eklenmeli.
- Günün etkinliği yalnızca bir kez 25 pati ve rozet vermeli; ertesi gün yeniden katılım açılmalı.
- Dört etkinlik ve dört koleksiyon adı sırayla doğrulanmalı.
- Kasaba Meydanında yavru şenlik veya etkin günlük istek kartına sürüklenebilmeli; etkin olmayan istek bırakma hedefi olmamalı.
- Park, Okul ve Meydanda yavru hedefe giderken kısa hareket etmeli, geri dönmeli ve ekran değişince tekrarlayan animasyon kalmamalı.

## Okul ve meslek

- Üst menüdeki `Evimiz` düğmesi tek dokunuşla ana ev ekranına dönmeli.
- Dersler/Meslekler bölümlü denetimi beş büyük kartın içeriğini doğru değiştirmeli; eski metin tablosu görünmemeli.
- Yavru beş ders ve beş meslek kartının her birine sürüklenebilmeli; kart hedefken büyüyüp çerçevesi kalınlaşmalı.
- Ders 10 pati harcamalı ve normalde +1 ilerlemeli.
- İlgili mobilya odadaysa ders +2 ilerlemeli; beceri 10'u aşmamalı.
- Yetişkinlikten önce meslek seçilememeli.
- Yetişkinlikte ilgili beceri 3 altındaysa seçim engellenmeli; 3 ve üstünde meslek kaydolmalı.
- Çalışma aynı gün yalnızca bir kez 45 pati vermeli.

## Mini oyunlar

- Eşleştirmede aynı karta iki kez basmak ikinci seçim sayılmamalı.
- Yanlış çift 0,65 saniye sonra kapanmalı; doğru çift kilitlenmeli.
- Dört çift tamamlanınca günün ilk turunda 30 pati verilmeli.
- Matematikte doğru cevaplar sayılmalı, yanlışta doğru sonuç gösterilmeli ve beş doğruda 30 pati verilmeli.
- Top Yakala sekiz tur boyunca topu farklı konumlara kısa hareketlerle götürmeli; aynı turda art arda dokunmak yalnızca bir skor vermeli.
- Beş veya daha fazla yakalamada günün ilk turu 30 pati vermeli; dört veya altında ödül vermeden tekrar düğmesini açmalı.
- Aynı oyunu aynı gün tekrar bitirmek para vermemeli ama oyun çalışmaya devam etmeli.

## Albüm ve fotoğraf

- Fotoğraf düğmesi 512×352 JPEG üretip albüme eklemeli.
- Otomatik büyüme, etkinlik, meslek ve rehber anıları görünmeli.
- Albüm 12 anıyı aşmamalı; çıkarılan fotoğraf dosyaları temizlenmeli.
- Eksik/bozuk fotoğraf dosyası albümü çökertmemeli.

## Fiziksel iPad 1

- Açılışta çökme olmamalı; iki yatay yönde içerik kırpılmamalı.
- Türkçe karakterler, simgeler ve küçük WAV sesleri doğru çalışmalı.
- Tablolar, harita bölgeleri, dolap düğmeleri ve oda eşyaları rahat dokunulmalı; mini oyunlarda gecikme hissedilmemeli.
- 15 dakika boyunca harita/park/meydan/okul/dolap/oda arasında dolaş, tüm aksesuarları dene, 12 fotoğraf çek ve mini oyun oyna; bellek uyarısı veya kapanma olmamalı.
- Aynı 15 dakikalık turda ekranlara en az 20 kez girip çık; bakımın ortasında da ekran değiştir. Boşta bekleme, bakım, özerk an ve ortam animasyonları birikmemeli, giderek hızlanmamalı veya takılmamalı.
- Mama/top/fırça eylemlerini arka arkaya 30 kez, oda eşyalarını 20 kez çalıştır; bellek uyarısı, kayıp nesne, donmuş dokunma veya üst üste binen gecikmiş hareket olmamalı.
- Dört dokunma bölgesini toplam 40 kez, Top Yakala'yı 10 tur ve üç saniyelik ses tekrarını 10 kez çalıştır; geçici kayıt büyümemeli, ses oturumu kilitlenmemeli ve mikro hareketler birikmemeli.
- Askıya alıp geri dönünce kayıt korunmalı.
