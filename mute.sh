#!/bin/bash

# Mute/unmute input through PulseAudio
# Usage: ./mute_input.sh

# Find the source index of your input device
SOURCE_INDEX=$(pactl list sources | grep -A2 RUNNING | grep 'Name: ' | awk -F" " '{print $2}')

# Check if the source is already muted
IS_MUTED=$(pacmd list-sources | awk '/index: '"$SOURCE_INDEX"'/{getline; getline; print $2}')

# Toggle mute state
if [ "$IS_MUTED" = "yes" ]; then
    pactl set-source-mute "$SOURCE_INDEX" 0
    echo "Input unmuted"
else
    pactl set-source-mute "$SOURCE_INDEX" 1
    echo "Input muted"
fi
