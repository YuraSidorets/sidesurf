#!/usr/bin/env bash
set -euo pipefail

FPS=24
TargetH=1080
MusicVol=0.05

MAIN="main.mp4"
OVERLAY="subway_surfer.mp4"
MUSIC="trip_hop.mp3"
OUT="surfers_main.mp4"

F='[0:v]fps='"$FPS"',setpts=PTS-STARTPTS,setsar=1,scale=w=-2:h='"$TargetH"'[m];'\
'[1:v]fps='"$FPS"',setpts=PTS-STARTPTS,setsar=1,scale=w=-2:h='"$TargetH"'[s];'\
'[s][m]hstack=inputs=2[v];'\
'[0:a]volume=1[a0];'\
'[2:a]volume='"$MusicVol"'[a1];'\
'[a0][a1]amix=inputs=2:duration=first:dropout_transition=3[a]'

set -x
ffmpeg -hide_banner -y \
  -i "$MAIN" \
  -stream_loop -1 -i "$OVERLAY" \
  -stream_loop -1 -i "$MUSIC" \
  -filter_complex "$F" -map "[v]" -map "[a]" \
  -r "$FPS" -fps_mode cfr -shortest \
  -c:v libx264 -preset veryfast -crf 18 -pix_fmt yuv420p \
  -c:a aac -b:a 192k \
  -movflags +faststart+frag_keyframe+empty_moov \
  -max_muxing_queue_size 9999 \
  "$OUT"
set +x

echo "Done → $OUT"
