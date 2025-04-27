#!/bin/bash

echo "🎛️ Setting up Virtual Audio Devices..."

# Function to check if a module is loaded
module_loaded() {
    pactl list short modules | grep -q "$1"
}

# Ensure PipeWire is running
if ! systemctl --user is-active --quiet pipewire; then
    echo "🔄 Starting PipeWire..."
    systemctl --user restart pipewire pipewire-pulse
    sleep 3  # Wait for PipeWire to fully restart
fi

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

echo "✅ Virtual Audio Devices Set Up!"
echo "🎛️ Watching for Bitwig Audio Outputs..."

# Keep checking for Bitwig’s audio output until it appears
while true; do
    if ! ps aux | grep -i "bitwig" | grep -v "grep" > /dev/null; then
        echo "❌ Bitwig is not running. Waiting..."
    else
        echo "✅ Bitwig is running. Checking for audio outputs..."

        # Check if Bitwig's output exists in PipeWire
        BITWIG_NODE=$(pw-cli list-objects Node | grep -i "Bitwig" -A 10 | grep "id" | awk '{print $2}' | head -n 1)

        if [[ -n "$BITWIG_NODE" ]]; then
            echo "✅ Detected Bitwig Audio Output (Node ID: $BITWIG_NODE)"
            echo "🔄 Connecting Bitwig to Virtual_Output and Speakers..."

            # Detect Virtual Output & Speakers
            VIRTUAL_OUT=$(pactl list short sinks | grep "Virtual_Output" | awk '{print $2}' | head -n 1)
            SPEAKER_OUT=$(pactl list short sinks | grep "alsa_output" | awk '{print $2}' | head -n 1)

            if [[ -n "$BITWIG_NODE" && -n "$VIRTUAL_OUT" ]]; then
                echo "✅ Connecting Bitwig ($BITWIG_NODE) → Virtual_Output ($VIRTUAL_OUT)"
                pw-link "$BITWIG_NODE" "$VIRTUAL_OUT"
            else
                echo "❌ Failed to detect Bitwig or Virtual_Output."
            fi

            if [[ -n "$BITWIG_NODE" && -n "$SPEAKER_OUT" ]]; then
                echo "✅ Connecting Bitwig ($BITWIG_NODE) → Speakers ($SPEAKER_OUT)"
                pw-link "$BITWIG_NODE" "$SPEAKER_OUT"
            else
                echo "❌ Failed to detect Bitwig or Speaker."
            fi

            echo "✅ Audio Setup Complete! Virtual Mic should now work in Discord."
            exit 0  # Exit script once setup is done
        else
            echo "⏳ Bitwig audio not yet available, waiting..."
        fi
    fi

    sleep 5  # Check every 5 seconds
done
