#! /usr/bin/env sh
url="$1"
browser="${2:-firefox}"  # Default to firefox if no browser is specified

# Map application names to their specific class names
case "$browser" in
    zen-browser)
        app_class="zen-beta"  # Map zen-browser to zen-beta
        ;;
    firefox)
        app_class="firefox"  # Map firefox to its class
        ;;
    *)
        app_class="$browser"  # Default to the same name if no special mapping is needed
        ;;
esac

# Get the active window's class
activeWindow="$(hyprctl activewindow -j | jq -r .initialClass)"

# Check if the active window matches the application's class
if [ "$activeWindow" = "$app_class" ]; then
    echo "$browser is the active window. Opening new tab: $url"
    "$browser" --new-tab "$url"
else
    echo "$browser is not the active window. Opening new window: $url"
    "$browser" --new-window "$url"
fi
