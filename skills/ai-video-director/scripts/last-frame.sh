#!/usr/bin/env bash
# Extract the last frame of a take as a PNG, to use as the start frame of the next take.
# Usage: last-frame.sh in.mp4 [out.png]
set -euo pipefail
in="$1"; out="${2:-${in%.*}.last.png}"
ffmpeg -v error -y -sseof -0.1 -i "$in" -update 1 -frames:v 1 "$out"
echo "$out"
