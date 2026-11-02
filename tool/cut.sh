#!/bin/bash
# cut.sh <in.mov> <out.mp4> "<a:b[:speed] ...>" [still.png]
# Cuts a simulator screen recording of the app tour into one clip: each
# segment a..b seconds, played at speed factor (setpts multiplier, default 1;
# 0.5 = twice as fast), concatenated at 30 fps, H.264.
# With still.png (e.g. store/screenshots/v195-6.9-<lang>/7-news.png) 2.5 s of
# that screenshot is appended (the 1.9.5 (57) clips); without it the clip is
# only the segments (the 1.9.5 (64) clips).
# Input: rv_<lang>.mov from rec.sh, or from store_tour.sh <lang> video.
# Segment lists used:
#   1.9.5 (64), all langs, store_tour.sh video recording:
#     "0:2:1 4:6:1 10:13.5:1 15:17:1 20.5:23.5:1 26.5:28:1 33:40:0.5 43:45.5:1 53:55:1 57:72:0.3 76:80:0.67"
#   1.9.5 (57), with 7-news.png: pt "1:5.5 8.5:11 18:20.5 31.5:35 38:41 58.5:62 63:65 65:68.4:0.5"
#                                ru "1:5.5 8:10.5 19:21.5 22.5:26 37.5:40.5 51.5:55 58:60 73:77.8:0.5"
# Output feeds mkvid2.sh / mkvid3.sh as clip_<lang>.mp4.
set -e
[ $# -ge 3 ] || { sed -n 2,4p "$0"; exit 1; }
IN=$1; OUT=$2; SEGS=($3); STILL=${4:-}
N=${#SEGS[@]}
FC="[0:v]fps=30,format=yuv420p,split=$N"
for i in $(seq 0 $((N-1))); do FC="$FC[a$i]"; done; FC="$FC;"
CAT=""
for i in $(seq 0 $((N-1))); do
  IFS=: read a b sp <<< "${SEGS[$i]}"
  FC="$FC[a$i]trim=$a:$b,setpts=${sp:-1}*(PTS-STARTPTS)[s$i];"; CAT="$CAT[s$i]"
done
if [ -n "$STILL" ]; then
  FC="$FC[1:v]fps=30,format=yuv420p,scale=1320:2868,trim=0:2.5,setpts=PTS-STARTPTS[n];${CAT}[n]concat=n=$((N+1)):v=1:a=0[v]"
  ffmpeg -v error -y -i "$IN" -loop 1 -t 2.5 -i "$STILL" -filter_complex "$FC" -map "[v]" -r 30 -c:v libx264 -crf 16 -preset slow "$OUT"
else
  FC="$FC${CAT}concat=n=$N:v=1:a=0,fps=30[v]"
  ffmpeg -v error -y -i "$IN" -filter_complex "$FC" -map "[v]" -r 30 -c:v libx264 -crf 16 -preset medium "$OUT"
fi
ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT"
