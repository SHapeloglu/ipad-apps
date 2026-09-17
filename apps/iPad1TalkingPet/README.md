# iPad1TalkingPet v1.2 — 2D Rig Animation

Bu sürüm Tom-benzeri akıcılığı iPad 1 sınırları içinde artırmak için hibrit 2D rig sistemini getirir.

## Yeni
- PetRigView
- Ayrı kafa, gövde, kol, bacak ve kuyruk katmanları
- Anchor-point tabanlı parça animasyonları
- Baş eğme
- Kol sallama
- Kuyruk hareketi
- Zıplamada squash/stretch hissi
- Ayrı göz katmanları
- Ayrı göz kapağı katmanları
- 4 ağız şekli
- Konuşma sırasında ağız animasyonu
- Bakış yönü animasyonu
- Sprite sistemi fallback olarak korunur

## Gardırop
Mevcut kıyafet overlay sistemi korunur.
Bu sürümden sonraki adım, kıyafetleri rig parçalarına bağlayarak kol/gövde ile birlikte hareket ettirmektir.

## Derleme
```bash
cd ~/projects/iPad1TalkingPet-v1.2
rm -rf .theos packages
FINALPACKAGE=1 make package
```
