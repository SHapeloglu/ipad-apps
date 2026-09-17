# TASKS

## Phase 0 - Skeleton

- [x] Theos application skeleton
- [x] iPad-only Info.plist
- [x] armv7 / iOS 5.1 target
- [x] MRC / no ARC
- [x] Home screen

## Phase 1 - Local PTY

- [x] POSIX PTY allocation
- [x] `fork`
- [x] `setsid`
- [x] slave PTY setup
- [x] stdin/stdout/stderr duplication
- [x] `/bin/sh -i`
- [x] background read loop
- [x] terminal write API
- [x] resize with `TIOCSWINSZ`
- [ ] Compile in actual Theos environment
- [ ] Install on iPad 1
- [ ] Verify `pwd`
- [ ] Verify `ls`
- [ ] Verify Ctrl+C
- [ ] Verify arrow-key history

## Phase 2 - Terminal UI

- [x] terminal text area
- [x] command input
- [x] Esc
- [x] Ctrl+C
- [x] Tab
- [x] arrow keys
- [x] bounded scrollback
- [x] Clear
- [ ] improve direct keystroke behavior
- [ ] Ctrl modifier state
- [ ] A-/A+ font size
- [ ] copy/paste validation
- [ ] keyboard toolbar layout on rotation

## Phase 3 - ANSI parser

- [ ] parser state machine
- [ ] cursor model
- [ ] clear screen
- [ ] SGR
- [ ] basic colors
- [ ] full-screen command compatibility

## Phase 4 - SSH

Do not begin until Local PTY passes real-device testing.

- [ ] discover installed `ssh`
- [ ] SSH profile model
- [ ] host / port / username UI
- [ ] run ssh under PTY
- [ ] connect / disconnect
- [ ] host key prompt
- [ ] password prompt
- [ ] reconnect behavior

## Phase 5 - Stability

- [ ] memory pressure tests
- [ ] orientation tests
- [ ] process cleanup
- [ ] zombie-process verification
- [ ] repeated open/close test
