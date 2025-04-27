#!/bin/bash

AZURE_KEY="YOUR_AZURE_KEY"
AZURE_REGION="eastus"
VOICE="en-US-AriaNeural"
TMPFILE="/tmp/azure_tts_output.mp3"

log() {
  echo "INFO $1" >&2
}

log "Azure TTS module started"

while read -r line; do
  case "$line" in
    "BEGIN")
      log "BEGIN received"
      TEXT=""
      ;;
    "END")
      log "END received"
      # Send to Azure
      curl -s -X POST "https://${AZURE_REGION}.tts.speech.microsoft.com/cognitiveservices/v1" \
        -H "Ocp-Apim-Subscription-Key: $AZURE_KEY" \
        -H "Content-Type: application/ssml+xml" \
        -H "X-Microsoft-OutputFormat: audio-16khz-32kbitrate-mono-mp3" \
        -d "<speak version='1.0' xml:lang='en-US'><voice name='${VOICE}'>${TEXT}</voice></speak>" \
        --output "$TMPFILE"

      # Play the file (you can use mpv, ffplay, aplay, etc.)
      ffplay -nodisp -autoexit "$TMPFILE" >/dev/null 2>&1

      echo "OK"
      ;;
    *)
      TEXT+="$line "
      ;;
  esac
done
