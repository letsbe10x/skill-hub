---
name: lets-onboard-repo
description: "Use when you need to understand an unfamiliar repo's structure, commands, and context. Runs onboard_repo goal to discover and write context artifacts."
metadata:
  author: cogsmith-ai
  version: "1.0.0"
  tags: [onboarding, bootstrap, context]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-onboard-repo/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - onboard me
  - I'm new to this repo
  - set up this repo
goals:
  - onboard_repo
outcome_runtime:
  open_agency_zones:
    - onboarding_path_selection
    - repo_context_explanation
  governed_action_zones:
    - onboarding_truth_claims
  allowed_moves:
    - request_missing_context
    - route_to_bootstrap_when_context_stale
  hard_limits:
    - do_not_invent_repo_facts
    - do_not_hide_context_gaps
  required_decision_frames:
    - onboarding_readiness_decision
  validation_gates:
    - context_freshness_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `lets` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

## Overview

`lets-onboard-repo` is the recommended first step for any developer who is new to a repository. It
discovers and synthesizes the repo's context, then presents the results in a walkthrough format
tailored for a first-time reader: tech stack, critical paths, governance posture, and a "top 3
things you need to know" summary.

The skill ends with a personalised recommendation for the next skill to run based on what was
discovered — for example, `lets-triage-issue` if there are recent failures, or `lets-audit-repo`
if governance gaps were detected.

## When to Use

- A developer is joining a project and needs to get up to speed quickly.
- You are exploring an unfamiliar repository and want a structured orientation.
- You want to verify that the repo's context artifacts accurately reflect the current state.
- You are setting up a new repo for the first time.

## When Not to Use

- The repo context is already fresh and no re-onboarding is needed — skip this and use `lets-triage-issue` or `lets-develop-feature` directly.
- You only need to check CI status, not understand the full repo structure.

## Inputs

- Input: Repo root path (required)

## Steps

1. Scan the repository to discover and synthesize context: read README, AGENTS.md, CLAUDE.md,
   CI configuration, Makefile or build scripts, and key source files.
2. Present the discovered context in three parts: **Tech stack** (languages, frameworks,
   build system), **Critical paths** (key modules and their dependency directions), and
   **Governance posture** (policy compliance status, if determinable).
3. Highlight the top 3 things the developer needs to know: the single most important architectural
   invariant, the most active area of recent change, and the biggest current risk or open issue.
4. Suggest the next skill to run based on context: `lets-triage-issue` if recent runs have failed,
   `lets-audit-repo` if governance gaps were found, or `lets-bootstrap-agents-md` if AGENTS.md
   is absent. Use the decision table in
   [references/next-skill-decision-table.md](references/next-skill-decision-table.md).

## Example

```bash
# Inspect the repo structure
ls -la
cat README.md
# Check CI configuration
ls .github/workflows/
# Look for context artifacts
ls AGENTS.md CLAUDE.md service.yaml 2>/dev/null
```

## Anti-patterns

- **Reporting onboarding complete without reading key files** — discovery must actually happen; assumptions are not evidence.
- **Assuming repo structure matches the detected stack** — verify by reading actual files.
- **Inventing facts about the repo** — every claim must come from a file you read; mark anything inferred as inferred.

## Outputs

A personalised repo orientation containing:

- Output: **Tech stack summary** — languages, frameworks, build tools, and test infrastructure.
- Output: **Critical paths** — key modules with their layer, owner, and dependency direction.
- Output: **Governance posture** — pass/fail for configured policies, with a one-line status.
- Output: **Top 3 things to know** — the most important invariant, hottest change area, and biggest risk.
- Output: **Recommended next skill** — one suggested follow-up skill with a one-sentence rationale.

Done when: discovery is complete, all three context sections are presented, and a next-skill recommendation is made.

## Error handling

- If the repo has no AGENTS.md or README, fallback to manual discovery: scan source directories, check CI config, look for test commands in Makefile or package.json.
- If no critical paths are detectable, confirm with the user before marking complete: "No critical paths detected — should I proceed anyway? (y/n)"
- If context artifacts appear stale (last modified more than 30 days ago), flag this to the user and recommend running `lets-bootstrap-repo` to refresh them.
