# iPad1 VNC v0.2

Lightweight VNC client for first-generation iPad / iOS 5.1.1.

## v0.2 changes

- Remembers VNC host, port, and password locally with `NSUserDefaults`.
- Automatically collapses the connection panel after a successful connection.
- `Setup` restores the connection panel; `Hide` collapses it manually.
- Keyboard button now toggles the iOS keyboard open/closed.
- Two-finger vertical swipe sends VNC mouse-wheel events for remote scrolling.
- Pinch zoom from 1.0x to 2.5x.
- Keeps the original single-finger mouse drag and long-press right-click behavior.

## Target

- Architecture: `armv7`
- SDK: iPhoneOS 6.1
- Deployment target: iOS 5.1
- Packaging: Theos `.deb`

The Makefile expects `iPhoneOS6.1.sdk` under `$THEOS/sdks/`.

## Build

```bash
cd ~/projects/ipad1vnc/iPad1VNC
make clean
make package FINALPACKAGE=1
```

Expected output:

```text
packages/com.olap.ipad1vnc_0.2.0_iphoneos-arm.deb
```

## Upgrade on the iPad

Copy the `.deb` to the iPad and run as root:

```bash
dpkg -i /var/mobile/com.olap.ipad1vnc_0.2.0_iphoneos-arm.deb
killall SpringBoard
```

## Gestures

- One finger: left mouse button / drag
- Long press: right mouse button
- Two-finger vertical swipe: remote mouse-wheel scroll
- Pinch: local zoom (1.0x–2.5x)
- Keyboard button: show/hide iOS keyboard

## Server example

TigerVNC display `:1` normally listens on TCP port `5901`:

```bash
vncserver :1 -geometry 1024x768 -depth 24 -localhost no
```
