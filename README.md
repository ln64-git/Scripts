# elder-scripts-iv

This is a personal collection of scripts and relative files or programs primarily used for a productive workflow.

## Included Scripts:

### dictation.sh
- Utilizes Nerd Dictation for Speech-To-Text.
- Currently bound to: `$mainMod CTRL, SPACE`.

### mixer.sh
- Toggles display for PulseAudio Volume Control.
- Currently bound to: `,Pause`.

### open_website.sh
- Designed to work with Hyprland.
- Calls `hyprctl` to get information on the selected window, then parses response through `jq`.
- Before opening the link (args1), checks if Firefox is the active window. If so, opens link in current window.

### text_to_speech.sh
- Pulls text from Hyprland with `wl-clipboard` then feeds into `aspeak` and Microsoft's Speech Services.
- Currently bound to: `$mainMod, SPACE`.
