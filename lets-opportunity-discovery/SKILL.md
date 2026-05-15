---
name: lets-opportunity-discovery
description: "Use when discovering and ranking product opportunities from a solution, hypothesis, or research corpus. Produces a scored opportunity map. Not for validating already-decided features."
metadata:
  author: cogsmith-ai
  version: "0.1.0"
  tags: [research, product, opportunity, solution, hypothesis, prd]
lifecycle: draft
source: https://github.com/letsbe10x/skills/blob/main/lets-opportunity-discovery/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - I have a working solution, find opportunities
  - discover product opportunities for this solution
  - turn this hypothesis into ranked product directions
  - where can this technical capability be applied
  - find customers, trends, and startups for this capability
not-for:
  - Validating or justifying already-decided features
  - Replacing customer interviews with synthetic ranking
goals:
  - prd-groom
outcome_runtime:
  open_agency_zones:
    - opportunity_discovery
    - market_synthesis
    - capability_mapping
    - strategic_recommendation
  governed_action_zones:
    - opportunity_ranking
    - recommended_next_prd
  allowed_moves:
    - compare_alternative_opportunities
    - mark_market_evidence_as_needed
    - challenge_solution_fit
  hard_limits:
    - do_not_promote_unvalidated_market_claims
    - do_not_fabricate_customer_evidence
  required_decision_frames:
    - opportunity_recommendation
  validation_gates:
    - opportunity_evidence_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
    - strategic_pivot
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `lets` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

## Overview

`lets-opportunity-discovery` is a Research Studio workflow for turning an existing solution, a hypothesis, or both into a ranked portfolio of product opportunities.

Use it when the user is not only grooming an existing PRD, but asking:

> Given this capability or thesis, what valuable problems could it solve if we adapt it intelligently?

The workflow uses `lets research prd groom --modes opportunity_discovery` and keeps creative ideas governed by capability links, assumptions, market signals, validation gates, and audit artifacts.

## When To Use

- The user has a working solution, prototype, repo, architecture, API, or technical mechanism and wants product opportunities.
- The user has a hypothesis, market hunch, or customer pain thesis and wants ranked product directions.
- The user has both a solution and a hypothesis and wants to compare actual capability against product direction.
- The user asks for potential customers, recent market/startup patterns, trends, or ways to adapt the technology.

Do not use this skill for generic brainstorming with no solution or hypothesis input. Ask for at least one of those inputs first.

## Intake

Classify intake using [`references/intake-card.yml`](references/intake-card.yml):

- `solution_led`: solution input exists, hypothesis is absent.
- `hypothesis_led`: hypothesis exists, solution input is absent.
- `hybrid`: both solution and hypothesis exist.

Accepted inputs:

- `--solution-root {PATH}`: repo, prototype directory, architecture file, workflow doc, API spec, or mechanism description.
- `--hypothesis {TEXT}`: inline product or market hypothesis. Avoid sensitive raw content.
- `--hypothesis-file {PATH}`: file reference for the hypothesis. The runtime should not embed raw file text in audit artifacts.
- `--market-context {PATH}`: YAML/JSON context for market, competitive, demand, TAM, persona, positioning, and GTM signals.
- `--evidence {PATH}`: interview notes, sales notes, support notes, CRM exports, or research summaries.

Use [`scripts/validate-intake.py`](scripts/validate-intake.py) before running when the intake is complex.

## Command

```bash
lets research prd groom \
  --repo-root . \
  --artifact ./docs/prd-or-hypothesis.md \
  --evidence ./research/evidence.md \
  --modes opportunity_discovery \
  --solution-root ./path/to/solution \
  --hypothesis-file ./research/hypothesis.md \
  --market-context ./research/market_context.yml
```

For solution-only discovery, omit `--hypothesis` and `--hypothesis-file`.
For hypothesis-only discovery, omit `--solution-root`.

## Workflow

