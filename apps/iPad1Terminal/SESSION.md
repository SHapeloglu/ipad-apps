# SESSION

## Current status

Project initialized as `0.1.0-alpha1`.

A first-pass Local Terminal implementation has been created.

## Completed

- Theos app skeleton
- iPad-only Info.plist
- Home screen
- Local Terminal screen
- POSIX PTY allocation
- child process creation
- `/bin/sh -i`
- non-blocking PTY reader thread
- UTF-8 boundary buffering
- bounded scrollback
- terminal resize using `TIOCSWINSZ`
- Esc / Ctrl+C / Tab / arrow shortcut buttons
- MRC cleanup

## Decisions

1. Local PTY must pass on real iPad 1 before SSH work starts.
2. PTY implementation starts with POSIX `posix_openpt` rather than a hard `forkpty()` dependency.
3. SSH will eventually launch an installed SSH binary under PTY.
4. Terminal history must remain bounded for the 256 MB RAM limit.
5. No WebView terminal and no modern iOS APIs.

## Known issues / validation required

- The source has not yet been compiled against the user's actual Theos SDK in this session.
- `posix_openpt` family availability must be confirmed in the installed SDK/runtime.
- Jailbreak process permissions for `fork/exec` must be validated on hardware.
- Current UI is deliberately minimal and is not yet a real VT100 screen model.
- `UITextView` currently displays accumulated plain terminal output; ANSI escape parsing comes later.

## Immediate next action

On the actual development machine:

```bash
cd iPad1Terminal-v0.1-local-pty
make clean
make package
```

If compilation succeeds, install on iPad 1 and test:

```bash
pwd
whoami
uname -a
ls -la
df -h
```

If compilation fails, preserve the complete compiler/linker output and fix only the compatibility issue before adding features.

If the app launches but PTY creation fails, capture the exact `[PTY ERROR]` text shown on screen.
