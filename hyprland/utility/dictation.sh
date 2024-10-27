#!/bin/bash
if pgrep -f "nerd-dictation begin" > /dev/null
then
    ~/Documents/Scripts/voxctl -input "Dictation ended." -quit
    nerd-dictation end
    echo "Nerd Dictation stopped."
else
    ~/Documents/Scripts/voxctl -input "Dictation started." -quit
    nerd-dictation begin
    echo "Nerd Dictation started."
fi
test 