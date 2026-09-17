# iPad1VNC v2.0.0-beta3

A feature-complete beta aimed at turning an iPad 1 / iOS 5.1.1 into a lightweight Linux thin client.

## Included
- VNC: RAW + Hextile + **experimental Tight** (copy/palette/JPEG; gradient filter intentionally falls back)
- Auto quality + Fast/Balanced/Quality
- Direct Touch + Trackpad
- Connection stats: FPS, kbps, encoding, quality
- Connection profiles + load/delete management
- Fullscreen, reconnect, rotation, clipboard, special keys, Backspace, pinch zoom, two-finger scroll
- SSH terminal using the jailbroken device's `/usr/bin/ssh`
- Key-based SSH VNC tunnel
- Native authenticated Files v2 client + Python API supporting:
  - list/download
  - upload
  - rename
  - delete
  - new folder
- Cleaner 1024x768 setup layout

## Important beta constraints
1. **SSH**
   - `/usr/bin/ssh` must exist on the iPad (OpenSSH client).
   - Tunnel mode intentionally requires an SSH key. Password automation is not embedded.
2. **Tight**
   - Tight is optional. Leave the switch OFF for Hextile if a server uses an unsupported Tight gradient filter.
3. **Files v2**
   - Replace plain `python3 -m http.server` with the bundled `scripts/ipad1vnc_fileserver.py`.
   - The v2 API uses a token. The token is created in `/home/desktop/.ipad1vnc-files-token`.
   - Upload/New Folder/Rename/Delete are wired to the authenticated API; validate them on device before exposing the API publicly.
4. This is a jailbreak-targeted application, not an App Store build.

## Build
```bash
cd ~/projects/ipad1vnc/iPad1VNC-v2.0.0-beta
make clean
make package FINALPACKAGE=1
```

Expected package:
`packages/com.olap.ipad1vnc_2.0.0-beta1_iphoneos-arm.deb`

## Server: install Files v2 API
```bash
sudo mkdir -p /opt/ipad1vnc
sudo cp scripts/ipad1vnc_fileserver.py /opt/ipad1vnc/
sudo chmod 755 /opt/ipad1vnc/ipad1vnc_fileserver.py
sudo cp scripts/ipad1vnc-fileserver.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now ipad1vnc-fileserver
sudo cat /home/desktop/.ipad1vnc-files-token
```

Do not expose port 8085 broadly until the app token field is tested. SSH tunneling is the preferred final security model for VNC.


## beta2 compile fix
- Closes the private `AppDelegate` class extension before the first method body.
- Adds the missing `@implementation AppDelegate` and `@synthesize window = _window`.
- Moves stray method prototypes (`keyboardTapped`, `filesTapped`, Files helpers) back into the private interface.
- Fixes beta1's `expected ';' after method prototype` errors.
- No v2 feature was removed.


## beta3 compile fixes
- Removed duplicate `settingsTapped`.
- Removed unused `manageProfilesTapped` declaration.
- Restored missing `startDownloadFromURL:` implementation.
- Restored missing `refreshFileList` implementation.
- Added private declarations for Files/download helper methods so the iOS 5 compiler does not treat them as unknown selectors.
- No v2 feature was removed.
