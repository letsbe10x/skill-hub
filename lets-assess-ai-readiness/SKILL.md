---
name: lets-assess-ai-readiness
description: "Holistic AI readiness assessment for any repository. Evaluates 8 pillars (feedback velocity, error clarity, determinism, change safety, context discoverability, pattern consistency, recovery cost, environment independence) across 6 maturity levels (L0-L5). Produces a hybrid report with deterministic gates, heuristic signals, blockers-to-next-level, and optional scaffolding plans."
metadata:
  author: cogsmith-ai
  version: "1.0.0"
  tags: [readiness, audit, ai-readiness, maturity, assessment]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-assess-ai-readiness/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - assess AI readiness
  - AI readiness check
  - how AI-ready is this repo
  - readiness assessment
  - maturity level check
  - audit this repo
  - is this repo ready for AI
outcome_runtime:
  open_agency_zones:
    - readiness_assessment_strategy
    - pillar_scoring
    - heuristic_evaluation
    - scaffold_plan_generation
    - advisory_analysis
  governed_action_zones:
    - readiness_level_claims
    - scaffold_mutation
  allowed_moves:
    - challenge_readiness_claim
    - downgrade_confidence
    - flag_heuristic_as_uncertain
    - recommend_scaffold_priority
    - skip_inaccessible_pillar
  hard_limits:
    - do_not_fabricate_evidence
    - do_not_inflate_maturity_level
    - do_not_scaffold_without_plan_approval
    - do_not_treat_advisory_as_gating
    - do_not_run_destructive_commands
  required_decision_frames:
    - assessment_scope_decision
    - scaffold_depth_decision
  validation_gates:
    - evidence_gate
    - deterministic_check_gate
    - level_gating_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - scaffold_apply_request
    - low_confidence_pillar
    - external_access_required
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `lets` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

# lets-assess-ai-readiness

Holistic AI readiness assessment for any repository. Measures whether an AI coding agent can work effectively, safely, and autonomously — not just whether documentation exists. Produces a maturity level (L0-L5), blockers to the next level, and optional scaffold plans. Operational detail in references — this file is the contract.

---

## Pipeline

```
Phase 1: Detect      -> Identify repo shape, ecosystem, existing context
Phase 2: Assess      -> Run deterministic checks + heuristic signals per pillar
Phase 3: Score       -> Compute pillar scores, derive overall level via gating
Phase 4: Report      -> Present hybrid report (levels, blockers, advisory)
Phase 5: Plan        -> Optional: generate scaffold plan to reach target level
```

---

## When to Use

- First time assessing a repo for AI-assisted development
- After bootstrap to measure progress
- Periodic health check on AI readiness (quarterly)
- Before onboarding a new team to agentic workflows
- To compare readiness across repos in a portfolio

## When Not to Use

- You only need to capture service truth (use `lets-bootstrap-repo`)
- You only need to generate AGENTS.md (use `lets-bootstrap-agents-md`)
- You want to audit governance compliance only (this does that AND more)

---

## Core Model

### The Utility Principle

This assessment measures **utility**, not **presence**. The question is never "does X exist?" — it's "can an agent use X to make correct decisions autonomously?"

A README that exists but contains no runnable commands scores the same as no README for the feedback-velocity pillar.

### Hybrid Assessment

Two independent axes:

| Axis | What it measures | Source |
|------|-----------------|--------|
| **Context readiness** | Verified repo-owned truth artifacts | `lets-bootstrap-repo` output |
| **Agent readiness** | Can an agent iterate safely and effectively? | 8-pillar rubric (this skill) |

Overall level = min(context_max_level, agent_level). Neither alone is sufficient.

### Level Semantics

| Level | Label | What it means for an agent |
|-------|-------|---------------------------|
| **L0** | Unready | Agent cannot operate without continuous human guidance |
| **L1** | Functional | Agent can build and run something, but guesses at patterns and scope |
| **L2** | Documented | Agent has explicit guidance on what to do and what not to touch |
| **L3** | Standardized | Agent can validate changes quickly, follow enforced patterns, operate within clear boundaries |
| **L4** | Optimized | Agent gets fast feedback, errors are unambiguous, changes are safely scoped and reversible |
| **L5** | Autonomous | Agent can operate with minimal supervision across the full development cycle |

### Gating Rules (not just scoring)

To claim Level L, ALL required checks at min_level <= L must PASS. A repo with 90/100 score but a failing L2 required gate stays at L1.

---

## The 8 Pillars

| # | Pillar | Core question |
|---|--------|---------------|
| 1 | **Feedback Velocity** | Can an agent validate a change in under 60 seconds? |
| 2 | **Error Signal Clarity** | When something fails, can an agent diagnose WHY? |
| 3 | **Determinism** | Given identical inputs, does the repo produce identical outputs? |
| 4 | **Change Safety** | Can an agent predict the blast radius of a change? |
| 5 | **Context Discoverability** | Can an agent find what it needs without asking a human? |
| 6 | **Pattern Consistency** | Is there exactly one obvious way to do each thing? |
| 7 | **Recovery Cost** | How expensive is a mistake to undo? |
| 8 | **Environment Independence** | Can an agent operate without external state it cannot control? |

