# Değişiklik Günlüğü

## 0.4.0-alpha4

- Bütün Core Graphics hayvan çizimleri ortak `visualScale=0.25` ile önceki görünür boyutun dörtte birine indirildi; en az 54×54 dokunma hedefi korundu.
- Oda ve besleme tepkisindeki mama kabı gölge, gövde, koyu üst kenar, mama taneleri ve pati işaretiyle yeniden çizildi.
- Haritadaki yavruyu Ev, Pati Okulu, Dostluk Parkı veya Kasaba Meydanına sürükleyerek gezinme eklendi; büyük bölge düğmeleri dokunma alternatifi olarak korundu.
- Haritaya Core Graphics ile çizilen bayrak, ağaç ve fener eklendi; yalnızca transform/alpha katman animasyonlarıyla hareket ediyor.
- Ev, oda, dolap ve harita yavrularına 5 puntoluk yavaş boşta bekleme hareketi eklendi.
- Ekran kaybolurken sürekli animasyonların kaldırılması ve gecikmiş harita geçişlerinin iptali eklendi.
- Doğrulayıcı GIF kare dizisi, SVG yorumlayıcı, `NSTimer`, `CADisplayLink` ve yanlış legacy animasyon çağrılarını engelleyecek şekilde genişletildi.
- Kayıt biçimi sürüm 3 olarak korundu; alpha4 yeni kalıcı alan gerektirmiyor.

## 0.3.0-alpha3

- Baş, yüz, boyun ve gövde yuvalarında sekiz parçalı aksesuar/kıyafet dolabı eklendi.
- Takılan parçalar Core Graphics avatarına, ev ve oda önizlemelerine bağlandı.
- Ayrı etkileşimli oda ekranı eklendi; yerleştirilmiş mobilyalara dokunmak bakım veya beceri eylemini çalıştırıyor.
- Ev, Pati Okulu, Dostluk Parkı ve Kasaba Meydanı arasında görsel harita eklendi.
- Dört komşuya üçer tane düşen 12 günlük görev ve okul/park/meydan konum doğrulaması eklendi.
- Komşular Dostluk Parkına, etkinlikler Kasaba Meydanına ayrıldı.
- Kayıt formatı sürüm 3'e yükseltildi; 0.1/0.2 kayıt anahtarı ve geçişi korundu.
- Legacy UIKit animasyonlarında iOS 5 uyumlu `setAnimationRepeatAutoreverses:` çağrısı kullanıldı.

## 0.2.0-alpha2

- Altı adımlı, para ödüllü Pati Rehberi eklendi.
- Yavru, genç ve yetişkin büyüme aşamaları eklendi.
- Hayvana dokunma tepkileri, eylem sembolleri, kısa animasyonlar ve ses aç/kapa eklendi.
- Sekiz eşyalı envanter ve sabit yuvalı oda düzenleme eklendi; bakım/ders bonuslu mobilyalar uygulandı.
- Günün dört bölümü, dört mevsim ve dört kasaba etkinliği eklendi.
- Dört komşu, günlük komşu istekleri, arkadaşlık puanları ve dostluk koleksiyonları eklendi.
- Beş beceri, Pati Okulu, beş yetişkin mesleği ve günlük çalışma eklendi.
- Pati Eşleştirme ve Mama Matematiği mini oyunları eklendi.
- Fotoğraf çekimi, otomatik anılar ve koleksiyon albümü eklendi.
- Kişiliğe bağlı, sürekli zamanlayıcı kullanmayan özgür irade olayları eklendi.
- Kayıt formatı sürüm 2 alanlarıyla genişletildi; 0.1 kayıt geçişi korundu.
- Fotoğraflar 12 anı ve 512×352 JPEG ile, oda altı eşya ve kasaba dört hayvan ile sınırlandı.

## 0.1.0-alpha1

- iPad 1 / iOS 5.1.1 / armv7 / non-ARC Theos proje temeli kuruldu.
- Barınak ve pet shop başlangıç yolları, dört yavru, isim ve beş kişilik eklendi.
- Core Graphics hayvan çizimleri, altı ihtiyaç ve beş bakım eylemi eklendi.
- Gün, pati parası, bakım harçlığı, çevrimdışı kayıt, simge ve kurulum yönergesi eklendi.
