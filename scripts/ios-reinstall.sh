#!/bin/zsh
# Weekly re-sign+reinstall of Madeira Ativa on the iPhone (free Apple signing
# expires every 7 days). Runs via launchd; no-op if the phone isn't connected.
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
DEV="00008110-0004050C3633801E"
LOG=~/Library/Logs/ativa-ios-reinstall.log
echo "=== $(date) ===" >> "$LOG"
if ! xcrun devicectl list devices 2>/dev/null | grep -qi "connected"; then
  echo "iPhone not connected — skip" >> "$LOG"
  # warn if we have not managed to reinstall for 5+ days (signing expires at 7)
  LAST=$(grep -n "reinstalled OK" "$LOG" | tail -1 | cut -d: -f1)
  if [ -n "$LAST" ]; then
    TS=$(sed -n "1,${LAST}p" "$LOG" | grep "^=== " | tail -1 | sed 's/=== //;s/ ===//')
    AGE=$(( ( $(date +%s) - $(date -j -f "%a %b %d %T %Z %Y" "$TS" +%s 2>/dev/null || echo 0) ) / 86400 ))
    if [ "$AGE" -ge 5 ] 2>/dev/null; then
      osascript -e 'display notification "Connect the iPhone by cable - signature expires in '"$((7-AGE))"' days." with title "Madeira Ativa"' 2>/dev/null
    fi
  fi
  exit 0
fi
cd ~/Projects/ativa || exit 1

# Build straight at this UDID rather than at a generic device: that is also what
# registers the phone with the team, without which a fresh Apple ID can issue no
# profile at all. Pin DerivedData to this project — the sibling Flutter apps
# (alfacat_app, bulldozer_app) all build a product called Runner.app, and picking
# the first match under the shared DerivedData root could install the wrong one.
DD=~/Projects/ativa/build/ios-dd
BUILD_OUT=$(xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release \
  -destination "id=$DEV" -derivedDataPath "$DD" -allowProvisioningUpdates build 2>&1)
BUILD_RC=$?
echo "$BUILD_OUT" >> "$LOG"

if [ $BUILD_RC -ne 0 ]; then
  echo "build FAILED" >> "$LOG"
  # The one cause a human must clear before any retry can work.
  if grep -q "No Accounts" <<<"$BUILD_OUT"; then
    osascript -e 'display notification "No Apple ID in Xcode - Settings > Apple Accounts > + (needs your password and 2FA)." with title "Madeira Ativa: signing blocked"' 2>/dev/null
  fi
  exit 1
fi

APP=$(find "$DD" -name "Runner.app" -path "*Release-iphoneos*" | head -1)
xcrun devicectl device install app --device "$DEV" "$APP" >> "$LOG" 2>&1 \
  && { echo "reinstalled OK" >> "$LOG"; osascript -e 'display notification "App reinstalled on the iPhone" with title "Madeira Ativa"' 2>/dev/null; } || echo "install FAILED" >> "$LOG"
