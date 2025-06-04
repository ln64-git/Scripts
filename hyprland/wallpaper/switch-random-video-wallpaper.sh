#!/bin/bash

# Default directory if no argument is passed
DEFAULT_WALLPAPER_DIR="/home/ln64/Videos/wallpapers"
TRACK_FILE="/tmp/wallpaper_cycle"

# Use the argument passed to the script, or the default directory if none is provided
WALLPAPER_DIR="${1:-$DEFAULT_WALLPAPER_DIR}"

# Check if the directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Directory '$WALLPAPER_DIR' does not exist."
    exit 1
fi

# Create or update the list of wallpapers
if [ ! -f "$TRACK_FILE" ] || [ ! -s "$TRACK_FILE" ]; then
    find "$WALLPAPER_DIR" -type f | shuf > "$TRACK_FILE"
fi

# Get the next wallpaper from the list
NEXT_WALLPAPER=$(head -n 1 "$TRACK_FILE")

# If the file is empty or the wallpaper doesn't exist, refresh the list
if [ -z "$NEXT_WALLPAPER" ] || [ ! -f "$NEXT_WALLPAPER" ]; then
    find "$WALLPAPER_DIR" -type f | shuf > "$TRACK_FILE"
    NEXT_WALLPAPER=$(head -n 1 "$TRACK_FILE")
fi

# Remove the used wallpaper from the list
sed -i '1d' "$TRACK_FILE"

# Change the wallpaper
~/.config/ags/scripts/color_generation/switchwall.sh "$NEXT_WALLPAPER"
