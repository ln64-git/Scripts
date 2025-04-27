#!/bin/bash
while true; do
    if pgrep -x "BitwigStudio" > /dev/null; then
        echo "Bitwig detected, routing audio..."
        pactl load-module module-loopback source=Virtual_Out.monitor sink=alsa_output.usb-Audient_EVO4-00.analog-surround-40
        pactl load-module module-loopback source=Virtual_Out.monitor sink=Virtual_Mic_Input
    else
        echo "Bitwig not detected, cleaning up..."
        pactl unload-module module-loopback
    fi
    sleep 5  # Check every 5 seconds
done
