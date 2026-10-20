# CLAUDE

This repository is a legacy iOS project with strict constraints.

Read `PROJECT_CONTEXT.md` and `SESSION.md` before making changes.

## Hard constraints

```text
iPad 1
iOS 5.1.1
armv7
256 MB RAM
jailbreak
Theos
Objective-C
non-ARC / MRC
UIKit / Foundation
```

Do not modernize the deployment target.

Do not introduce Swift.

Do not use iOS APIs unavailable on iOS 5.1.1.

Do not add a WebView-based terminal.

## Current build target

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

This is intentional.

The iPhoneOS9.3 SDK path previously produced bad simulator `.tbd` linker behavior for this armv7 project.

## Current project phase

The PTY/local shell has already been proven on real iPad 1 hardware.

Current work is focused on:

1. input correctness
2. Turkish/UTF-8 keyboard input
3. Backspace
4. helper-key UI
5. ANSI/VT100 terminal correctness

Do not skip to SSH before `SESSION.md` says the Local Terminal milestone has passed.

## Architecture

Keep these concepts separate:

```text
TerminalInputView
TerminalViewController
TerminalANSIParser
LocalTerminalSession
future TerminalScreen
future SSHSession
```

## Terminal direction

The current ANSI parser is transitional.

The desired next major architecture is:

```text
PTY bytes
-> ANSI parser
-> fixed-size terminal screen/cursor model
-> UIKit renderer
```

Do not permanently solve terminal escape codes by just deleting them all.

## Memory

Everything must be designed for 256 MB RAM.

Keep all histories and buffers bounded.

## MRC

Manual retain/release only.

Do not convert files to ARC.

## Testing

Real-device behavior is authoritative.

A successful compile does not prove an API works correctly on iOS 5.1.1.

After code changes, follow `TESTING.md`.

## Documentation

At session end update `SESSION.md`, especially:

```text
Immediate next action
```
