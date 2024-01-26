#! /usr/bin/env sh
url="$1"
activeWindow="$(hyprctl activewindow -j | jq .initialClass)"
if [ "$activeWindow" = '"firefox"' ]; then
  echo "Firefox is the active window. Opening new tab: $url"
  firefox --new-tab "$url"
else
  echo "Firefox is not the active window. Opening new window: $url"
  firefox --new-window "$url"
fi
