---
name: lets-research-prd-grooming
description: "Use to transform partner or customer feedback into structured PRD inputs — ranked opportunities, acceptance criteria, and open questions. Not for grooming engineering backlogs or technical specs."
metadata:
  author: cogsmith-ai
  version: "0.1.0"
  tags: [research, prd, product, requirements, grooming]
lifecycle: draft
source: https://github.com/letsbe10x/skills/blob/main/lets-research-prd-grooming/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - groom this PRD
  - run PRD grooming
  - validate this PRD with evidence
  - evolve product requirements from interviews
not-for:
  - Grooming engineering backlogs or sprint tasks
  - Writing technical specifications
goals:
  - prd-groom
outcome_runtime:
  open_agency_zones:
    - assumption_challenge
    - opportunity_discovery
    - pivot_strategy
  governed_action_zones:
    - prd_mutation
    - pivot_recommendation
  allowed_moves:
    - challenge_initial_framing
    - request_missing_evidence
    - propose_blocked_state
  hard_limits:
    - do_not_fabricate_evidence
    - do_not_apply_synthetic_only_pivots
  required_decision_frames:
    - prd_grooming_decision
  validation_gates:
    - prd_grooming_evidence_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
    - strategic_pivot
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `lets` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

## Overview

`lets-research-prd-grooming` is a Research Studio program wrapper for evidence-backed PRD evolution.

It is designed for product builders who need a truth-maintaining PRD workflow:

`PRD artifact -> evidence structuring -> assumption graph -> pivot policy -> PRD delta proposal -> differential revalidation -> audit spine`

It also covers market intelligence and opportunity discovery when users bring an existing solution, a product hypothesis, or both.

Use it when the user wants to test whether product requirements should change based on interviews, sales notes, support notes, CRM exports, or other partner/customer evidence.

## When To Use

- The user has a PRD and wants to know which assumptions are supported, weakened, or need real research.
- The user wants pivots across ICP, value proposition, or workflow with an audit trail.
- The user wants a committed reasoning spine in the repo's PRD Grooming audit directory.
- The user is grooming product requirements, not just polishing wording or rewriting a document.
- The user wants market, demand, persona, TAM, positioning, or GTM context linked to PRD assumptions.
- The user wants to run `opportunity_discovery` to produce a ranked opportunity portfolio from a solution or hypothesis.

## Intake Card

Capture the brief using [`references/prd_grooming_brief.yml`](references/prd_grooming_brief.yml).

Minimum fields:

- PRD artifact path.
- Evidence paths.
- Modes: `concept_test`, `use_case_discovery`, `journey_walkthrough`, optionally `opportunity_discovery`.
- Optional market context path.
- Optional solution root, inline hypothesis, or hypothesis file for opportunity discovery.
- Phases: `opportunity`, `problem`, `solution`, `validation`, `feasibility`, `gtm`.
- Pivot policy: usually `default`.
- Audit output policy: default committed Tier 1 + Tier 2 artifacts, raw evidence never committed by default.

## Steps

1. Confirm the PRD artifact path and evidence paths are local, intended for this run, and safe to process.
2. Confirm whether the run should materialize audit artifacts in the repo. Use `--no-commit-artifacts` for scratch analysis.
3. Run the CLI:

```bash
lets research prd groom \
  --repo-root . \
  --artifact ./docs/prd.md \
  --evidence ./research/interview-notes.md \
  --modes concept_test,use_case_discovery,journey_walkthrough
```

For market intelligence:

```bash
lets research prd groom \
  --repo-root . \
  --artifact ./docs/prd.md \
  --evidence ./research/interview-notes.md \
  --market-context ./research/market_context.yml
```

For opportunity discovery:

```bash
lets research prd groom \
  --repo-root . \
  --artifact ./docs/prd.md \
  --evidence ./research/interview-notes.md \
  --modes opportunity_discovery \
  --solution-root ./prototype \
  --hypothesis-file ./research/hypothesis.md \
  --market-context ./research/market_context.yml
```

