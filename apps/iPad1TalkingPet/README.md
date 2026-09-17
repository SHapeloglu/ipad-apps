# iPad1TalkingPet v1.4 — Neutral Base Clothing Rig

## En önemli değişiklik
Kıyafet sistemi artık eski kıyafetli karakter yerine `pet_base_neutral.png` kullanır.

Bu sayede:
- kıyafet kıyafetin üstüne binmez
- bel/kalça/gövde bölgeleri daha temiz görünür
- ClothingRigManager maskeleri daha anlamlı çalışır
- tişört/crop/pantolon/etek karakterin nötr anatomisine bağlanır

## Mimari
- neutral base character
- ClothingRigManager
- torso / hips / left leg / right leg masks
- segmented top/bottom clothing
- attachment-like transforms
- no mesh engine / no physics
- iPad 1 friendly

## Not
Bu sürümde nötr karakter görseli yüklenen referanstan hazırlanmıştır.
Arka planı temizlemek için hafif alfa ayrıştırması uygulanmıştır.
Gerçek cihazda kenar kalitesi ve olası arka plan kalıntıları kontrol edilmelidir.

## Derleme
```bash
cd ~/projects/iPad1TalkingPet-v1.4
rm -rf .theos packages
FINALPACKAGE=1 make package
```
