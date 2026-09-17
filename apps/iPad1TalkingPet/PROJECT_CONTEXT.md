# PROJECT_CONTEXT

Current version: 1.4.1
Milestone: Clean Neutral Base Integration

Platform:
iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1 / armv7 / Objective-C / Theos / non-ARC.

## Key update
The application now uses a proper transparent neutral base character:
`Resources/pet_base_neutral.png`

This asset replaces the previously auto-extracted noisy neutral base.

## Architecture kept
- neutral base character
- ClothingRigManager
- torso / hips / left leg / right leg masks
- segmented Style 1 clothing
- legacy Style 2 clothing fallback
- lightweight UIImageView/CALayer transform approach

## Immediate next action
Compile and physically test:
1. neutral base visual quality
2. T-shirt Style 1 + Pants Style 1
3. Crop Style 1 + Skirt Style 1
4. wave/jump/dance/stretch
5. any halo or outline issues on light/dark room themes
