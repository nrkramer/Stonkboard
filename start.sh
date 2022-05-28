#!/bin/bash

set -e

SCRIPTPATH=$(dirname $(readlink -f "$0"))

export WATCHLIST_PATH=`pwd`/watchlist.json
export IEX_CONFIG_PATH=`pwd`/iex_sandbox

export FONTCONFIG_PATH=/etc/fonts
export GEM_HOME=$HOME/.gem
export PATH=$PATH:$GEM_HOME/bin

smashing start &

sleep 5

unclutter&
chromium-browser http://localhost:3030 --window-size=1920,1080 --start-fullscreen --kiosk --incognito --noerrdialogs --disable-translate --no-first-run --fast --fast-start --disable-infobars --disable-features=TranslateUI --disk-cache-dir=/dev/null --password-store=basic
