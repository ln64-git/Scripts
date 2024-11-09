#!/bin/bash
# smooth_cursor_zoom.sh
# Parameters: $1 = "in" or "out"
step=0.1       # Increased step amount for faster zoom adjustment
base_delay=0.000030  # Further reduced base delay between steps (in seconds)
steps=10        # Reduced number of steps for faster animation
min_zoom=1.0   # Minimum zoom factor
max_zoom=10.0  # Maximum zoom factor
acceleration=1  # Acceleration factor for zoom adjustment
lock_file="/tmp/zoom_animation.lock"

# Function to clean up lock file on exit
cleanup() {
    rm -f "$lock_file"
    exit
}

# Trap signals to ensure cleanup
trap cleanup SIGINT SIGTERM

# Get the current zoom factor
current_zoom=$(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2}')

# Dynamic delay calculation based on zoom level for finer control at higher zoom
function calculate_delay {
    local zoom_level=$1
    echo "$(echo "scale=5; $base_delay + ($zoom_level / $max_zoom * $base_delay)" | bc -l)"
}

# Check if an animation is already running
if [ -f "$lock_file" ]; then
    echo "Animation in progress. Stopping current animation..."
    cleanup
fi

# Create lock file to indicate animation is in progress
touch "$lock_file"

if [ "$1" = "in" ]; then
    for i in $(seq 1 $steps); do
        # Increase zoom factor with acceleration
        new_zoom=$(echo "$current_zoom + ($step * $i * $acceleration)" | bc -l)

        # Clamp to max_zoom
        if (( $(echo "$new_zoom > $max_zoom" | bc -l) )); then
            new_zoom=$max_zoom
            break  # Stop further zoom-in if max reached
        fi

        hyprctl keyword cursor:zoom_factor "$new_zoom"
        sleep $(calculate_delay "$new_zoom")
    done

elif [ "$1" = "out" ]; then
    for i in $(seq 1 $steps); do
        # Decrease zoom factor with acceleration
        new_zoom=$(echo "$current_zoom - ($step * $i * $acceleration)" | bc -l)

        # Clamp to min_zoom
        if (( $(echo "$new_zoom < $min_zoom" | bc -l) )); then
            new_zoom=$min_zoom
            break  # Stop further zoom-out if min reached
        fi

        hyprctl keyword cursor:zoom_factor "$new_zoom"
        sleep $(calculate_delay "$new_zoom")
    done
fi

# Clean up lock file after animation completes
cleanup