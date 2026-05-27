# Verification

Before committing a demo, prove three things: it's the right size, the right
length, and the right content. The first two are deterministic checks via
`ffprobe`; the third is visual via frame extraction.

## Budgets

| Budget | Limit | Rationale |
|---|---|---|
| **Duration** | ≤ 20s | Longer = video, belongs on YouTube. Auto-play loops above ~15s feel droning. |
| **Size (in-repo)** | ≤ 1MB | Larger bloats `git clone`; CDN-host instead. |
| **Size (CDN)** | ≤ 5MB | Mobile data + GitHub's image proxy struggle past this. |
| **Source dimensions** | match tape's `Set Width/Height` | Confirms VHS rendered what you asked for. |
| **Displayed width** | 600–900px | Set in the README's `<img width=>`, not the GIF. |

## Deterministic checks (the script)

`scripts/verify-demo.sh` is checked into the repo and run in CI. It uses
`ffprobe` (ships with ffmpeg) to read the GIF's metadata.

```bash
bash scripts/verify-demo.sh assets/demo.gif
```

Exit codes:
- `0` — all checks passed
- `1` — at least one check failed
- `2` — invalid invocation (missing file, ffprobe not installed)

What it checks:
1. File exists and is readable
2. Format is GIF / SVG / MP4 (matches expected)
3. Duration ≤ 20 seconds
4. File size ≤ 1MB
5. Dimensions match expected (default: 1000×420)

Override budgets via env vars:

```bash
DEMO_MAX_SECONDS=30 DEMO_MAX_BYTES=2000000 bash scripts/verify-demo.sh assets/demo.gif
```

## Visual checks (frame extraction)

`ffprobe` confirms the GIF is *shaped* right. It doesn't tell you the GIF
shows the right *content*. For that, extract frames and eyeball them.

```bash
mkdir -p /tmp/demo-frames
ffmpeg -y -i assets/demo.gif -vf "fps=1" /tmp/demo-frames/frame_%02d.png
```

This writes one PNG per second of the GIF. Open three frames:
1. **Early** (~1-2s in) — confirms the opening tagline / first command typed
2. **Middle** (~halfway) — confirms the key output rendered
3. **Late** (~last 2s) — confirms the closing caption / final state

For each frame, verify:

- [ ] No leaked paths (no `/Users/<your-name>/`, `/home/<your-name>/`)
- [ ] No leaked counts ("21 skills", "v3.4.7") that will go stale
- [ ] No tokens, keys, or internal URLs visible
- [ ] Text is sharp (not fuzzy or pixelated)
- [ ] Colors render OK on both light and dark backgrounds (best test:
  view the rendered README in GitHub's light and dark themes)

## Visual checks with a single command

For quick spot-checks without writing files:

```bash
# Show a single frame at t=5s
ffmpeg -ss 5 -i assets/demo.gif -frames:v 1 -f image2pipe -vcodec png - | open -a Preview -f
```

(macOS — pipes a PNG into Preview without saving.)

## When the GIF is fine but the README looks wrong

The GIF can be verified correct and still render poorly in the README.
Common causes:

| Symptom | Cause | Fix |
|---|---|---|
| GIF takes up the full README width | `<img width>` not set or set to 100% | Set explicit `width="900"` |
| GIF clipped on mobile | Container overflow at >1000px | Cap displayed width at 900 |
| GIF blends into white background | Light theme + dark GIF without padding | Add `Set Padding 30` in the tape |
| GIF blends into dark background | Dark theme + light GIF | Use Dracula or another dark-friendly theme |
| GIF appears as broken image | File doesn't exist OR path mismatch | Render and check the `<img src>` |

## CI integration

Add this to `.github/workflows/verify-demo.yml`:

```yaml
name: Verify demo
on: [pull_request]
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install ffmpeg
        run: sudo apt-get install -y ffmpeg
      - name: Verify demo budgets
        run: bash scripts/verify-demo.sh assets/demo.gif
```

This blocks any PR that ships a demo violating the budgets.
