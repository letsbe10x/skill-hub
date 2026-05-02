---
name: lets-research-ux-walkthrough
description: "Use when performing a guided UX walkthrough of a flow to log friction, confusion, and drop-off signals. Produces a friction log with severity ratings. Not for A/B testing or quantitative metrics analysis."
metadata:
  author: cogsmith-ai
  version: "0.1.0"
  tags: [research, ux, walkthrough]
lifecycle: draft
source: https://github.com/letsbe10x/skills/blob/main/lets-research-ux-walkthrough/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
  requirements:
    - A browser navigation tool (Codex in-app browser, Claude Code browser, or equivalent)
triggers:
  - ux walkthrough
  - click through onboarding
  - find friction in this flow
  - navigate this product and report issues
not-for:
  - A/B testing or conversion rate optimization
  - Quantitative usability metrics (use analytics tools instead)
goals:
  - persona-simulate
  - agent-interview
outcome_runtime:
  open_agency_zones:
    - ux_friction_discovery
    - persona_sensitivity_mapping
    - flow_walkthrough_strategy
  governed_action_zones:
    - ux_finding_claims
    - remediation_recommendation
  allowed_moves:
    - request_missing_flow_context
    - preserve_repro_steps
    - separate_observation_from_inference
  hard_limits:
    - do_not_fabricate_navigation_evidence
    - do_not_expose_sensitive_user_data
  required_decision_frames:
    - ux_walkthrough_decision
  validation_gates:
    - repro_evidence_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
    - compliance_risk
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

## Overview

`lets-research-ux-walkthrough` is a Research Studio program for finding funnel friction by actually navigating a user journey.

It is designed for product/growth/UX teams who need:
- reproduction steps
- friction taxonomy + severity
- segment sensitivity overlays (optional persona cohort)

## When to Use

- You want "what breaks and where users drop off", not just copy critique.
- You need a reproducible bug/funnel friction log for engineering/design.
- You want to test flow changes against different persona sensitivities (risk-averse vs impatient-mobile).

## When Not to Use

- Do not use this for quantitative analytics or A/B-test readouts.
- Do not use this without a defined start state and success condition.
- Do not expose sensitive user data while capturing walkthrough evidence.

## Intake Card

- Target URL + entry point (where the walkthrough starts)
- Primary journey: onboarding / pricing → checkout / upgrade / activation
- Environment: device + viewport + locale + auth state
- Success criteria: what "done" looks like (e.g., reach checkout, complete signup)
- Persona overlay (optional): cohort + scenario for segment sensitivity

## Inputs

- Input: target URL and entry point
- Input: journey boundaries and success condition
- Input: environment details such as device, viewport, locale, and auth state
- Input: optional persona overlay for segment sensitivity

## Steps

1. Fill out the brief template: [`references/ux_walkthrough_brief.yml`](references/ux_walkthrough_brief.yml).
2. Open the target URL/flow in a browser tool and navigate the journey step-by-step.
3. Log each step with:
   - what you expected vs what happened
   - friction category (clarity, CTA, trust, pricing, form, performance, accessibility)
   - severity and confidence
   - reproduction notes (device, viewport, locale)
4. Optionally run persona simulation on key screens to quantify which segments are most affected.
5. Produce a walkthrough report with a prioritized fix list and a measurement plan.

## Commands

```bash
l10x persona simulate --repo-root . \
  --kind url --uri "https://example.com/signup" \
  --persona-id skeptical_buyer --scenario-id trust_and_click \
  --packs-root "$PACKS_ROOT" \
  --dry-run
```

## Anti-patterns

- **Conflating friction observations with user intent** — log what was observed, not inferred motivations.
- **Skipping severity ratings** — every friction item must have a severity: critical / moderate / minor.
- **Running a walkthrough without a defined start and end state** — the flow boundaries must be specified before starting.

## Outputs

- A walkthrough report (recommended name: `ux_walkthrough.md`) containing:
  - step-by-step findings with repro notes
  - taxonomy breakdown + prioritized fixes
  - screenshots/links captured during navigation (when available)

Done when: friction log is complete with severity ratings for all items, and start/end states are confirmed.

## Notes

- Keep navigation authorized (no scraping of gated/private areas without permission).
- Do not expose sensitive user data in screenshots, notes, or walkthrough exports.
- When you run persona simulation, prefer the same cohort spec to keep comparisons consistent.

## Checkpoints

- Checkpoint `repro_evidence_gate`: before walkthrough, confirm environment setup (device/locale/auth) and the exact journey steps you'll follow.
- Checkpoint `repro_evidence_gate`: before filing fixes, confirm severity and reproduction reliability; separate true bugs from preference-level UX issues.

## Error Handling

- If a step cannot be reproduced, mark it as uncertain instead of reporting it as a confirmed issue.
- If environment drift changes the flow, restart with a clean setup and documented state.
- If sensitive data appears during the walkthrough, stop capture, redact the evidence, and restart from a safe state.
