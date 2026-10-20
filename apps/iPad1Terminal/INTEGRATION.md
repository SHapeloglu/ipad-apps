# INTEGRATION

## Purpose

This document defines how `iPad1Terminal` interacts with the other iPad 1 applications without violating responsibility boundaries.

The architectural rule is mandatory:

> If another iPad1 Suite application owns a capability, iPad1Terminal must not duplicate that capability. It should use a small integration/handoff contract when practical.

This rule must be evaluated before every new feature.

---

## Feature ownership matrix

```text
iPad1Terminal
= local shell + PTY + terminal emulation + SSH + terminal UX

iPad1Files
= file/folder browsing + selection + file operations + archive UI

iPad1PDFReader
= PDF/text reading + reader-specific navigation/search/highlight UI

iPad1FTPDownloader
= managed download workflows + queue/resume/retry/destination UI

iPad1VNC
= graphical remote desktop
```

### Ownership test

Before implementation:

```text
Is it intrinsically terminal/SSH?
    yes -> Terminal may implement it
    no  -> check specialist ownership

Does Files/Reader/Downloader/VNC own it?
    yes -> do not implement in Terminal

Can a handoff satisfy the use case?
    yes -> launch specialist application
```

If ownership remains ambiguous, document and resolve it before coding.

---

## iPad1Files

Canonical shared files root:

```text
/var/mobile/Media/iPad1Files/
```

Terminal may navigate to this path with ordinary shell commands.

To avoid confusing shell navigation with file management, the quick command should be named:

```text
Shared Root
```

rather than `Files`.

Example:

```bash
cd /var/mobile/Media/iPad1Files/
```

A separate `Files App` integration may launch iPad1Files for actual browsing/management.

### File selection

Terminal must not build a general file picker.

Future examples that should delegate to iPad1Files:

- selecting an SSH identity/key file
- selecting a destination directory for a graphical SCP/SFTP workflow
- browsing shared files
- rename/copy/move/delete/archive UI

Terminal remains responsible for using the selected path in its own terminal/SSH operation.

### Open terminal in directory

Future optional URL scheme may allow iPad1Files to request:

```text
ipad1terminal://local?cwd=/var/mobile/Media/iPad1Files/Documents/
```

Do not implement until Local Terminal lifecycle and URL parsing are stable.

Security:

- validate and normalize `cwd`
- accept only directory paths
- never accept arbitrary command text

---

## iPad1PDFReader

Terminal may run normal shell commands such as:

```text
cat
head
less
```

because these are terminal behaviors.

Terminal must not implement:

- PDF rendering
- text-reader screens
- bookmarks
- highlights
- document search/navigation UI

A future `Reader` handoff should launch iPad1PDFReader for supported documents.

---

## iPad1FTPDownloader

Terminal users may manually run installed CLI tools such as:

```text
ftp
scp
curl
wget
```

if present on the device.

This does not make Terminal a managed downloader.

Terminal must not implement:

- graphical FTP browser
- download queue
- pause/resume manager
- retry manager
- download history UI
- graphical destination picker

Those belong to iPad1FTPDownloader and/or iPad1Files.

---

## iPad1VNC

Responsibility separation:

```text
iPad1Terminal = CLI / PTY / SSH
iPad1VNC      = graphical remote desktop
```

Terminal may offer a `Remote Desktop` launcher, but it must only hand off to iPad1VNC.

Do not implement:

- remote framebuffer rendering
- VNC protocol/session UI
- graphical pointer handling
- remote desktop scaling

inside iPad1Terminal.

---

## SSH and SSH-key boundary

SSH is part of iPad1Terminal.

Terminal owns:

- SSH process launch under PTY
- host/port/username
- profile management
- host-key interaction
- reconnect UX
- identity-file path usage
- authentication flow through the installed `ssh` executable

Terminal does not own general file browsing.

Therefore an optional identity-file chooser should delegate selection to iPad1Files rather than embedding a file browser.

Passwords/private keys must never be passed in URL query strings.

---

## SCP/SFTP boundary

Manual CLI `scp`/`sftp` use is valid Terminal behavior.

Graphical file management is not Terminal behavior.

If graphical SCP/SFTP workflows are ever approved:

```text
Terminal/SSH operation
        |
        +--> file/folder selection -> iPad1Files
        |
        +--> managed download flow -> iPad1FTPDownloader when appropriate
```

Do not create a second general-purpose file manager inside Terminal.

---

## Suite launchers

Future lightweight launchers may include:

```text
Files App       -> iPad1Files
Reader          -> iPad1PDFReader
Downloader      -> iPad1FTPDownloader
Remote Desktop  -> iPad1VNC
```

These are integration points, not embedded features.

Use `canOpenURL:` before `openURL:` and fail gracefully when the specialist application is not installed.

All APIs must remain compatible with iOS 5.1.1.

---

## URL scheme safety

Potential future schemes:

```text
ipad1terminal://local
ipad1terminal://local?cwd=...
ipad1terminal://ssh?profile=...

ipad1files://browse?path=...
ipad1reader://open?path=...
ipad1downloader://new?url=...
ipad1vnc://connect?profile=...
```

Do not support arbitrary command execution:

```text
ipad1terminal://exec?...
ipad1terminal://local?command=...
```

Never put these in URLs:

```text
password
private-key contents
authentication secrets
```

---

## Shared code policy

Do not copy major code from:

- iPad1Files
- iPad1VNC
- iPad1FTPDownloader
- iPad1PDFReader

Use small public integration contracts instead.

Do not create a heavy shared runtime or resident integration daemon.

---

## Shared platform policy

All iPad 1 family applications continue to target:

```text
iPad 1
iOS 5.1.1
armv7
256 MB RAM
non-ARC / MRC
Theos
```

Each project must remain independently installable and independently buildable.

---

## Mandatory pre-feature checklist

Before adding any new iPad1Terminal feature:

- [ ] Is the capability intrinsically terminal/SSH?
- [ ] Does another suite application already own it?
- [ ] Can the use case be satisfied through handoff instead?
- [ ] Does the feature preserve 256 MB RAM constraints?
- [ ] Does it use only iOS 5.1.1-compatible APIs?
- [ ] Is the ownership decision reflected in TASKS/ARCHITECTURE when material?

Do not implement until these questions have been answered.
