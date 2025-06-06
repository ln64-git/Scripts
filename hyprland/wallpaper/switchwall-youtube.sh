#!/usr/bin/env bash
set -euo pipefail

################################################################################
# switchwall‐youtube.sh (fast start, < 5 s to wallpaper)
#
# 1) Pick “closest to 2560×1440” format via yt‐dlp -F.
# 2) Immediately start mpvpaper on the HLS stream URL at 00:01:30.
# 3) In the background: ffmpeg -ss 90 -i "$STREAM_URL" -frames:v 1 → /tmp/…png.
# 4) Once the PNG exists, run colorgen.sh on it.
################################################################################

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="$XDG_CONFIG_HOME/ags/scripts/color_generation"
SCREENSHOT_PATH="/tmp/video_wallpaper_frame.png"

# ─── (0) Check prerequisites ───────────────────────────────────────────────────
for cmd in mpvpaper yt-dlp ffmpeg wl-paste; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' not found. Install with: sudo pacman -S $cmd" >&2
    exit 1
  fi
done

# ─── (1) Read YouTube URL from clipboard ────────────────────────────────────────
YOUTUBE_URL=$(wl-paste --no-newline 2>/dev/null || true)
if [[ -z "$YOUTUBE_URL" || ! "$YOUTUBE_URL" =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/ ]]; then
  echo "Error: Clipboard does not contain a valid YouTube URL." >&2
  exit 1
fi
echo "YouTube URL: $YOUTUBE_URL"

# ─── (2) List all formats and pick the one closest to 2560×1440 ─────────────────
ALL_FORMATS=$(yt-dlp -F "$YOUTUBE_URL" 2>&1)

BEST_CODE=""
BEST_WIDTH=0
BEST_HEIGHT=0
BEST_DIST=999999

TARGET_W=2560
TARGET_H=1440

while read -r LINE; do
  [[ "$LINE" =~ audio\ only ]] && continue

  # (a) explicit “WIDTHxHEIGHT”
  if [[ "$LINE" =~ ^[[:space:]]*([0-9]+)[[:space:]]+.*([0-9]{2,4}x[0-9]{2,4}).* ]]; then
    CODE="${BASH_REMATCH[1]}"
    RES="${BASH_REMATCH[2]}"
    W="${RES%x*}"
    H="${RES#*x}"

  # (b) else match “<number>p” and infer 16:9
  elif [[ "$LINE" =~ ^[[:space:]]*([0-9]+)[[:space:]]+.*[[:space:]]([0-9]{3,4})p[[:space:]] ]]; then
    CODE="${BASH_REMATCH[1]}"
    H="${BASH_REMATCH[2]}"
    W=$(( (H * 16 + 8) / 9 ))
  else
    continue
  fi

  # distance = |W−2560| + |H−1440|
  DX=$(( W>TARGET_W ? W-TARGET_W : TARGET_W-W ))
  DY=$(( H>TARGET_H ? H-TARGET_H : TARGET_H-H ))
  D=$(( DX + DY ))

  if (( D < BEST_DIST )); then
    BEST_DIST=$D
    BEST_WIDTH=$W
    BEST_HEIGHT=$H
    BEST_CODE=$CODE
  fi
done < <(printf '%s\n' "$ALL_FORMATS")

if [[ -z "$BEST_CODE" ]]; then
  echo "Error: Could not find any video‐only format." >&2
  exit 1
fi

echo "→ Chosen format code $BEST_CODE at ${BEST_WIDTH}×${BEST_HEIGHT} (Δ=${BEST_DIST})"

# ─── (3) Get the direct stream URL ──────────────────────────────────────────────
STREAM_URL=$(yt-dlp -g -f "$BEST_CODE" "$YOUTUBE_URL" 2>/dev/null)
if [[ -z "$STREAM_URL" ]]; then
  echo "Error: Failed to get stream URL for format $BEST_CODE." >&2
  exit 1
fi
echo "Stream URL → $STREAM_URL"

# ─── (4) Kill any existing mpvpaper for this URL ────────────────────────────────
pkill -f "mpvpaper .*${YOUTUBE_URL}" &>/dev/null || true

# ─── (5) Start mpvpaper immediately (looped at 00:01:30, no audio, hwdec) ──────
echo "Starting mpvpaper at 00:01:30 (hwdec=auto, loop, no audio)…"
mpvpaper '*' "$STREAM_URL" -- \
  --no-audio \
  --hwdec=auto \
  --start=90 \
  --loop=inf \
  &>/dev/null &
echo "mpvpaper launched."

# ─── (6) In background: grab one frame at 00:01:30 via ffmpeg ──────────────────
(
  echo "🔹 [bg] Capturing frame at 00:01:30…"

  # Remove any old screenshot
  rm -f "$SCREENSHOT_PATH"

  # Because -ss is *before* -i, ffmpeg will jump straight to ~90s on HLS.
  ffmpeg -hide_banner -loglevel error \
    -ss 90 \
    -i "$STREAM_URL" \
    -vf "scale=2560:1440:force_original_aspect_ratio=decrease,format=yuv420p" \
    -frames:v 1 \
    -q:v 2 \
    "$SCREENSHOT_PATH"

  if [[ -f "$SCREENSHOT_PATH" ]]; then
    echo "🔹 [bg] Screenshot saved → $SCREENSHOT_PATH"
    echo "🔹 [bg] Running colorgen.sh…"
    if "$CONFIG_DIR/colorgen.sh" "$SCREENSHOT_PATH" --apply --smart; then
      echo "🔹 [bg] colorgen.sh succeeded."
    else
      echo "🔹 [bg] colorgen.sh failed, re-running for debug:" >&2
      echo "────────────────────────────────────────────────"
      "$CONFIG_DIR/colorgen.sh" "$SCREENSHOT_PATH" --apply --smart
      echo "────────────────────────────────────────────────"
    fi
    rm -f "$SCREENSHOT_PATH"
  else
    echo "🔹 [bg] Error: could not write screenshot." >&2
  fi
) &

# ─── (7) Return immediately ────────────────────────────────────────────────────
echo "Wallpaper up! colorgen will run once frame is ready."
exit 0
