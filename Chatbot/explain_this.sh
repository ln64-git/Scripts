#!/bin/bash
aspeak text "Please wait as I compose an explanation..."
custom_prompt="Breifly explain this..."
ollama_model="llama2-uncensored"
get_clipboard_text() {
    if ! wl-paste >/dev/null 2>&1; then
        echo "Error: Unable to paste text from the clipboard." >&2
        exit 1
    fi
    wl-paste
}
process_text() {
    local text="$1"
    text=$(echo "$text" | tr -d '"\\') # Remove unwanted characters
    text=$(echo "$text" | tr -d '\n\r' | tr -s ' ')  # Replace newlines with spaces
    text=$(echo "$text" | awk -v RS='[.!?]' '{gsub(/[ \t]+/, " "); print $0}')  # Use awk to split the text into sentences based on periods
    echo "$text"
}
speak() {
    local text="$1"
    echo "Text to speak: $text"  # Output the text before speaking
    aspeak text "$text"
}
final_prompt="$custom_prompt $(get_clipboard_text)"
ollama_response=$(curl -s -X POST http://localhost:11434/api/generate -d "{\"model\": \"$ollama_model\", \"prompt\": \"$final_prompt\"}")
response_stream=$(echo "$ollama_response" | jq -r '.response')  # Extract response text using jq
processed_text=$(process_text "$response_stream")
speak "$processed_text"
