#!/usr/bin/env bash

################################################################################
# youtube-video-wallpaper.sh
#
# 1) Grabs a direct “bestvideo[height<=1440][fps<=60][vcodec=h264]” URL via yt-dlp.
# 2) Starts mpvpaper at 1m30s using that URL (mpv does its own buffering & decoding).
# 3) Uses FFmpeg on the same URL to grab one frame at 1m30s for color‐generation.
# 4) Feeds that JPEG into your colorgen.sh, showing any output/errors.
################################################################################

# (A) Config / paths
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="$XDG_CONFIG_HOME/ags"
screenshot_path="/tmp/video_wallpaper_screenshot.jpg"

# (B) Check prerequisites
for cmd in mpvpaper yt-dlp ffmpeg wl-paste; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it:"
        echo "    → sudo pacman -S ${cmd}   # (or your distro’s package manager)"
        exit 1
    fi
done

# (C) Pull YouTube URL from clipboard
youtube_url=$(wl-paste --no-newline 2>/dev/null)
echo "YouTube URL: $youtube_url"
if [[ -z "$youtube_url" || ! "$youtube_url" =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/ ]]; then
    echo "Error: Clipboard does not contain a valid YouTube URL."
    exit 1
fi

# (D) Fetch a direct H.264 stream link at ≤1440p/60fps
echo "Trying to fetch an H.264 stream URL (≤1440p, ≤60 fps)…"
stream_url=$(
  yt-dlp -g --format "bestvideo[height<=1440][fps<=60][vcodec=h264]" \
    "$youtube_url" 2>/dev/null
)

if [[ -z "$stream_url" ]]; then
  echo "…no H.264 track found. Falling back to bestvideo (any codec) at ≤1440p/60fps."
  stream_url=$(
    yt-dlp -g --format "bestvideo[height<=1440][fps<=60]" \
      "$youtube_url" 2>/dev/null
  )
  if [[ -z "$stream_url" ]]; then
    echo "Error: Could not extract any suitable video stream via yt-dlp."
    exit 1
  fi
fi

echo "Stream URL obtained →"
echo "    $stream_url"

# (E) Kill any existing mpvpaper tied to this URL
pkill -f "mpvpaper .*${youtube_url}" >/dev/null 2>&1 || true
echo "Stopped any existing mpvpaper instances for this URL."

# (F) Start mpvpaper at 1m30s (mpv handles buffering/decoding).
#     Redirect all mpvpaper output to /dev/null so you don’t see “undefined”.
echo "Starting mpvpaper at 00:01:30 (looping, no audio)…"
mpvpaper '*' "$stream_url" -- --no-audio --start=90 --loop \
  >/dev/null 2>&1 &
mpvpid=$!
echo "mpvpaper launched (PID $mpvpid)."

# (G) Meanwhile, grab a single frame at 1m30s for color‐generation
echo "Capturing a frame at 00:01:30 for color generation…"
ffmpeg -hide_banner -loglevel error \
       -ss 90 \
       -i "$stream_url" \
       -vf "scale=2560:1440,format=yuv420p" \
       -frames:v 1 \
       -q:v 2 \
       "$screenshot_path"
ffmpeg_exit=$?

if [[ $ffmpeg_exit -ne 0 ]]; then
    echo "Error: FFmpeg exited with code $ffmpeg_exit. Could not grab screenshot."
    exit 1
fi

if [[ ! -f "$screenshot_path" ]]; then
    echo "Error: FFmpeg claimed success but $screenshot_path does not exist."
    exit 1
fi

echo "Screenshot saved → $screenshot_path"
echo "File info: $(file --brief "$screenshot_path")"

# (H) Feed that screenshot into colorgen.sh (showing any output/errors)
echo "Applying colors from screenshot…"
"$CONFIG_DIR/scripts/color_generation/colorgen.sh" "$screenshot_path" --apply
colorgen_exit=$?

if [[ $colorgen_exit -eq 0 ]]; then
    echo "✅ colorgen.sh finished successfully."
else
    echo "❌ colorgen.sh failed (exit code $colorgen_exit)."
    echo "— Here is any output it produced:"
    echo "--------------------------------------------------"
    "$CONFIG_DIR/scripts/color_generation/colorgen.sh" "$screenshot_path" --apply
    echo "--------------------------------------------------"
    exit 1
fi

# (I) Clean up
rm -f "$screenshot_path"
echo "Wallpaper + color‐generation complete."
