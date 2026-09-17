# TESTING

## A. Build

- [ ] `make clean`
- [ ] `make package`
- [ ] no ARC errors
- [ ] armv7 package produced
- [ ] install with `dpkg -i`

## B. Launch

- [ ] application starts on iPad 1
- [ ] Home screen appears
- [ ] Local Terminal opens
- [ ] keyboard appears

## C. Local shell

Run:

```bash
pwd
whoami
uname -a
ls
ls -la
cd /var/mobile
pwd
df -h
ps
echo hello
```

Expected:

- [ ] prompt/output appears
- [ ] commands do not freeze UI
- [ ] current directory initially `/var/mobile`

## D. PTY behavior

- [ ] `Ctrl+C` interrupts a running command
- [ ] `Tab` reaches the shell
- [ ] Up arrow recalls previous command when supported by shell
- [ ] Left/right arrows reach shell
- [ ] `clear` does not crash
- [ ] `exit` terminates the child process cleanly

## E. UTF-8

Run:

```bash
echo "Türkçe: ğüşiöç İĞÜŞÖÇ"
```

- [ ] characters render correctly

## F. Scrollback

Generate lots of output, using an available command.

Examples:

```bash
find /usr -maxdepth 3 2>/dev/null
```

or, if installed:

```bash
seq 1 5000
```

- [ ] UI remains usable
- [ ] old scrollback is trimmed
- [ ] memory does not grow without bound

## G. Rotation

- [ ] portrait works
- [ ] landscape works
- [ ] terminal remains alive after rotation
- [ ] PTY rows/columns are updated

## H. Process cleanup

Open and close Local Terminal repeatedly.

- [ ] no orphan shells
- [ ] no zombie child processes
- [ ] no crash on controller deallocation

## Known alpha risks to validate

1. Whether this specific iOS 5.1.1 environment exposes `posix_openpt/grantpt/unlockpt/ptsname` through the selected SDK/runtime.
2. Whether the jailbreak launch environment permits `fork/exec` directly for this application.
3. Whether `/bin/sh` exists and is executable from the app context.
4. Whether interactive `/bin/sh` provides arrow-key history; plain `sh` may not. This is not necessarily a PTY bug.
