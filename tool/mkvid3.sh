#!/bin/bash
# mkvid3.sh <clips_dir> <holes_dir> [version]
# 1.9.5 (64/65): per language, App Store header (3840x1646) and search
# (3840x2560) videos with the clip inside the centre phone of the fan, the
# 886x1920 App Preview (silent audio track), and a 1080x1920 short (the clip
# over a blurred copy of itself).
# clips_dir: clip_<lang>.mp4 (cut.sh, no still, from store_tour.sh <lang> video).
# holes_dir: bgb-/mask-<k>-<lang>.png and scr-<k>-<lang>.json from
#   python3 tool/fan.py --holes <holes_dir> --holes-only
# version (default 1.9.5-64) -> store/APPSTORE-<version>/video, store/SHORTS-<version>.
# LANGS="en pt de ru" by default.
set -e
[ $# -ge 2 ] || { sed -n 2,3p "$0"; exit 1; }
APP=$(cd "$(dirname "$0")/.." && pwd)
T=$(cd "$1" && pwd); V=$(cd "$2" && pwd); VER=${3:-1.9.5-64}
OUT=$APP/store/APPSTORE-$VER/video; SH=$APP/store/SHORTS-$VER; mkdir -p "$OUT" "$SH"
for L in ${LANGS:-en pt de ru}; do
  C=$T/clip_$L.mp4; D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$C")
  for k in header search; do
    if [ "$k" = header ]; then SIZE=3840x1646; else SIZE=3840x2560; fi
    set -- $(python3 -c "import json;d=json.load(open('$V/scr-$k-$L.json'));print(d['sx'],d['sy'],d['sw'],d['sh'])")
    ffmpeg -v error -y -loop 1 -i "$V/bgb-$k-$L.png" -i "$C" -loop 1 -i "$V/mask-$k-$L.png" -filter_complex \
      "[1:v]scale=$3:$4:flags=lanczos,format=rgba[v];[2:v]format=gray,scale=$3:$4[m];[v][m]alphamerge[vm];[0:v][vm]overlay=$1:$2:shortest=1,format=yuv420p[o]" \
      -map "[o]" -r 30 -c:v libx264 -crf 18 -preset medium -t "$D" "$OUT/$k-$SIZE-$L.mp4"
  done
  ffmpeg -v error -y -i "$C" -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
    -vf "scale=886:1925:flags=lanczos,crop=886:1920:0:0,format=yuv420p" -r 30 -c:v libx264 -profile:v high -crf 18 \
    -c:a aac -b:a 128k -shortest "$OUT/preview-886x1920-$L.mp4"
  ffmpeg -v error -y -i "$C" -filter_complex \
    "[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=30:2,eq=brightness=-0.08[b];[0:v]scale=-2:1840:flags=lanczos[f];[b][f]overlay=(W-w)/2:(H-h)/2,format=yuv420p[o]" \
    -map "[o]" -r 30 -c:v libx264 -crf 20 -preset medium "$SH/short-1080x1920-$L.mp4"
  echo "$L done ($D s)"
done
ls -la "$OUT" "$SH"
