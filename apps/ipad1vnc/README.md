# iPad1VNC 1.0

A deliberately lightweight VNC thin-client for the first-generation iPad (armv7 / iOS 5.1.1) and a Linux desktop such as Ubuntu 24.04 + XFCE + TigerVNC.

## 1.0 feature set

- RFB/VNC 3.8 client with classic VNC password authentication
- RAW framebuffer encoding for broad legacy compatibility
- Fast (8-bit), Balanced (16-bit RGB565), and Quality (32-bit) display profiles
- Direct touch pointer control and pointer-speed adjustment
- Long-press right-click
- Pinch zoom
- Two-finger wheel scrolling
- Portrait / landscape rotation
- Full-screen mode with Menu button
- Automatic reconnect after disconnect
- On-screen keyboard input
- Legacy-friendly special-key bar: Esc, Ctrl, Alt, Tab, arrows, Copy, Paste
- Bidirectional text clipboard synchronization through VNC ClientCutText / ServerCutText
- Streaming HTTP/HTTPS URL downloads without buffering the whole file in RAM
- Downloaded-file list and collision-safe filenames
- Connection settings remembered between launches

## Download location

The app first tries:

`/var/mobile/Documents/iPad1VNC/`

If that location is not writable it falls back to a temporary application directory.

For modern HTTPS sites, iOS 5's old TLS/CA stack can prevent a download even when the URL works on newer devices. Plain HTTP or a compatible server can be used for trusted/private transfers.

## Build

The project is designed for the Theos setup already validated with this device:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Required working SDK path:

`$THEOS/sdks/iPhoneOS6.1.sdk`

Build:

```bash
cd iPad1VNC
make clean
make package FINALPACKAGE=1
```

Expected package:

`packages/com.olap.ipad1vnc_1.0.0_iphoneos-arm.deb`

Copy to the iPad, then on the iPad as root:

```bash
dpkg -i /var/mobile/com.olap.ipad1vnc_1.0.0_iphoneos-arm.deb
killall SpringBoard
```

## Ubuntu / TigerVNC

Install:

```bash
sudo apt update
sudo apt install -y tigervnc-standalone-server tigervnc-tools dbus-x11 xfce4
vncpasswd
mkdir -p ~/.vnc
```

`~/.vnc/xstartup`:

```sh
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-launch --exit-with-session startxfce4
```

Then:

```bash
chmod +x ~/.vnc/xstartup
vncserver :1 -geometry 1024x768 -depth 24 -localhost no
```

Display `:1` normally listens on TCP `5901`.

## Security

Do not leave TCP 5901 open to the entire internet. Restrict it at the Contabo firewall to trusted source IP addresses, or place VNC behind a private network/VPN/SSH tunnel. Classic VNC authentication does not provide modern end-to-end transport security.

## Scope

The 1.0 build intentionally avoids heavyweight dependencies such as libssh2 and modern video codecs. That keeps the app realistic for 256 MB RAM and iOS 5.1.1. Native SSH tunnelling, SFTP browsing, audio streaming, and H.264-style remote-display codecs are candidates for a separate advanced branch rather than the legacy core.
