#! /usr/bin/env sh
url="$1"
activeWindow="$(hyprctl activewindow -j | jq .initialClass)"
if [ "$activeWindow" = '"firefox"' ]; then
  echo "firefox is the active window. Opening new tab: $url"
  firefox --new-tab "$url"
else
  echo "firefox is not the active window. Opening new window: $url"
  firefox --new-window "$url" 
fi
