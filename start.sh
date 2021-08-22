#!/bin/bash

export WATCHLIST_FILE=`pwd`/watchlist.json
export IEX_API_KEY_FILE=`pwd`/iex_sandbox_api_key

smashing start -d

sleep 5

chromium http://localhost:3030 --window-size=1920,1080 --start-fullscreen --kiosk --incognito --noerrdialogs --disable-translate --no-first-run --fast --fast-start --disable-infobars --disable-features=TranslateUI --disk-cache-dir=/dev/null --password-store=basic
