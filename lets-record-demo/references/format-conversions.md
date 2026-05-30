# Output format guide

The recorder always produces a `.webm` (Playwright's native format). The
`convert.sh` helper turns that into one of four PR-friendly formats. Choose
based on the destination surface.

## Decision table

| Format | Use when | Pros | Cons |
|--------|----------|------|------|
| `.mov` | Default. Attaching to a GitHub PR / issue / release note. | Plays inline on GitHub; faststart-flagged so seek works immediately; H.264 is universally supported. | Slightly larger than `.mp4` on some clips. |
| `.mp4` | Outside GitHub (Slack, Linear, Notion, blog posts). | Universal player support; same H.264 + faststart as `.mov`. | Some forums strip audio metadata. |
| `.gif` | README hero, Twitter / X, Mastodon, anywhere that doesn't play video inline. | Plays anywhere without a click; no audio = no autoplay block. | Much larger than video for the same length; 256 colors only; loop-only. |
| `.webm` | When file size matters most and the audience uses Chrome / Firefox. | ~3-5x smaller than equivalent `.mov`. | Safari < 14.1 can't play; some chat apps don't preview. |

## Size guidance

For a 22-second 1440×900 dark-UI demo at default settings:

| Format | Approx. size |
|--------|--------------|
| `.webm` | ~1.5–2.5 MB |
| `.mov` (CRF 22, medium preset) | ~1.5–2 MB |
| `.mp4` (same) | ~1.5–2 MB |
| `.gif` (15fps, 900px wide, palettegen) | ~3–8 MB |

GitHub's PR attachment limit is **10 MB per file**. If a `.mov` is over,
either shorten the flow or drop `deviceScaleFactor` from 2 to 1 in the
flow spec.

## Quality knobs

The `convert.sh` defaults are tuned for PR demos. If you need to tweak:

- **Lower file size**: edit `convert.sh` to use `-crf 26` (smaller, slight
  quality loss).
- **Higher quality**: `-crf 18` (larger, near-lossless).
- **Slower CPU, smaller file**: `-preset slow` instead of `medium`.
- **Smaller GIF**: drop `scale=900:-1` to `scale=600:-1`, or `fps=15` to
  `fps=10`.

## Faststart and why it matters

`.mov` / `.mp4` files have a metadata block (`moov` atom). By default
ffmpeg writes it at the *end* of the file, which means players have to
download the whole file before they can start. `-movflags +faststart`
moves it to the front — required for inline GitHub playback and a much
better experience anywhere video streams.

The `convert.sh` script always passes `+faststart`. If you encode manually,
include it.

## Audio

The recorder produces silent video — there's no microphone or system audio
capture. If you need narration, record the video first, then add audio in
a post step:

```bash
ffmpeg -i demo.mov -i narration.m4a -c:v copy -c:a aac -shortest demo-with-audio.mov
```

## When to NOT convert

Keep the `.webm` if:
- The destination already accepts `.webm` and you want the smallest file.
- You're going to re-process the recording (split, trim, add overlays) —
  re-encoding from `.webm` once is better than transcoding twice.
