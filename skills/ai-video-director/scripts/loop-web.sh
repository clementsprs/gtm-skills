#!/usr/bin/env bash
# Export a seamless website loop: crossfades the tail into the head, no audio.
# Usage: loop-web.sh in.mp4 name [width=1080] [xfade=0.5]
# Writes name.mp4 (x264), name.webm (VP9) and name-poster.jpg (frame 0).
set -euo pipefail
in="$1"; name="$2"; w="${3:-1080}"; xf="${4:-0.5}"
dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$in")
off=$(awk -v d="$dur" -v x="$xf" 'BEGIN{printf "%.3f", d-2*x}')
# body = [x, end], head = [0, x] faded in over the end of body: last frame lands on frame x of the original
filter="[0:v]split[a][b];[a]trim=start=${xf},setpts=PTS-STARTPTS[body];[b]trim=0:${xf},setpts=PTS-STARTPTS[head];[body][head]xfade=transition=fade:duration=${xf}:offset=${off},scale=${w}:-2,format=yuv420p[v]"
ffmpeg -v error -y -i "$in" -filter_complex "$filter" -map "[v]" -an -c:v libx264 -crf 23 -preset slow -movflags +faststart "${name}.mp4"
ffmpeg -v error -y -i "${name}.mp4" -an -c:v libvpx-vp9 -crf 36 -b:v 0 -row-mt 1 "${name}.webm"
ffmpeg -v error -y -i "${name}.mp4" -frames:v 1 -q:v 3 "${name}-poster.jpg"
ls -lh "${name}.mp4" "${name}.webm" "${name}-poster.jpg"
