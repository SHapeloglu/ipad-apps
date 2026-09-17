# iPad1VNC v2.1.0-rc1 acceptance checklist

## Baseline
- [ ] Build succeeds for armv7 / iOS 5.1
- [ ] App launches
- [ ] Existing host/port remain
- [ ] Existing VNC secret is migrated to Keychain
- [ ] Existing Files token is migrated to Keychain

## Hextile
- [ ] Tight OFF connects
- [ ] Direct mode
- [ ] Trackpad mode
- [ ] Zoom
- [ ] Two-finger scroll
- [ ] Clipboard
- [ ] Keyboard + extended toolbar
- [ ] 15-minute stable session

## Health / Auto Quality
- [ ] RTT appears
- [ ] FPS appears
- [ ] kbps appears
- [ ] encoding appears
- [ ] uptime/reconnect count appears in Tools
- [ ] Auto does not oscillate rapidly

## Tight
- [ ] Tight ON connects
- [ ] desktop remains correct after scrolling/moving windows
- [ ] gradients do not corrupt colors
- [ ] JPEG regions render
- [ ] reconnect after server restart

## Profiles
- [ ] save
- [ ] load
- [ ] duplicate
- [ ] delete
- [ ] set default
- [ ] auto connect
- [ ] profile-specific VNC password
- [ ] profile-specific Files token

## SSH
- [ ] username respected
- [ ] host fingerprint prompt shown on first interactive connection
- [ ] known_hosts persists
- [ ] key generation works
- [ ] Ctrl-C/arrows/Home/End/PgUp/PgDn
- [ ] `top` displays acceptably
- [ ] SSH tunnel connects after host is trusted

## Files
- [ ] list
- [ ] download
- [ ] upload small file
- [ ] upload 100+ MB file without memory crash
- [ ] progress updates
- [ ] new folder
- [ ] rename
- [ ] delete
- [ ] server restart keeps token

## Tools
- [ ] WOL valid MAC
- [ ] Match iPad resolution
- [ ] rotate portrait/landscape
- [ ] Auto Resolution does not loop
