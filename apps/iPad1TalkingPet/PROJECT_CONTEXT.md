# PROJECT_CONTEXT

Current version: 1.3.0
Milestone: Clothing Rig & Mask System

Platform:
iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1 / armv7 / Objective-C / Theos / non-ARC.

## Key change
Flat clothing overlays are no longer the primary method for Style 1.

ClothingRigManager uses:
- torso mask
- hips mask
- left/right leg masks
- segmented shirt sleeves
- segmented pants legs
- skirt back/front layering
- lightweight transforms for wave/jump/dance/stretch

Style 2 still uses the legacy flat overlay as fallback.

## Immediate next action
Compile and physically test Style 1 only:
1. T-shirt Style 1
2. Crop Style 1
3. Pants Style 1
4. Skirt Style 1
5. combinations
6. wave/jump/dance/stretch

If Style 1 works, port Style 2 assets to the same rig.
