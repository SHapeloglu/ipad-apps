# CLAUDE.md

## Project
iPad1Files — shared file manager and common storage layer for iPad 1 / iOS 5.1.1.

## Hard compatibility rules
- Deployment target: iOS 5.1
- Architecture: armv7
- Objective-C manual reference counting (`-fno-objc-arc`)
- Do not introduce Swift
- Do not use APIs introduced after iOS 5 unless guarded and optional
- Prefer Foundation/UIKit APIs already used by legacy iOS
- Keep memory allocations conservative

## Storage contract
Never casually change:
`/var/mobile/Media/iPad1Files`

Existing and future iPad1 applications rely on this path.

## Build
```bash
make clean
make package FINALPACKAGE=1
```

## Design rule
Reusable filesystem behavior belongs in IP1* classes, not directly inside view controllers.
