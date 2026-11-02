#!/bin/bash
# rec.sh start <name> [dir] | rec.sh stop [dir]
# Records the iPhone simulator screen (H.264) to <dir>/rv_<name>.mov while you
# drive the app by hand; stop ends the recording. dir default: current folder.
# DEV overrides the simulator UDID (default: the iPhone 17 Pro Max used for the
# 1.9.4/1.9.5 (57) clips). store_tour.sh <lang> video replaced this for 1.9.5 (64).
# Output feeds cut.sh.
U=${DEV:-A5C3947B-0475-4523-BC7A-9717404FF00F}
if [ "$1" = start ]; then
  [ -n "$2" ] || { sed -n 2p "$0"; exit 1; }
  F=${3:-.}
  rm -f "$F/rv_$2.mov"
  xcrun simctl io "$U" recordVideo --codec=h264 --force "$F/rv_$2.mov" > "$F/rec.log" 2>&1 &
  echo $! > "$F/rec.pid"; sleep 3; tail -1 "$F/rec.log"
elif [ "$1" = stop ]; then
  F=${2:-.}
  kill -INT "$(cat "$F/rec.pid")"; sleep 4; ls -la "$F"/rv_*.mov | tail -1
else
  sed -n 2p "$0"; exit 1
fi
