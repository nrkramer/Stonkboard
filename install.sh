#!/bin/bash

SCRIPTPATH=$(dirname $(readlink -f "$0"))

#echo "@xset s off" >> $AUTOSTART
#echo "@xset -dpms" >> $AUTOSTART
#echo "@xset s noblank" >> $AUTOSTART

# Install dependencies
sudo apt install nodejs unclutter chromium-browser

# Install gems
sudo gem install bundler smashing rufus-scheduler thin
bundle

# Install systemd service for stonkboard
mkdir -p /etc/systemd/system
cp stonkboard.service /etc/systemd/system/.
systemctl enable stonkboard.service

echo "Install complete"
