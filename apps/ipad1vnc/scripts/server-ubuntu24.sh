#!/usr/bin/env bash
set -euo pipefail
sudo apt update
sudo apt install -y tigervnc-standalone-server tigervnc-common dbus-x11
printf '\nCreate a VNC password with: vncpasswd\n'
printf 'Then start XFCE on display :1 (port 5901), e.g.:\n'
printf '  vncserver :1 -geometry 1024x768 -depth 24\n'
printf 'Configure ~/.vnc/xstartup to run startxfce4.\n'
