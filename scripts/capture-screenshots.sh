#!/usr/bin/env bash
# Captures every -screenshot screen from an already-booted simulator with Damp installed.
# Usage: bash scripts/capture-screenshots.sh "<simulator name or UDID>"
set -euo pipefail
DEVICE="${1:?simulator name or UDID}"
OUT="$(cd "$(dirname "$0")/.." && pwd)/docs/screenshots"
mkdir -p "$OUT"
for s in hook drinks price reasons reveal goal first result paywall home log milestone settings share; do
  xcrun simctl launch --terminate-running-process "$DEVICE" app.usedamp.damp -screenshot "$s" >/dev/null
  sleep 5
  xcrun simctl io "$DEVICE" screenshot "$OUT/$s.png" >/dev/null
  echo "captured $s"
done
# Downscaled copies for quick review in the repo.
cd "$OUT" && for f in $(ls *.png | grep -v '^small-'); do sips -Z 600 "$f" --out "small-$f" >/dev/null; done
