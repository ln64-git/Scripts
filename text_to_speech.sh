#!/bin/bash
if ! wl-paste >/dev/null 2>&1; then
    echo "Error: Unable to paste text from the clipboard."
    exit 1
fi
text=$(wl-paste)
if [ -z "$text" ]; then
    echo "Error: No text found in the clipboard."
    exit 1
fi
aspeak text "$text"