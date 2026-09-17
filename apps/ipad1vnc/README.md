# iPad1VNC v0.3

A deliberately small VNC client for the first-generation iPad running iOS 5.1.1. It targets armv7 and is packaged as a jailbreak-friendly `.deb` with Theos.

## v0.3 changes

- Automatic reconnect 3 seconds after a dropped VNC connection.
- Full-screen desktop mode with a small `Menu` button to return to controls.
- Pointer-speed control (0.5x to 1.5x), saved between launches.
- TCP keepalive + TCP_NODELAY for lower-latency input and more resilient sessions.
- Existing v0.2 features remain: saved host/port/password, collapsible setup bar, keyboard button, pinch zoom, two-finger wheel scrolling and long-press right click.

## Build target

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Expected build environment: Theos on Linux/WSL, iOS cross-toolchain, and a complete iPhoneOS 6.1 SDK linked at `$THEOS/sdks/iPhoneOS6.1.sdk`.

Build:

```bash
make clean
make package FINALPACKAGE=1
```

Expected package:

```text
packages/com.olap.ipad1vnc_0.3.0_iphoneos-arm.deb
```

## Install on jailbroken iPad

Copy the package to `/var/mobile/`, then from a root shell on the iPad:

```bash
dpkg -i /var/mobile/com.olap.ipad1vnc_0.3.0_iphoneos-arm.deb
killall SpringBoard
```

## VNC server

The existing Ubuntu/TigerVNC setup can continue to use display `:1` / TCP port `5901` at 1024x768. Restrict the VNC port with the provider firewall whenever possible.
