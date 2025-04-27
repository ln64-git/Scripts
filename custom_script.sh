#!/bin/bash

# Get the PID(s) of any running Obsidian instance
pids=$(ps aux | grep '[o]bsidian' | awk '{print $2}')

if [ -n "$pids" ]; then
    echo "Killing Obsidian (PIDs: $pids)"
    kill $pids
    sleep 1
else
    echo "Obsidian not running."
fi

# Start it again
obsidian &
