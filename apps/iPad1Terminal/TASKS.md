# TASKS

## Phase 0 — Project bootstrap

- [x] Create Theos application skeleton
- [x] Target iPad
- [x] armv7
- [x] iOS 5.1 deployment target
- [x] non-ARC / MRC
- [x] Home screen
- [x] Local Terminal navigation

---

## Phase 1 — Local PTY

- [x] PTY master allocation
- [x] `grantpt`
- [x] `unlockpt`
- [x] `ptsname`
- [x] `fork`
- [x] `setsid`
- [x] PTY slave open
- [x] `dup2` stdin/stdout/stderr
- [x] `/bin/sh -i`
- [x] initial `chdir("/var/mobile")`
- [x] background PTY reading
- [x] PTY writing
- [x] process cleanup
- [x] `TIOCSWINSZ`
- [x] real-device shell prompt verified

---

## Phase 2 — Basic terminal input/UI

- [x] remove visible white command field
- [x] direct keyboard capture
- [x] Enter -> PTY
- [x] Esc
- [x] Ctrl+C
- [x] Tab
- [x] arrow keys
- [x] `~`
- [x] `|`
- [x] bounded scrollback
- [x] clear button
- [x] helper key bar
- [x] iOS 5 `UITextView.selectable` incompatibility removed
- [x] Unicode-capable keyboard fix prepared
- [x] PTY `VERASE` fix prepared
- [x] helper row `inputAccessoryView` fix prepared
- [ ] validate Turkish input on real device
- [ ] validate Backspace on real device
- [ ] validate helper key row above keyboard on real device
- [ ] validate rotation after v0.2.1 input changes
- [ ] add A-/A+ font controls
- [ ] polish copy/paste
- [ ] implement reusable Ctrl modifier state

---

## Phase 3 — ANSI/VT100 screen model

### Parser

- [x] suppress raw `ESC[K`
- [x] consume common CSI sequences
- [x] basic `ESC[2J` detection
- [x] consume SGR rather than print raw codes
- [ ] parser state machine for split escape sequences
- [ ] numeric CSI parameters
- [ ] multiple CSI parameters
- [ ] private-mode handling where required

### Screen buffer

- [ ] create fixed row/column screen model
- [ ] create cursor row/column
- [ ] printable character insertion
- [ ] CR
- [ ] LF
- [ ] BS
- [ ] TAB
- [ ] cursor up
- [ ] cursor down
- [ ] cursor left
- [ ] cursor right
- [ ] cursor absolute position
- [ ] erase in line
- [ ] erase in display
- [ ] clear screen
- [ ] scroll region or minimum scrolling behavior
- [ ] save cursor
- [ ] restore cursor
- [ ] basic attributes
- [ ] basic foreground colors

### Renderer

- [ ] render screen model efficiently
- [ ] avoid full giant-string rebuild on every byte
- [ ] maintain fixed memory usage
- [ ] visible cursor
- [ ] portrait sizing
- [ ] landscape sizing
- [ ] redraw after `TIOCSWINSZ`

### Commands/programs

- [ ] `clear`
- [ ] `printf` ANSI tests
- [ ] `less`
- [ ] `nano`
- [ ] `top`
- [ ] `vim` basic use

---

## Phase 4 — SSH

Do not begin until Phase 2 hardware tests pass and the Phase 3 screen model is usable.

### Discovery

- [ ] locate `ssh` executable on device
- [ ] record SSH version
- [ ] inspect supported algorithms

### Session

- [ ] create `SSHSession`
- [ ] launch `ssh` under PTY
- [ ] host
- [ ] port
- [ ] username
- [ ] connect
- [ ] disconnect
- [ ] host key prompt
- [ ] password prompt
- [ ] child exit handling

### Profiles

- [ ] profile model
- [ ] add profile
- [ ] edit profile
- [ ] delete profile
- [ ] recent profile
- [ ] do not store plaintext password

### Authentication

- [ ] existing SSH key usage
- [ ] optional identity-file path usage
- [ ] identity-file chooser handoff to iPad1Files (do not embed file browser)
- [ ] legacy algorithm options only if actually needed

---

## Phase 5 — Usability

- [ ] quick commands
- [ ] command history UX
- [ ] `Shared Root` shell shortcut -> `cd /var/mobile/Media/iPad1Files/`
- [ ] optional `Files App` launcher -> iPad1Files (integration only)
- [ ] paste safety for large text
- [ ] font size persistence
- [ ] profile persistence
- [ ] reconnect UX
- [ ] landscape key-bar layout

Suggested quick commands:

```text
Disk       -> df -h
Processes  -> ps
Shared Root -> cd /var/mobile/Media/iPad1Files/
```

Do not add too many hardcoded commands.

---

## Phase 6 — Stability

- [ ] repeated Local Terminal open/close
- [ ] zombie process check
- [ ] PTY descriptor leak check
- [ ] memory-pressure test
- [ ] long-output test
- [ ] large-paste test
- [ ] rotate repeatedly
- [ ] background/foreground test
- [ ] child shell exits unexpectedly
- [ ] PTY read error
- [ ] app memory warning behavior

---

## Ownership guardrails

Do not add these capabilities inside iPad1Terminal:

- [ ] general file browser / file picker — owner: iPad1Files
- [ ] copy/move/delete/archive GUI — owner: iPad1Files
- [ ] graphical SFTP browser — owner: iPad1Files
- [ ] PDF/text reader UI — owner: iPad1PDFReader
- [ ] managed FTP/download queue/resume UI — owner: iPad1FTPDownloader
- [ ] graphical remote desktop — owner: iPad1VNC

Terminal may expose lightweight launchers/handoffs to these applications after the common integration contract is implemented and physically validated.

Manual shell commands such as `cd`, `cat`, `less`, `scp`, `sftp`, `ftp`, `curl`, and `wget` remain valid terminal behavior when binaries are present.

---

## Deferred / not planned for first v1

- [ ] multiple simultaneous terminal tabs
- [ ] SFTP graphical browser
- [ ] Mosh
- [ ] Telnet
- [ ] theme marketplace/system
- [ ] embedded Web terminal
- [ ] graphical monitoring dashboard

These require explicit approval before implementation.
