# AGENTS

## Non-negotiable platform constraints

- iPad 1
- iOS 5.1.1
- armv7
- 256 MB RAM
- jailbreak
- Objective-C
- non-ARC / MRC
- Theos
- UIKit / Foundation
- no Swift
- no modern iOS API assumptions

## Development rule

Do not start SSH, ANSI complexity, themes, tabs, SFTP or multiple sessions until the local `/bin/sh` PTY milestone has passed on real hardware.

## Compatibility rule

Prefer simple POSIX and APIs available on iOS 5.1.1.

Do not replace working legacy-compatible code with newer APIs simply for style.

## Memory rule

All buffers and histories must be bounded.

## Documentation rule

At the end of meaningful changes update:

- SESSION.md
- TASKS.md
- TESTING.md
- ARCHITECTURE.md when architecture changes
