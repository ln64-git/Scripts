#!/usr/bin/env bash

# Directories for configurations
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/ags"
CACHE_DIR="$XDG_CACHE_HOME/ags"
STATE_DIR="$XDG_STATE_HOME/ags"
screenshot_path="/tmp/desktop_screenshot.png"

# Dependencies Check
for cmd in grim "$CONFIG_DIR/scripts/color_generation/colorgen.sh"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it to continue."
        exit 1
    fi
done

# Capture a screenshot of the desktop
echo "Capturing a screenshot of the desktop..."
if grim "$screenshot_path"; then
    echo "Screenshot saved to $screenshot_path."
else
    echo "Error: Failed to capture a screenshot."
    exit 1
fi

# Derive and apply the color palette from the screenshot
echo "Deriving and applying color palette from screenshot..."
if "$CONFIG_DIR/scripts/color_generation/colorgen.sh" "$screenshot_path" --apply >/dev/null 2>&1; then
    echo "Colors applied successfully."
else
    echo "Error: Failed to apply colors. Check the colorgen script for issues."
    rm -f "$screenshot_path"
    exit 1
fi

# Clean up the screenshot
rm -f "$screenshot_path"
echo "Desktop color palette applied successfully."
