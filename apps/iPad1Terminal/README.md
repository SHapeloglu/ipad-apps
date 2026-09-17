# iPad1Terminal

Lightweight local shell and future SSH terminal for a jailbroken iPad 1.

## Platform

- iPad 1
- iOS 5.1.1
- armv7
- 256 MB RAM
- Objective-C
- non-ARC / MRC
- Theos
- UIKit / Foundation

## v0.1 milestone

The first milestone intentionally implements only:

1. Launch application.
2. Open **Local Terminal**.
3. Allocate a POSIX pseudo terminal.
4. Fork and launch `/bin/sh -i`.
5. Send commands from the UI.
6. Read terminal output without blocking the main thread.
7. Provide Esc, Ctrl+C, Tab and arrow keys.
8. Limit terminal scrollback memory.

SSH is deliberately postponed until the local PTY works on real hardware.

## Build

From the project root:

```bash
make clean
make package
```

If your installed SDK is represented by a different Theos target string, adjust `TARGET` in the Makefile while keeping deployment target 5.1 and `ARCHS = armv7`.

## Install

Install the generated `.deb` on the jailbroken iPad with your normal SCP/dpkg flow.

## First hardware test

Open **Local Terminal** and run:

```bash
pwd
whoami
uname -a
ls -la
df -h
echo "Türkçe: ğüşiöç İĞÜŞÖÇ"
```

Expected initial working directory is `/var/mobile`.

## Important

A normal App Store sandbox cannot provide a real fork/exec terminal. This project assumes the existing jailbroken/Theos deployment environment.
