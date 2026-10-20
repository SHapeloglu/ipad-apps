# iPad1TalkingPet v1.4.1 — Clean Neutral Base Update

Bu sürümün amacı, gardırop sisteminin nihayet doğru bir temel karakter asset'i üzerinde çalışmasını sağlamaktır.

## Değişiklik
- `Resources/pet_base_neutral.png` temiz, gerçek alpha kanallı, transparan kıyafetsiz karakter ile değiştirildi.
- Yeni neutral base, kullanıcı tarafından sağlanan şeffaf PNG'den kırpılıp uygulama ölçeğine uygun hale getirildi.
- Kod mimarisi korunmuştur:
  - `ClothingRigManager`
  - torso / hips / left leg / right leg masks
  - Style 1 için segmented clothing rig
  - Style 2 için legacy overlay fallback

## Neden önemli?
Önceki denemelerde:
- eski kıyafetli karakter üstüne yeni kıyafet biniyordu
- veya arka plan temizliği bozuk asset yüzünden görüntü kirleniyordu

Bu sürümde artık temel karakter:
- kıyafetsiz
- temiz transparan
- tek parça
- gardırop sistemi için uygun

## Derleme
```bash
cd ~/projects/iPad1TalkingPet-v1.4.1
rm -rf .theos packages
FINALPACKAGE=1 make package
```

## Test odağı
Önce sadece şu kombinasyonları kontrol et:
1. Tişört Stil 1 + Pantolon Stil 1
2. Crop Stil 1 + Etek Stil 1

Ardından:
- jump
- dance
- wave
- stretch
sırasında kıyafet kayması var mı bak.
