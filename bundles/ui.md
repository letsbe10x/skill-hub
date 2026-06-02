# UI Bundle

Build and verify UIs with product judgment, evidence-based capture, and the
verification gate chain. Pairs with the `engineering` bundle for the
implementation + review + verify loop.

## Install

```bash
npx github:letsbe10x/skill-hub install ui --agent cursor
```

Change `--agent cursor` to `--agent claude-code`, `--agent codex`, or
`--agent copilot`.

## Included workflows

| Workflow | Purpose |
|----------|---------|
| `lets-build-ui` | Audit flows + UX architecture, lock direction, define tokens, execute via gated work packages, verify with evidence |
| `lets-browser-evidence` | Repeatable browser evidence via Microsoft Webwright — screenshots, journey scripts, rerun logs |

## Typical flow

```
lets-build-ui → (capture evidence via lets-browser-evidence) → lets-review-code → lets-verify-change
```

## Setup note for `lets-browser-evidence`

The skill ships with `scripts/setup.sh` that installs Microsoft Webwright + a
headless Chromium. Run it once after install:

```bash
bash ~/.cursor/skills/lets-browser-evidence/scripts/setup.sh
```

(Substitute your agent's skills directory.)

For CI / headless: set `LETS_SKIP_WEBWRIGHT_SETUP=1` to skip cloning Webwright
and downloading Chromium.

## Pairs well with

- `engineering` — `lets-build-ui` chains with `lets-develop-feature`,
  `lets-review-code`, `lets-verify-change`, `lets-verify-ready`.
- `research` — `lets-research-ux-walkthrough` (in skill-hub's research bundle)
  uses `lets-browser-evidence` for repro captures.
