#!/usr/bin/env sh
zoom="$1"
activeWindow="$(hyprctl activewindow -j | jq .initialClass)"
# Key codes: Control_L = 29, Shift_L = 42, equal = 13, minus = 12
if [ "$activeWindow" = '"kitty"' ]; then
    if [ "$zoom" = "1" ]; then
        # For zoom in (Ctrl + Shift + =)
        hyprctl dispatch exec ydotool key 29:1 42:1 13:1 13:0 42:0 29:0
    else
        # For zoom out (Ctrl + Shift + -)
        hyprctl dispatch exec ydotool key 29:1 42:1 12:1 12:0 42:0 29:0
    fi
fi

zoom="$1"
# Key codes: Control_L = 29, Shift_L = 42, equal = 13, minus = 12
    if [ "$zoom" = "1" ]; then
        sudo ydotool key 29:1 42:1 13:1 13:0 42:0 29:0
    else
        sudo ydotool key 29:1 42:1 12:1 12:0 42:0 29:0
    fi
