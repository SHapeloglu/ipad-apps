# iPad1VNC v1.1.1

Legacy VNC thin-client for first-generation iPad / iOS 5.1.1.

## v1.1.0 additions
- **Direct / Trackpad mode**
  - Direct: touch maps to the remote screen.
  - Trackpad: the iPad surface behaves like a laptop touchpad; tap clicks and movement is relative.
- **Auto quality**
  - Quality selector is now `Auto / Fast / Balanced / Quality`.
  - Auto starts at Balanced and can move down/up based on decode time.
- **Hextile VNC encoding**
  - Requests Hextile first and falls back to RAW.
  - Reduces network traffic and CPU spent moving large RAW frames.
- **Connection profiles**
  - Save several host/port/password/quality/input/speed profiles.
  - Load them from the Profiles button.
- **Native remote Files browser**
  - Compatible with `python3 -m http.server 8085`.
  - Folder navigation, Up, tap-to-download.
- Existing features preserved: rotation, fullscreen, reconnect, clipboard sync, Backspace, special keys, pinch zoom, two-finger scroll, pointer speed.

## Build
```bash
cd ~/projects/ipad1vnc/iPad1VNC-v1.1.0
make clean
make package FINALPACKAGE=1
```

Expected package:
`packages/com.olap.ipad1vnc_1.1.0_iphoneos-arm.deb`

## Server
VNC:
```bash
vncserver :1 -geometry 1024x768 -depth 24 -localhost no
```

Files:
```bash
python3 -m http.server 8085 --bind 0.0.0.0 --directory /home/desktop/Downloads
```

## Deliberately not bundled yet
SSH tunneling and a native SSH terminal are **not** faked in this release. A secure implementation needs a maintained SSH crypto/library layer (for example libssh2) compiled for armv7/iOS 5 and should be tested separately before opening it to production credentials.


## v1.1.1 build fix
- Fixes the Objective-C compile error in v1.1.0 where connection-profile method implementations were accidentally emitted inside the private `@interface` block.
- No feature was removed; Trackpad, Auto Quality, Hextile, Profiles and native Files remain enabled.
