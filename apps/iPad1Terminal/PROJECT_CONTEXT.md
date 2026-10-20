# iPad1Terminal — Project Context

## Purpose

`iPad1Terminal` is a lightweight terminal application for a jailbroken iPad 1.

The application is intended to provide:

1. A real local shell on the iPad through a pseudo-terminal (PTY).
2. SSH access to remote Unix/Linux systems in a later phase.
3. A terminal UI designed specifically for iPad 1 / iOS 5.1.1 / 256 MB RAM.

SSH is a feature of `iPad1Terminal`; it is not a separate application.

---

## Non-negotiable platform constraints

These constraints must never be changed without explicit user approval:

- Device: iPad 1
- iOS: 5.1.1
- Architecture: armv7
- RAM: 256 MB
- Jailbreak environment
- Theos
- Objective-C
- non-ARC / MRC
- UIKit / Foundation
- no Swift
- no modern iOS-only APIs
- no WebView-based terminal
- no heavy dependency stack

Current working build target:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

The iPhoneOS9.3 SDK caused linker problems involving simulator `.tbd` files and a missing armv7 `liblaunch.dylib`. The iPhoneOS6.1 SDK is the working SDK for this project.

---

## Repository

GitHub repository:

```text
https://github.com/SHapeloglu/iPad1Terminal
```

Default branch:

```text
main
```

At the time this context file was created, the repository existed but was still empty.

---

## Current development status

Current intended version:

```text
0.2.1-alpha1
```

### Real-device milestone already achieved

The following has been proven on the real iPad 1:

- application installs and launches
- `Local Terminal` screen opens
- PTY creation works
- child shell starts
- `/bin/sh -i` prompt is visible
- PTY output reaches the UIKit terminal view
- local shell is alive on the real device

The first screenshot showed:

```text
sh-4.0$
[Ksh-4.0$
```

The `[K` text was caused by raw ANSI `ESC[K` sequences being shown instead of interpreted.

### v0.2 changes

v0.2 introduced:

- direct keyboard input into the terminal
- removal of the visible white command `UITextField`
- lightweight ANSI filtering
- suppression of raw `ESC[K` / CSI text
- basic `ESC[2J` clear-screen handling
- special terminal key row
- bounded scrollback
- UTF-8 output buffering
- PTY resize with `TIOCSWINSZ`

### Real-device v0.2 findings

The real-device v0.2 test revealed:

1. Turkish characters could not be typed.
2. Backspace did not work.
3. The helper-key row was hidden behind the software keyboard.

The screenshot confirmed that the shell itself still worked.

### v0.2.1 fixes prepared

The following fixes were prepared for `0.2.1-alpha1`:

- `UIKeyboardTypeASCIICapable` -> `UIKeyboardTypeDefault`
- Turkish/Unicode input allowed
- PTY slave `VERASE` explicitly set to `0x7F`
- Backspace continues to send DEL `0x7F`
- special terminal helper row moved to `inputAccessoryView`
- iOS 5 compatibility preserved by not using `UITextView.selectable`

These v0.2.1 input fixes still need final local build/install/device validation unless a later SESSION entry states otherwise.

---

## Current architecture

```text
iOS keyboard
    |
    v
TerminalInputView (UIKeyInput)
    |
    +------------------+
    |                  |
    v                  v
normal input      helper key row
                       |
                       v
                Esc / Ctrl+C / Tab
                arrows / ~ / |
    |
    v
TerminalViewController
    |
    +--> TerminalANSIParser
    |
    v
LocalTerminalSession
    |
    v
PTY master <--> PTY slave <--> /bin/sh -i
```

---

## Important architectural decisions

### 1. PTY first

Local terminal must be stable before SSH work begins.

### 2. SSH will reuse the PTY layer

Do not implement an SSH protocol stack from scratch.

Preferred future architecture:

```text
Terminal UI
   |
   v
PTY
   |
   v
installed ssh binary
   |
   v
remote server
```

### 3. ANSI/VT100 before serious SSH usage

The current ANSI parser is intentionally incomplete.

It can suppress common raw CSI sequences but it is not yet a real terminal screen model.

Before considering the terminal mature enough for:

```text
vim
nano
top
htop
less
```

implement a real terminal screen buffer and cursor model.

### 4. Memory must remain bounded

iPad 1 has only 256 MB RAM.

Do not allow:

- unlimited terminal history
- unbounded string append
- huge terminal buffers
- multiple heavy terminal sessions by default

Current scrollback is bounded.

### 5. MRC only

All Objective-C memory ownership must follow manual retain/release rules.

---

## Current known limitations

- ANSI/VT100 support is incomplete.
- Cursor movement is not modeled correctly yet.
- Full-screen terminal applications are not yet a supported milestone.
- SSH is not implemented yet.
- SSH profiles are not implemented yet.
- SSH keys are not implemented yet.
- multiple terminal sessions are not implemented.
- SFTP/SCP UI is not implemented.
- theme system is intentionally out of scope.
- Unicode input fix still needs final hardware validation unless later documented.

---

## Product direction

Target experience:

```text
MobileTerminal local-shell strength
        +
Prompt-style SSH usability
        +
iPad 1 / iOS 5.1.1 optimization
        +
iPad1Files integration
        =
iPad1Terminal
```

Do not chase modern terminal feature count.

Priorities:

```text
stability
> compatibility
> low RAM
> correct terminal behavior
> usability
> SSH
> advanced features
```

---

## Planned v1 capabilities

Target v1 scope:

- Local Terminal
- usable ANSI/VT100 subset
- UTF-8 / Turkish input and output
- Esc / Ctrl / Tab / arrows
- copy/paste
- bounded scrollback
- portrait/landscape
- SSH
- saved SSH connection profiles
- SSH key usage
- quick commands
- iPad1Files shortcut

Out of initial v1 scope unless explicitly approved:

- Mosh
- Telnet
- SFTP GUI
- multiple concurrent tabs
- themes
- graphical system monitor
- Web terminal
- embedded modern SSH crypto library

---

## Immediate next action

Do not begin SSH.

First validate the prepared `0.2.1-alpha1` input fixes on the real iPad 1.

Build:

```bash
cd ~/projects/iPad1Terminal-v0.2.1-input-fix
make clean
make package
```

Install the generated package on the iPad at the current LAN address used in this development session.

Inside **iPad1Terminal -> Local Terminal**, test:

```text
Türkçe: ğüşiöç İĞÜŞÖÇ
```

Before pressing Return:

- erase several characters with Backspace
- type them again
- verify helper keys are visible above the iOS keyboard

Then validate:

```bash
pwd
whoami
ls -la
clear
```

Only after these tests pass should the next terminal-engine milestone begin.

The next major engine milestone should be:

```text
real ANSI/VT100 screen buffer + cursor model
```

not SSH.
