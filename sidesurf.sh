#!/usr/bin/env bash
set -euo pipefail

MAIN="${MAIN:-main.mp4}"
OVERLAY="${OVERLAY:-subway_surfer.mp4}"
MUSIC="${MUSIC:-trip_hop.mp3}"
OUT="${OUT:-surfers_main.mp4}"

START="${START:-00:00:00}"
MUSIC_START="${MUSIC_START:-}"

TARGET_H="${TARGET_H:-1080}"
GAP="${GAP:-0}"
MUSIC_VOL="${MUSIC_VOL:-0.1}"
FPS="${FPS:-24}"
CRF="${CRF:-18}"
PRESET="${PRESET:-veryfast}"

main_seek=()
overlay_seek=()
music_seek=()
if [[ -n "${START}" ]]; then
  main_seek+=(-ss "$START")
  overlay_seek+=(-ss "$START")
fi
if [[ -n "${MUSIC_START}" ]]; then
  music_start_val="$MUSIC_START"
else
  music_start_val="$START"
fi
if [[ -n "${music_start_val}" ]]; then
  music_seek+=(-ss "$music_start_val")
fi

if [[ "$GAP" -gt 0 ]]; then
  GAP_PART='[s]pad=iw+'"$GAP"':ih:0:0:color=black[sG];[sG][m]hstack=inputs=2[v];'
else
  GAP_PART='[s][m]hstack=inputs=2[v];'
fi

F='[0:v]fps='"$FPS"',setpts=PTS-STARTPTS,setsar=1,scale=w=-2:h='"$TARGET_H"':flags=lanczos[m];'\
'[1:v]fps='"$FPS"',setpts=PTS-STARTPTS,setsar=1,scale=w=-2:h='"$TARGET_H"':flags=lanczos[s];'\
"$GAP_PART"\
'[0:a]volume=1[a0];[2:a]volume='"$MUSIC_VOL"'[a1];[a0][a1]amix=inputs=2:duration=first:dropout_transition=3[a]'

set -x
ffmpeg -hide_banner -y \
  "${main_seek[@]}"    -i "$MAIN" \
  -stream_loop -1 "${overlay_seek[@]}" -i "$OVERLAY" \
  -stream_loop -1 "${music_seek[@]}"   -i "$MUSIC" \
  -filter_complex "$F" -map "[v]" -map "[a]" \
  -r "$FPS" -fps_mode cfr \
  -c:v libx264 -preset "$PRESET" -crf "$CRF" -pix_fmt yuv420p \
  -c:a aac -b:a 192k \
  -movflags +faststart+frag_keyframe+empty_moov \
  -max_muxing_queue_size 9999 \
  "$OUT"
set +x

echo "Done → $OUT"
