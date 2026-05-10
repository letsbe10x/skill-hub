---
name: lets-research-content-evaluate
description: "Use when evaluating messaging, copy, or content against a rubric and target personas. Produces scored findings and improvement variants. Not for evaluating code or technical documentation."
metadata:
  author: cogsmith-ai
  version: "0.1.0"
  tags: [research, content, messaging, marketing]
lifecycle: draft
source: https://github.com/letsbe10x/skills/blob/main/lets-research-content-evaluate/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - evaluate this copy
  - critique this landing page copy
  - improve this email
  - messaging feedback
not-for:
  - Evaluating code quality or technical documentation
  - Running without a defined rubric or target audience
goals:
  - persona-ingest-artifact
  - persona-simulate
  - agent-interview
outcome_runtime:
  open_agency_zones:
    - content_rubric_interpretation
    - rewrite_strategy
    - persona_segment_analysis
  governed_action_zones:
    - content_quality_claims
    - rewrite_recommendation
  allowed_moves:
    - challenge_target_audience
    - request_brand_or_rubric_context
    - propose_multiple_rewrite_options
  hard_limits:
    - do_not_fabricate_audience_evidence
    - do_not_hide_segment_disagreement
  required_decision_frames:
    - content_evaluation_decision
  validation_gates:
    - rubric_evidence_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
    - unresolved_disagreement
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

## Overview

`lets-research-content-evaluate` is a Research Studio program for evaluating messaging quality and proposing corrections.

It produces a structured critique focused on:
- clarity and specificity
- value proposition and relevance
- trust and risk reducers
- CTA clarity and commitment
- segment sensitivity (optional persona cohort)

## When to Use

- You need a rubric-based critique rather than generic copy suggestions.
- You want segment-aware messaging deltas (skeptical vs value-seeking vs impatient).
- You want multiple rewrite options tied to measurable hypotheses.

## When Not to Use

- Do not use this without a rubric or target audience.
- Do not use this as a final copy-approval step.

## Intake Card

- Artifact: landing page URL or raw copy/email text (no PII)
- Target audience / ICP: one sentence
- Channel: landing page / email / ad / onboarding
- Constraints: legal/compliance, brand voice, geo/locale
- Fidelity: run persona simulation + interview or keep rubric-only

## Inputs

- Input: one artifact source
- Input: one rubric
- Input: target audience or ICP
- Input: channel and constraints

## Steps

1. Fill out the brief template: [`references/content_evaluate_brief.yml`](references/content_evaluate_brief.yml).
2. Ingest the artifact (`raw_copy` for email/ad copy; `url` for landing pages) using `lets persona ingest`.
3. Optionally run persona simulation on the same artifact to get segment friction and trust signals.
4. Produce a report with:
   - issues grouped by taxonomy (clarity, trust, pricing, CTA, cognitive load)
   - severity/impact/confidence
   - rewrite variants (A/B/C) + expected lift hypotheses + measurement plan

## Commands

```bash
lets persona ingest --repo-root . \
  --kind raw_copy --text "Headline: ... CTA: ... Proof: ..." \
  --title "Content evaluation artifact"
```

## Anti-patterns

- **Evaluating content without a rubric** — the rubric defines scoring criteria; running without one produces unactionable output.
- **Treating scored output as final copy** — findings are improvement signals, not approved replacements.
- **Skipping persona context** — evaluations without audience context produce generic, low-signal results.

## Outputs

- A content evaluation report (recommended name: `content_evaluation.md`).
- Optional persona simulation artifacts (if you ran the persona simulation method as part of this program).

Done when: content is scored against the rubric with per-criterion findings, and at least one improvement variant is proposed per failing criterion.

## Checkpoints

- Checkpoint `rubric_evidence_gate`: before running, confirm the artifact source and any compliance/brand constraints in the brief.
- Checkpoint `rubric_evidence_gate`: before rewriting, confirm whether you want 1 rewrite (safe) or multiple variants (A/B/C) with explicit hypotheses.

## Error Handling

- If the rubric is missing or weak, stop and define it before evaluating.
- If audience context is missing, add it before accepting the critique as meaningful.

## Notes

- Keep claims evidence-backed and label confidence.
- For regulated industries, incorporate legal/compliance constraints from the brief.
