---
name: lets-record-demo
description: "Use when you need a polished browser-flow demo video (.mov / .mp4 / .webm / .gif) to attach to a pull request, release note, or design review. Drives a headless Chromium via Playwright through a declarative JSON flow you describe — goto, scroll, click, hover, wait — and produces a faststart-flagged video ready to drop into GitHub. Host-agnostic: works against any local or remote URL the user has permission to record."
metadata:
  author: letsbe10x
  version: "0.1.0"
  tags: [demo, video, recording, playwright, screencast, browser, pr, mov, release-notes]
lifecycle: published
source: https://github.com/letsbe10x/skill-hub/blob/main/lets-record-demo/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
  requirements:
    - Node.js 18+ on PATH
    - ffmpeg on PATH (only required for .mov / .mp4 / .gif output; .webm works without it)
triggers:
  - record a demo video for the PR
  - create a screencast of this flow
  - generate a .mov walkthrough for the release notes
  - capture a browser demo for the design review
  - I need a video showing the new UI
  - make a demo gif from a localhost flow
not-for:
  - Recording authenticated production sessions without explicit owner consent
  - Replacing a project's checked-in e2e test suite (use Playwright e2e instead)
  - Continuous monitoring or screenshot scraping
  - Terminal-only demos — use `lets-create-readme-gifs` (VHS-tape) instead
  - Manual / human-controlled screen recording — use the OS screen recorder
---

# lets-record-demo

## Overview

`lets-record-demo` produces **rerunnable browser-flow demo videos** for pull
requests, release notes, and design reviews. The agent:

1. Captures the demo intent (URL, viewport, what to highlight) in a small
   declarative **flow spec** (JSON) — no per-project recording code.
2. Drives a headless Chromium via **Playwright** through the spec, emitting a
   `.webm`.
3. Converts the `.webm` to `.mov` (H.264, faststart) — the format GitHub
   plays inline on PR previews. `.mp4` and `.gif` are also supported.
4. Saves both source `.webm` and final `.mov` to a user-chosen output dir
   (default: `~/Documents/<flow-name>.mov`).

The skill is **host-agnostic** — point it at any local dev server, deployed
preview URL, or production page you have permission to record. It is the
sibling of `lets-create-readme-gifs` (terminal flows via VHS); this skill is
specifically for **browser demo videos meant for human review surfaces**.

## Install

Install on its own:

```bash
# Claude Code (default agent)
npx github:letsbe10x/skill-hub install lets-record-demo

# Cursor / Codex / Copilot
npx github:letsbe10x/skill-hub install lets-record-demo --agent cursor
npx github:letsbe10x/skill-hub install lets-record-demo --agent codex
npx github:letsbe10x/skill-hub install lets-record-demo --agent copilot

# Project-scoped (writes to .claude/skills/ in cwd instead of ~/)
npx github:letsbe10x/skill-hub install lets-record-demo --scope project
```

Or as part of a bundle that already includes it:

```bash
npx github:letsbe10x/skill-hub install engineering --agent claude-code
npx github:letsbe10x/skill-hub install design       --agent claude-code
npx github:letsbe10x/skill-hub install all          --agent claude-code
```

The installer copies the skill directory to the agent's skills dir (e.g.
`~/.claude/skills/lets-record-demo/`). **No further setup is needed.** The
first time the agent invokes the recorder, Playwright + Chromium install
themselves automatically (see below).

## How dependencies are handled (no setup step)

The recorder is **self-bootstrapping**. On first invocation it:

- Verifies `node >= 18`.
- Installs Playwright (`1.60.0` by default) into `~/.cache/lets-record-demo/`
  via `npm install` (single, one-time, idempotent).
- Downloads the headless Chromium binary into Playwright's standard cache
  (`~/Library/Caches/ms-playwright/` on macOS).

Subsequent runs reuse both caches and skip straight to recording. To pin a
different Playwright version: `LETS_RECORD_DEMO_PLAYWRIGHT_VERSION=1.59.0`.
To relocate the cache: `LETS_RECORD_DEMO_CACHE=/some/path`.

