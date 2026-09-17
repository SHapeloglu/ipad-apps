# PROJECT_CONTEXT

## Immutable constraints
- iPad 1 / Apple A4 / 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C / Theos / legacy iPhoneOS 6.1 SDK
- non-ARC/MRC
- offline-first
- no heavy 3D engine

## Current version
0.6.0

## Architecture
RoomBackgroundView
  -> programmatic room
  -> real furniture PNG assets

PetCharacterView
  -> transparent pet_base.png
  -> PetSpriteAnimator
  -> pre-rendered animation frame PNGs
  -> lightweight outfit overlay slots

SoundManager
  -> short WAV SFX
  -> looping room music

AchievementManager
  -> persistent achievements
  -> daily counters

## v0.6 implemented
- real multi-frame sprite playback
- idle/blink/talk/happy/sad/touch/chew/sleep animation sets
- sound effects and room music
- real furniture PNG swapping
- achievements
- daily tasks
- level-up feedback
- previous v0.5 gameplay retained

## Immediate next action
Compile and test on the physical iPad 1.

Do not mark complete until:
1. all animation sets render
2. no memory warning/crash after repeated animations
3. music/SFX do not block talking audio
4. furniture switching works
5. daily task counters increment
6. level-up alert works
