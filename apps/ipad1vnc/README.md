# iPad1 VNC

A minimal VNC/RFB client aimed at the original iPad (iPad1,1 / iOS 5.1.1) and a lightweight Linux desktop such as XFCE.

## What v0.1 supports
- iPad UI for host, port and VNC password
- RFB 3.8 negotiation
- Security type None (1) and classic VNC Authentication (2)
- 32-bit true-colour framebuffer
- RAW VNC encoding
- Touch as left mouse button / drag
- Long press as right mouse button
- Basic on-screen keyboard (ASCII, Enter, Backspace)

## Target
- `ARCHS = armv7`
- deployment target iOS 5.1
- jailbreak-style Theos application package (`.deb`)

## Build
This repository is source-ready, but building the actual `.deb` requires a Theos environment with an ARMv7-capable iOS toolchain and an iOS SDK usable for legacy builds.

```bash
export THEOS=$HOME/theos
make package FINALPACKAGE=1
```

The package should appear under `packages/`.

## Install on a jailbroken iPad
Copy the generated `.deb` to the iPad and run as root:

```bash
dpkg -i com.olap.ipad1vnc_0.1.0_iphoneos-arm.deb
killall SpringBoard
```

## Recommended server
Use TigerVNC or another standard VNC server on the Ubuntu/XFCE host. Prefer binding VNC to localhost plus a secure tunnel, or firewall port 5901 to a trusted source IP. Do not leave unauthenticated VNC open to the Internet.

## Known limitations
RAW encoding is intentionally simple but bandwidth-heavy. For Internet use, a next version should add Hextile/Tight encoding. Clipboard, wheel scrolling, modifier keys and reconnection UI are not implemented yet.
