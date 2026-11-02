#!/bin/bash
# mkvid.sh <work_dir> [out_dir]
# 1.9.4, English only: App Store header (3840x1646) and search (3840x2560)
# videos with the clip playing inside the centre phone of the fan, plus the
# 886x1920 App Preview with a silent audio track.
# work_dir must hold: clip_en.mp4 (cut.sh), and per k in header|search
# bgb-<k>.png, mask-<k>.png, scr-<k>.json - or the -en variants written by
# python3 tool/fan.py --holes <work_dir>.
# out_dir default: store/APPSTORE-1.9.4/video. DUR (default 21.8 s, the 1.9.4
# clip) caps the fan videos.
# Superseded by mkvid2.sh (four languages) and mkvid3.sh (1.9.5 (64)).
set -e
[ $# -ge 1 ] || { sed -n 2,3p "$0"; exit 1; }
APP=$(cd "$(dirname "$0")/.." && pwd)
W=$(cd "$1" && pwd); OUT=${2:-$APP/store/APPSTORE-1.9.4/video}; mkdir -p "$OUT"
cd "$W"
for k in header search; do
  if [ "$k" = header ]; then SIZE=3840x1646; else SIZE=3840x2560; fi
  S=""; [ -f "scr-$k.json" ] || S=-en
  set -- $(python3 -c "import json;d=json.load(open('scr-$k$S.json'));print(d['sx'],d['sy'],d['sw'],d['sh'])")
  SX=$1; SY=$2; SW=$3; SH=$4
  ffmpeg -v error -y -loop 1 -i bgb-$k$S.png -i clip_en.mp4 -loop 1 -i mask-$k$S.png -filter_complex \
    "[1:v]scale=$SW:$SH:flags=lanczos,format=rgba[v];[2:v]format=gray,scale=$SW:$SH[m];[v][m]alphamerge[vm];[0:v][vm]overlay=$SX:$SY:shortest=1,format=yuv420p[o]" \
    -map "[o]" -r 30 -c:v libx264 -crf 18 -preset medium -t "${DUR:-21.8}" "$OUT/$k-$SIZE-en.mp4"
  echo "$k done"
done
ffmpeg -v error -y -i clip_en.mp4 -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
  -vf "scale=886:1925:flags=lanczos,crop=886:1920:0:0,format=yuv420p" -r 30 -c:v libx264 -profile:v high -crf 18 \
  -c:a aac -b:a 128k -shortest "$OUT/preview-886x1920-en.mp4"
echo preview done
ls -la "$OUT"
