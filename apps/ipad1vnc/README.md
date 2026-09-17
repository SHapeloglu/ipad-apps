# iPad1VNC v2.2.0-beta1

This branch combines the post-2.1 competitor-gap roadmap in one update. It is intentionally a **beta** because several large changes need real-device validation on iOS 5.1.1.

## New in 2.2

### Diagnostics 2.0
- refresh interval reduced to 0.5 s
- RTT current / rolling average / maximum
- FPS current / cumulative average
- kbps
- total framebuffer updates
- encoding / quality
- uptime / reconnect count
- simple Excellent / Good / Poor health classification

### VeNCrypt / TLS
- optional **X509Vnc (VeNCrypt subtype 261)** client path using iOS SecureTransport
- server certificate hostname validation
- VNC password authentication takes place inside the encrypted channel
- normal VncAuth remains the default and safe fallback
- X509 TLS is OFF by default

This beta deliberately targets X509Vnc rather than anonymous TLSVnc. Configure TigerVNC with X.509-based VeNCrypt before enabling the switch.

### Mouse UX
- Precision mode: 0.30x fine pointer movement
- Drag Lock: double tap toggles held left button
- 3-finger tap: middle mouse button
- existing long press: right click
- existing 2-finger pan: wheel

### Profiles 3.0
Selecting a profile now exposes quick actions:
- Desktop Connect
- Terminal
- Files
- Wake
- Load & Edit
- Duplicate
- Delete

Profiles also persist:
- X509 TLS
- Precision mode
- Drag Lock

### LAN discovery
- scans the local IPv4 /24
- detects SSH (22) and configured VNC port
- results can populate the connection host
- scanning is on a worker thread

### Keyboard
- F1-F12
- Insert / Delete / Print Screen
- Alt+Tab
- Ctrl+Alt+Del
- Ctrl+Alt+T
- Ctrl+Shift+Esc
- Super / Menu / Pause / Scroll Lock
- extended keys are exposed via a compact `Keys…` menu to avoid overcrowding the iPad 1 keyboard bar

### Files 2.2
- sequential transfer queue
- pause/resume state
- HTTP Range download resume
- partial downloads use `.part`
- failed/cancelled partial downloads are retained
- server `/api/stat`
- chunk upload resumes from current remote size
- 64 KB upload chunks remain RAM-safe for 256 MB devices
- server supports `Accept-Ranges`

**Server script must be upgraded** before testing resume.

### iPad 1 stability
- per-network-message autorelease pool to prevent long VNC sessions accumulating autoreleased frame objects
- memory warning handler trims terminal scrollback and temporary file/browser data
- terminal normal limit remains bounded

## Build

```bash
cd ~/projects/ipad1vnc/iPad1VNC-v2.2.0-beta1
make clean
make package FINALPACKAGE=1
```

Expected package:

```text
packages/com.olap.ipad1vnc_2.2.0-beta1_iphoneos-arm.deb
```

## Upgrade Files API on Contabo

From WSL:

```bash
scp scripts/ipad1vnc_fileserver.py root@95.111.242.96:/opt/ipad1vnc/ipad1vnc_fileserver.py
```

On Contabo:

```bash
sudo chmod 755 /opt/ipad1vnc/ipad1vnc_fileserver.py
sudo systemctl restart ipad1vnc-fileserver
sudo systemctl status ipad1vnc-fileserver --no-pager -l
```

The existing token file remains unchanged.

## Recommended validation order

1. Compile.
2. Tight ON baseline.
3. Diagnostics 2.0 while dragging windows / scrolling.
4. Precision, right/middle click, Drag Lock.
5. Profiles 3.0 quick actions.
6. Terminal.
7. Upgrade server Files API.
8. Download interruption -> resume.
9. Upload interruption -> resume.
10. LAN Scan on Wi-Fi.
11. SSH Tunnel.
12. X509 TLS **only after TigerVNC is configured for X509Vnc**.
13. 30-60 minute VNC memory/stability test.

Do not expose plain VNC to the internet merely because TLS support exists; keep SSH tunnel as the known-good secure path until X509Vnc has been validated on the actual server.
