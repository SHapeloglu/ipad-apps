# SESSION

## Current status

Version: `0.2.0-alpha1`

The first real-device screenshot confirmed:

- PTY starts successfully.
- `/bin/sh` starts successfully.
- shell prompt is visible on iPad 1.
- raw ANSI `ESC[K` was leaking to the screen as `[K`.
- the temporary white command input field made the UI look unlike a real terminal.
- custom key labels were not reliably visible.

## Completed in 0.2

- Removed the visible white command `UITextField`.
- Added invisible `UIKeyInput` capture view.
- Tapping the terminal focuses the software keyboard.
- Normal typed characters go directly to the PTY.
- Return goes directly to PTY.
- Backspace sends DEL (`0x7F`).
- Added lightweight ANSI parser.
- `ESC[K` and similar CSI sequences are consumed rather than printed.
- `ESC[2J` clears the local terminal screen.
- SGR/color sequences are consumed for now.
- Basic cursor CSI sequences are consumed for now.
- Special-key bar uses explicit custom button colors/titles.
- Added Esc, Ctrl+C, Tab, arrows, `~`, and `|`.
- Existing bounded scrollback, UTF-8 buffering and PTY resize remain intact.
- Build target is fixed to `iphone:clang:6.1:5.1`.

## Important limitation

This is still not a complete VT100/xterm screen model.

Cursor movement sequences are currently consumed, not simulated. This is enough to remove visible `[K` artifacts and improve normal shell use, but applications such as:

- `vim`
- `nano`
- `top`
- `htop`
- `less`

will require the next ANSI/VT100 screen-buffer phase.

## Immediate next action

Build and install `0.2.0-alpha1` on the real iPad 1.

Validate:

```bash
pwd
whoami
ls -la
echo test
clear
```

Also test:

- direct typing on terminal screen
- Backspace
- Enter
- Esc
- Ctrl+C
- Tab
- Up/Down/Left/Right
- `~`
- `|`

Confirm that `[K` no longer appears.

Do not begin SSH until these tests pass.
