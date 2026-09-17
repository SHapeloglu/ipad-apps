# Test Planı

## Derleme kapısı

- `ARCHS=armv7`, deployment target 5.1, iPhoneOS 6.1 SDK, ARC kapalı.
- `./scripts/validate_project.sh` geçmeli.
- Derleyici uyarıları incelenmeli; modern API veya sahiplik uyarısı kalmamalı.
- Üretilen paketin mimarisi ve sürümü `iphoneos-arm / 0.3.0-alpha3` olmalı.

## Sahiplenme ve kayıt geçişi

1. Barınaktan yeni oyun başlat; dört türü, boş isim engelini ve beş kişiliği dene.
2. Evde 500 pati, yatak ve mama kabını doğrula.
3. Pet shop yolunda 300 pati, top sahipliği ve topun odada olduğunu doğrula.
4. Uygulamayı kapat/aç; Devam Et ile tüm değerlerin korunduğunu doğrula.
5. 0.1.0-alpha1 ve ayrı olarak 0.2.0-alpha2 kaydı olan cihazda 0.3'ü aç; eski yavru, ekonomi ve ihtiyaçlar korunurken kırmızı kurdele/yeşil tasmanın dolaba eklenip takılmasını doğrula.
6. Kaydet, uygulamayı yeniden aç ve eşya yerleşimi ile takılan aksesuarların aynı kaldığını doğrula.
7. Yeni Oyun seçeneğinde onaydan sonra eski kayıt ve fotoğraf klasörünün temizlendiğini doğrula.

## Ev, bakım ve tepki

- Besle 5 pati harcamalı; mama kabı yerleştirilmişse ek bonus vermeli.
- Para yetersizse besleme ve tur ilerlemesi olmamalı.
- Oyna, Uyut, Temizle ve Sev beklenen ihtiyaçları değiştirmeli; bütün değerler 0–100 kalmalı.
- Hayvana dokunmak sevgi eylemi, kalp tepkisi, kısa animasyon ve metin vermeli.
- Eylem simgeleri yaklaşık 0,4 saniyede temizlenmeli; ekran kapanınca gecikmiş çağrı çökmemeli.
- Ses anahtarı anında çalışmalı ve yeniden açılışta korunmalı.
- Her dört anlamlı eylemde gün +1 ve para +20 olmalı.
- Her üçüncü eylemde seçilen kişiliğe uygun özgür irade metni görülebilmeli.

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
- Bitki, kitaplık, piyano ve sanat masası ilgili dersi doğrudan başlatmalı; 10 pati ve yerleşik eşya bonusu uygulanmalı.
- Üst üste gelen halı/eşya dokunma alanlarında görünür küçük eşya halıdan önce seçilmeli.

## Dolap ve avatar

- Baş, Gözlük, Boyun ve Kostüm bölümlerinin her birinde iki; toplam sekiz parça görünmeli.
- Yeni oyunda Kırmızı Kurdele ve Yeşil Tasma sahip olunmuş ve takılmış gelmeli.
- Yetersiz para alımı engellemeli; başarılı alım parayı düşürüp parçayı hemen takmalı.
- Aynı bölgeden ikinci parça giyilince ilki otomatik çıkmalı; Giy/Çıkar durumu doğru yenilenmeli.
- Takılan parçalar dolap önizlemesinde, evde ve etkileşimli odada görünmeli; kayıt sonrası korunmalı.
- Dört hayvan türü ve üç büyüme aşamasında aksesuar katmanları yüzü ve dokunma alanını bozmayacak şekilde kontrol edilmeli.

## Harita, kasaba, ilişkiler ve etkinlik

- Haritada Ev, Okul, Dostluk Parkı ve Kasaba Meydanı büyük dokunma alanlarıyla görünmeli.
- Günlük isteğin bölgesinde sarı çerçeve ve `İstek burada!` metni olmalı; her bölge doğru ekrana gitmeli.
- Dostluk Parkında aynı anda yalnızca dört komşu görünmeli ve tablo akıcı kaymalı.
- Her ziyaret arkadaşlığı +8 ve komşunun becerisini +1 artırmalı.
- Günün komşu isteği yanlış bölgede tamamlanamamalı ve ödül/tur ilerlemesi olmamalı.
- Doğru bölgede yalnızca bir kez 20 pati, +12 arkadaşlık ve +1 ilgili beceri vermeli.
- 12 gün boyunca sırayla Luna, Zeytin, Mira, Fındık üç kez gelmeli; görev kimlikleri tekrarlanmadan 12 farklı olmalı ve 13. günde ilk görev yeniden başlamalı.
- Park, meydan ve okul görevlerinin her biri dört kez görülmeli; harita işareti gün değişince yenilenmeli.
- Arkadaşlık 40'a ulaştığında dostluk koleksiyonu eklenmeli.
- Günün etkinliği yalnızca bir kez 25 pati ve rozet vermeli; ertesi gün yeniden katılım açılmalı.
- Dört etkinlik ve dört koleksiyon adı sırayla doğrulanmalı.

## Okul ve meslek

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
- Askıya alıp geri dönünce kayıt korunmalı.
