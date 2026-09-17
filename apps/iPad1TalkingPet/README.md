# iPad1TalkingPet v1.2.2 — Clothing Fit Fix

## Bu sürümde
- Tişörtler gövdeye daha dar ve eğimli formda yeniden çizildi.
- Crop üstler gövde oranına göre yeniden çizildi.
- Pantolon/şort kalça-bel formuna göre daraltıldı.
- Pantolonda bacak arası transparan boşluk korunup iyileştirildi.
- Etek daha dar bel bandı + A-line/pileli gövde şeklinde yeniden çizildi.
- Kıyafet `CGRect` konumları gerçek cihazdaki mevcut karakter oranlarına göre yeniden ayarlandı.
- Katman sırası açık şekilde body → top → bottom → shoes → hat/face olarak düzenlendi.
- v1.2.1 hybrid rig ve motionLayer korunur.

## Derleme
```bash
cd ~/projects/iPad1TalkingPet-v1.2.2
rm -rf .theos packages
FINALPACKAGE=1 make package
```
