# Recording workflow

End-to-end procedure the agent follows when a user asks for a demo
recording. Each step lists the action, the artifact produced, and the
checkpoint (if any) before continuing.

## 1. Gather intent

Ask explicitly (do not assume):

| Field | Example |
|-------|---------|
| URL | `http://127.0.0.1:5173`, `https://pr-247.preview.app`, `https://staging.example.com` |
| Viewport | `1440 × 900` (default), `1280 × 800`, `375 × 812` (mobile) |
| Color scheme | `dark` / `light` / `no-preference` (default) |
| Plain-English flow | "Land on /, scroll the hero, click 'Skills' in the rail, hover the first row, click it, scroll through the detail page" |
| Output format(s) | `.mov` (default; PR-friendly), `.mp4`, `.gif`, `.webm` |
| Output location | `~/Documents/` (default), repo-relative path, custom |
| Slug | inferred from filename — used to name `<slug>.flow.json`, `<slug>.webm`, `<slug>.<fmt>` |

**Refuse** to proceed if:
- URL is a production system and the user has not stated they have consent.
- Flow includes typing into auth forms (passwords, tokens).
- Recording would capture other users' data.

## 2. Translate intent → flow spec

Pick a starting template from `assets/flow-templates/`:

| Template | Best for |
|----------|----------|
| `dashboard-demo.json` | Operator UIs with rail nav + tables + detail pages |
| `landing-page-demo.json` | Marketing / docs sites with hero + scroll + CTA click |
| `form-flow-demo.json` | Forms with focus / type / submit |

Rewrite the URL, selectors, and timings for the user's flow. Keep:
- A 1500ms pause after first paint.
- A `moveMouse` to roughly the centre after first paint (suggests "cursor
  is here").
- A hover before every click that triggers visible change.
- A 600ms `trailingPauseMs` at the end.

Save as `<output-dir>/<slug>.flow.json`.

## 3. Checkpoint — confirm the flow

Show the user:
1. The JSON (or a summary like "8 steps: goto → wait → moveMouse → scroll
   → hover → click → wait → scroll").
2. The plain-English description.
3. The output paths.

Get explicit confirmation. Do not skip this for non-localhost URLs.

## 4. Record

```bash
node scripts/record.mjs \
  --flow <output-dir>/<slug>.flow.json \
  --out <output-dir>/<slug>.mov
```

First invocation installs Playwright + Chromium under
`~/.cache/lets-record-demo/` and `~/Library/Caches/ms-playwright/`
(~120 MB, one-time, ~30s). Subsequent runs skip straight to recording.

The recorder writes the `.webm` and (if `--out` ends in `.mov`/`.mp4`/`.gif`)
converts in one shot via `scripts/convert.sh` (needs `ffmpeg`).

## 5. Report

Tell the user, in order:
1. Whether recording succeeded (exit code 0 + final paths printed).
2. Duration + size of each artifact (`ffprobe -v error -show_entries
   format=duration,size <file>`).
3. The GitHub markdown snippet — for a `.mov`, drag-drop into the PR
   description; GitHub uploads to its CDN and rewrites it inline.
4. Whether to commit the `.flow.json` to the repo (yes by default — it's
   tiny and rerunnable; binaries usually not).

## 6. (Optional) Iterate

If the recording missed something:
- The cursor moved too fast → bump `moveMouse` `steps` or add intermediate
  `wait`.
- A hover state didn't show → add 400–600ms `wait` between `hover` and
  `click`.
- The page wasn't ready → add `waitForSelector` instead of fixed `wait`.
- The viewport was wrong → fix in the JSON and rerun.

Each iteration takes ~10s — the recording itself is the only slow part.

## Output discipline

Default destination: `~/Documents/`. Never write inside the project repo
unless the user explicitly asks. Never commit binary artifacts without
asking.
