---
name: lets-research-competitive-scan
description: "Use when collecting and comparing competitor positioning, pricing, proof points, and CTAs. Produces a structured comparison report. Not for technical stack analysis or patent research."
metadata:
  author: cogsmith-ai
  version: "0.1.0"
  tags: [research, competitive, marketing, ux]
lifecycle: draft
source: https://github.com/letsbe10x/skills/blob/main/lets-research-competitive-scan/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - competitive research
  - analyze competitors
  - compare landing pages
  - build a battlecard
not-for:
  - Technical architecture or stack analysis
  - Legal or patent competitive research
goals:
  - persona-ingest-artifact
  - persona-simulate
  - agent-interview
outcome_runtime:
  open_agency_zones:
    - competitive_positioning_analysis
    - market_pattern_synthesis
    - differentiation_strategy
  governed_action_zones:
    - competitor_claims
    - positioning_recommendation
  allowed_moves:
    - request_missing_competitor_artifacts
    - mark_claims_as_unverified
    - compare_alternative_positioning
  hard_limits:
    - do_not_fabricate_competitor_evidence
    - do_not_use_insecure_external_sources
  required_decision_frames:
    - competitive_scan_decision
  validation_gates:
    - source_evidence_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
    - compliance_risk
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

## Overview

`lets-research-competitive-scan` is a Research Studio program for answering:
"How do competitors position, price, prove trust, and convert — and what opportunities does that create for us?"

This skill is intentionally **artifact-first**: it captures competitor pages as snapshots and produces an evidence-backed comparison.

## When to Use

- You are updating messaging/positioning and need a reality check vs the market.
- You are redesigning pricing or onboarding and want comparative patterns.
- You need a battlecard-style summary for internal alignment.

## When Not to Use

- Do not use this for technical architecture or legal/patent analysis.
- Do not use this without source artifacts you are permitted to analyze.
- Do not use insecure external sources or protected content you are not authorized to access.

## Intake Card

- Competitors: list of URLs (authorized/public)
- Your product: one sentence positioning + target ICP
- Comparison focus: pricing, proof, CTAs, differentiators, onboarding flow
- Cohort/scenario: optional — use the same cohort + scenario for all competitors for comparability
- Fidelity: `--use-llm` on/off (requires `ANTHROPIC_API_KEY`)

## Inputs

- Input: competitor URLs
- Input: your product positioning and ICP
- Input: comparison focus such as pricing, proof, CTA, or onboarding
- Input: optional shared cohort/scenario for comparability

## Steps

1. Fill out the brief template: [`references/competitive_scan_brief.yml`](references/competitive_scan_brief.yml).
2. Ingest competitor artifacts (URLs) using `l10x persona ingest` (one run per competitor).
3. For each competitor, optionally run the same cohort scenario via `l10x persona simulate` to get segment-aware friction and trust signals.
4. Synthesize a report:
   - positioning claims, proof/trust signals, CTAs, pricing model, differentiators
   - "what they do well" vs "where they're weak"
   - opportunity hypotheses + recommended experiments

## Commands

```bash
l10x persona ingest --repo-root . \
  --kind url --uri "https://example.com" \
  --title "Competitor landing page"
```

## Anti-patterns

- **Including unverified claims about competitors** — all findings must be traceable to a specific artifact or source.
- **Reporting pricing without a retrieval date** — pricing changes; all data must be timestamped.
- **Treating a scan as a strategy recommendation** — the skill produces observations, not strategic decisions.

## Outputs

- A competitive report (recommended name: `competitive_report.md`) containing:
  - evidence excerpts per competitor
  - a comparison table (claims/pricing/proof/CTA/friction)
  - opportunity map and experiment ideas
- Run IDs for each competitor snapshot and any simulations performed.

Done when: comparison report is written with source references and retrieval timestamps for all claims.

## Notes

- Keep claims evidence-backed and label confidence.
- Do not use insecure external sources or scrape protected/paid content without authorization; only ingest what you can access legitimately.

## Checkpoints

- Checkpoint `source_evidence_gate`: before ingest, confirm the competitor list is accurate and permitted to analyze.
- Checkpoint `source_evidence_gate`: before synthesis, confirm which dimensions matter most (pricing vs trust vs CTA vs onboarding) so the report stays focused.

## Error Handling

- If a claim cannot be tied back to a source artifact, drop it or mark it unverified.
- If pricing or proof content is stale or incomplete, include the retrieval limitation instead of smoothing it over.
