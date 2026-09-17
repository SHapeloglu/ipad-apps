# TASKS

## Phase 0 - Skeleton
- [x] Theos skeleton
- [x] armv7 / iOS 5.1 target
- [x] MRC
- [x] Home screen

## Phase 1 - Local PTY
- [x] PTY allocation
- [x] fork / setsid / dup2 / exec
- [x] `/bin/sh -i`
- [x] background PTY read
- [x] direct PTY write
- [x] TIOCSWINSZ
- [x] real-device shell prompt confirmed

## Phase 2 - Terminal UI
- [x] remove visible command box
- [x] direct keyboard capture
- [x] Backspace
- [x] Enter
- [x] Esc
- [x] Ctrl+C
- [x] Tab
- [x] arrows
- [x] `~`
- [x] `|`
- [x] visible special-key labels
- [x] bounded scrollback
- [ ] font A-/A+
- [ ] copy/paste polish
- [ ] Ctrl modifier state

## Phase 3 - ANSI / VT100
- [x] suppress raw ESC[K artifacts
- [x] consume common CSI
- [x] clear-screen action for ESC[2J
- [x] consume SGR codes
- [ ] real cursor row/column model
- [ ] screen cell buffer
- [ ] erase line semantics
- [ ] erase display semantics
- [ ] cursor save/restore
- [ ] basic colors
- [ ] `nano`
- [ ] `vim`
- [ ] `top`
- [ ] `less`

## Phase 4 - SSH
Do not begin until Phase 2 real-device validation passes.
- [ ] discover ssh binary
- [ ] SSH profiles
- [ ] host/port/user
- [ ] run ssh under PTY
- [ ] connect/disconnect
- [ ] host key prompt
- [ ] password prompt
