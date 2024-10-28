#!/usr/bin/env sh
app_class="$1"

# Check if the application is running
if pgrep -x "$app_class" > /dev/null; then
    echo "$app_class is running. Focusing the window."
    # Get the window ID and workspace for the given app_class
    window_info=$(hyprctl clients -j | jq -r --arg app_class "$app_class" \
                 '.[] | select(.class == $app_class) | {address: .address, workspace: .workspace["id"]}')
    
    if [ -n "$window_info" ]; then
        window_id=$(echo "$window_info" | jq -r '.address')
        workspace_id=$(echo "$window_info" | jq -r '.workspace')

        # Move to the workspace containing the application
        hyprctl dispatch workspace "$workspace_id"
        # Focus on the window
        hyprctl dispatch focuswindow "$window_id"
    else
        echo "Could not find window ID for $app_class."
    fi
else
    echo "$app_class is not running. Opening new instance."
    "$app_class" &
fi
