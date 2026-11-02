#!/bin/bash
# shoot_droid.sh <lang>...   (lang: en | pt | de)
# Play screenshots from the Pixel 7 emulator at 1080x2160 (demo status bar on):
# restarts ai.azenha.ativa, picks the language in the menu, then taps through
# Home, Events, Map, Levadas, one trail (and its profile), Ask.
# Writes $OUT/phone-<lang>/{1-home,5-events,4-map,2-levadas,3-trail,3b-trail-profile,6-ask}.png
# OUT default: store/PLAY-1.9.4. ADB / EMU override the adb binary and the
# emulator serial (default emulator-5554).
# The taps are pixel positions of the 1.9.4 layout (bottom nav at y=1960,
# language buttons at y=192); check them after UI changes. No ru position.
APP=$(cd "$(dirname "$0")/.." && pwd)
A=${ADB:-$HOME/Library/Android/sdk/platform-tools/adb}; E=${EMU:-emulator-5554}
OUT=${OUT:-$APP/store/PLAY-1.9.4}
[ $# -ge 1 ] || { sed -n 2p "$0"; exit 1; }
t() { $A -s $E shell input tap $1 $2; }
shot() { $A -s $E exec-out screencap -p > "$1"; }
for L in "$@"; do
  D="$OUT/phone-$L"; mkdir -p "$D"
  $A -s $E shell am force-stop ai.azenha.ativa; $A -s $E shell monkey -p ai.azenha.ativa -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1; sleep 6
  case $L in en) X=640;; pt) X=760;; de) X=888;; esac
  t 108 1960; sleep 1; t $X 192; sleep 7; shot "$D/1-home.png"
  t 448 1960; sleep 4; shot "$D/5-events.png"
  t 632 1960; sleep 4; t 875 300; sleep 5; shot "$D/4-map.png"
  t 812 1960; sleep 4; shot "$D/2-levadas.png"
  t 540 1000; sleep 6; shot "$D/3-trail.png"
  $A -s $E shell input swipe 540 1700 540 400 400; sleep 2; shot "$D/3b-trail-profile.png"
  t 60 200; sleep 2
  t 272 1960; sleep 16; shot "$D/6-ask.png"
  t 108 1960; sleep 1
done
echo shot "$@"
