# iPad1Terminal 0.2 alpha

A lightweight real local terminal for jailbroken iPad 1 / iOS 5.1.1.

## Current milestone

The PTY and `/bin/sh` have already been confirmed on real iPad 1 hardware.

0.2 improves the UI based on the first hardware screenshot:

- direct terminal keyboard input
- no separate white command field
- basic ANSI escape suppression
- fixes visible `[K` artifacts
- visible special terminal key bar
- Backspace / Enter / Esc / Ctrl+C / Tab / arrows
- `~` and `|`
- bounded scrollback
- iOS 5.1 / armv7 / MRC

## Build

```bash
make clean
make package
```

## Install/test before SSH

```bash
pwd
whoami
ls -la
clear
```

SSH remains intentionally postponed until this terminal UI passes real-device validation.
