#!/usr/bin/zsh

activeWindow="$(hyprctl activewindow -j | jq .initialClass)"
selected=""

if [ "$activeWindow" = '"firefox"' ]; then
    selected=$(firefox "$(xsel -o)")
elif [ "$activeWindow" = '"kitty"' ]; then
    selected=$(kitty "$(xsel -o)")
else
    text=$(xsel -o)
fi

if [ -n "$selected" ]; then
    kitty --hold -- sh -c "echo $selected"
else
    kitty --hold -- sh -c "echo 'Neither Firefox nor Kitty is the active window.'"
fi
