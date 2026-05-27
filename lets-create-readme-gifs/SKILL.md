---
name: lets-create-readme-gifs
description: "Use when producing the above-the-fold demo GIF (or animated SVG / hosted MP4) for an OSS README. The agent picks a format, writes a VHS tape script, mocks any path/secret/count leaks, renders the artifact, verifies it against duration / size / dimension budgets, and inserts it into the README with the right header HTML (title, tagline, demo, badges, nav). Methodology-driven — informed by the patterns gum / mods / vhs / oterm / lazygit all converge on."
metadata:
  author: letsbe10x
  version: "0.1.0"
  tags: [readme, demo, gif, vhs, oss, devrel, brand, launch]
lifecycle: published
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - make a demo gif for the readme
  - add a demo gif to the readme
  - create a readme demo
  - record a demo for this repo
  - write a vhs tape for this project
  - make this readme look like supabase / cal.com / gum
  - the readme needs a hero demo
  - generate a launch-ready readme header
discovery_signals:
  keywords: [readme, gif, demo, vhs, tape, svg, screencast, hero, above-the-fold, oss, devrel, launch, badges, header]
  languages: [markdown, bash, shell, yaml]
  frameworks: [vhs, ttyd, ffmpeg, svg-term-cli]
  governance_impact:
    adds_mutation_policy: local_write
    requires_adapters: []
    installs_hooks: []
    extends_critical_paths: false
  min_context_readiness: 5
---

# lets-create-readme-gifs

## Overview

This skill produces the **above-the-fold demo** for an OSS README — the single
visual that telegraphs what the project does in under five seconds. The agent
follows a documented protocol to pick the right format (VHS-generated GIF,
animated SVG, hosted MP4, or static screenshot), write a deterministic source
script, mock anything in the recording that would leak a username / secret /
brittle count, render the artifact, verify it against size/duration/dimension
budgets, and wire it into the README with the right header HTML.

The patterns codify what consistently wins for OSS dev-tool READMEs across
the field (`gum`, `mods`, `vhs`, `oterm`, `lazygit`, `httpie`, `starship`,
`tRPC`, `aider`, `soft-serve`) — single-flow demos at 600–900px wide, 8–15s
loops, placed after the tagline and before the badges, with the source script
checked into the repo so the next person can regenerate the artifact in one
command.

## When to Use

- The repo's current README leads with a logo, a wall of badges, or a code
  block — and the project does not yet have enough brand recognition to skip
  the demo.
- The user says "make the README look like [Supabase / Cal.com / gum / etc.]"
  or "add a demo to the README."
- The repo is preparing for a Show HN / Launch Day / Product Hunt push and
  needs a header that telegraphs value in under five seconds.
- A pre-existing demo has gone stale (paths leaked, count outdated, branding
  changed) and needs to be re-recorded deterministically.

## When Not to Use

- The repo is a logo-recognized brand (Bun, Vite, React, LangChain) — a hero
  banner outperforms a demo at that scale.
- The project is a backend library with no terminal-visible action (e.g. a
  typed-config parser, a math primitive) — a code snippet is the better hero.
- The user wants a full marketing site, not a README header — that's a
  different skill (`lets-author-launch-page`, not this one).
- The target output is a long-form video (>30s) or a multi-scene tutorial —
  use a screen-recording tool and host on YouTube; this skill is the
  short-loop above-the-fold artifact only.

## Inputs and Outputs

### Inputs

| Input | Required | Source |
|---|---|---|
| Repo path | yes | Local path to the repo whose README is being decorated |
| Project name + tagline | yes | One short sentence the demo must reinforce |
| Killer demo idea | yes | The single 8–15s flow the GIF should show (one command, one outcome) |
| Format preference | optional | `vhs` (terminal), `svg` (terminal, crisper), `mp4` (UI app), `static` (no animation). Default: agent decides per `references/format-decision.md` |
| Mocking targets | optional | Any paths / counts / secrets / tokens that must not appear literally in the recording |

### Outputs

| Output | Location | Format |
|---|---|---|
| Source script | `<repo>/assets/demo.tape` (VHS) or `<repo>/assets/demo.svg.config` (svg-term) | Plain text, checked in |
| Rendered artifact | `<repo>/assets/demo.gif` or `<repo>/assets/demo.svg` or `<repo>/assets/demo.mp4` | Binary, checked in (if <2MB) or CDN-hosted |
| README header block | Top of `<repo>/README.md` | HTML — title, tagline, `<img>`, badges, nav |
| Verification script | `<repo>/scripts/verify-demo.sh` | Bash — asserts duration ≤ 20s, size ≤ 1MB, dims correct |

## Example

> User: "Add a demo GIF to skill-hub's README, like gum has."

1. Agent reads `references/format-decision.md`: skill-hub is a terminal-based
   install tool — VHS GIF is the right format.
2. Agent picks the killer demo: one `npx install` command, install output
   streams 12 skill lines, final caption tells the reader what to do next.
3. Agent identifies mocking targets per `references/mocking-techniques.md`:
   the install prints `/Users/<operator>/.cursor/skills/X` — operator's home
   will leak. Plan: VHS Hide/Show shim that defines an `npx` bash function
   printing the same line format rooted at `/Users/lets`.
4. Agent writes `assets/demo.tape` from the template, sized 1000×420, Menlo
   18pt, Dracula theme, bash shell.