`ffmpeg` is the only system dependency — install via your OS package
manager (`brew install ffmpeg`, `apt install ffmpeg`, `choco install
ffmpeg`). The recorder produces `.webm` without ffmpeg and emits a clear
hint with the install command if you ask for `.mov` / `.mp4` / `.gif`
without it on PATH.

## When to use

- A pull request adds visible UI behavior and a reviewer needs a 15–30s clip
  to evaluate it.
- A release note or changelog needs an inline `.mov` demonstrating the new
  flow.
- A design review wants the actual UI clicked through (not a static
  screenshot) at a fixed viewport.
- A bug report needs a reproducible recording of the trigger sequence.

## When not to use

- The demo is a terminal flow → `lets-create-readme-gifs` (VHS-based).
- You need an authenticated production session and don't have an explicit
  consent gate from the data owner.
- The recording is one-off / throwaway and the OS screen recorder is faster.

## Steps

1. Announce: "Using `lets-record-demo`."
2. **Capture intent with the user.** Ask explicitly:
   - URL to record (localhost? deployed preview? prod?)
   - Viewport (default `1440 × 900` desktop)
   - The flow in plain English ("land on /, scroll the hero, click 'Skills',
     hover the first row, click it, scroll through the detail page")
   - Output filename + location (default `~/Documents/<slug>.mov`)
   - Output format(s): `mov` (PR-friendly, default), `mp4` (broader),
     `webm` (smallest), `gif` (no audio).
3. **Translate intent → flow spec.** Write a JSON file at
   `<output-dir>/<slug>.flow.json` following
   [`references/flow-spec.md`](references/flow-spec.md). Start from one of
   [`assets/flow-templates/`](assets/flow-templates/) and rewrite the URL,
   selectors, and timings.
4. **Checkpoint — confirm the flow spec with the user before recording.**
   Show the JSON and the plain-English summary. Do not proceed without
   explicit y/n confirmation, especially if recording involves
   `click`/`type` actions or non-localhost URLs.
5. **Record.** Invoke the recorder. First run will install Playwright +
   Chromium one-time (~120 MB total, ~30s on a fast connection):
   ```bash
   node <skill-dir>/scripts/record.mjs \
     --flow <output-dir>/<slug>.flow.json \
     --out <output-dir>/<slug>.mov
   ```
   When `--out` ends in `.mov` / `.mp4` / `.gif`, the script records the
   `.webm` and then converts in one shot. Exits non-zero on failure with a
   specific error.
6. **Report** the absolute paths and the duration / size of each artifact
   back to the user (use `ffprobe -v error -show_entries
   format=duration,size <file>`). Suggest the GitHub markdown to attach
   the `.mov` (drag-drop into the PR description).
7. **Promotion (optional):** if the user wants the flow spec checked into
   the repo so the next person can rerender, commit
   `<slug>.flow.json`. Do not commit the binary `.mov` unless the repo's
   policy permits it.

## Flow spec — the recording DSL

A flow is a JSON object:

```json
{
  "url": "http://127.0.0.1:5173",
  "viewport": { "width": 1440, "height": 900 },
  "deviceScaleFactor": 2,
  "colorScheme": "dark",
  "steps": [
    { "action": "wait", "ms": 1500 },
    { "action": "moveMouse", "x": 720, "y": 400 },
    { "action": "scroll", "y": 320, "durationMs": 700 },
    { "action": "hover", "selector": "a[href='/skills']" },
    { "action": "click", "selector": "a[href='/skills']" },
    { "action": "waitForUrl", "pattern": "**/skills" },
    { "action": "wait", "ms": 1500 },
    { "action": "click", "selector": "table tbody tr", "nth": 0 },
    { "action": "wait", "ms": 2000 }
  ]
}
```

Full DSL reference: [`references/flow-spec.md`](references/flow-spec.md).

Supported actions: `goto`, `wait`, `waitForUrl`, `waitForSelector`,
`scroll`, `moveMouse`, `hover`, `click`, `type`, `press`, `screenshot`,
`evaluate`.

For flows the DSL can't express (multi-window, file uploads, drag-drop),
pass `--flow <file>.mjs` instead — see
[`references/flow-spec.md`](references/flow-spec.md#javascript-escape-hatch).

## Commands

```bash
# Record + auto-convert in one shot (writes both .webm and .mov)
node <skill-dir>/scripts/record.mjs \
  --flow ~/Documents/my-demo.flow.json \
  --out ~/Documents/my-demo.mov

# Record only (writes .webm; no ffmpeg required)
node <skill-dir>/scripts/record.mjs \
  --flow ~/Documents/my-demo.flow.json \
  --out ~/Documents/my-demo.webm

# Convert an existing .webm to .mov / .mp4 / .gif
bash <skill-dir>/scripts/convert.sh ~/Documents/my-demo.webm ~/Documents/my-demo.gif

# Override the flow's url without editing the JSON
node <skill-dir>/scripts/record.mjs \
  --flow my-demo.flow.json --out my-demo.mov --url https://staging.example.com
```

`<skill-dir>` resolves to `~/.claude/skills/lets-record-demo/`,
`~/.cursor/skills/lets-record-demo/`, `~/.codex/skills/lets-record-demo/`,
or `~/.github/skills/lets-record-demo/` depending on the host agent.

## Output contract

Done when all of the following are satisfied:

| Artifact | Required | Location / notes |
|----------|----------|------------------|
| `<slug>.flow.json` | yes | The declarative spec — keep it; rerunnable |
| `<slug>.webm` | yes | Raw Playwright capture at the chosen viewport |
| `<slug>.<format>` | yes | Final artifact in the format(s) the user asked for; `.mov` is faststart-flagged for GitHub inline playback |
| Report | yes | Absolute paths + duration / file size for each artifact, returned to the user |

## Outputs

- A declarative flow spec the user (or any future agent) can rerun.
- A `.webm` source recording.
- One or more derived artifacts: `.mov` (default), `.mp4`, `.gif`.
- A short summary message with file paths and the GitHub-ready markdown
  snippet.

## Anti-patterns

- **Hardcoding a single app's flow into the skill.** The flow must always
  be parameterized via the JSON spec — never embed app-specific selectors
  or URLs in the skill scripts.
- **Recording without a checkpoint.** Always confirm the flow spec with the
  user before recording, especially for any non-localhost URL or any flow
  that includes `type` / `click` actions on form elements.
- **Recording authenticated sessions silently.** If the URL is not
  `localhost` / `127.0.0.1` / a known preview domain, require explicit
  user confirmation that they own / have consent to record it.
- **Committing binary `.mov` / `.mp4` files to repos without policy
  approval.** Most repos prefer hosted attachments; commit the `flow.json`
  source-of-truth and link to the GitHub-hosted attachment instead.
- **Selectors tied to React-internal class names** (`__cls_a1b2c3`) —
  they change on every build. Prefer `role` + accessible name,
  `data-testid`, or stable semantic selectors.
- **No `wait` between hover and click** — the hover state won't render in
  the video.

## Error handling

- **`failed to install playwright`**: rerun in a shell with `HTTPS_PROXY`
  set if behind a corporate proxy. The cache lives at
  `~/.cache/lets-record-demo/`; delete it to force a clean reinstall.
- **`failed to install chromium`**: same proxy story; or set
  `PLAYWRIGHT_BROWSERS_PATH` to a writable location.
- **`ffmpeg not on PATH`**: install via `brew install ffmpeg`,
  `sudo apt install ffmpeg`, or `choco install ffmpeg`. The `.webm` is
  preserved on conversion failure so you don't lose the recording.
- **`Timeout 30000ms exceeded` on a selector**: the page didn't render the
  expected element. Re-check the selector, increase the preceding `wait`,
  or add a `waitForSelector` step.
- **Recording is blank / black**: the browser likely couldn't reach the
  URL. Confirm the dev server is running and curl the URL first.
- **Cursor not visible in recording**: Playwright's headless mode does not
  render a real cursor; the skill compensates with `moveMouse` + `hover`
  actions before clicks to suggest cursor location.

## Related skills

- Terminal screencasts (VHS / GIF) → [`lets-create-readme-gifs`](../lets-create-readme-gifs/)
- UX walkthroughs with friction logging → [`lets-research-ux-walkthrough`](../lets-research-ux-walkthrough/)
