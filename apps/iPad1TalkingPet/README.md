# iPad1TalkingPet v1.3 — Clothing Rig & Mask System

## Amaç
Kıyafetlerin karakterin üstüne yapıştırılmış gibi görünmesi sorununu çözmek.

## Yeni mimari
`ClothingRigManager`:
- attachment mantığı
- CALayer mask kullanımı
- kıyafeti parçalara bölme
- hareket anında kıyafet parçasını ilgili bölgeyle birlikte transform etme

### Tişört Stil 1
- gövde
- sol kol
- sağ kol
- torso mask

### Crop Stil 1
- gövde
- sol kol
- sağ kol
- torso mask

### Pantolon Stil 1
- bel
- sol paça
- sağ paça
- hips + leg masks

### Etek Stil 1
- arka panel
- bel
- ön panel

## Neden sadece Stil 1?
Önce mimarinin gerçek cihazda doğru çalıştığını kanıtlamak için.
Stil 1 düzgün görünürse Stil 2'ler aynı sisteme kolayca taşınabilir.

## iPad 1 performans yaklaşımı
- mesh engine yok
- physics yok
- 3D yok
- sadece UIImageView/CALayer/mask/transform
- az sayıda katman
- MRC uyumlu

## Derleme
```bash
cd ~/projects/iPad1TalkingPet-v1.3
rm -rf .theos packages
FINALPACKAGE=1 make package
```
