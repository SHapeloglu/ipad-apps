# v2.0.0-beta1 test order

1. Install and launch; verify setup controls no longer overlap.
2. Connect with Tight OFF (Hextile baseline).
3. Test Direct + Trackpad, scroll, zoom, keyboard, clipboard.
4. Watch FPS/kbps/encoding stats.
5. Enable Tight and reconnect. If session disconnects, turn Tight OFF and capture server log.
6. Profiles: save 2, load, delete 1.
7. Terminal: confirm `/usr/bin/ssh` exists and interactive login works.
8. SSH key: copy key to `/var/mobile/.ssh/`, chmod 600, test terminal.
9. Enable VNC Tunnel and reconnect. Once confirmed, firewall 5901 from the public Internet.
10. Install Files v2 API on server and test token-authenticated list/download.
11. Test upload, new folder, rename, delete only inside `/home/desktop/Downloads`.
12. Rotate during live VNC and terminal sessions.
13. Reboot server and iPad; confirm services/settings persist.
