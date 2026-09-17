# PROJECT_CONTEXT

Current version: 0.9.0
Milestone: Living Pet

## Platform constraints
iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1 / armv7 / Objective-C / Theos / non-ARC.

## New architecture
LivingPetManager:
- spontaneous non-user-triggered pet animations
- lightweight NSTimer scheduling

WeeklyEventManager:
- fully offline weekday-based event modifiers

HighScoreManager:
- local high score and combo infrastructure

## Immediate next action
Compile and test on real iPad 1.
Focus on:
- spontaneous animations not colliding with talk/eat/sleep
- wardrobe alignment while spontaneous animation runs
- event discounts
- memory usage after 10+ minutes
