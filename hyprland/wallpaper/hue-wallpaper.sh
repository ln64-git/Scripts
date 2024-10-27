#!/usr/bin/env bash

# Get the current wallpaper
CURRENT_WALLPAPER=$(swww query | awk -F 'image: ' '{print $2}')

# Check if a wallpaper is set
if [ -z "$CURRENT_WALLPAPER" ]; then
  echo "No current wallpaper found."
  exit 1
fi

# Generate a random hue shift value (between 0 and 360 degrees)
HUE_SHIFT=$((RANDOM % 360))

# Apply the hue shift to the current wallpaper using ImageMagick
TEMP_WALLPAPER="/tmp/$(basename "$CURRENT_WALLPAPER")_hue.png"
convert "$CURRENT_WALLPAPER" -modulate 100,100,$HUE_SHIFT "$TEMP_WALLPAPER"

# Reapply the altered wallpaper
~/.config/ags/scripts/color_generation/switchwall.sh "$TEMP_WALLPAPER"

# Optionally clean up after setting the wallpaper
# rm "$TEMP_WALLPAPER"
