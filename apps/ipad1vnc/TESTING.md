# iPad1VNC 2.2.0-beta1 acceptance

## Compile
- [ ] armv7 / iOS 5.1 build passes
- [ ] application installs and launches

## VNC baseline
- [ ] Tight ON connects
- [ ] Hextile fallback connects
- [ ] 15 minutes no visual corruption

## Diagnostics
- [ ] RTT now changes
- [ ] RTT avg changes
- [ ] RTT max increases on a slow event
- [ ] FPS changes during idle vs window movement
- [ ] kbps changes
- [ ] total frame counter increases
- [ ] health classification changes sensibly

## Mouse
- [ ] Precision is visibly slower
- [ ] long press right click
- [ ] 3-finger middle click
- [ ] Drag Lock double tap
- [ ] 2-finger wheel

## Profiles
- [ ] Desktop Connect
- [ ] Terminal
- [ ] Files
- [ ] Wake
- [ ] Load & Edit
- [ ] Duplicate
- [ ] Delete

## Keyboard
- [ ] F1-F12
- [ ] Insert/Delete
- [ ] Alt+Tab
- [ ] Ctrl+Alt+T
- [ ] Ctrl+Alt+Del

## Files server 2.2
- [ ] /api/stat works
- [ ] Range download returns HTTP 206
- [ ] interrupted download resumes
- [ ] interrupted upload resumes
- [ ] queue starts next item
- [ ] 100+ MB transfer does not crash app

## LAN
- [ ] Wi-Fi IPv4 detected
- [ ] SSH server appears
- [ ] VNC server appears
- [ ] selected LAN result fills Host

## TLS / VeNCrypt
- [ ] server configured for X509Vnc
- [ ] X509 TLS switch connects
- [ ] wrong/untrusted certificate fails
- [ ] normal VncAuth remains functional with TLS switch OFF

## Stability
- [ ] 30 minute session
- [ ] 60 minute session
- [ ] memory warning does not crash
- [ ] reconnect works after Wi-Fi interruption
