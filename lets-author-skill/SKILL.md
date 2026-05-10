---
name: lets-author-skill
description: "Use when creating, improving, or evaluating a skill — runs skill-forge authoring, bundle, dataset, benchmark, improve, and quality gates."
metadata:
  author: cogsmith-ai
  version: "1.2.0"
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
  keywords: [skill, authoring, scaffold, enhance, forge, bundle, benchmark, eval, dashboard, graders]
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

Create, improve, or evaluate a skill with a structured intake, bundle-local eval
contract, deterministic QA gates, and benchmark-backed quality evidence. This
skill uses the `forge` CLI to scaffold or enhance a skill, create its Skill
Bundle folder, generate starter datasets, run benchmarks, analyze results,
inspect local result evidence, and accept only reviewed quality summaries.

## When to Use

- You want to create a new skill with a high-quality intake card and responsibilities
- You want to enhance an existing skill with consistent metadata and sections
- You want to run deterministic quality gates (no LLM required) before opening a PR
- You want the skill to carry its eval contract, quality thresholds, and accepted evidence
- You want to improve the skill against a bundle benchmark suite
- You want local result browsing or event-aware graders for tool calls, action sequences, skill invocation, or prompt quality

## Steps

1. Confirm the local Forge environment before authoring or evaluating.

```bash
cd skill-forge
uv run forge doctor
uv run forge runtime list
```

2. Decide whether you are creating, enhancing, or evaluating an existing skill.
3. Run the authoring wizard (create) or the enhancer (enhance).

```bash
# Create a new skill (interactive)
uv run forge skill create

# Enhance an existing skill (interactive)
uv run forge skill enhance lets-your-skill

# Enhance without prompts (adds safe defaults; does not invent content)
uv run forge skill enhance lets-your-skill --non-interactive
```

4. Initialize or validate the Skill Bundle.

```bash
# Create .skill/ with manifest, evals, quality, and evidence folders
uv run forge bundle init ../skill-hub/lets-your-skill

# Validate bundle manifest, dataset references, quality paths, and hashes
uv run forge bundle validate ../skill-hub/lets-your-skill
```

5. Generate starter datasets, then curate them before treating them as evidence.

```bash
uv run forge dataset generate ../skill-hub/lets-your-skill --suite trigger
uv run forge dataset generate ../skill-hub/lets-your-skill --suite capability
uv run forge dataset generate ../skill-hub/lets-your-skill --suite regression
```

Generated datasets are scaffolding. Replace generic prompts and expected terms
with skill-specific trigger, capability, and regression cases before accepting a
benchmark as quality evidence.

6. Add stronger verifiers when plain text checks do not prove the behavior.

Use deterministic graders first. Add event-aware assertions when the runtime
emits structured evidence, and use `prompt_judge` only for quality dimensions
that cannot be expressed deterministically.

```json
{
  "verifier": {
    "type": "prompt_judge",
    "criteria": "The output gives precise, actionable skill-authoring guidance.",
    "threshold": 0.8,
    "advisory": false
  },
  "behavior_assertions": [
    {"type": "must_call_tool", "tool": "ReadFile"},
    {"type": "action_sequence", "sequence": ["ReadFile", "ApplyPatch"]},
    {"type": "skill_invocation", "skill": "lets-author-skill"}
  ]
}
```

7. Validate the result and iterate until the gates pass.

```bash
# Run the deterministic PR gate
uv run forge check ../skill-hub/lets-your-skill --baselines-dir ../skill-hub/.forge/baselines
```

8. Run the eval loop when the skill needs measured quality evidence.

```bash
# Run bundle-local benchmark suites
uv run forge bench ../skill-hub/lets-your-skill --suite smoke
uv run forge bench ../skill-hub/lets-your-skill --suite capability

# Analyze the latest benchmark artifact before accepting it
uv run forge result analyze .forge/benchmarks/lets-your-skill.json

# Browse benchmark artifacts, run records, and bundle quality locally
uv run forge serve --skills-dir ../skill-hub

# Improve against the capability suite when the result says improve
uv run forge improve ../skill-hub/lets-your-skill --suite capability --no-confirm

# Accept only reviewed benchmark results
uv run forge bundle accept-run ../skill-hub/lets-your-skill \
  .forge/benchmarks/lets-your-skill.json \
  --reason "accepted curated capability baseline"

# Produce a reviewer-friendly report
uv run forge bundle report ../skill-hub/lets-your-skill
```

9. If the skill is ready to ship:
   - ensure `lifecycle: published` and `metadata.version` are set
   - add a Makefile install target
   - add it to a bundle only if it is intended to be installed by default

## Outputs

### Output contract

- A new or updated skill directory under the skills repository:
  - a `SKILL.md` file under the skill directory (the authored skill)
- A Skill Bundle folder containing:
  - a manifest
  - generated and curated eval datasets
  - quality thresholds and latest accepted summary
  - accepted run references
- A deterministic QA result from `forge check`:
  - a passing terminal report (human-readable)
  - an updated baseline JSON file under the skills baseline store (when the score improves)
- Optional benchmark evidence from `forge bench`, `forge result analyze`, and `forge bundle report`
- Optional local review evidence from `forge serve` when benchmark artifacts or run records need inspection

## Anti-patterns

- **Skipping forge check** — leads to broken links/sections and failed PR gates later.
- **Bulk-accepting generated datasets** — generated evals are scaffolding, not proof.
- **Accepting raw benchmark output without review** — use `forge result analyze` and record a reason with `forge bundle accept-run`.
- **Using prompt judges for deterministic facts** — prefer text, regex, file, JSON schema, diff, program, or event assertions before `prompt_judge`.
- **Publishing without version** — published skills must set `metadata.version`.
- **Over-scoping** — keep the skill narrow; split distinct workflows into multiple skills.

## Error handling

- If `forge` is not available, install skill-forge in your workspace and retry from the `skill-forge` repo using `uv`.
- If `forge check` fails HG1 (missing paths), remove invalid links or add the referenced files before continuing.
- If `forge check` fails HG2 (placeholders), replace placeholders with concrete, non-placeholder text before retrying.
- If `forge bench --suite` cannot resolve a suite, run `forge bundle validate` and confirm the bundle manifest points at the expected dataset.
- If benchmark results are flaky, inspect `flakiness_rate`, failure tags, and changed-file evidence before improving or accepting the run.
- If event-aware assertions report insufficient evidence, keep the assertion only for runtimes that emit structured events or fall back to deterministic output/file checks.
- If `prompt_judge` fails because `ANTHROPIC_API_KEY` is unavailable, either provide the key or mark the verifier advisory only when the benchmark should not block on judge availability.
