#!/usr/bin/env sh
new_window=false

# Check for the `-n` flag as the first parameter, indicating a new window should open
if [ "$1" = "-n" ]; then
    new_window=true
    shift  # Remove `-n` from arguments
fi

app_name="$1"  # The application name (e.g., firefox, code)
shift          # Remove the first argument so any additional options are captured
extra_args="$@"  # Remaining arguments (e.g., flags for the app)

# Define a temporary file to store the last focused window ID for cycling
tmp_file="/tmp/${app_name}_last_window_id"

# Set `app_class` to match the application name by default; override for specific applications
case "$app_name" in
    code)
        app_class="Code"  # Use the actual class name for VSCode as returned by hyprctl
        ;;
    *)
        app_class="$app_name"  # Default to the same name if no special mapping is needed
        ;;
esac

case "$app_name" in
    obs)
        app_class="com.obsproject.Studio"  # Use the actual OBS class name
        ;;
esac

# If `-n` is set, skip the window focusing and open a new instance
if [ "$new_window" = true ]; then
    echo "Opening a new instance of $app_class with arguments: $extra_args"
    "$app_name" $extra_args &
    exit 0
fi

# Retrieve all open windows of the specified class, sorted by last activation time
windows=$(hyprctl clients -j | jq -r --arg app_class "$app_class" \
           '[.[] | select(.class | test($app_class; "i"))] | sort_by(.at) | .[].address')

# Debugging: Display windows found
echo "Found windows for class $app_class: $windows"

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

    # Debugging: Display next window to focus
    echo "Next window to focus: $next_window_id"

    # Get the workspace ID for the next window
    workspace_id=$(hyprctl clients -j | jq -r --arg next_window_id "$next_window_id" \
                   '.[] | select(.address == $next_window_id) | .workspace["id"]')

    # Switch to the workspace and focus the selected window
    if [ -n "$workspace_id" ]; then
        echo "Switching to workspace: $workspace_id"
        hyprctl dispatch workspace "$workspace_id"
    else
        echo "No workspace ID found; skipping workspace switch."
    fi

    hyprctl dispatch focuswindow "$next_window_id"

    # Save the focused window ID to the temporary file
    echo "$next_window_id" > "$tmp_file"

else
    # If no instances are running, open a new instance with the provided arguments
    echo "$app_class is not running. Opening a new instance with arguments: $extra_args"
    "$app_name" $extra_args &
fi
