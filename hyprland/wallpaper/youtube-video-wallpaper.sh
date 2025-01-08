#!/usr/bin/env bash

# Directories for configurations
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/ags"
CACHE_DIR="$XDG_CACHE_HOME/ags"
STATE_DIR="$XDG_STATE_HOME/ags"
screenshot_path="/tmp/video_wallpaper_screenshot.jpg"

# Dependencies Check
for cmd in mpvpaper yt-dlp ffmpeg wl-paste; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it to continue."
        exit 1
    fi
done

# Get YouTube URL from clipboard
youtube_url=$(wl-paste --no-newline 2>/dev/null)

# Debug output to confirm URL
echo "YouTube URL: $youtube_url"

# Validate YouTube URL
if [[ -z "$youtube_url" || ! "$youtube_url" =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/ ]]; then
    echo "Error: Clipboard does not contain a valid YouTube URL."
    exit 1
fi

# Stop any existing mpvpaper instances
pkill -f mpvpaper >/dev/null 2>&1 || echo "No existing mpvpaper instances running."

# Start video wallpaper at 30 seconds
echo "Starting video wallpaper at 30 seconds..."
yt-dlp --quiet --no-warnings --output - --format "bestvideo[height<=2160]" "$youtube_url" | \
    mpvpaper '*' - --start=30 &

# Extract a screenshot for color generation
echo "Capturing a frame for color generation..."
yt-dlp --quiet --no-warnings --output - --format "bestvideo[height<=2160]" "$youtube_url" | \
    ffmpeg -hide_banner -loglevel error -y -i pipe:0 -ss 00:00:30 -frames:v 1 -q:v 2 "$screenshot_path"

# Check if the screenshot was saved
if [ -f "$screenshot_path" ]; then
    echo "Screenshot saved to $screenshot_path."

    # Apply colors using the generated screenshot
    echo "Applying colors from screenshot..."
    if "$CONFIG_DIR/scripts/color_generation/colorgen.sh" "$screenshot_path" --apply >/dev/null 2>&1; then
        echo "Colors applied successfully."
    else
        echo "Error: Failed to apply colors. Check the colorgen script for issues."
    fi

    # Clean up the screenshot
    rm -f "$screenshot_path"
else
    echo "Error: Failed to save the screenshot for color generation."
    exit 1
fi

echo "Wallpaper setup complete."
