#!/bin/bash
if pgrep -f "nerd-dictation begin" > /dev/null
then
    aspeak text "Dictation ended."
    nerd-dictation end
    echo "Nerd Dictation stopped."
else
    aspeak text "Dictation started."
    nerd-dictation begin
    echo "Nerd Dictation started."
fi
test 