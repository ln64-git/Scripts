#!/usr/bin/env bash

# Get the current wallpaper
CURRENT_WALLPAPER=$(swww query | awk -F 'image: ' '{print $2}')

# Check if a wallpaper is set
if [ -z "$CURRENT_WALLPAPER" ]; then
  echo "No current wallpaper found."
  exit 1
fi

# Invert the colors of the current wallpaper using ImageMagick
TEMP_WALLPAPER="/tmp/$(basename "$CURRENT_WALLPAPER")_inverted.png"
convert "$CURRENT_WALLPAPER" -negate "$TEMP_WALLPAPER"

# Reapply the altered wallpaper
~/.config/ags/scripts/color_generation/switchwall.sh "$TEMP_WALLPAPER"

# Optionally clean up after setting the wallpaper
# rm "$TEMP_WALLPAPER"
