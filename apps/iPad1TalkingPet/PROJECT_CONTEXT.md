# PROJECT_CONTEXT

## Immutable constraints
- iPad 1 / Apple A4 / 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- UIKit/Foundation/CoreGraphics/AVFoundation
- Theos + legacy iPhoneOS 6.1 SDK
- non-ARC/MRC
- offline-first
- no heavy 3D engine

## Current milestone
v0.5 Character 2.0

## Major architecture change
The pet is no longer baked into the room background.

`RoomBackgroundView`
    -> programmatic lightweight room

`PetCharacterView`
    -> transparent pet_base.png
    -> face animation overlays
    -> outfit layers

This is the required architecture for future real sprite sheets.

## Implemented
- separated transparent pet layer
- idle/blink/talk/happy/sad/touch animations
- outfit slots
- 4 room themes + furniture slot persistence
- 6 food types
- bath foam/shower
- sleep room
- six mini-games
- talking/repeat audio
- XP/levels/coins/daily reward/offline decay
- local photo album
- lightweight travel screen

## Remaining important differences from modern Talking Tom
- true multi-frame body animation art for eat/sleep/run
- more polished clothing artwork instead of procedural overlay shapes
- more furniture artwork
- richer mini-game graphics
- achievements UI
- more destinations/content
- sound effects/music pack

## Immediate next action
Compile and physically test v0.5 on iPad 1.
Do not assume it works until hardware validation.
