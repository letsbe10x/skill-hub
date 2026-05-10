---
name: lets-author-skill
description: "Use when creating, improving, or evaluating a skill — runs a structured intake, finds the right shape, drafts a thin orchestrator, wires repo surfaces, and runs forge quality gates."
metadata:
  author: cogsmith-ai
  version: "2.0.0"
  tags: [skills, authoring, quality]
lifecycle: published
source: https://github.com/letsbe10x/skill-hub/blob/main/lets-author-skill/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - create a new skill
  - write a new skill
  - author a skill
  - improve a skill
  - enhance a skill
  - evaluate a skill
  - forge a skill
discovery_signals:
  keywords: [skill, authoring, scaffold, enhance, forge, bundle, benchmark, eval, shapes, blueprint]
  languages: [markdown, yaml]
  frameworks: []
  adapters: []
  route_families: []
  governance_impact:
    adds_mutation_policy: read_only
    requires_adapters: []
    installs_hooks: []
    extends_critical_paths: false
  min_context_readiness: 10
---

# lets-author-skill

## Overview

Create, improve, or evaluate a skill in skill-hub using a structured loop: intake → classify → analog inspection → shape selection → draft → repo wiring → quality gates → simplicity check → result summary.

This skill wraps the forge CLI workflow with the authoring judgment layer that forge alone does not provide — knowing what to build, how to structure it, and when it is genuinely done.

## When to Use

- You want to create a new skill from scratch with a clear boundary and quality evidence
- You want to improve an existing skill — tighten its boundary, add references, or fix gate failures
- You want to evaluate whether a skill is ready to ship (structural gate + bench evidence)
- You want to pick the right shape before drafting to avoid structural rework later
- You need to decide whether to research first or draft directly

## Read These References First

- `references/authoring-guide.md` — the full authoring loop with all steps and rules
- `references/skill-shapes.md` — choose the nearest shape before drafting (workflow / tool wrapper / doc synthesizer / meta)
- `references/skill-contract.md` — canonical layout, frontmatter rules, and contribution contract for skill-hub
- `references/quality-checklist.md` — trigger fixture requirements, forge gate commands, done definition
- `references/evaluation-gate.md` — when to stop at packaging gates vs when to add a boundary dataset
- `references/discovery-mode.md` — when to switch into research mode before touching skill files
- `references/simplicity-check.md` — pressure-test whether the skill is overbuilt before adding files or phases

## Steps

1. Present a short intake card. Clarify one blocking question at a time.

   - new skill vs update
   - target skill name and nearest neighbors (routing boundary)
   - mutation posture (read-only / additive / writes to external state)
   - expected artifact outputs and where they live
   - one blocking question if anything is unclear

2. Decide the mode: brand-new skill, update to an existing skill, research first, or evaluation only.

   If the request involves brainstorming, landscape research, or "what should exist" rather than "write the skill now", switch to discovery mode before drafting. See `references/discovery-mode.md`.

   If the skill already exists, read its current `SKILL.md`, trigger fixture, and any `references/` before changing structure.

3. Inspect 2–3 local analogs. Use `references/skill-shapes.md` to pick the nearest shape — by shape, not by keyword. Borrow from the closest skill first.

4. Confirm the forge environment is ready.

   ```bash
   cd skill-forge
   uv run forge doctor
   uv run forge runtime list
   ```

5. Scaffold or enhance the skill.

   ```bash
   # create a new skill (interactive)
   uv run forge skill create

   # enhance an existing skill (adds safe defaults; does not invent content)
   uv run forge skill enhance lets-{name}

   # non-interactive mode
   uv run forge skill enhance lets-{name} --non-interactive
   ```

6. Draft `SKILL.md` as a thin orchestrator. See `references/authoring-guide.md` §4 for the drafting rules. Key points:

   - `name` must match the folder name exactly
   - `description` explains both what and when
   - body covers workflow stages, routing decisions, boundaries
   - deep procedures go into `references/`, not inline
   - use `{PLACEHOLDER}` tokens, never angle-bracket style

   Run the simplicity pressure test before expanding. See `references/simplicity-check.md`.

