#!/bin/bash
# Check if 'wl-paste' command is available
if ! command -v wl-paste &>/dev/null; then
    echo "Error: 'wl-paste' command is not installed or not in your PATH."
    exit 1
fi

# Get text from clipboard using 'wl-paste'
text=$(wl-paste)

# Check if there's no text in the clipboard
if [ -z "$text" ]; then
    echo "Error: No text found in the clipboard."
    exit 1
fi

aspeak text "$text"