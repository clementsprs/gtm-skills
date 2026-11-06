#!/usr/bin/env bash
# Contact sheet of a take for review.
# Usage: contact-sheet.sh in.mp4 [fps=1] [grid=5x2]
# Writes <in>.sheet.png (one sheet; if the take is longer than the grid, frames are sampled evenly).
set -euo pipefail
in="$1"; fps="${2:-1}"; grid="${3:-5x2}"
out="${in%.*}.sheet.png"
cols="${grid%x*}"; rows="${grid#*x}"; n=$((cols * rows))
dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$in")
total=$(awk -v d="$dur" -v f="$fps" 'BEGIN{printf "%d", d*f}')
if [ "$total" -gt "$n" ]; then
  fps=$(awk -v n="$n" -v d="$dur" 'BEGIN{printf "%.4f", n/d}')
fi
ffmpeg -v error -y -i "$in" -vf "fps=${fps},scale=360:-1,drawtext=text='%{pts\:hms}':x=8:y=8:fontcolor=white:box=1:boxcolor=black@0.5,tile=${grid}" -frames:v 1 "$out" 2>/dev/null \
  || ffmpeg -v error -y -i "$in" -vf "fps=${fps},scale=360:-1,tile=${grid}" -frames:v 1 "$out"
echo "$out"
