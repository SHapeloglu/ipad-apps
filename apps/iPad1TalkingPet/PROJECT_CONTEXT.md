# PROJECT_CONTEXT

Current version: 1.2.1
Milestone: Hybrid Rig Hotfix

Platform constraints unchanged:
iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1 / armv7 / non-ARC.

## Important architecture decision
Do NOT use rectangular crops of pet_base.png as anatomical rig parts.
They create duplicated pixels and visible rectangular seams.

Current stable approach:
- coherent full-body pet_base.png
- subtle face overlays
- unified motionLayer for character + clothing
- lightweight transform animations
- sprite fallback preserved

Future true limb rig requires manually prepared transparent, non-overlapping body-part assets.

## Immediate next action
Compile and physically verify:
- character is visually whole
- no rectangular body seams
- clothing follows jump/dance/stretch
- mouth overlay is subtle
- no doubled eyes
