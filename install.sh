#!/bin/bash

SCRIPTPATH=$(dirname $(readlink -f "$0"))

# Install automation into /home/pi/.config/lxsession/LXDE-pi/autostart
#AUTOSTART="/home/pi/.config/lxsession/LXDE-pi/autostart"
#mkdir -p $(dirname "$AUTOSTART")
#touch $AUTOSTART

#echo "@xset s off" >> $AUTOSTART
#echo "@xset -dpms" >> $AUTOSTART
#echo "@xset s noblank" >> $AUTOSTART
#echo "@cd $SCRIPTPATH && ./start.sh" >> $AUTOSTART
#echo "@chromium http://localhost:3030 --window-size=1920,1080 --start-fullscreen --kiosk --incognito --noerrdialogs --disable-translate --no-first-run --fast --fast-start --disable-infobars --disable-features=TranslateUI --disk-cache-dir=/dev/null --password-store=basic &" >> $AUTOSTART
#echo "Changes written to $AUTOSTART"

# Install systemd service for smashing
mkdir -p /etc/systemd/system
cp stonkboard.service /etc/systemd/system/.
systemctl enable stonkboard.service

#DESKTOP_ENTRY="$HOME/.config/autostart/stonkboard.desktop"

#rm -f $DESKTOP_ENTRY
#mkdir -p $(dirname "$DESKTOP_ENTRY")
#touch $DESKTOP_ENTRY

#echo "[Desktop Entry]" >> $DESKTOP_ENTRY
#echo "Type=Application" >> $DESKTOP_ENTRY
#echo "Name=Stonkboard" >> $DESKTOP_ENTRY
#echo "Exec=/usr/bin $SCRIPTPATH/start.sh" >> $DESKTOP_ENTRY

#echo "Changes written to $DESKTOP_ENTRY"

echo "Install complete"
