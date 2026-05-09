---
name: lets-author-skill
description: "Use when creating or improving a skill — runs the skill-forge authoring wizard, enhances existing skills, and enforces forge check gates."
metadata:
  author: cogsmith-ai
  version: "1.0.0"
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
discovery_signals:
  keywords: [skill, authoring, scaffold, enhance, forge]
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

Create or improve a skill with a structured intake and deterministic QA gates.
This skill uses the `forge` CLI to scaffold a new skill, enhance an existing one, and
validate it with `forge check` before you add it to any bundle or ship it.

## When to Use

- You want to create a new skill with a high-quality intake card and responsibilities
- You want to enhance an existing skill with consistent metadata and sections
- You want to run deterministic quality gates (no LLM required) before opening a PR

## Steps

1. Decide whether you are creating a new skill or enhancing an existing skill.
2. Run the authoring wizard (create) or the enhancer (enhance).

```bash
# Create a new skill (interactive)
cd skill-forge
uv run forge skill create

# Enhance an existing skill (interactive)
uv run forge skill enhance lets-your-skill

# Enhance without prompts (adds safe defaults; does not invent content)
uv run forge skill enhance lets-your-skill --non-interactive
```

3. Validate the result and iterate until the gates pass.

```bash
# Run the deterministic PR gate
uv run forge check ../skills/lets-your-skill/SKILL.md --baselines-dir ../skills/.forge/baselines
```

4. If the skill is ready to ship:
   - ensure `lifecycle: published` and `metadata.version` are set
   - add a Makefile install target
   - add it to a bundle only if it is intended to be installed by default

## Outputs

### Output contract

- A new or updated skill directory under the skills repository:
  - a `SKILL.md` file under the skill directory (the authored skill)
- A deterministic QA result from `forge check`:
  - a passing terminal report (human-readable)
  - an updated baseline JSON file under the skills baseline store (when the score improves)

## Anti-patterns

- **Skipping forge check** — leads to broken links/sections and failed PR gates later.
- **Publishing without version** — published skills must set `metadata.version`.
- **Over-scoping** — keep the skill narrow; split distinct workflows into multiple skills.

## Error handling

- If `forge` is not available, install skill-forge in your workspace and retry from the `skill-forge` repo using `uv`.
- If `forge check` fails HG1 (missing paths), remove invalid links or add the referenced files before continuing.
- If `forge check` fails HG2 (placeholders), replace placeholders with concrete, non-placeholder text before retrying.
