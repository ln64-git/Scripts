#!/bin/bash

echo "🎛️ Setting up Virtual Audio Routing for Bitwig & Discord..."

# Function to check if a module is loaded
module_loaded() {
    pactl list short modules | grep -q "$1"
}

# Ensure Bitwig is running before proceeding
if ! pgrep -x "bitwig-studio" > /dev/null; then
    echo "❌ Bitwig Studio is not running! Please start Bitwig and re-run the script."
    exit 1
fi

echo "✅ Bitwig Studio is running!"

# Check if PipeWire is already running before restarting
if systemctl --user is-active --quiet pipewire; then
    echo "🔄 PipeWire is already running, skipping restart."
else
    echo "🔄 Restarting PipeWire..."
    systemctl --user restart pipewire pipewire-pulse
    sleep 3  # Wait for PipeWire to fully restart
fi

echo "🎛️ Setting up Virtual Devices..."

# Create Virtual Output if not exists
if ! module_loaded "sink_name=Virtual_Output"; then
    pactl load-module module-null-sink sink_name=Virtual_Output sink_properties=device.description="Virtual_Output"
fi

# Create Virtual Microphone if not exists
if ! module_loaded "sink_name=Virtual_Microphone"; then
    pactl load-module module-null-sink sink_name=Virtual_Microphone sink_properties=device.description="Virtual_Microphone"
fi

# Create Remapped Virtual Microphone if not exists
if ! module_loaded "source_name=Virtual_Mic"; then
    pactl load-module module-remap-source master=Virtual_Microphone.monitor source_name=Virtual_Mic description="Virtual Mic"
fi

# Remove old loopbacks to avoid duplicates
echo "🧹 Cleaning up previous loopbacks..."
pactl unload-module module-loopback 2>/dev/null

# Route Virtual_Output to Virtual_Microphone (for Discord)
pactl load-module module-loopback source=Virtual_Output.monitor sink=Virtual_Microphone

echo "🔍 Checking Available Devices..."
echo "Available Sinks (Outputs):"
pactl list short sinks

echo "Available Sources (Inputs):"
pactl list short sources

echo "🔍 Searching for Bitwig in PipeWire..."

# Search for Bitwig using PipeWire CLI
BITWIG_NODE=$(pw-cli list-objects Node | grep -i "Bitwig" -A 10 | grep "id" | awk '{print $2}' | head -n 1)

if [[ -z "$BITWIG_NODE" ]]; then
    echo "❌ Could not find Bitwig in PipeWire."
    exit 1
fi

echo "✅ Found Bitwig Node ID: $BITWIG_NODE"

# Detect Virtual Output dynamically
VIRTUAL_OUT=$(pactl list short sinks | grep "Virtual_Output" | awk '{print $2}' | head -n 1)

# Detect EVO4 dynamically
EVO4_OUT=$(pactl list short sinks | grep -i "alsa_output.usb-Audient_EVO4" | awk '{print $2}' | head -n 1)

if [[ -z "$EVO4_OUT" ]]; then
    echo "❌ EVO4 output not found! Check 'pactl list sinks' manually."
    exit 1
else
    echo "✅ Found EVO4: $EVO4_OUT"
fi

# Ensure Bitwig is connected to Virtual_Output
if [[ -n "$BITWIG_NODE" && -n "$VIRTUAL_OUT" ]]; then
    echo "✅ Connecting Bitwig ($BITWIG_NODE) → Virtual_Output ($VIRTUAL_OUT)"
    pw-link "$BITWIG_NODE" "$VIRTUAL_OUT"
else
    echo "❌ Failed to detect Bitwig or Virtual_Output."
fi

# Ensure Virtual Output audio is routed to EVO4
echo "🔄 Routing Virtual_Output to EVO4 ($EVO4_OUT)..."
LOOPBACK_ID=$(pactl load-module module-loopback source=Virtual_Output.monitor sink="$EVO4_OUT")

# Check if the loopback module was loaded correctly
if [[ -z "$LOOPBACK_ID" ]]; then
    echo "❌ Failed to create loopback from Virtual_Output to EVO4."
else
    echo "✅ Successfully routed Virtual_Output to EVO4 with module ID: $LOOPBACK_ID"
fi

echo "✅ Audio Setup Complete! Virtual Mic should now work in Discord, and Virtual Output will play through EVO4."
