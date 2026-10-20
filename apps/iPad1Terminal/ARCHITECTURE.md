# ARCHITECTURE

## Overview

`iPad1Terminal` is a native UIKit terminal application designed specifically for a jailbroken iPad 1 running iOS 5.1.1.

The architecture separates:

- terminal UI
- keyboard input
- ANSI parsing
- terminal session
- PTY/process management

SSH will later reuse the same terminal/PTY presentation layer.

---

## Platform contract

```text
iPad 1
iOS 5.1.1
armv7
256 MB RAM
Theos
Objective-C
non-ARC / MRC
UIKit / Foundation
```

Current working Theos target:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

---

## Current component model

```text
AppDelegate
    |
    v
HomeViewController
    |
    v
TerminalViewController
    |
    +----------------------+
    |                      |
    v                      v
TerminalInputView     TerminalANSIParser
    |                      |
    +----------+-----------+
               |
               v
      LocalTerminalSession
               |
               v
           PTY master
               |
               v
           PTY slave
               |
               v
           /bin/sh -i
```

---

## AppDelegate

Responsibilities:

- create window
- create navigation controller
- display `HomeViewController`

Must remain minimal.

---

## HomeViewController

Current role:

- show `Local Terminal`
- later show SSH connection profiles

Do not put PTY logic here.

---

## TerminalViewController

Responsibilities:

- terminal display
- terminal input routing
- special key handling
- ANSI output routing
- scrollback presentation
- terminal resize calculation
- session lifecycle coordination

Must not implement low-level PTY allocation directly.

---

## TerminalInputView

Purpose:

Provide direct software-keyboard input without a visible white form field.

Implements:

```objc
UIKeyInput
```

Important decisions:

- must be first-responder capable
- uses `UIKeyboardTypeDefault`
- must not force ASCII-only keyboard because Turkish input is required
- `deleteBackward` maps to PTY erase input
- returns the special terminal helper bar as `inputAccessoryView`

---

## Special terminal key row

Target keys:

```text
Esc
Ctrl+C
Tab
Left
Up
Down
Right
~
|
```

Later enhancements may add:

```text
Ctrl modifier state
/
\
-
_
:
```

Do not make the bar heavy or visually complex.

---

## LocalTerminalSession

Responsibilities:

- allocate PTY
- create child process
- configure slave terminal
- launch shell
- read output
- write input
- resize terminal
- terminate child cleanly

Current PTY strategy:

```text
posix_openpt
grantpt
unlockpt
ptsname
fork
setsid
open(slave)
dup2
execl
```

The implementation intentionally avoids making `forkpty()` a required dependency.

---

## PTY termios

Backspace behavior uses:

```text
DEL = 0x7F
```

The slave PTY is configured with:

```c
tio.c_cc[VERASE] = 0x7F;
```

This must match `TerminalInputView` Backspace behavior.

---

## Shell

Current shell launch:

```text
/bin/sh -i
```

Fallback may attempt:

```text
/bin/bash -i
```

Initial working directory:

```text
/var/mobile
```

Environment includes:

```text
TERM=vt100
HOME=/var/mobile
SHELL=/bin/sh
```

Do not assume shell behavior equivalent to modern bash.

---

## PTY output thread

The main UI thread must never block on PTY reads.

Current model:

```text
NSThread
  |
  v
select()
  |
  v
read()
  |
  v
UTF-8 byte buffering
  |
  v
performSelectorOnMainThread
```

This is intentionally compatible with old iOS.

---

## UTF-8 handling

PTY reads are byte-oriented.

A multi-byte UTF-8 character can be split between `read()` calls.

The session therefore retains incomplete UTF-8 tail bytes and joins them with the next read.

Buffers must remain bounded.

---

## TerminalANSIParser

Current parser is an interim compatibility layer, not a full terminal emulator.

Current responsibilities:

- prevent raw `ESC[K` text from appearing
- consume common CSI sequences
- detect basic clear-screen sequences
- consume SGR codes rather than print them literally

Current non-goal:

- accurate cursor/state rendering

---

## Required next architecture: terminal screen buffer

The next major terminal-engine phase should add a real screen model.

Suggested future classes:

```text
TerminalScreen
TerminalCell
TerminalCursorState
TerminalANSIParser
TerminalRenderer
```

Possible conceptual model:

```text
PTY bytes
   |
   v
ANSI parser
   |
   v
TerminalScreen [rows x columns]
   |
   +--> cursor row/column
   +--> character cells
   +--> attributes
   |
   v
UIKit renderer
```

The screen buffer must be fixed-size or tightly bounded.

---

## ANSI/VT100 target subset

Before SSH is considered mature, support at least:

- CR
- LF
- BS
- TAB
- cursor up/down/left/right
- cursor position
- erase in line
- erase in display
- clear screen
- save/restore cursor
- basic SGR reset
- basic foreground colors
- terminal resize

Acceptance should eventually include:

```text
clear
less
nano
top
```

`vim` can follow once the basic model is stable.

---

## SSH architecture

Future target:

```text
TerminalViewController
        |
        v
SSHSession
        |
        v
PTY
        |
        v
installed ssh executable
        |
        v
remote host
```

Do not duplicate terminal rendering for SSH.

Local and SSH sessions should share the same terminal UI.

---

## SSH profile model

Future fields:

```text
Name
Host
Port
Username
Authentication mode
Optional identity file
```

Passwords must not be stored in plaintext plist files.

Initial SSH version may simply let the `ssh` process display its own password prompt.

---

## iPad1Files integration

Future lightweight integration:

```text
/var/mobile/Media/iPad1Files/
```

Possible quick shortcut:

```text
Files
```

which sends:

```bash
cd /var/mobile/Media/iPad1Files/
```

Do not copy iPad1Files source code into this project.

---

## Memory policy

Device RAM:

```text
256 MB
```

Rules:

- bounded scrollback
- fixed/bounded screen buffer
- fixed PTY read buffer
- no unlimited history
- no WebView terminal
- no large image assets
- avoid multiple active sessions initially
- drain autorelease pools in long-running background loops

---

## Lifecycle

When terminal screen closes:

- disconnect delegate
- terminate child if required
- close PTY descriptor
- call `waitpid`
- avoid zombie processes

Background persistence is not a v1 requirement.

---

## Security

Never log:

- passwords
- private keys
- sensitive terminal input

SSH private keys should remain files with appropriate permissions.

---

## Architectural priorities

```text
correctness
compatibility
bounded memory
simple ownership
testability
usability
```

Avoid modern abstractions that reduce iOS 5 compatibility.
