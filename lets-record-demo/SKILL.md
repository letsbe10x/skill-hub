---
name: lets-record-demo
description: "Use when you need a polished browser-flow demo video (.mov / .mp4 / .webm / .gif) to attach to a pull request, release note, or design review. Drives a Chromium browser via Playwright through a declarative JSON flow you describe — goto, scroll, click, hover, wait — and produces a faststart-flagged video ready to drop into GitHub. Works against any local or remote URL; the skill is host-agnostic and does not assume any particular app."
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
    - ffmpeg on PATH (Homebrew, apt, choco — see scripts/setup.sh)
    - ~120 MB free disk for Playwright's headless Chromium
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
sibling of `lets-create-readme-gifs` (terminal flows via VHS) and
`lets-browser-evidence` (rerunnable proof for ship gates); this skill is
specifically for **demo videos meant for human review surfaces**.

## Install and setup (one-time, idempotent)

```bash
# After installing the skill into your agent's skills dir:
bash ~/.claude/skills/lets-record-demo/scripts/setup.sh
# (Adjust path for your agent: ~/.cursor/skills/, ~/.codex/skills/, ~/.github/skills/)
```

The setup script:

1. Verifies `node >= 18` and `ffmpeg` are on PATH; prints platform-specific
   install hints if not.
2. Creates `~/.letsbe10x/tools/record-demo/` and runs
   `npm i playwright@1.60.0 --silent` into it.
3. Downloads Chromium headless shell via `npx playwright install chromium`.
4. Writes `~/.letsbe10x/config/record-demo-ready.json` with paths and
   versions; subsequent runs detect this and skip reinstall.

Skip in CI / air-gapped: `LETS_SKIP_RECORD_DEMO_SETUP=1` (the skill will
error with a clear message if the tools dir is missing at run time).

Verify readiness any time with [`scripts/doctor.sh`](scripts/doctor.sh).

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
- You need rerunnable proof for a ship gate (asserting state, not just
  showing it) → `lets-browser-evidence`.
- You need an authenticated production session and don't have an explicit
  consent gate from the data owner.
- The recording is one-off / throwaway and the OS screen recorder is faster.

## Steps

1. Announce: "Using `lets-record-demo`."
2. **Confirm readiness:** run [`scripts/doctor.sh`](scripts/doctor.sh). If it
   reports missing tools, tell the user to run
   [`scripts/setup.sh`](scripts/setup.sh) once.
3. **Capture intent with the user.** Ask explicitly:
   - URL to record (localhost? deployed preview? prod?)
   - Viewport (default `1440 × 900` desktop)
   - The flow in plain English ("land on /, scroll the hero, click 'Skills',
     hover the first row, click it, scroll through the detail page")
   - Output filename + location (default `~/Documents/<slug>.mov`)
   - Output format(s): `mov` (PR-friendly, default), `mp4` (broader),
     `webm` (smallest), `gif` (no audio, smallest LOC).
4. **Translate intent → flow spec.** Write a JSON file at
   `<output-dir>/<slug>.flow.json` following
   [`references/flow-spec.md`](references/flow-spec.md). Use one of
   [`assets/flow-templates/`](assets/flow-templates/) as a starting point.
5. **Checkpoint — confirm the flow spec with the user before recording.**
   Show the JSON and the plain-English summary. Do not proceed without
   explicit y/n confirmation, especially if recording involves
   click/type actions or non-localhost URLs.
6. **Record.** Invoke:
   ```bash
   node ~/.claude/skills/lets-record-demo/scripts/record.mjs \
     --flow <output-dir>/<slug>.flow.json \
     --out <output-dir>/<slug>.webm
   ```
   The script prints `[record] wrote <path>` on success and exits non-zero
   on failure.
7. **Convert** to requested format(s) using
   [`scripts/convert.sh`](scripts/convert.sh):
   ```bash
   bash ~/.claude/skills/lets-record-demo/scripts/convert.sh \
     <output-dir>/<slug>.webm <output-dir>/<slug>.mov
   ```
8. **Report** the absolute paths and the duration / size of each artifact
   back to the user. Suggest the GitHub markdown to attach the `.mov`
   (drag-drop into PR description).
9. **Promotion (optional):** if the user wants the flow spec checked into
   the repo so the next person can rerender, commit
   `<slug>.flow.json` and a short README pointing at this skill. Do not
   commit the binary `.mov` unless the repo's policy permits it.

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
# One-time setup
bash ~/.claude/skills/lets-record-demo/scripts/setup.sh

# Readiness check
bash ~/.claude/skills/lets-record-demo/scripts/doctor.sh

# Record (writes .webm)
node ~/.claude/skills/lets-record-demo/scripts/record.mjs \
  --flow ~/Documents/my-demo.flow.json \
  --out ~/Documents/my-demo.webm

# Convert (writes .mov via H.264 + faststart)
bash ~/.claude/skills/lets-record-demo/scripts/convert.sh \
  ~/Documents/my-demo.webm ~/Documents/my-demo.mov

# Convert to .gif (uses palettegen for quality)
bash ~/.claude/skills/lets-record-demo/scripts/convert.sh \
  ~/Documents/my-demo.webm ~/Documents/my-demo.gif

# One-shot: record + convert (uses default mov output)
node ~/.claude/skills/lets-record-demo/scripts/record.mjs \
  --flow ~/Documents/my-demo.flow.json \
  --out ~/Documents/my-demo.mov
# (when --out ends in .mov/.mp4/.gif the script also converts)
```

## Output contract

Done when all of the following are satisfied:

| Artifact | Required | Location / notes |
|----------|----------|------------------|
| `<slug>.flow.json` | yes | The declarative spec — keep it; rerunnable |
| `<slug>.webm` | yes | Raw Playwright capture (1080p+ if viewport is) |
| `<slug>.<format>` | yes | Final artifact in the format(s) the user asked for; `mov` is faststart-flagged for GitHub inline playback |
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
- **Pure black on dark UIs.** When recording a dark UI, set
  `colorScheme: "dark"` in the spec so the browser emits proper
  `prefers-color-scheme: dark` (some apps key off it).
- **Forgetting `deviceScaleFactor`.** Default to 2 for crisp text on retina;
  drop to 1 only if file size is a constraint.

## Error handling

- **`playwright not installed`**: rerun `scripts/setup.sh`. If the install
  fails behind a corporate proxy, set `HTTPS_PROXY` and retry.
- **`ffmpeg: command not found`**: print platform-specific install command
  (`brew install ffmpeg`, `apt install ffmpeg`, `choco install ffmpeg`).
- **`Timeout 30000ms exceeded` on a selector**: the page didn't render the
  expected element. Re-check the selector, increase the preceding `wait`,
  or add a `waitForSelector` step.
- **Recording is blank / black**: the browser likely couldn't reach the
  URL. Confirm the dev server is running and curl the URL first.
- **Cursor not visible in recording**: Playwright's headless mode does not
  render a real cursor; the skill compensates with subtle `moveMouse`
  + `hover` actions before clicks. If you need a visible cursor overlay,
  document it as a follow-up — this skill does not currently inject one.

## Related skills

- Terminal screencasts (VHS / GIF) → [`lets-create-readme-gifs`](../lets-create-readme-gifs/)
- Rerunnable browser proof for ship gates → [`lets-browser-evidence`](../lets-browser-evidence/)
- UX walkthroughs with friction logging → [`lets-research-ux-walkthrough`](../lets-research-ux-walkthrough/)
