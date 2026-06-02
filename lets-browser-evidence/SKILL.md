---
name: lets-browser-evidence
description: "Use when you need repeatable browser evidence — screenshots, journey scripts, and rerun logs — via Microsoft Webwright or repo Playwright. Installs the Webwright engine on skill setup. Delegate from lets-build-ui, lets-research-ux-walkthrough, and verify flows."
metadata:
  author: letsbe10x
  version: "0.2.2"
  tags: [browser, webwright, playwright, evidence, automation, ui, ux, verification]
lifecycle: published
source: https://github.com/letsbe10x/skill-hub/blob/main/lets-browser-evidence/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
  requirements:
    - Python 3.10+ (installed automatically by make lets-browser-evidence when possible)
    - Bash for setup script; optional host Webwright plugin on Claude Code or Codex
capabilities:
  surfaces: [cli]
  resources: [file_system, network]
  handoffs:
    subagent: false  # noqa-capability: handoffs.subagent: no Task/subagent dispatch in this skill
    sub_runs: false
    resume: false  # noqa-capability: handoffs.resume: YAML field name only, not a resume handoff
  deployment:
    cloud_only: false
    air_gap_ok: false
capabilities_evidence:
  - capability: file_system
    citation: "references/workspace-contract.md:7-14"
  - capability: network
    citation: "scripts/setup_webwright.sh: git clone and playwright install chromium"
  - capability: surfaces.cli
    citation: "SKILL.md:112-118"
triggers:
  - capture browser evidence
  - screenshot the app at breakpoints
  - craft browser smoke script
  - rerun ui journey in the browser
  - webwright audit
  - playwright evidence for the ship gate
not-for:
  - Backend-only changes with no live UI
  - Replacing a team's checked-in Playwright CI suite without review
  - Unauthorized scraping of gated or production user data
---

## Overview