See [references/PILLARS.md](references/PILLARS.md) for detailed per-pillar level criteria, checks, and evidence requirements.

---

## Phase Contracts (Summary)

### Phase 1 — Detection

Identify:
- Ecosystem (language, package manager, build tool, test framework)
- Repo shape (monorepo, library, service, tool)
- Existing context artifacts (AGENTS.md, service.yaml, coding-rules.md)
- CI system and configuration

Present an intake card:
```
Repo: {name}
Ecosystem: {language} / {package_manager} / {test_framework}
Shape: {monorepo|service|library|tool}
Existing context: {list of present artifacts}
CI: {system} ({status})
```

### Phase 2 — Assessment

For each pillar, run:
1. **Deterministic checks** — file presence, config parsing, structural analysis
2. **Heuristic signals** — pattern sampling, convention inference, quality estimation

Each check produces: `status` (pass/fail/unknown), `evidence` (what was observed), `confidence` (0.0-1.0 for heuristics).

See [references/RUBRIC.md](references/RUBRIC.md) for the full check catalog.

### Phase 3 — Scoring

- Per-pillar: sum of weighted check scores
- Per-pillar level: highest level where all required gates pass
- Overall agent level: min(pillar levels) across required pillars
- Overall level: min(context_max_level, agent_level)

### Phase 4 — Report

Present:
1. Overall level + label
2. Pillar scorecard (score + level per pillar)
3. Blockers to next level (the cheapest fixes for the biggest level gain)
4. Advisory notes (heuristic findings that are non-gating)

See [references/REPORT.md](references/REPORT.md) for report structure and format.

### Phase 5 — Scaffold Plan (optional)

Ask: "Would you like a plan to reach {next_level}?"

| Choice | Action |
|--------|--------|
| **Just assess** (default) | Stop at report |
| **Plan to next level** | Generate scaffold plan for blockers |
| **Plan to L3** | Generate scaffold plan to reach L3 (common target) |
| **Apply** | Execute scaffold plan (requires confirmation) |

See [references/SCAFFOLD.md](references/SCAFFOLD.md) for scaffold templates per level.

---

## Error Handling

- If a pillar cannot be assessed (e.g., no CI access): mark as `unknown`, note in report, do not gate overall level on unknowns unless check is required
- If heuristic confidence is below 0.5: flag as uncertain, exclude from gating, include as advisory only
- If ecosystem is unrecognized: fall back to generic structural checks, note reduced coverage
- If repo is a monorepo: assess each sub-project independently, report aggregate

---

## Anti-patterns

- **Treating file presence as readiness** — a README without commands is not feedback velocity
- **Inflating levels from advisory signals** — only deterministic checks gate levels
- **Assessing without running** — never claim "tests pass" without observing a run or CI evidence
- **Language-specific assumptions** — checks must work for any ecosystem
- **Ignoring the weakest pillar** — overall readiness is limited by the weakest critical pillar
- **Scaffolding without assessment** — always assess first, scaffold from the gap report
- **Treating all pillars equally** — weight by the repo's primary agent use case

---

## Outputs

- Output: Intake card with repo shape and ecosystem detection
- Output: Pillar scorecard with per-pillar levels and scores
- Output: Overall maturity level (L0-L5) with gating rationale
- Output: Blockers to next level with prioritized remediation
- Output: Advisory notes (non-gating heuristic findings)
- Output: Optional scaffold plan with concrete file/config changes

Done when: Phase 4 report has been presented to the user. If scaffold was requested, done when plan is shown (or applied with confirmation).

---

## References (Progressive Disclosure)

Read each reference only when its phase activates — not upfront.

| Reference | When to read |
|-----------|-------------|
| [PILLARS.md](references/PILLARS.md) | Phase 2 — detailed pillar definitions, level criteria, checks |
| [RUBRIC.md](references/RUBRIC.md) | Phase 2 — full check catalog with detect methods and evidence |
| [REPORT.md](references/REPORT.md) | Phase 4 — report structure, scoring derivation, format |
| [SCAFFOLD.md](references/SCAFFOLD.md) | Phase 5 — scaffold templates per level, generation rules |

## Templates & Scripts

| Asset | Purpose | Used in |
|-------|---------|---------|
| [assets/templates/readiness-report.template.md](assets/templates/readiness-report.template.md) | Report structure template | Phase 4 |
| [assets/templates/rubric.schema.json](assets/templates/rubric.schema.json) | Rubric check schema | Phase 2 |
| [scripts/detect_ecosystem.sh](scripts/detect_ecosystem.sh) | Detect language, package manager, build tool | Phase 1 |
| [scripts/assess_feedback_velocity.sh](scripts/assess_feedback_velocity.sh) | Measure test execution time and scoping | Phase 2 |
| [scripts/assess_determinism.sh](scripts/assess_determinism.sh) | Check lockfiles, test isolation signals | Phase 2 |

## Hard Rules

- Never inflate maturity level — unknown checks on required gates mean the level is NOT achieved
- Never treat heuristic signals as gating — only deterministic checks gate levels
- Never run destructive commands during assessment — observation only
- Never scaffold without showing a plan first — plan-first, apply only with explicit confirmation
- Advisory notes must cite evidence (file path or observed behavior) — no invented observations
- Assessment must be reproducible — same repo state should produce same report
