#!/usr/bin/env bash
# Convert a Playwright .webm into a PR-friendly format.
# Outputs:
#   .mov / .mp4 -> H.264 (yuv420p) + faststart, CRF 22
#   .gif        -> palette-quantized gif at the source frame rate
#
# Usage: convert.sh <input.webm> <output.{mov,mp4,gif}>
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <input.webm> <output.{mov,mp4,gif}>" >&2
  exit 2
fi

IN="$1"
OUT="$2"

if [[ ! -f "${IN}" ]]; then
  echo "✗ input not found: ${IN}" >&2
  exit 2
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "✗ ffmpeg not found. Install:" >&2
  echo "  macOS:   brew install ffmpeg" >&2
  echo "  Debian:  sudo apt install ffmpeg" >&2
  echo "  Fedora:  sudo dnf install ffmpeg" >&2
  echo "  Windows: choco install ffmpeg" >&2
  exit 3
fi

mkdir -p "$(dirname "${OUT}")"

ext="$(printf '%s' "${OUT##*.}" | tr '[:upper:]' '[:lower:]')"

case "${ext}" in
  mov|mp4)
    ffmpeg -y -loglevel error -i "${IN}" \
      -c:v libx264 -pix_fmt yuv420p -movflags +faststart -crf 22 -preset medium \
      "${OUT}"
    ;;
  gif)
    # Two-pass palette for clean colors.
    palette="$(mktemp -u -t lets-record-demo-palette.XXXXXX).png"
    trap 'rm -f "${palette}"' EXIT
    ffmpeg -y -loglevel error -i "${IN}" \
      -vf "fps=15,scale=900:-1:flags=lanczos,palettegen" "${palette}"
    ffmpeg -y -loglevel error -i "${IN}" -i "${palette}" \
      -lavfi "fps=15,scale=900:-1:flags=lanczos [v]; [v][1:v] paletteuse" \
      "${OUT}"
    ;;
  webm)
    cp "${IN}" "${OUT}"
    ;;
  *)
    echo "✗ unsupported output format: .${ext}" >&2
    echo "  supported: .mov, .mp4, .gif, .webm" >&2
    exit 4
    ;;
esac

echo "✓ wrote ${OUT}"