`lets-browser-evidence` is the **shared browser-evidence layer** for letsbe10x. It installs the [Microsoft Webwright](https://github.com/microsoft/Webwright) engine, records where artifacts live, and standardizes prompts and security for any program that needs **rerunnable** browser proof.

**Consumers** (invoke this skill, then apply domain prompts):

| Program skill | Typical use |
|---------------|-------------|
| `lets-build-ui` | Breakpoint audit, journey smoke, ship regression |
| `lets-research-ux-walkthrough` | Step-by-step friction capture with screenshots |
| `lets-verify-change` | Run again the crafted script or repo e2e listed in the packet |

This skill does **not** own UI direction, tokens, or friction taxonomy — only browser capture and script artifacts.

## Install and setup (automatic, every install path)

Install via the standard skill-hub installer — the skill directory ships
with [`scripts/setup.sh`](scripts/setup.sh) which the user runs once after
install:

```bash
npx github:letsbe10x/skill-hub install lets-browser-evidence --agent cursor
bash ~/.cursor/skills/lets-browser-evidence/scripts/setup.sh
```

(Adjust `~/.cursor/skills/` to your agent's skills directory: `~/.claude/skills/`,
`~/.codex/skills/`, or `~/.github/skills/`.)

**CI / headless:** set `LETS_SKIP_WEBWRIGHT_SETUP=1` before running the
setup script to skip cloning Webwright and downloading Chromium (plugin
install still attempted when `claude` is on PATH).

Setup is idempotent and includes:

1. **Engine** — clone Microsoft Webwright at `LETS_WEBWRIGHT_GIT_REF` (default `main`), `pip install -e .` into the active `python3`, `playwright install chromium`, state file under letsbe10x config (see `setup_webwright.sh`).
2. **Claude Code plugin** — when `claude` CLI is on PATH: marketplace add + `webwright@webwright` install (restart Claude Code after first install).

Skip engine setup in CI: `LETS_SKIP_WEBWRIGHT_SETUP=1`.

Verify: `make doctor-browser-evidence` or [`scripts/doctor_webwright.sh`](scripts/doctor_webwright.sh).

**Codex:** install the Webwright plugin from `/plugins` after engine setup (not automated by `claude` CLI).

**Engineering bundle:** `lets-browser-evidence` ships in the skill-hub
engineering bundle (`npx github:letsbe10x/skill-hub install engineering`).

## When to use

- A workflow needs **live** UI proof (URL or localhost), not mocks alone.
- You need the same journey rerun after a change (crafted `final_script.py` or repo e2e).
- Multiple breakpoints or states must be captured consistently.

## When not to use

- No browser surface (API-only, CLI-only work).
- The repo already has e2e coverage and you only need `pnpm exec playwright test` — run that instead of parallel agent harnesses.

## Steps

1. Announce: “Using `lets-browser-evidence`.”
2. Confirm setup: if `webwright-ready.json` is missing, tell the user to run `make lets-browser-evidence` (or run the setup script once).
3. Fill [`references/browser_evidence_brief.yml`](references/browser_evidence_brief.yml) (program, URL, auth, constraints).
4. Choose a surface (first match wins) — see [`references/surface-priority.md`](references/surface-priority.md).
5. Run the matching prompt from [`references/domain-prompts.md`](references/domain-prompts.md).
6. Follow [`references/workspace-contract.md`](references/workspace-contract.md); apply [`references/security.md`](references/security.md).
7. Attach artifact paths to the calling program’s packet (UI execution packet, walkthrough report, verify ledger).
8. **Promotion:** human-review `final_script.py` before merging into the app repo’s e2e tree.

## Choose a surface

Documented in [`references/surface-priority.md`](references/surface-priority.md):

1. Webwright host plugin (`/webwright:run`, `/webwright:craft`)
2. Webwright CLI (`python3 -m webwright.run.cli` from installed engine)
3. Repo Playwright e2e
4. IDE browser MCP (exploration only unless followed by a rerunnable script)

## Commands

```bash
# Install skill + Webwright engine (from skills/ repo root)
make lets-browser-evidence

# Readiness
make doctor-browser-evidence

# Standalone Webwright CLI (needs provider API keys in env — see Webwright README)  # noqa-capability: resources.secrets: keys stay in user env, never in artifacts
# Run from the Webwright clone created by setup_webwright.sh (see webwright-ready.json for home path)
python3 -m webwright.run.cli \
  -c base.yaml -c model_openai.yaml \
  -t "Audit http://localhost:3000 at widths 375 and 768" \
  --start-url http://localhost:3000 \
  --task-id browser-evidence-demo \
  -o outputs/browser-evidence-demo
```

Plugin slash examples (Claude Code / Codex with webwright@webwright):

```text
/webwright:run walk through signup at http://localhost:3000 per browser evidence brief
/webwright:craft reusable smoke for onboarding journey
```

## Output contract

Done when all of the following are satisfied:

| Artifact | Required | Location / notes |
|----------|----------|------------------|
| `browser_evidence_brief.yml` | yes | Filled under `references/` or copied into the calling program packet |
| `plan.md` | yes for Webwright workspace runs | Under `WORKSPACE_DIR` per workspace contract |
| Screenshots | yes for audit/walkthrough | Under each run folder per [`workspace-contract.md`](references/workspace-contract.md); paths recorded in brief |
| `final_script_log.txt` | yes when a crafted script ran | Last line must include success datum |
| `final_script.py` | optional until promotion | Human-reviewed before merging into app e2e |
| Repo Playwright pointer | alternative | CI URL + spec path when repo e2e used instead |

## Outputs

- Filled `references/browser_evidence_brief.yml`
- Webwright workspace: `plan.md`, run screenshots, `final_script_log.txt`, optional `final_script.py`
- Or: pointer to repo Playwright test run and CI URL

## Anti-patterns

- **Ephemeral clicks only** — no `plan.md` or rerun command for the ship gate.
- **Shipping agent scripts unreviewed** — always review before adding to app e2e.
- **Duplicating Microsoft’s skill** — install their plugin; this skill is letsbe10x policy + setup only.
- **Production walkthroughs** without explicit approval.

## Error handling

- Setup fails (no Python 3.10, pip error): report stderr; suggest `make lets-browser-evidence` after fixing Python.
- Plugin unavailable: use workspace contract with Bash + Playwright from the installed engine (see setup script), or repo e2e.
- Auth blocked: stop and request test credentials; do not bypass.

## Related skills

- UI design and tokens → `lets-build-ui`
- Friction taxonomy and report → `lets-research-ux-walkthrough`
- Mechanical verify → `lets-verify-change`, `lets-verify-ready`
