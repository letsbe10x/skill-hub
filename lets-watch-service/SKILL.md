---
name: lets-watch-service
description: "Use when you need a live read on service health, want to verify a deploy against pre-deploy baseline, or are actively watching an incident. Fans out to alerts/metrics/logs/k8s surfaces via the watchtower capability contract and escalates to lets-triage-incident on CRITICAL findings."
metadata:
  author: letsbe10x
  version: "0.1.0"
  tags: [observability, watchtower, incident, deploy]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-watch-service/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
  requirements:
    - "adapter capability: alerts"
    - "adapter capability: metrics"
    - "adapter capability: logs"
    - "adapter capability: k8s"
triggers:
  - watch this service
  - is the service healthy
  - verify deploy
  - watchtower
  - incident watch
goals:
  - inspect_service
  - investigate_change
outcome_runtime:
  open_agency_zones:
    - mode_selection
    - surface_correlation
    - health_severity_assessment
  governed_action_zones:
    - health_status_claim
    - deploy_verification_claim
  allowed_moves:
    - escalate_on_critical
    - request_missing_adapter_capability
    - fan_out_to_surface_skills
  hard_limits:
    - do_not_claim_health_without_all_declared_surfaces
    - do_not_perform_destructive_actions
    - do_not_expose_sensitive_signal_data
  required_decision_frames:
    - watchtower_mode_decision
  validation_gates:
    - surface_readiness_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
    - critical_severity_finding
---

## Investigation Law

**NO HEALTH CLAIM WITHOUT EVERY DECLARED SURFACE REPORTING.**

If any declared adapter capability (alerts / metrics / logs / k8s) is unavailable or its probe returns `not_ready`, the overall verdict is `UNKNOWN`, never `GREEN`. A missing surface is a gap, not a pass.

## Overview

`lets-watch-service` is the operator front door for service observability. It runs one of three modes — `health`, `deploy-verify`, or `incident` — against the `run_watchtower` goal, which fans out across the four watchtower surfaces (alerts, metrics, logs, k8s) through the capability contract and returns a correlated verdict.

It is the only skill that invokes `run_watchtower` directly. The four surface skills (`lets-manage-alerts`, `lets-inspect-metrics`, `lets-search-logs`, `lets-diagnose-k8s`) are subordinate: use them only when a narrow, single-surface question is being asked.

## Phase 0 — Load workflow context and classification

Read context artifacts from the active run manifest before executing this goal.

```bash
lets run list --format json | jq '.[0].run_dir // empty'
```

If a `run_dir` is found:
1. Read `workflow_context.json` — extract `must_preserve` (non_negotiables + critical_paths). Missing file logs `[warn] workflow_context.json not found` and proceeds.
2. Read `classification.json` — extract `governance_verdict`. If `BLOCK`: halt and surface the block.
3. Embed `must_preserve.critical_paths` in context for correlation.

If no active run directory exists, skip Phase 0 silently.

## When to Use

- A user or operator asks "is the service healthy?" — run in `health` mode.
- A deploy just landed and you need a before/after comparison — run in `deploy-verify` mode.
- An alert is firing and you want correlated signal across surfaces before triage — run in `incident` mode.
- You do NOT know which specific surface holds the answer — this front door picks the right fan-out.

## Steps

1. Classify intent into one of three modes: `health`, `deploy-verify`, `incident`. Confirm the mode with the user.
2. Run `lets run exec run_watchtower --mode $MODE --service $SERVICE` — let the capability contract resolve the four surface probes. Do not substitute raw adapter calls. For a single-surface follow-up, invoke the matching surface skill (step 4), which wraps `lets inspect surface $CAPABILITY` — cheaper than re-running the full fan-out.
3. If any surface returns `not_ready`: record as UNKNOWN for that surface; never infer it away.
4. For narrow follow-ups, fan out to the surface skill that owns the capability:
   - alerts → `lets-manage-alerts`
   - metrics → `lets-inspect-metrics`
   - logs → `lets-search-logs`
   - k8s → `lets-diagnose-k8s`
5. If the correlated verdict is CRITICAL: stop the health flow and escalate to `lets-triage-incident`. Pass the watchtower output as the Phase 1 signal.
6. Produce the verdict card in the structured format below under Outputs.

## Escalation Criteria

Escalate to `lets-triage-incident` immediately when:
- Overall verdict is `CRITICAL`.
- Any surface reports an active paging alert.
- Two or more surfaces contradict each other and cannot be reconciled in one correlation pass.

## Anti-patterns

- **Calling `kubectl` / `promql` / `splunk search` directly** — blocked. `lets run_watchtower` is the seam; direct tool calls bypass the capability contract and provenance.
- **Claiming GREEN when a surface probe returned `not_ready`** — blocked. Unknown is not healthy; do not claim health without all declared surfaces returning a successful probe.
- **Performing destructive actions (rollouts, restarts, silencing alerts)** — blocked. This skill must not perform destructive actions. Destructive actions require on-call lead sign-off outside this skill.
- **Exposing sensitive signal data (PII, credentials, raw customer records) in the verdict card** — blocked. Do not expose sensitive signal data; redact before surfacing.
- **Skipping escalation on CRITICAL because "the fix looks obvious"** — blocked. CRITICAL routes through `lets-triage-incident`; the front door does not propose mitigations.
- **Running `health` mode during an active incident** — blocked. `incident` mode exists so correlation windows are aligned.

## Outputs

A structured verdict card containing:

- Output: **Mode** — `health` | `deploy-verify` | `incident`.
- Output: **Overall verdict** — `GREEN` | `YELLOW` | `RED` | `CRITICAL` | `UNKNOWN`.
- Output: **Per-surface status** — one line per surface (alerts / metrics / logs / k8s) with probe status and summary.
- Output: **Correlated findings** — cross-surface signals when ≥2 surfaces point at the same cause.
- Output: **Next action** — which surface skill or `lets-triage-incident` to invoke next (explicit, by skill name).

Done when: the verdict card is printed and, if CRITICAL, `lets-triage-incident` has been invoked with the card as input.
