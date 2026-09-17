# Pati Kasabası

Pati Kasabası, iPad 1 için çevrimdışı ve çocuk dostu bir hayvan yaşam simülasyonudur. Oyuncu barınaktan veya pet shop'tan bir yavru seçer; bakımını yapar, evini düzenler, kasaba dostlarıyla ilişki kurar, beceriler öğrenir ve yavrudan yetişkinliğe birlikte büyür.

## Platform sınırları

- iPad 1 / iOS 5.1.1 / Apple A4 / armv7 / 256 MB RAM
- Objective-C, UIKit, Foundation, Core Graphics, AudioToolbox ve AVFoundation
- Theos + legacy iPhoneOS 6.1 SDK
- non-ARC / MRC
- Tamamen çevrimdışı; hesap, reklam, gerçek para ve sohbet yok

## 0.7.0-alpha7 kapsamı

- Barınak veya pet shop ile başlayan sahiplenme akışı
- Kedi, köpek, tavşan ve panda; isim ve beş kişilik seçimi
- Altı ihtiyaç ve beş bakım eylemi
- Baş, karın, pati ve kuyruğa dokununca ayrı tepki; açılıp kapanabilen sesler ve her bakım eylemine özgü kısa görsel dizi
- Göz kırpma, etrafa bakma, esneme, kulak oynatma ve el sallamadan oluşan kısa mikro hareketler
- Evdeki mama, top ve fırçayı yavrunun üzerine sürükleme; büyük bakım düğmeleri dokunma alternatifi olarak korunur
- Normal mama, balık, havuç ve kurabiye seçimi; hayvan türüne göre favori, nötr veya komik sevmeme tepkisi
- Beslemede kabın yavruya gidip boşalması ve çiğneme; oyunda topun yuvarlanması ve yavrunun kovalaması
- Uykuda yatağa gidiş ve kapanan gözler; temizlikte fırça, köpük ve silkelenme; sevgide yaklaşma ve kalpler
- Uzun açıklamalar yerine ihtiyacı ve anlık tepkiyi gösteren kısa metinli Core Graphics düşünce balonları
- Yavru → genç → yetişkin büyümesi; ölüm veya kalıcı kayıp yok
- Sekiz eşyalı envanter, sabit yuvalı oda düzenleme ve dokunarak kullanılan işlevsel mobilyalar
- Dört giyim yuvasına ayrılmış sekiz parçalı kıyafet/aksesuar dolabı
- Beş becerili Pati Okulu, yetişkinlikte beş meslek ve günlük çalışma
- Ev, okul, Dostluk Parkı ve meydanı gösteren görsel kasaba haritası
- Dört kasaba komşusu, üçer tane olmak üzere 12 dönüşümlü ve konuma bağlı günlük istek
- Günün bölümü, dört mevsim ve dört dönüşümlü kasaba etkinliği
- Pati Eşleştirme, Mama Matematiği ve sekiz turluk Top Yakala mini oyunları
- Yeme, uyku, top, köpük, kahkaha ve şaşırma için düşük boyutlu mono eylem sesleri
- `Konuş` düğmesiyle en fazla üç saniyelik çevrimdışı kayıt ve aynı iPad içinde geri oynatma; ağ aktarımı yok
- Fotoğraf çekimi, büyüme/etkinlik anıları ve koleksiyon albümü
- Her üçüncü başarılı eylemden sonra kişiliğe bağlı, eylemle tetiklenen görsel “özgür irade” anları
- Bütün hayvan çizimlerinde önceki boyutun dörtte biri olan ortak görsel ölçek; en az 54×54 dokunma alanı
- Mama, kap gövdesi, üst kenar, gölge ve pati işaretiyle yeniden çizilmiş mama kabı
- Haritadaki yavruyu dört bölgeye sürükleyerek gezinme; büyük bölge düğmeleri dokunma alternatifi olarak korunur
- Core Graphics ile çizilen bayrak, ağaç ve fenerde düşük maliyetli ortam hareketleri; ev, oda ve dolapta hafif yavru hareketi
- Park, Pati Okulu ve Kasaba Meydanında metin tablosu yerine Core Graphics sahnesi, büyük etkinlik kartları ve ekranda görünen yavru
- Evde bakım düğmelerine; odada yatak, mama kabı ve oyuncağa; okul, park ve meydanda etkinlik hedeflerine yavru sürükleme
- Oda eşyasına dokunulduğunda veya yavru üzerine bırakıldığında yavrunun eşyaya gidip sonucu görsel olarak oynaması
- Pati Okulunda Dersler/Meslekler görsel geçişi ve her zaman görünen `Evimiz` üst menü düğmesi
- Yükseltilmiş kenarı, iç minderi ve pati motifi olan gerçek hayvan yatağı çizimi
- Sürekli ağır oyun döngüsü yerine kısa yolculuk, tepki ve boşta bekleme hareketleriyle “Sims hissi”; ekran kapanınca bütün hareketler durur
- `NSUserDefaults` tabanlı sürüm 3 kayıt; 0.1/0.2 kayıtları için geriye dönük varsayılanlar

## Derleme

```bash
cd PatiKasabasi
./scripts/validate_project.sh
make clean package
```

Dağıtım paketi `packages/` altında oluşur. Bu kaynak tesliminde statik legacy doğrulaması yapılmıştır; gerçek armv7 derlemesi ve fiziksel iPad 1 testi için legacy Theos ortamı gerekir.

## Tasarım yaklaşımı

Oyun açık dünya yerine küçük ekranlara ayrılır. Harita yalnızca dört hafif bölge arasında geçiş sağlar; görseller çoğunlukla Core Graphics şekilleridir ve parkta en fazla dört hayvan çizilir. Oyuncu yavruyu hedeflere götürür; sistem kısa yolculuk ve tepki animasyonlarıyla canlılık üretir. Hareketli görünümler Core Graphics ile bir kez çizilen küçük katmanların kısa dönüşümleridir, ekran kapanınca durdurulur ve GIF/SVG oynatıcı ya da sürekli zamanlayıcı kullanılmaz. Mama, top ve fırça için ayrı bitmap tutulmaz. Zaman yalnızca oyuncu eylemleriyle ilerler, dolayısıyla uygulama kapalıyken çocuk cezalandırılmaz.
