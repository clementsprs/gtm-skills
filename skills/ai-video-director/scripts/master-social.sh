#!/usr/bin/env bash
# Master a video for social / ads: yuv420p, bt709 tags, -14 LUFS, faststart.
# Usage: master-social.sh in.mp4 out.mp4 [lufs=-14]
set -euo pipefail
in="$1"; out="$2"; lufs="${3:--14}"
tmp="$(mktemp -t master.XXXXXX).mp4"
trap 'rm -f "$tmp"' EXIT
ffmpeg -v error -y -i "$in" -vf format=yuv420p -c:v libx264 -preset slow -crf 17 \
  -colorspace bt709 -color_primaries bt709 -color_trc bt709 -color_range tv \
  -af "loudnorm=I=${lufs}:TP=-1.5:LRA=11" -c:a aac -b:a 192k -ar 48000 -movflags +faststart "$tmp"
ffmpeg -v error -y -i "$tmp" -c copy \
  -bsf:v h264_metadata=colour_primaries=1:transfer_characteristics=1:matrix_coefficients=1:video_full_range_flag=0 \
  -movflags +faststart "$out"
ffprobe -v error -show_entries stream=codec_name,width,height,pix_fmt,color_space -show_entries format=duration -of compact "$out"
