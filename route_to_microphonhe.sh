#!/bin/bash

# Create the virtual microphone if it doesn't exist
if ! pw-link -l | grep -q "bitwig_to_mic"; then
    echo "Creating virtual microphone..."
    pw-loopback --capture-props='media.class=Audio/Source' --playback-props='node.name=bitwig_to_mic' &
    sleep 3  # Give PipeWire time to register the node
fi

# Ensure the virtual mic actually exists
if ! pw-link -l | grep -q "bitwig_to_mic"; then
    echo "Error: Virtual microphone did not initialize. Exiting."
    exit 1
fi

# Get correct node names
BITWIG_LEFT=$(pw-link -l | grep -o 'Bitwig Studio:out1')
BITWIG_RIGHT=$(pw-link -l | grep -o 'Bitwig Studio:out2')
VIRTUAL_MIC_LEFT="bitwig_to_mic:input_FL"
VIRTUAL_MIC_RIGHT="bitwig_to_mic:input_FR"

# Ensure Bitwig outputs exist before linking
if [ -z "$BITWIG_LEFT" ] || [ -z "$BITWIG_RIGHT" ]; then
    echo "Error: Bitwig output not found. Is Bitwig running?"
    exit 1
fi

# Link Bitwig’s outputs to the virtual mic
echo "Routing Bitwig to virtual microphone..."
pw-link "$BITWIG_LEFT" "$VIRTUAL_MIC_LEFT" || echo "Failed to link $BITWIG_LEFT -> $VIRTUAL_MIC_LEFT"
pw-link "$BITWIG_RIGHT" "$VIRTUAL_MIC_RIGHT" || echo "Failed to link $BITWIG_RIGHT -> $VIRTUAL_MIC_RIGHT"

# Set the virtual mic as the default input
pactl set-default-source bitwig_to_mic

echo "Routing complete. Bitwig is now the microphone input."
