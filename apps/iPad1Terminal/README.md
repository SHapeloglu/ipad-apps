# iPad1Terminal

A lightweight local shell and SSH terminal project for a jailbroken **iPad 1 running iOS 5.1.1**.

## Status

Current development line:

```text
0.2.x alpha
```

The Local Terminal PTY and shell have already been demonstrated on real iPad 1 hardware.

Current focus is terminal input correctness and ANSI/VT100 behavior before SSH is added.

---

## Goals

- real local terminal
- PTY-backed shell
- UTF-8 / Turkish input and output
- terminal-specific keyboard controls
- bounded RAM usage
- usable ANSI/VT100 terminal emulation
- later SSH support
- later saved SSH profiles
- lightweight iPad1Files integration

---

## Platform

```text
iPad 1
iOS 5.1.1
armv7
256 MB RAM
jailbreak
Theos
Objective-C
MRC / non-ARC
UIKit / Foundation
```

Current build configuration:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

---

## Current architecture

```text
iOS keyboard
    |
TerminalInputView
    |
TerminalViewController
    |
TerminalANSIParser
    |
LocalTerminalSession
    |
PTY
    |
/bin/sh -i
```

SSH will later reuse the same terminal presentation layer.

---

## Current known state

Working on real hardware:

- app launch
- Local Terminal launch
- PTY allocation
- `/bin/sh -i`
- shell prompt
- terminal output
- bounded scrollback
- terminal resize

Recently addressed:

- raw `[K` ANSI artifacts
- direct terminal keyboard input
- Turkish keyboard input path
- Backspace/PTY erase alignment
- helper key row placement

See:

```text
PROJECT_CONTEXT.md
SESSION.md
```

for the authoritative current state.

---

## Build

```bash
make clean
make package
```

The generated package will be under:

```text
packages/
```

---

## Development rule

Do not begin SSH until the Local Terminal and ANSI/VT100 milestones are stable on the real iPad 1.

---

## Documentation

For a new development chat or contributor, read:

1. `PROJECT_CONTEXT.md`
2. `SESSION.md`
3. `ARCHITECTURE.md`
4. `TASKS.md`
5. `TESTING.md`
6. `INTEGRATION.md`
7. `AGENTS.md`

The `Immediate next action` section in `SESSION.md` is the correct continuation point.
