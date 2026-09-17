# iPad1TalkingPet v1.2.1 — Hybrid Rig Hotfix

Gerçek cihazdaki parçalanmış/kolaj görünümü düzeltilmiştir.

## Neden oldu?
v1.2'de `pet_base.png` dosyasından dikdörtgen crop ile kafa/kol/gövde/bacak parçaları
üretilmişti. Crop alanları gerçek alfa maskeli anatomik parçalar olmadığı için kompozisyonda
dikdörtgen bölgeler, çift görüntüler ve kopmuş eklemler oluşuyordu.

## Düzeltme
- Parçalı gövde rig'i ekranda kullanılmıyor.
- Tek ve temiz `pet_base.png` karakteri korunuyor.
- Göz kapağı ve ağız gibi yüz rig katmanları hafif overlay olarak devam ediyor.
- Animasyonlar artık karakter + kıyafetleri birlikte taşıyan `motionLayer` üzerinden uygulanıyor.
- Gardırop hareket sırasında karakterden ayrılmıyor.
- Eski sprite fallback korunuyor.

Bu sürüm görsel bütünlüğü önceliklendirir. Gerçek bağımsız kol/bacak rig için
ileride elle hazırlanmış alfa maskeli parçalar gerekir.
