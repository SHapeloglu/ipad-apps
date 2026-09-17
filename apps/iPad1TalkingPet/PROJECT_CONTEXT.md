# PROJECT_CONTEXT

## Platform
- iPad 1
- Apple A4
- 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- Theos
- legacy iPhoneOS 6.1 SDK
- non-ARC / MRC

## Product Goal
Talking-pet tarzı, tamamen offline çalışan, özgün beyaz kedi karakterli sanal evcil hayvan oyunu.

## Visual Direction
Ana karakter:
- Beyaz tüylü
- Büyük mavi gözlü
- Pembe tişört
- Sarı kalp
- Açık mavi kot şort

## v0.1 Architecture
Tek ana ekran, statik optimize edilmiş arka plan ve UIKit overlay.
Ağır 3D engine yok.
Video tabanlı sürekli animasyon yok.
OpenGL zorunlu değil.

## Immediate next action
Fiziksel iPad 1 üzerinde v0.1'i derle, kur ve şu 6 alanı doğrula:
1. Food
2. Bath
3. Sleep
4. Play
5. Wardrobe
6. Character touch

Ardından karakteri arka plandan ayırıp hafif sprite animasyon sistemine geç.
