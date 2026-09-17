# ARCHITECTURE

## Scope

iPad1Terminal is a lightweight terminal application for iPad 1 / iOS 5.1.1.

Current phase: **local PTY only**.

SSH is not yet implemented.

## Data flow

```text
UITextField / Special Key Bar
        |
        v
TerminalViewController
        |
        v
LocalTerminalSession
        |
        v
PTY master <----> PTY slave
                     |
                     v
                  /bin/sh
```

## PTY choice

The first implementation avoids a direct `forkpty()` dependency.

It uses:

- `posix_openpt`
- `grantpt`
- `unlockpt`
- `ptsname`
- `fork`
- `setsid`
- `open` of slave PTY
- `dup2`
- `execl`

This keeps the implementation close to POSIX/libc and reduces dependency risk on old SDKs.

## Threading

The UI thread never blocks on PTY reads.

A single `NSThread` runs a `select()` + `read()` loop.

Received text is delivered to the main thread with `performSelectorOnMainThread:`.

## Memory

Terminal history is bounded by character count.

Current alpha default:

```text
120000 UTF-16 characters
```

This is intentionally conservative for a 256 MB device.

## MRC

All Objective-C code is manual retain/release.

No ARC is used.

## SSH future phase

SSH will reuse the same terminal/PTY presentation layer and launch the installed `ssh` executable as a child process rather than implementing cryptography in the app.
