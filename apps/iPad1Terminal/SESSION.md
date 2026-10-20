# SESSION

## Current status

Project: `iPad1Terminal`

Current intended build:

```text
0.2.1-alpha1
```

Platform:

```text
iPad 1
iOS 5.1.1
armv7
256 MB RAM
jailbreak
Objective-C / MRC
Theos
```

Working build target:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

---

## Completed

### Project bootstrap

- Theos application skeleton
- iPad-only application configuration
- armv7 target
- iOS 5.1 deployment target
- MRC / no ARC
- Home screen
- Local Terminal screen

### PTY / local shell

- POSIX PTY allocation
- `posix_openpt`
- `grantpt`
- `unlockpt`
- `ptsname`
- `fork`
- `setsid`
- slave PTY open
- stdin/stdout/stderr `dup2`
- `/bin/sh -i`
- initial directory `/var/mobile`
- PTY background reader thread
- `select()` + `read()`
- main-thread UI delivery
- PTY write API
- PTY resize with `TIOCSWINSZ`
- process cleanup
- bounded UTF-8 tail buffer
- bounded terminal scrollback

### Real-device verification

Real iPad 1 test proved:

- application launches
- Local Terminal opens
- PTY creation works
- shell starts
- prompt appears
- output reaches screen

### Terminal UI v0.2

- visible command `UITextField` removed
- direct terminal keyboard capture introduced
- basic ANSI parser added
- raw `[K` issue addressed through CSI filtering
- basic clear-screen action
- special terminal keys added

### v0.2.1 input fixes prepared

- Unicode-capable default keyboard
- Turkish input path enabled
- `VERASE = 0x7F`
- Backspace DEL alignment
- helper row moved to `inputAccessoryView`
- iOS 5 `UITextView.selectable` incompatibility removed

---

## Important test history

### Compile issue 1

`UIReturnKeyReturn` was invalid.

Fixed with:

```objc
UIReturnKeyDefault
```

### Compile issue 2

`UITextAlignmentCenter` caused an enum conversion warning treated as error with newer SDK headers.

Resolved for legacy compatibility.

### Linker issue

Using:

```make
TARGET = iphone:clang:9.3:5.1
```

caused simulator `.tbd` warnings and:

```text
ld: file not found: /usr/lib/system/liblaunch.dylib for architecture armv7
```

Resolved by switching to:

```make
TARGET = iphone:clang:6.1:5.1
```

The iPhoneOS6.1 SDK includes:

```text
/usr/lib/system/liblaunch.dylib
```

### Compile issue 3

`UITextView.selectable` is unavailable on iOS 5.1.1.

The line was removed.

---

## Real-device UI findings

The v0.1 screenshot showed raw ANSI text:

```text
[Ksh-4.0$
```

The v0.2 screenshot showed improved prompt display, but:

- Turkish characters could not be typed
- Backspace did not erase
- helper key bar was obscured by the software keyboard

These are the reasons for v0.2.1.

---

## Decisions

1. Do not start SSH until local terminal input is stable.
2. Do not implement SSH cryptography in-app initially.
3. Future SSH should run an installed `ssh` binary under PTY.
4. Full ANSI/VT100 screen-buffer work comes before serious remote-shell use.
5. Keep scrollback bounded.
6. Keep MRC.
7. Keep SDK 6.1 / deployment 5.1 unless a verified compatibility reason requires change.
8. Do not use newer UIKit properties that are unavailable on iOS 5.1.1.
9. Do not add heavy dependencies.
10. Keep the application focused on terminal/SSH responsibilities.

---

## Known issues

- v0.2.1 fixes still require final hardware validation unless superseded by a later entry.
- ANSI parser is not a real terminal screen emulator.
- cursor row/column model does not exist yet.
- `vim`, `nano`, `top`, `less`, `htop` are not yet acceptance criteria.
- SSH is not implemented.
- connection profiles are not implemented.

---

## Immediate next action

Build and install `0.2.1-alpha1`.

Test inside the application:

```text
Türkçe: ğüşiöç İĞÜŞÖÇ
```

Test Backspace before Enter.

Confirm helper keys appear above the keyboard:

```text
Esc | Ctrl+C | Tab | < | ^ | v | > | ~ | |
```

Then test:

```bash
pwd
whoami
ls -la
clear
```

If all pass:

**next implementation phase = real ANSI/VT100 screen buffer and cursor model.**

Do not jump directly to SSH.
