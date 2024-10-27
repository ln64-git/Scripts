# This is the script I use to change my wallpaper
# ~/.config/ags/scripts/color_generation/switchwall.sh /home/ln64/Pictures/wallpapers/Q3_2024/60hoyqmp2obd1.jpeg

# Directory containing wallpapers
WALLPAPER_DIR="/home/ln64/Pictures/Office + Fluent Design Collection (55 wallpapers) - WallpaperHub"

# Select a random wallpaper
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Change the wallpaper
~/.config/ags/scripts/color_generation/switchwall.sh "$RANDOM_WALLPAPER"