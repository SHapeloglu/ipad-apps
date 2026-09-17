# PROJECT_CONTEXT

## Platform constraints
- iPad 1
- Apple A4
- 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- Theos
- legacy iPhoneOS 6.1 SDK
- non-ARC / MRC
- Offline-first
- Ağır 3D engine yok

## Product goal
My Talking Tom benzeri temel sanal evcil hayvan döngüsünü, özgün beyaz kedi karakteri ve özgün görsellerle iPad 1'de akıcı biçimde sunmak.

## Current implemented gameplay
- Needs: hunger, happiness, hygiene, energy
- Offline decay
- Touch reactions
- Talking/repeat audio
- XP / levels
- Coins
- Daily reward
- Wardrobe ownership/select state
- Mini game
- Persistent save

## Known visual limitation
Character is still baked into the current room image.
Wardrobe state is functional but cannot visually alter the baked-in character yet.

## Immediate next action
1. Build and install v0.2 on real iPad 1.
2. Verify microphone record/repeat.
3. Verify mini-game.
4. Verify wardrobe purchase persistence.
5. Verify RAM/stability.
6. Then split character from background into lightweight sprites.