1. Confirm the user has at least one valid intake: solution or hypothesis.
2. Confirm raw evidence and market context are safe to process. Do not paste sensitive source, customer data, or private hypotheses into inline `--hypothesis`.
3. Validate intake with the script when paths or templates are involved.
4. Run `lets research prd groom --modes opportunity_discovery`.
5. Inspect `role_execution_packets.json`. If it contains open packets, run or dispatch those bounded roles using the packet's doctrine refs, role playbook, persona lenses, thinking archetypes, question banks, and rubrics. Pass results back as `role_outputs` for a follow-up run. See [`references/role-execution-handoff.md`](references/role-execution-handoff.md).
6. Check artifact completeness with [`scripts/check-artifact-completeness.py`](scripts/check-artifact-completeness.py).
7. Summarize the ranked portfolio with [`scripts/summarize-opportunity-portfolio.py`](scripts/summarize-opportunity-portfolio.py).
8. Review the portfolio using [`references/opportunity-review-checklist.md`](references/opportunity-review-checklist.md).
9. Do not promote an opportunity to PRD work unless it has capability links, assumptions, validation gates, and sufficient evidence or an explicit `needs_research` status.

## Anti-patterns

- **Starting from a solution instead of a problem space** — opportunity discovery must be problem-first; solutions narrow the space prematurely.
- **Reporting opportunities without evidence provenance** — each opportunity must cite its source signals.
- **Treating synthetic ranking as validated priority** — opportunity maps require human review before roadmap decisions.

## Output Contract

Required Phase 5 artifacts:

- `solution_capability_graph.yml`
- `problem_space_map.yml`
- `trend_report.yml`
- `startup_landscape.yml`
- `customer_segment_map.yml`
- `adaptation_candidates.yml`
- `technical_modification_plan.yml`
- `opportunity_scorecard.yml`
- `opportunity_portfolio.yml`
- `recommended_next_prds.yml`
- `role_execution_packets.json`

Done when: opportunity map is ranked with evidence provenance for each item, and a human review gate is acknowledged before treating the output as roadmap input.

See [`references/artifact-contracts.md`](references/artifact-contracts.md) for completion criteria.

## Fallbacks

- If no solution or hypothesis is provided, stop and ask for one input before running.
- If the CLI does not expose `--solution-root`, `--hypothesis`, `--hypothesis-file`, or `--market-context`, stop and ask for the PRD Grooming Phase 5 runtime to be installed or updated.
- If `--market-context` is absent, continue only if the user accepts `needs_research` outputs for trends, startups, personas, demand, TAM, and positioning.
- If required Phase 5 artifacts are missing, rerun the command or use `scripts/check-artifact-completeness.py` to identify the missing files before summarizing.
- If `role_execution_packets.json` contains open packets, do not describe the run as fully agent-executed. Treat it as ready for external role work until a follow-up run consumes matching `role_outputs`.
- If a packet lacks doctrine, role playbook, persona lens, thinking archetype, question bank, or rubric refs, treat it as an incomplete runtime packet and ask for the PRD Grooming doctrine pack/runtime update.
- If `opportunity_portfolio.yml` contains a single option, treat it as incomplete unless the user explicitly asked for one recommendation.

## Guardrails

- Do not invent market facts, startup traction, customer segments, or trend claims. Mark missing evidence as `needs_research`.
- Do not embed raw solution files or raw hypothesis-file contents into audit artifacts.
- Treat inline `--hypothesis` as user-approved text, but still avoid sensitive data.
- Preserve multiple ranked opportunities by default. Do not collapse to one answer unless the user asks for a single recommendation.
- Separate creative adaptation from venture scoring. Speculative ideas may be kept, but weak ideas should be marked `defer` or `reject`.
- External role outputs can change rankings, but they must keep validation gates and must not upgrade factual evidence unless they provide cited market/customer support.
- External agents must answer through their assigned persona lenses and must preserve unresolved questions rather than smoothing them into recommendations.
- Persona lenses define whose constraints matter; thinking archetypes define how the role reasons about those constraints.

## Related Skill

Use `lets-research-prd-grooming` for the broader PRD Grooming flow. Use this skill when the main job is solution-to-opportunity discovery.
