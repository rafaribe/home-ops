#!/usr/bin/env bash
sudo cat >/etc/default/keyboard <<EOF
XKBMODEL="pc105"
XKBLAYOUT="$1"
XKBVARIANT=""
XKBOPTIONS=""
BACKSPACE="guess"
EOF
sudo invoke-rc.d keyboard-setup start
sudo udevadm trigger --subsystem-match=input --action=change

#show some love for the virtual consoles as well
#sudo debconf-set-selections <<< 'console-data console-data/keymap/policy select Select keymap from full list'
sudo localectl set-keymap --no-convert $1
