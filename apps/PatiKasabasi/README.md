# Pati Kasabası

Pati Kasabası, iPad 1 için çevrimdışı ve çocuk dostu bir hayvan yaşam simülasyonudur. Oyuncu barınaktan veya pet shop'tan bir yavru seçer; bakımını yapar, evini düzenler, kasaba dostlarıyla ilişki kurar, beceriler öğrenir ve yavrudan yetişkinliğe birlikte büyür.

## Platform sınırları

- iPad 1 / iOS 5.1.1 / Apple A4 / armv7 / 256 MB RAM
- Objective-C, UIKit, Foundation, Core Graphics ve AudioToolbox
- Theos + legacy iPhoneOS 6.1 SDK
- non-ARC / MRC
- Tamamen çevrimdışı; hesap, reklam, gerçek para ve sohbet yok

## 0.3.0-alpha3 kapsamı

- Barınak veya pet shop ile başlayan sahiplenme akışı
- Kedi, köpek, tavşan ve panda; isim ve beş kişilik seçimi
- Altı ihtiyaç ve beş bakım eylemi
- Hayvana dokununca tepki, kısa eylem animasyonları ve açılıp kapanabilen sesler
- Yavru → genç → yetişkin büyümesi; ölüm veya kalıcı kayıp yok
- Sekiz eşyalı envanter, sabit yuvalı oda düzenleme ve dokunarak kullanılan işlevsel mobilyalar
- Dört giyim yuvasına ayrılmış sekiz parçalı kıyafet/aksesuar dolabı
- Beş becerili Pati Okulu, yetişkinlikte beş meslek ve günlük çalışma
- Ev, okul, Dostluk Parkı ve meydanı gösteren görsel kasaba haritası
- Dört kasaba komşusu, üçer tane olmak üzere 12 dönüşümlü ve konuma bağlı günlük istek
- Günün bölümü, dört mevsim ve dört dönüşümlü kasaba etkinliği
- Pati Eşleştirme ve Mama Matematiği mini oyunları
- Fotoğraf çekimi, büyüme/etkinlik anıları ve koleksiyon albümü
- Kişiliğe bağlı, eylemle tetiklenen küçük “özgür irade” anları
- `NSUserDefaults` tabanlı sürüm 3 kayıt; 0.1/0.2 kayıtları için geriye dönük varsayılanlar

## Derleme

```bash
cd PatiKasabasi
./scripts/validate_project.sh
make clean package
```

Dağıtım paketi `packages/` altında oluşur. Bu kaynak tesliminde statik legacy doğrulaması yapılmıştır; gerçek armv7 derlemesi ve fiziksel iPad 1 testi için legacy Theos ortamı gerekir.

## Tasarım yaklaşımı

Oyun açık dünya yerine küçük ekranlara ayrılır. Harita yalnızca dört hafif bölge arasında geçiş sağlar; görseller çoğunlukla Core Graphics şekilleridir ve parkta en fazla dört hayvan çizilir. Zaman yalnızca oyuncu eylemleriyle ilerler, dolayısıyla uygulama kapalıyken çocuk cezalandırılmaz ve arka planda sürekli zamanlayıcı çalışmaz.
