# PROJECT_CONTEXT

Current version: 1.0.0
Milestone: Emotion & Polish

## Platform constraints
- iPad 1
- Apple A4
- 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C / UIKit
- Theos / legacy iPhoneOS 6.1 SDK
- non-ARC / MRC

## Core architecture

### PetMoodManager
Maps needs to one dominant mood:
- happy
- hungry
- dirty
- sleepy
- bored
- neutral

### LivingPetManager
Uses current needs to choose spontaneous animation rather than pure random behavior.

### HighScoreManager
Persistent local scores and combo multiplier support.

### WeeklyEventManager
Offline weekday event modifiers.

### Wardrobe
Top:
- T-shirt style 1/2
- Crop style 1/2

Bottom:
- Pants style 1/2
- Skirt style 1/2

Head/face/shoes retained.

## Immediate next action
Compile on the user's legacy Theos toolchain and test on physical iPad 1.

Priority tests:
1. Build compatibility with iOS 5 SDK APIs
2. Mood label updates
3. Need-based spontaneous reactions
4. Runner high-score/combo
5. Scores screen
6. Food list expansion
7. 15+ minute memory stability
8. Outfit alignment while LivingPet animations run
