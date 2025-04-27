#!/usr/bin/env sh
url="$1"
browser="${2:-firefox}"  # Default to Firefox if no browser is specified

# Get the actual window class name
get_window_class() {
    hyprctl activewindow -j | jq -r .initialClass
}

# Map application names to their specific class names
case "$browser" in
    zen-browser)
        app_class="zen"  # Ensure this matches the actual class name
        browser_cmd="zen-browser"
        ;;
    firefox)
        app_class="firefox"
        browser_cmd="firefox"
        ;;
    google-chrome|chromium|brave)
        app_class="$browser"  # Most Chromium-based browsers use their binary name as the class
        browser_cmd="$browser"
        ;;
    *)
        app_class="$browser"
        browser_cmd="$browser"
        ;;
esac

# Get the active window's class
activeWindow="$(get_window_class)"

# Check if the active window matches the application's class
if [ "$activeWindow" = "$app_class" ]; then
    echo "$browser_cmd is the active window. Opening new tab: $url"
    case "$browser_cmd" in
        firefox|librewolf|zen-browser)
            "$browser_cmd" --new-tab "$url"
            ;;
        google-chrome|chromium|brave|zen-browser)
            "$browser_cmd" --new-tab "$url" 2>/dev/null || "$browser_cmd" "$url"
            ;;
        *)
            "$browser_cmd" "$url"
            ;;
    esac
else
    echo "$browser_cmd is not the active window. Opening new window: $url"
    "$browser_cmd" --new-window "$url" 2>/dev/null || "$browser_cmd" "$url"
fi
