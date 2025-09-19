#!/usr/bin/env bash
set -euo pipefail

F='[0:v]fps=fps=24,setpts=PTS-STARTPTS,trim=duration=3868.277,setpts=PTS-STARTPTS[base];[1:v][base]scale2ref=w=-2:h=ih[ov0][base2];[ov0]scale=ceil(iw*0.315/2)*2:ceil(ih*0.315/2)*2,fps=fps=24,setpts=PTS-STARTPTS,trim=duration=3868.277,setpts=PTS-STARTPTS[ov];[base2][ov]overlay=x=main_w-overlay_w-5:y=(main_h-overlay_h)-100:format=auto[v];[0:a]volume=1[a0];[2:a]volume=0.05[a1];[a0][a1]amix=inputs=2:duration=first:dropout_transition=3[a]'

ffmpeg -hide_banner -y \
  -t 3868.277 -i "main.mp4" \
  -stream_loop -1 -t 3868.277 -i "subway_surfer.mp4" \
  -stream_loop -1 -t 3868.277 -i "trip_hop.mp3" \
  -filter_complex "$F" \
  -map "[v]" -map "[a]" \
  -c:v libx264 -preset veryfast -crf 18 -pix_fmt yuv420p \
  -c:a aac -b:a 192k \
  -movflags +faststart+frag_keyframe+empty_moov \
  -fps_mode cfr -max_muxing_queue_size 9999 \
  "final_cut.mp4"
