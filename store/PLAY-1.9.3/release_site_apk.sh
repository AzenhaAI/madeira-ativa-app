#!/bin/bash
# Release day, after both stores are live: put APK 42 on azenha.ai/ativa
# (same signing key as the one there, 94:EA:47..., so it installs over it).
set -euo pipefail
APK="$HOME/Projects/ativa/store/android/madeira-ativa-v1.9.3+42.apk"
SITE="$HOME/Projects/azenha"
cp "$APK" "$SITE/ativa/madeira-events.apk"
cd "$SITE"
git add ativa/madeira-events.apk
git commit -qm "Madeira Ativa APK 1.9.3 (42) on the site"
git pull -q --rebase --autostash
git push -q
scripts/deploy_prod.sh | tail -1
curl -sI https://azenha.ai/ativa/madeira-events.apk | grep -i "content-length"
