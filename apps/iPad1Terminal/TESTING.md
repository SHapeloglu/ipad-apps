# TESTING

## Build
- [ ] `make clean`
- [ ] `make package`
- [ ] package produced without linker errors

## Real-device Local Terminal
Run:

```bash
pwd
whoami
uname -a
ls -la
df -h
echo "Türkçe: ğüşiöç İĞÜŞÖÇ"
```

Verify:
- [ ] no `[K` text is visible
- [ ] prompt is readable
- [ ] no white command-entry box exists
- [ ] tapping terminal opens keyboard
- [ ] typed text reaches shell
- [ ] Return executes
- [ ] Backspace works

## Special key bar
- [ ] Esc label visible
- [ ] Ctrl+C label visible
- [ ] Tab label visible
- [ ] arrow labels visible
- [ ] `~` visible
- [ ] `|` visible
- [ ] Ctrl+C interrupts a running command

## ANSI alpha
Run:

```bash
clear
printf '\033[31mRED\033[0m\n'
```

Expected for 0.2:
- [ ] `clear` does not print `[K` or raw CSI text
- [ ] SGR escape text itself is not visible
- [ ] actual red color is NOT required yet

## Regression
- [ ] shell remains alive after rotation
- [ ] scrollback remains bounded
- [ ] terminal opens/closes repeatedly without crash