7. Initialize or validate the skill bundle.

   ```bash
   uv run forge bundle init ../skill-hub/lets-{name}
   uv run forge bundle validate ../skill-hub/lets-{name}
   ```

8. Generate starter datasets, then curate before treating as evidence.

   ```bash
   uv run forge dataset generate ../skill-hub/lets-{name} --suite trigger
   uv run forge dataset generate ../skill-hub/lets-{name} --suite capability
   uv run forge dataset generate ../skill-hub/lets-{name} --suite regression
   ```

   Generated datasets are scaffolding. Replace generic prompts with skill-specific trigger, capability, and regression cases before accepting a benchmark as quality evidence.

9. Wire repo surfaces. Update in the same change when they exist:

   - `Makefile` — add install target
   - `README.md` — add catalog row
   - `tests/skill-triggers/lets-{name}.json` — trigger fixture

   See `references/skill-contract.md` for the full surface list.

10. Run quality gates. See `references/quality-checklist.md` for the full gate list.

    ```bash
    # structural gate — required before PR
    uv run forge check ../skill-hub/lets-{name} --baselines-dir ../skill-hub/.forge/baselines

    # smoke bench
    uv run forge bench ../skill-hub/lets-{name} --suite smoke
    ```

11. Run the full capability bench when measured quality evidence is needed.

    ```bash
    uv run forge bench ../skill-hub/lets-{name} --suite capability

    # analyze before accepting
    uv run forge result analyze .forge/benchmarks/lets-{name}.json

    # browse locally
    uv run forge serve --skills-dir ../skill-hub

    # improve against the capability suite when the result says improve
    uv run forge improve ../skill-hub/lets-{name} --suite capability --no-confirm

    # accept only reviewed results
    uv run forge bundle accept-run ../skill-hub/lets-{name} \
      .forge/benchmarks/lets-{name}.json \
      --reason "accepted curated capability baseline"

    uv run forge bundle report ../skill-hub/lets-{name}
    ```

12. Run the simplicity check. See `references/simplicity-check.md`. Cut before you add.

13. Present the result:
    - what was added or changed
    - whether discovery mode ran and what it concluded
    - why this shape was chosen
    - which repo surfaces were updated
    - what validation ran
    - any remaining routing or boundary risks
    - one explicit challenge statement: why this skill boundary could still be wrong

## Outputs

- A new or updated `SKILL.md` under `lets-{name}/`
- A skill bundle folder with manifest, curated eval datasets, and accepted quality evidence
- A passing `forge check` result with updated baseline
- Updated `Makefile`, `README.md`, and trigger fixture
- Optional bench evidence from `forge bench` and `forge bundle report`

## Anti-patterns

- **Skipping the intake card** — leads to boundary drift and structural rework
- **Drafting before picking a shape** — mixing patterns produces unmaintainable skills
- **Skipping forge check** — broken frontmatter and sections cause failed PR gates
- **Bulk-accepting generated datasets** — generated evals are scaffolding, not proof
- **Accepting raw benchmark output without review** — use `forge result analyze` first
- **Using prompt judges for deterministic facts** — prefer text, regex, file, or event assertions before `prompt_judge`
- **Publishing without version** — published skills must set `metadata.version`
- **Overbuilding** — run `references/simplicity-check.md` before adding phases, scripts, or references

## Error Handling

- If `forge` is not available, install skill-forge in your workspace and retry using `uv`
- If `forge check` fails HG1 (missing paths), remove invalid links or add the referenced files before continuing
- If `forge check` fails HG2 (placeholders), replace all `{PLACEHOLDER}` tokens with concrete content
- If `forge bench --suite` cannot resolve a suite, run `forge bundle validate` and confirm the manifest points at the expected dataset
- If benchmark results are flaky, inspect `flakiness_rate` and failure tags before improving or accepting the run
- If `prompt_judge` fails because `ANTHROPIC_API_KEY` is unavailable, mark the verifier advisory-only or provide the key
