# CHANGELOG

## 0.2.1-alpha1 — prepared

Input/UI fixes prepared after real-device v0.2 testing:

- allow default/Unicode iOS keyboard instead of ASCII-only keyboard
- enable Turkish character input path
- set PTY `VERASE` to DEL (`0x7F`)
- align Backspace with PTY erase configuration
- move terminal helper row to keyboard `inputAccessoryView`
- preserve iOS 5 compatibility

Hardware validation still required unless later `SESSION.md` entries say otherwise.

---

## 0.2.0-alpha1

- removed separate white command input field
- added direct keyboard capture
- added lightweight ANSI/CSI filtering
- addressed visible `[K` terminal artifacts
- added basic clear-screen handling
- improved terminal helper-key UI
- kept bounded scrollback
- retained PTY resize support

Real-device findings:

- Turkish input failed because keyboard was ASCII-only
- Backspace failed
- helper bar was hidden behind keyboard

---

## 0.1.0-alpha1

Initial Local Terminal prototype:

- Theos skeleton
- Home screen
- Local Terminal
- POSIX PTY
- fork/setsid/dup2/exec
- `/bin/sh -i`
- background PTY reader
- direct PTY writing
- UTF-8 output buffering
- bounded scrollback
- terminal resize

Major milestone:

**real iPad 1 successfully displayed an interactive shell prompt.**
