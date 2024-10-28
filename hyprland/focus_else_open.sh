#!/usr/bin/env sh
app_name="$1"  # First argument is the application name (e.g., firefox, vesktop, code)
shift          # Shift to remove the first argument, so we can capture any additional options
extra_args="$@"  # Additional arguments (e.g., flags for the app)

# Define a temporary file to store the last focused window ID for cycling
tmp_file="/tmp/${app_name}_last_window_id"

# Set `app_class` to match the application name by default; override for specific applications
case "$app_name" in
    code)
        app_class="code-url-handler"  # Use the actual class name for VSCode
        ;;
    *)
        app_class="$app_name"  # Default to the same name if no special mapping is needed
        ;;
esac

# Retrieve all open windows of the specified class, sorted by last activation time
windows=$(hyprctl clients -j | jq -r --arg app_class "$app_class" \
           '[.[] | select(.class == $app_class)] | sort_by(.at) | .[].address')

# Check if there are any open windows of the app
if [ -n "$windows" ]; then
    echo "$app_class is running. Cycling through open windows."

    # Load the last focused window ID from the temporary file
    last_window_id=$(cat "$tmp_file" 2>/dev/null || echo "")

    # Cycle to the next window in the list after the last focused one
    next_window_id=""
    found_last=false
    for window_id in $windows; do
        if [ "$found_last" = true ]; then
            next_window_id="$window_id"
            break
        fi
        [ "$window_id" = "$last_window_id" ] && found_last=true
    done

    # If no next window is found, cycle back to the first window
    if [ -z "$next_window_id" ]; then
        next_window_id=$(echo "$windows" | head -n 1)
    fi

    # Get the workspace ID for the next window
    workspace_id=$(hyprctl clients -j | jq -r --arg next_window_id "$next_window_id" \
                   '.[] | select(.address == $next_window_id) | .workspace["id"]')

    # Switch to the workspace and focus the selected window
    if [ -n "$workspace_id" ]; then
        hyprctl dispatch workspace "$workspace_id"
    fi
    hyprctl dispatch focuswindow "$next_window_id"

    # Save the focused window ID to the temporary file
    echo "$next_window_id" > "$tmp_file"

else
    # If no instances are running, open a new instance with the provided arguments
    echo "$app_class is not running. Opening a new instance with arguments: $extra_args"
    "$app_name" $extra_args &
fi
