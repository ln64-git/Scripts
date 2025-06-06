#!/usr/bin/env bash

# ~/Scripts/update-if-idle.sh

# Get idle time in seconds
idle_time=$(xprintidle)
idle_minutes=$(( idle_time / 1000 / 60 ))

# Proceed if idle for more than 120 minutes (2 hours)
if [[ $idle_minutes -ge 120 ]]; then
  echo "Idle for $idle_minutes minutes. Starting update..."
  sudo pacman -Syu --noconfirm
else
  echo "User not idle long enough ($idle_minutes min). Skipping update."
fi
