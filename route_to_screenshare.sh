#!/bin/bash

# Check if the virtual microphone already exists
if ! pw-link -l | grep -q "bitwig_to_mic"; then
    echo "Creating virtual microphone..."
    pw-loopback --capture-props='media.class=Audio/Source' --playback-props='node.name=bitwig_to_mic' &
    sleep 2  # Wait for PipeWire to register the node
fi

# Get correct node names
BITWIG_LEFT="Bitwig Studio:out1"
BITWIG_RIGHT="Bitwig Studio:out2"
VIRTUAL_MIC="bitwig_to_mic:input_FL"

# Ensure Bitwig's outputs exist before linking
if ! pw-link -l | grep -q "$BITWIG_LEFT"; then
    echo "Error: Bitwig output not found. Is Bitwig running?"
    exit 1
fi

# Link Bitwig’s outputs to the virtual mic
echo "Routing Bitwig to virtual microphone..."
pw-link "$BITWIG_LEFT" "$VIRTUAL_MIC"
pw-link "$BITWIG_RIGHT" "$VIRTUAL_MIC"

# Set the virtual mic as default input
pactl set-default-source bitwig_to_mic
echo "Routing complete. Bitwig is now the microphone input."
