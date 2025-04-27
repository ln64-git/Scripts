#!/bin/bash
while true; do
    if pgrep -x "BitwigStudio" > /dev/null; then
        pw-link "Bitwig Studio:out1" "alsa_input.usb-Audient_EVO4-00.analog-surround-40:capture_FR"
        pw-link "Bitwig Studio:out2" "alsa_input.usb-Audient_EVO4-00.analog-surround-40:capture_FR"
    fi
    sleep 5
done
