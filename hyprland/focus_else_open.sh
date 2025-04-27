#!/usr/bin/env sh

new_window=false

# Check for the `-n` flag
if [ "$1" = "-n" ]; then
    new_window=true
    shift
fi

app_name="$1"
shift
extra_args="$@"

# Temporary file to track last focused window
tmp_file="/tmp/${app_name}_last_window_id"

# Map application names to Hyprland class names
case "$app_name" in
    code)
        app_class="Code"
        ;;
    zen-browser)
        app_class="zen"
        ;;
    bitwig-studio)
        app_class="com.bitwig.BitwigStudi"
        ;;
    obs)
        app_class="com.obsproject.Studio"
        ;;
    *)
        app_class="$app_name"
        ;;
esac

# If `-n` is set, open new instance
if [ "$new_window" = true ]; then
    echo "Opening a new instance of $app_class with arguments: $extra_args"
    "$app_name" $extra_args &
    exit 0
fi

# Get current workspace ID
current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

# Calculate workspace range
if [ "$current_workspace" -ge 31 ] && [ "$current_workspace" -le 39 ]; then
    workspace_min=31
    workspace_max=39
else
    workspace_min=$(( ( (current_workspace - 1) / 10 ) * 10 + 1 ))
    workspace_max=$(( workspace_min + 9 ))
fi

echo "Current workspace: $current_workspace (Range: $workspace_min-$workspace_max)"

# Retrieve windows matching app class within workspace range
windows=$(hyprctl clients -j | jq -r --arg app_class "$app_class" --argjson ws_min "$workspace_min" --argjson ws_max "$workspace_max" '
  [.[] | select(
    (.class | test($app_class; "i")) and
    (.workspace.id >= $ws_min and .workspace.id <= $ws_max)
  )] | sort_by(.at) | .[].address
')

# Debugging output
echo "Found windows for class $app_class in workspace range: $windows"

if [ -n "$windows" ]; then
    echo "$app_class is running. Cycling through open windows."

    last_window_id=$(cat "$tmp_file" 2>/dev/null || echo "")

    next_window_id=""
    found_last=false
    for window_id in $windows; do
        if [ "$found_last" = true ]; then
            next_window_id="$window_id"
            break
        fi
        [ "$window_id" = "$last_window_id" ] && found_last=true
    done

    if [ -z "$next_window_id" ]; then
        next_window_id=$(echo "$windows" | head -n 1)
    fi

    echo "Next window to focus: $next_window_id"

    workspace_id=$(hyprctl clients -j | jq -r --arg next_window_id "$next_window_id" '
      .[] | select(.address == $next_window_id) | .workspace.id')

    if [ -n "$workspace_id" ]; then
        echo "Switching to workspace: $workspace_id"
        hyprctl dispatch workspace "$workspace_id"
    else
        echo "No workspace ID found; skipping workspace switch."
    fi

    hyprctl dispatch focuswindow "$next_window_id"

    echo "$next_window_id" > "$tmp_file"

else
    echo "$app_class is not running. Opening a new instance with arguments: $extra_args"
    "$app_name" $extra_args &
fi