5. Agent runs `vhs assets/demo.tape` → `assets/demo.gif` (~235KB, ~16s loop).
6. Agent verifies via `scripts/verify-demo.sh`: duration, size, dimensions
   all within budget. Frame-extracts at t=4s, t=10s, t=14s with ffmpeg to
   confirm install output and final caption rendered.
7. Agent inserts the header HTML block at the top of README.md per
   `assets/header-template.md`: centered title, italic tagline, the GIF at
   `width="900"`, four badges, nav row, horizontal rule, then existing body.

Result: README hero shows the install end-to-end in 16 seconds, no path leak,
no stale count, fully re-renderable by anyone with `vhs` installed.

## Steps

The full protocol lives in [`references/protocol.md`](references/protocol.md).
High-level:

1. **Confirm format.** VHS-GIF for terminal demos, animated SVG for crisper
   terminal demos with long looping content, hosted MP4 for product-UI demos,
   static screenshot only when none of the above apply. See
   [`references/format-decision.md`](references/format-decision.md).
2. **Identify the killer demo.** One concrete flow, not a feature tour. The
   single command + outcome that makes a reader say "I want this." Reject
   demos with more than one user-typed line that aren't intrinsically chained.
3. **Audit for leaks.** Anything in the recording that would embed
   per-machine state (home directory, hostname, env-specific paths), shift
   over time (counts, version numbers, dates), or expose secrets (tokens,
   keys, internal URLs). Plan mocks before recording. See
   [`references/mocking-techniques.md`](references/mocking-techniques.md).
4. **Write the source script.** Use the template in
   [`assets/template.tape`](assets/template.tape). Set bash shell, Menlo
   font, 1000×420 for terminal demos. See
   [`references/sizing-placement.md`](references/sizing-placement.md).
5. **Render.** `vhs assets/demo.tape` → `assets/demo.gif`. If render fails
   on parser errors, consult [`references/vhs-gotchas.md`](references/vhs-gotchas.md)
   — semicolons inside `Type` strings, escaped quotes, and shell-prompt
   continuation are the three usual culprits.
6. **Verify.** Run `scripts/verify-demo.sh` to check duration, size, and
   dimensions against budget. Frame-extract via `ffmpeg -vf "fps=1"` and
   inspect three frames (early, mid, late) to confirm content rendered. See
   [`references/verification.md`](references/verification.md).
7. **Wire into README.** Insert the header block from
   [`assets/header-template.md`](assets/header-template.md) at the top of
   the README — title, tagline, `<img>` at `width="900"`, four badges
   (license, stars, PRs welcome, supported-with), nav row, horizontal rule.
   Existing README body stays untouched below.
8. **Document regeneration.** The first line of the source script is a
   comment explaining how to re-render: `vhs assets/demo.tape`. Anyone
   updating the demo later doesn't have to reverse-engineer the setup.

## Outputs

The repo gains these files:

```
<repo>/
├── README.md                  # header block inserted at top; body unchanged
├── assets/
│   ├── demo.tape              # VHS source — durable, re-renderable
│   ├── demo.gif               # rendered artifact, in-repo if <2MB
│   └── header-template.md     # (optional) the HTML block for reference
└── scripts/
    └── verify-demo.sh         # asserts duration/size/dimension budget
```

## Anti-patterns

- **Recording your own real terminal session.** Fonts get fuzzy, cursor
  blinks, you can't update without re-recording. Use VHS (deterministic
  bytes-in → bytes-out) or animated SVG.
- **Feature-tour demos.** Showing five things in 30s means the viewer
  retains nothing. Pick the *single* moment that makes them say "I want this."
- **Leaving your home directory in the recording.** `/Users/anugeet/.cursor/...`
  in a public README is a privacy + professionalism leak. Mock it.
- **Hardcoding counts ("21 skills").** Counts go stale every time someone
  adds or removes one. Drop the number, or compute it dynamically from the
  install output.
- **Letting an install command write to the real filesystem during recording.**
  Use Hide/Show shims to mock the side-effect-bearing command. The recording
  is a *demo*, not a real install.
- **Full-bleed images.** Width=100% looks heavy and pushes value-prop text
  off-screen. 600–900px is the sweet spot. See sizing-placement.md.
- **Bare markdown image syntax (`![](demo.gif)`).** Renders oversized on
  desktop and overflows mobile. Always wrap in
  `<p align="center"><img width="900">`.
- **Skipping the source script.** Committing only the rendered GIF means the
  next person inherits a maintenance dead-end. Always check in the `.tape`.
- **Demo durations over 20 seconds.** Beyond ~15s it's a video, and videos
  belong on YouTube, not in the README's auto-play loop.
- **Recording the npm-fetch pause.** Cold-cache `npx` adds 2–5s of empty
  terminal. Either pre-warm the cache, shim the command, or trim the
  Sleep budget.

## Gating Contract

This skill is a **gate** for shipping a public README hero. When invoked:

- **Never commit a rendered artifact without its source script.** The .tape
  (or .svg config, or .mp4 source) goes in the same PR as the artifact.
- **Never leak operator-specific state.** Home dirs, hostnames, tokens,
  internal URLs — all must be mocked or redacted before recording.
- **Never claim a count that will drift.** No hardcoded skill counts, file
  counts, version numbers, or dates in the demo's typed lines.
- **Never ship a demo that fails `verify-demo.sh`.** Budget violations
  (>1MB, >20s, wrong dimensions) require either a fix or an explicit
  documented exception.

If any of the above can't be honored, stop and explain why.
