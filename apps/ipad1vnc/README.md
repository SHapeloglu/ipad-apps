# iPad1VNC v2.1.0-rc1

This release candidate folds the planned "finish the fundamentals" roadmap into one branch for iPad 1 / iOS 5.1.1.

## What is included

### VNC / performance
- RAW + Hextile
- Reworked Tight decoder:
  - four persistent zlib streams
  - stream reset bits
  - Copy filter
  - Palette filter
  - Gradient filter
  - JPEG rectangles
  - Fill rectangles
- Tight uses a 24-bit true-color transport for interoperability.
- Auto Quality 2.0 for Hextile/RAW:
  - decode time
  - framebuffer request/update RTT estimate
  - hysteresis to avoid quality oscillation
- Health HUD:
  - RTT/latency estimate
  - FPS
  - kbps
  - encoding
  - quality
  - uptime
  - reconnect count

### Security
- VNC password and Files API token migrate out of NSUserDefaults into iOS Keychain.
- Profile-specific VNC password and Files token are stored in Keychain.
- SSH interactive sessions use `StrictHostKeyChecking=ask`.
- SSH tunnel uses `StrictHostKeyChecking=yes`; trust the server once in Terminal before enabling the tunnel.
- Private keys remain files under `/var/mobile/.ssh/` and are created with restrictive permissions.

### Profiles 2.0
Profiles can retain:
- VNC host/port
- quality/input/speed
- SSH user/port/key/tunnel
- Files URL
- WOL MAC/broadcast
- remote DISPLAY
- auto-resolution preference

Profile management includes:
- Load
- Duplicate
- Delete
- Set Default
- Toggle Auto Connect

### Terminal 2.0
- explicit Connect / Stop
- RSA key generation through jailbroken `/usr/bin/ssh-keygen`
- 5,000-line bounded scrollback
- lightweight VT100/ANSI screen interpretation
- terminal toolbar: Esc, Ctrl-C, Tab, Home, End, PgUp/PgDn and arrows

This is intentionally a small VT100-like compatibility layer, not a full modern xterm implementation.

### Files 2.1
Authenticated API:
- list
- download
- new folder
- rename
- delete
- file size + modified timestamp from server
- chunked 64 KB upload so large files are not loaded fully into the iPad's 256 MB RAM
- upload progress and cancel state

### Tools
- Wake-on-LAN
- Match remote XFCE/VNC framebuffer to current iPad orientation using SSH + `xrandr --fb`
- optional auto-resolution on orientation changes
- connection diagnostics panel

## Important rollout order

1. Build/install rc1.
2. Leave Tight OFF and verify the existing Hextile path.
3. Verify Keychain migration did not lose the VNC password/Files token.
4. Test Terminal and accept the SSH host fingerprint.
5. Test SSH tunnel; only after that close public VNC port 5901.
6. Upgrade the server Files API with the included Python script before testing chunked upload.
7. Test Tight separately. If TigerVNC still sends a Tight variant not handled correctly, switch Tight OFF and keep Hextile as the safe fallback.
8. Test Dynamic Resolution manually before enabling Auto Resolution.

## Build

```bash
cd ~/projects/ipad1vnc/iPad1VNC-v2.1.0-rc1
make clean
make package FINALPACKAGE=1
```

Expected:
`packages/com.olap.ipad1vnc_2.1.0-rc1_iphoneos-arm.deb`

## Server Files API upgrade

Copy:
`./scripts/ipad1vnc_fileserver.py`

to:
`/opt/ipad1vnc/ipad1vnc_fileserver.py`

then:

```bash
sudo chmod 755 /opt/ipad1vnc/ipad1vnc_fileserver.py
sudo systemctl restart ipad1vnc-fileserver
sudo systemctl status ipad1vnc-fileserver --no-pager
```

The existing token file remains valid.