4. Inspect the generated `decision_record.yml`, `assumptions.yml`, `revalidation.yml`, `market_intelligence.yml`, `opportunity_portfolio.yml`, and `audit_index.yml`.
5. Inspect `role_execution_packets.json`. If packets are present, dispatch or hand off those bounded roles before promoting the run as complete. Each packet should include doctrine refs, a role playbook, persona lenses, thinking archetypes, question banks, and rubrics. Use the role-output format in `lets-opportunity-discovery` when returning external agent results.
6. Treat selected pivots and opportunity recommendations as proposed product decisions. If a claim has `needs_real_interview`, `needs_experiment`, or `needs_research`, stop and ask for real validation before implementation.

## Anti-patterns

- **Treating all feedback as equally weighted** — opportunity ranking must reflect signal strength and frequency.
- **Producing acceptance criteria before opportunities are ranked** — ranking gates criteria writing.
- **Including implementation details in the PRD input** — PRD inputs define outcomes, not solutions.

## Outputs

The run directory and audit directory include:

- `prd_grooming_brief.yml`
- `evidence_items.json`
- `assumptions.yml`
- `panel_findings.json`
- `failure_modes.json`
- `prd_delta_proposal.yml`
- `revalidation.yml`
- `decision_record.yml`
- `audit_index.yml`
- `evidence_summary.md`
- `agent_plan.yml`
- `role_execution_packets.json`
- `market_context.yml`
- `market_intelligence.yml`
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

Done when: opportunities are ranked with signal provenance, acceptance criteria are written for the top-ranked opportunities, and open questions are listed.

### Handoff Artifact

When invoked as a handoff from `lets-develop-feature`, also produce a `requirements.md` summary with this frontmatter:

```yaml
---
artifact_type: requirements
produced_by: lets-research-prd-grooming
produced_at: <ISO 8601 timestamp>
status: approved
approval_source: self-review
---
```

The `requirements.md` condenses the grooming output into structured requirements (problem, user stories, acceptance criteria, open questions) suitable for downstream planning.

## Checkpoints

- Before running: confirm raw evidence policy and whether artifacts should be materialized in the repo.
- Before accepting a pivot: confirm it rewrote assumptions before PRD text and passed evidence-backed pivot policy.
- Before implementation: confirm revalidation net effect is positive and downstream regressions do not exceed improvements.
- Before recommending an opportunity: confirm the portfolio keeps multiple ranked options, every recommended opportunity has validation gates, and missing market/customer/startup evidence is marked `needs_research`.
- Before claiming agentic completion: confirm `role_execution_packets.json` is empty or every open packet has been fulfilled by a validated `role_outputs` payload and a follow-up run.
- Before trusting a role output: confirm it followed the packet's doctrine, answered its must-answer questions, used its persona lenses and thinking archetypes, and preserved unresolved questions.

## Fallbacks

- If the CLI does not expose `research prd groom`, stop and ask for the Phase 1 core runtime to be installed or updated.
- If the CLI does not expose `--market-context`, `--solution-root`, `--hypothesis`, or `--hypothesis-file`, stop and ask for the PRD Grooming Phase 5 runtime to be installed or updated before running market or opportunity discovery.
- If the CLI/runtime does not emit `role_execution_packets.json`, stop and ask for the PRD Grooming role-execution runtime to be installed or updated before claiming external agent handoff support.
- If role packets do not include doctrine/playbook/persona/archetype/question/rubric refs, stop and ask for the PRD Grooming doctrine pack/runtime update before claiming role-level agent judgment.
- If evidence paths contain raw transcripts that should not be processed, rerun with redacted notes or `--no-commit-artifacts`.
- If claims remain unresolved, mark the run blocked and ask for real interviews or experiments instead of drafting PRD changes.
- If the user primarily wants solution-to-opportunity discovery, use `lets-opportunity-discovery` for the deeper workflow, templates, scripts, and review checklist.

## Notes

- This skill does not claim product truth. It produces evidence-backed PRD evolution hypotheses.
- Synthetic-only agreement is not enough to accept a pivot.
- Do not commit raw transcripts, raw CRM exports, or verbose logs by default.
- Do not embed raw solution files or raw hypothesis-file contents in audit artifacts.
- Use Persona Simulation as a supporting method only when cohort behavior is needed; PRD Grooming owns the assumption graph and pivot decision record.
