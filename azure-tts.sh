#!/bin/bash

# Azure Credentials
AZURE_KEY="b16408ad75964fc69037d035ac0e4db0"
AZURE_REGION="eastus"  # change as needed

# Voice config (you can list all available later)
VOICE="en-US-AriaNeural"

# Text to synthesize
TEXT="$1"

# Azure request
curl -s -X POST "https://${AZURE_REGION}.tts.speech.microsoft.com/cognitiveservices/v1" \
  -H "Ocp-Apim-Subscription-Key: $AZURE_KEY" \
  -H "Content-Type: application/ssml+xml" \
  -H "X-Microsoft-OutputFormat: audio-16khz-32kbitrate-mono-mp3" \
  -d "<speak version='1.0' xml:lang='en-US'><voice name='${VOICE}'>${TEXT}</voice></speak>" \
  --output output.mp3

# Play audio
ffplay -nodisp -autoexit output.mp3
