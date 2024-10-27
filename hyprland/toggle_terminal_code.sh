#!/bin/bash

active_window=$(hyprctl activewindow -j | jq -r .class)
active_address=$(hyprctl activewindow -j | jq -r .address)
previous_window=""
previous_address=""

# Check if a temporary file containing previous window info exists
if [[ -f /tmp/previous_window.txt && -f /tmp/previous_address.txt ]]; then
    echo "Switching to previous window..."
    # Read previous window info from temporary files
    previous_window=$(cat /tmp/previous_window.txt)
    previous_address=$(cat /tmp/previous_address.txt)
    rm /tmp/previous_window.txt /tmp/previous_address.txt
    hyprctl dispatch focuswindow address:"$previous_address" &
else 
    echo "Switching to Kitty..."
    # If temporary files don't exist, store active window info as previous window
    echo "$active_window" > /tmp/previous_window.txt
    echo "$active_address" > /tmp/previous_address.txt
    hyprctl dispatch focuswindow "kitty"
fi
