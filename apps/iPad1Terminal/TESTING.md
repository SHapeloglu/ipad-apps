# TESTING

## Test environment

Primary device:

```text
iPad 1
iOS 5.1.1
armv7
jailbreak
256 MB RAM
```

Build environment:

```text
Theos
iPhoneOS6.1 SDK
deployment target 5.1
Objective-C MRC
```

---

## 1. Build test

Run:

```bash
make clean
make package
```

Pass criteria:

- no compilation error
- no armv7 linker error
- `.deb` generated
- warning about iOS 5.1 deprecation is acceptable
- simulator `.tbd` linker warnings must not appear when using the working 6.1 SDK

---

## 2. Installation test

Install generated package with the normal jailbreak deployment workflow.

Pass criteria:

- `dpkg -i` succeeds
- icon appears after `uicache` / SpringBoard refresh
- app launches

---

## 3. Local Terminal launch

Open:

```text
iPad1Terminal
-> Local Terminal
```

Pass criteria:

- black terminal screen appears
- shell prompt appears
- no `[PTY ERROR]`
- app does not crash

---

## 4. Basic shell commands

Inside **iPad1Terminal itself**, not the external SSH shell, run:

```bash
pwd
whoami
uname -a
ls
ls -la
df -h
ps
echo hello
```

Pass criteria:

- commands execute
- output is visible
- UI does not freeze

Expected initial directory:

```text
/var/mobile
```

Actual process user must be recorded from device output.

---

## 5. Turkish / UTF-8 input

Inside iPad1Terminal type:

```text
Türkçe: ğüşiöç İĞÜŞÖÇ
```

Pass criteria:

- Turkish keyboard can produce all characters
- typed text reaches the shell
- displayed text is not corrupted

Also run:

```bash
echo "Türkçe: ğüşiöç İĞÜŞÖÇ"
```

Pass criteria:

- UTF-8 output is correct

---

## 6. Backspace

Before pressing Enter:

1. type `abcdef`
2. press Backspace three times
3. type `XYZ`
4. press Enter

Pass criteria:

- shell command line visibly erases characters
- no `^?` or strange delete glyphs
- expected edited input reaches shell

If Backspace fails, verify:

```text
TerminalInputView sends 0x7F
PTY VERASE is 0x7F
```

---

## 7. Enter

Type:

```text
echo test
```

Press Return.

Pass criteria:

- command executes exactly once
- shell returns prompt

---

## 8. Special helper row

When the software keyboard is visible, verify a row above it containing:

```text
Esc
Ctrl+C
Tab
<
^
v
>
~
|
```

Pass criteria:

- row is above keyboard
- labels are readable
- row is tappable

---

## 9. Ctrl+C

Run a command that waits or runs continuously if available.

Then tap:

```text
Ctrl+C
```

Pass criteria:

- process is interrupted
- shell prompt returns

---

## 10. Tab

Type part of a path/command and tap Tab.

Pass criteria:

- Tab reaches the shell
- shell behavior is consistent with installed shell capabilities

Do not assume `/bin/sh` supports rich completion.

---

## 11. Arrow keys

Test:

```text
Up
Down
Left
Right
```

Pass criteria:

- sequences reach shell
- no raw `[A`, `[B`, `[C`, `[D` should appear as ordinary text in the final terminal architecture

Note:

plain `/bin/sh` may not provide bash-style history behavior. Distinguish shell limitations from terminal bugs.

---

## 12. ANSI artifact regression

Pass criteria:

The prompt must not visibly show:

```text
[K
```

or other raw CSI fragments during ordinary shell use.

---

## 13. Clear

Run:

```bash
clear
```

Pass criteria for current basic parser:

- raw escape sequences are not shown
- screen is cleared or acceptably reset

After full screen-buffer implementation:

- cursor must be at correct logical position
- old screen content must be removed correctly

---

## 14. ANSI SGR test

Run:

```bash
printf '\033[31mRED\033[0m\n'
```

Current interim parser pass criteria:

- raw `ESC[31m` / `ESC[0m` text is not displayed

Future screen-buffer pass criteria:

- `RED` is rendered using the supported basic foreground color
- following text returns to default attributes

---

## 15. Scrollback

Generate large output with commands available on the device.

Examples:

```bash
find /usr 2>/dev/null
```

or if available:

```bash
seq 1 5000
```

Pass criteria:

- app remains responsive
- history does not grow without limit
- no crash
- no obvious runaway memory growth

---

## 16. Rotation

Test:

- portrait
- landscape
- portrait again

Pass criteria:

- session remains alive
- shell does not restart
- terminal size is updated
- no overlap with keyboard/helper row

---

## 17. Repeated open/close

Open and leave Local Terminal at least 10 times.

Pass criteria:

- no crash
- no orphan child shells
- no zombie processes
- no PTY fd leak

Use external SSH only to inspect system process state if necessary.

---

## 18. Child exit

Inside Local Terminal run:

```bash
exit
```

Pass criteria:

- child process ends
- UI reports process exit
- app itself does not crash

---

## 19. Memory pressure

During long output:

- observe app stability
- trigger normal device memory pressure through realistic usage

Pass criteria:

- bounded scrollback remains effective
- app does not allocate unbounded buffers

---

## 20. Future ANSI/VT100 acceptance

After screen-buffer implementation, test:

```text
less
nano
top
vim
```

Minimum acceptance before SSH milestone:

- `less` usable
- `nano` usable enough to navigate/edit
- `top` redraws without accumulating garbage
- cursor movement works
- clear/erase behavior works

---

## 21. Future SSH tests

Only after SSH is implemented.

Test:

- valid host
- invalid host
- wrong port
- host key prompt
- password prompt
- authentication failure
- successful login
- disconnect
- reconnect
- server closes connection
- SSH key
- legacy algorithm failure if encountered

Never store or publish test passwords/private keys.

---

## 22. Regression checklist

Before any release:

- [ ] Local shell opens
- [ ] typing works
- [ ] Turkish input works
- [ ] Backspace works
- [ ] Enter works
- [ ] Ctrl+C works
- [ ] helper row visible
- [ ] no `[K`
- [ ] rotation works
- [ ] clear works
- [ ] bounded memory behavior
- [ ] close/reopen stability
