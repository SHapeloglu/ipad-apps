# ARCHITECTURE

## Current architecture

```text
iOS keyboard
    |
    v
TerminalInputView (UIKeyInput, invisible)
    |
    v
TerminalViewController
    |
    +--> Special key bar
    |
    +--> TerminalANSIParser
    |
    v
LocalTerminalSession
    |
    v
PTY master <--> PTY slave <--> /bin/sh
```

## Input

The visible command UITextField used by 0.1 has been removed.

`TerminalInputView` is an invisible `UIKeyInput` responder. This gives the terminal direct keyboard input without displaying a separate white form control.

## ANSI

`TerminalANSIParser` is intentionally lightweight in 0.2.

It prevents raw CSI sequences such as `ESC[K` from leaking into the terminal text.

It is not yet a complete screen emulator. Cursor-oriented terminal programs will be handled by a future screen-buffer implementation.

## Memory

- PTY reads use a fixed 2048-byte buffer.
- UTF-8 incomplete byte tails are bounded.
- terminal scrollback is bounded at 120000 characters.
- no WebView is used.

## Compatibility

- iPad 1
- iOS 5.1.1
- armv7
- Theos
- SDK 6.1 / deployment target 5.1
- Objective-C MRC
