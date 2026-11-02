#!/bin/bash
# mkvid2.sh <work_dir> [out_dir]
# 1.9.5 (57): per language, App Store header (3840x1646) and search
# (3840x2560) videos with clip_<lang>.mp4 inside the centre phone of the fan,
# plus the 886x1920 App Preview (silent audio track). Videos last as long as
# the clip.
# work_dir must hold clip_<lang>.mp4 (cut.sh) and, per k in header|search,
# bgb-<k>-<lang>.png, mask-<k>-<lang>.png, scr-<k>-<lang>.json, written by
#   python3 tool/fan.py --set v195-6.9 --text ask --holes <work_dir> --holes-only
# out_dir default: store/APPSTORE-1.9.5/video. LANGS="en pt de ru" by default.
set -e
[ $# -ge 1 ] || { sed -n 2,3p "$0"; exit 1; }
APP=$(cd "$(dirname "$0")/.." && pwd)
W=$(cd "$1" && pwd); OUT=${2:-$APP/store/APPSTORE-1.9.5/video}; mkdir -p "$OUT"
cd "$W"
for L in ${LANGS:-en pt de ru}; do
  D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 clip_$L.mp4)
  for k in header search; do
    if [ "$k" = header ]; then SIZE=3840x1646; else SIZE=3840x2560; fi
    set -- $(python3 -c "import json;d=json.load(open('scr-$k-$L.json'));print(d['sx'],d['sy'],d['sw'],d['sh'])")
    SX=$1; SY=$2; SW=$3; SH=$4
    ffmpeg -v error -y -loop 1 -i bgb-$k-$L.png -i clip_$L.mp4 -loop 1 -i mask-$k-$L.png -filter_complex \
      "[1:v]scale=$SW:$SH:flags=lanczos,format=rgba[v];[2:v]format=gray,scale=$SW:$SH[m];[v][m]alphamerge[vm];[0:v][vm]overlay=$SX:$SY:shortest=1,format=yuv420p[o]" \
      -map "[o]" -r 30 -c:v libx264 -crf 18 -preset medium -t "$D" "$OUT/$k-$SIZE-$L.mp4"
  done
  ffmpeg -v error -y -i clip_$L.mp4 -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
    -vf "scale=886:1925:flags=lanczos,crop=886:1920:0:0,format=yuv420p" -r 30 -c:v libx264 -profile:v high -crf 18 \
    -c:a aac -b:a 128k -shortest "$OUT/preview-886x1920-$L.mp4"
  echo "$L done ($D s)"
done
ls -la "$OUT"
