#!/bin/bash
# store_tour.sh <lang> <shots|video|words> [out_dir]
# Runs integration_test/store_tour_test.dart on the iPhone 17 Pro Max simulator.
# shots/words: a screenshot per "SHOT:<name>" line into out_dir (default
# store/screenshots/tour-<lang>); video: records the walk to out_dir/rv_<lang>.mov.
# For words, serve the site locally first (python3 -m http.server 8765 in the
# azenha worktree) so the app reads the unpublished dictionary.
set -u
L=$1; M=$2
U=A5C3947B-0475-4523-BC7A-9717404FF00F
APP=$(cd "$(dirname "$0")/.." && pwd)
OUT=${3:-$APP/store/screenshots/tour-$L}; mkdir -p "$OUT"
T=$(mktemp -d); ACK=$T/ack; mkdir -p "$ACK"; LOG=$T/log.txt
cd "$APP"
flutter test integration_test/store_tour_test.dart -d $U --dart-define=SHOT_TIME=11:20 \
  --dart-define=TOUR_LANG=$L --dart-define=TOUR_MODE=$M --dart-define=TOUR_ACK=$ACK \
  --dart-define=WORDS_BASE=http://localhost:8765/ativa/words > "$LOG" 2>&1 &
FP=$!; done_shots=""; REC=""
while kill -0 $FP 2>/dev/null; do
  if [ "$M" != video ]; then
    for n in $(grep -o 'SHOT:[0-9a-z-]*' "$LOG" | cut -d: -f2); do
      case " $done_shots " in *" $n "*) ;; *)
        sleep 0.6; xcrun simctl io $U screenshot --type=png "$OUT/$n.png" >/dev/null 2>&1
        touch "$ACK/${L}_$n"; done_shots="$done_shots $n"; echo "shot $n";;
      esac
    done
  else
    if [ -z "$REC" ] && grep -q 'TOUR:start' "$LOG"; then
      xcrun simctl io $U recordVideo --codec=h264 --force "$OUT/rv_$L.mov" > "$T/rec.log" 2>&1 & REC=$!; echo recording
    fi
    if [ -n "$REC" ] && grep -q 'TOUR:end' "$LOG"; then kill -INT $REC; sleep 3; REC=""; echo stopped; fi
  fi
  sleep 0.3
done
[ -n "$REC" ] && kill -INT $REC && sleep 3
tail -3 "$LOG"
