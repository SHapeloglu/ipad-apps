# AGENTS

## Mandatory first read

Before changing code, read in this order:

1. `PROJECT_CONTEXT.md`
2. `SESSION.md`
3. `ARCHITECTURE.md`
4. `TASKS.md`
5. `TESTING.md`
6. `INTEGRATION.md`
7. `README.md`

`PROJECT_CONTEXT.md` contains the permanent project constraints.

`SESSION.md` contains the latest actual state and the immediate next action.

---

## Non-negotiable constraints

Never silently change:

```text
iPad 1
iOS 5.1.1
armv7
256 MB RAM
jailbreak
Theos
Objective-C
MRC / non-ARC
UIKit / Foundation
```

No Swift.

No modern API migration.

No WebView terminal.

No heavy dependency added without explicit approval.

---

## Current SDK rule

Use:

```make
TARGET = iphone:clang:6.1:5.1
```

unless a later documented decision changes it.

Do not revert to the 9.3 SDK target that produced simulator `.tbd` / armv7 linker problems.

---

## Current phase rule

Do not start SSH until the current Local Terminal/input and ANSI screen-buffer milestones are completed as described in `SESSION.md` and `TASKS.md`.

The user explicitly wants a real terminal application, not merely a thin SSH launcher.

---

## Feature ownership gate

Before proposing, implementing, or accepting any feature, determine which iPad1 Suite application owns the capability.

Ownership:

```text
iPad1Terminal      = local shell + PTY + terminal emulation + SSH
iPad1Files         = file/folder browsing, selection, management, archive UI
iPad1PDFReader     = PDF/text reading and reader-specific UI
iPad1FTPDownloader = managed downloads, queue/resume/retry/destination workflow
iPad1VNC           = graphical remote desktop
```

Mandatory decision gate:

```text
1. Is this intrinsically a terminal/SSH capability?
   -> yes: Terminal may own it.

2. Is it naturally owned by Files / Reader / Downloader / VNC?
   -> yes: do NOT implement it in Terminal.

3. Can Terminal satisfy the use case by launching the specialist app?
   -> yes: use the integration contract instead of duplicating functionality.
```

Examples that must NOT be implemented inside iPad1Terminal:

- general file browser or file picker
- copy/move/delete/archive GUI
- graphical SFTP browser
- PDF/text reader UI
- download manager / queue / resume UI
- VNC or graphical remote desktop renderer

Normal shell commands such as `cd`, `cat`, `less`, `scp`, `ftp`, or `curl` remain valid terminal behavior when the corresponding binaries exist. This does not transfer ownership of graphical file/download/reader features to Terminal.

If ownership is ambiguous, stop feature implementation and resolve ownership against `INTEGRATION.md` first.

---

## Code organization

Keep responsibilities separate:

```text
TerminalViewController
TerminalInputView
TerminalANSIParser
LocalTerminalSession
future TerminalScreen
future SSHSession
```

Do not put all logic into one controller.

---

## MRC rules

- every `alloc/init`, `copy`, `retain` must have clear ownership
- release owned ivars in `dealloc`
- delegates should generally be `assign` in this legacy architecture
- avoid retain cycles
- use autorelease pools in long-running background loops

---

## Memory rules

iPad 1 has 256 MB RAM.

Required:

- bounded scrollback
- bounded parser state
- bounded screen buffer
- small read buffers
- avoid unlimited arrays/strings
- avoid multiple terminal sessions by default
- no expensive animated UI

---

## Compatibility rules

Never assume an API exists on iOS 5.1.1.

Examples already discovered:

- `UITextView.selectable` is not available
- newer SDK enum typing may create warnings treated as errors

If a modern SDK header compiles but runtime support is uncertain, verify iOS 5 availability before using it.

---

## Terminal correctness

Do not “fix” ANSI behavior merely by stripping all escape codes permanently.

The current lightweight parser is transitional.

The target is a real bounded terminal screen model.

---

## Security

Never:

- log passwords
- log private keys
- store plaintext SSH passwords in plist
- allow arbitrary external command execution through URL schemes

---

## Documentation update rule

After a meaningful coding/testing session update:

- `SESSION.md`
- `TASKS.md`
- `TESTING.md` when tests change
- `ARCHITECTURE.md` when design changes
- `PROJECT_CONTEXT.md` only for durable project-level decisions

`SESSION.md` must always end with a clear:

```text
Immediate next action
```

so a new chat can continue without guessing.

---

## Git rule

Before pushing:

```bash
git status -sb
git diff --check
```

Do not commit:

- `.theos/`
- generated package build directories
- temporary files
- passwords
- private keys

Commit source and project documentation.

Generated `.deb` packages should only be committed if explicitly desired.

---

## Development priority

```text
stability
compatibility
terminal correctness
low RAM
usability
SSH
advanced features
```
