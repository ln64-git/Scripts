#!/bin/bash
# smooth_cursor_zoom.sh
# Parameters: $1 = "in" or "out"
step=0.1
base_delay=0.000030
steps=10
min_zoom=1.0
max_zoom=10.0
acceleration=1
lock_file="/tmp/zoom_animation.lock"

# Cleanup function for lock file
cleanup() {
    rm -f "$lock_file"
    exit 0
}

# Ensure cleanup on script termination
trap cleanup SIGINT SIGTERM EXIT

# Get the current zoom factor
current_zoom=$(hyprctl getoption cursor:zoom_factor | awk '/float/ {print $NF}')
if [[ -z "$current_zoom" ]]; then
    echo "Error: Could not retrieve cursor zoom factor!"
    exit 1
fi

# Function for dynamic delay calculation
calculate_delay() {
    local zoom_level=$1
    echo "$(echo "scale=5; $base_delay + ($zoom_level / $max_zoom * $base_delay)" | bc -l)"
}

# Prevent multiple instances
if [ -f "$lock_file" ]; then
    echo "Animation already running. Exiting..."
    exit 1
fi
touch "$lock_file"

if [ "$1" = "in" ]; then
    for i in $(seq 1 $steps); do
        new_zoom=$(echo "$current_zoom + ($step * $i * $acceleration)" | bc -l)
        if (( $(echo "$new_zoom > $max_zoom" | bc -l) )); then new_zoom=$max_zoom; break; fi
        hyprctl keyword cursor:zoom_factor "$new_zoom"
        sleep "$(calculate_delay "$new_zoom")"
    done

elif [ "$1" = "out" ]; then
    for i in $(seq 1 $steps); do
        new_zoom=$(echo "$current_zoom - ($step * $i * $acceleration)" | bc -l)
        if (( $(echo "$new_zoom < $min_zoom" | bc -l) )); then new_zoom=$min_zoom; break; fi
        hyprctl keyword cursor:zoom_factor "$new_zoom"
        sleep "$(calculate_delay "$new_zoom")"
    done
fi

cleanup
