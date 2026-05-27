#!/usr/bin/env bash
# Deterministic checks for a README demo artifact (GIF / SVG / MP4).
#
# Usage:
#   verify-demo.sh <path-to-demo>
#
# Environment overrides:
#   DEMO_MAX_SECONDS   default 20      — duration ceiling
#   DEMO_MAX_BYTES     default 1000000 — file size ceiling (1MB)
#   DEMO_EXPECT_WIDTH  default 1000    — expected source width
#   DEMO_EXPECT_HEIGHT default 420     — expected source height
#
# Exit codes:
#   0  all checks passed
#   1  one or more checks failed
#   2  invalid invocation (missing file, ffprobe not installed)

set -eu

if [ -z "${1:-}" ]; then
  echo "usage: verify-demo.sh <path-to-demo>" >&2
  exit 2
fi

DEMO="$1"
MAX_SECONDS="${DEMO_MAX_SECONDS:-20}"
MAX_BYTES="${DEMO_MAX_BYTES:-1000000}"
EXPECT_WIDTH="${DEMO_EXPECT_WIDTH:-1000}"
EXPECT_HEIGHT="${DEMO_EXPECT_HEIGHT:-420}"

if [ ! -f "$DEMO" ]; then
  echo "✗ file not found: $DEMO" >&2
  exit 2
fi

if ! command -v ffprobe >/dev/null 2>&1; then
  echo "✗ ffprobe not installed (brew install ffmpeg)" >&2
  exit 2
fi

fail=0
pass() { echo "✓ $1"; }
flag() { echo "✗ $1" >&2; fail=$((fail + 1)); }

# 1. File size
SIZE=$(stat -f%z "$DEMO" 2>/dev/null || stat -c%s "$DEMO")
if [ "$SIZE" -le "$MAX_BYTES" ]; then
  pass "size $(($SIZE / 1024))KB ≤ $(($MAX_BYTES / 1024))KB"
else
  flag "size $(($SIZE / 1024))KB exceeds budget $(($MAX_BYTES / 1024))KB — CDN-host or shorten the demo"
fi

# 2. Duration
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$DEMO" 2>/dev/null || echo "0")
DURATION_INT=${DURATION%.*}
if [ "$DURATION_INT" -le "$MAX_SECONDS" ]; then
  pass "duration ${DURATION_INT}s ≤ ${MAX_SECONDS}s"
else
  flag "duration ${DURATION_INT}s exceeds budget ${MAX_SECONDS}s — trim Sleep budgets or move to YouTube"
fi

# 3. Dimensions
WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 "$DEMO" 2>/dev/null || echo "0")
HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 "$DEMO" 2>/dev/null || echo "0")

if [ "$WIDTH" = "$EXPECT_WIDTH" ] && [ "$HEIGHT" = "$EXPECT_HEIGHT" ]; then
  pass "dimensions ${WIDTH}x${HEIGHT} match expected"
else
  flag "dimensions ${WIDTH}x${HEIGHT} — expected ${EXPECT_WIDTH}x${EXPECT_HEIGHT}. Update the tape's Set Width/Height or update DEMO_EXPECT_* env vars."
fi

echo ""
if [ "$fail" -gt 0 ]; then
  echo "$fail check(s) failed."
  exit 1
fi
echo "all checks passed."
