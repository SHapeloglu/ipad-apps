# PROJECT_CONTEXT

## Hard constraints
- iPad 1
- Apple A4
- 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- Theos + legacy iPhoneOS 6.1 SDK
- non-ARC / MRC
- offline-first
- no heavy 3D engine

## Goal
Talking-pet oyun döngüsünü özgün beyaz kedi karakteriyle iPad 1 üzerinde akıcı çalıştırmak.

## v0.3 implemented
- Talking/repeat audio
- Hunger/Happiness/Hygiene/Energy
- Offline decay
- XP / levels / coins / daily reward
- Touch reactions
- Wardrobe purchase persistence
- Food drag-to-mouth interaction
- Bath soap + shower sequence
- Sleep room + lamp sequence
- Mini-game menu
- Pati Yakala
- Baloncuk Patlat

## Known gap
Character is still baked into the room artwork. Therefore:
- wardrobe ownership is functional but visual outfit compositing is not yet final
- true blink/talk/eat/sleep sprite animation requires separate transparent art frames

## Immediate next action
Compile and physically test v0.3 on iPad 1.
Then create/approve transparent character animation frames and wire them into a lightweight UIImageView sprite animator.
