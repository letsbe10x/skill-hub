---
name: lets-deploy-check
description: Pre-deploy checklist — context verification, governance checkpoint, deploy signal.
metadata:
  author: letsbe10x
  version: "1.0.0"
  tags: [deployment, status, observability]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-deploy-check/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - pre-deploy check
  - deploy check
  - ready to deploy?
goals:
  - deploy_service
outcome_runtime:
  open_agency_zones:
    - deploy_risk_assessment
    - verification_signal_selection
  governed_action_zones:
    - deploy_readiness_claim
    - release_go_no_go_recommendation
  allowed_moves:
    - block_on_missing_signal
    - request_rollout_context
    - recommend_extra_verification
  hard_limits:
    - do_not_claim_deploy_ready_without_evidence
    - do_not_ignore_failing_checks
  required_decision_frames:
    - deploy_readiness_decision
  validation_gates:
    - deploy_signal_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
    - unresolved_disagreement
---


## Overview

`lets-deploy-check` is a pre-deployment gate that verifies the repo is in a deployable state
before any service is promoted. It runs three checks in sequence — context freshness, governance
posture, and a dry-run deploy signal — and produces a traffic-light report (green / yellow / red)
with a concrete list of blocking issues.

Use this skill as the last step before opening a deploy PR or promoting a release, and as an
automated gate in your release workflow.

## Phase 0 — Load workflow context and classification

Read context artifacts from the active run manifest before executing this goal.

```bash
lets run list --format json | jq '.[0].run_dir // empty'
```

If a `run_dir` is found:
1. Read `workflow_context.json` from the resolved run directory — extract `must_preserve` (non_negotiables + critical_paths) and `defaults`. If absent, log `[warn] workflow_context.json not found — continuing with empty context` and proceed.
2. Read `classification.json` from the same run directory — extract `governance_verdict`. If absent, log `[warn] classification.json not found` and proceed.
3. If `governance_verdict == "BLOCK"`: stop, print block reason, do not proceed.
4. Embed `must_preserve.critical_paths` in context for all subsequent phases.

If no active run directory exists, skip Phase 0 silently.

---

## When to Use

- You are about to deploy to staging or production and want a final confidence check.
- Your release process requires a documented deploy readiness attestation.
- Governance or compliance rules require a pre-deploy checkpoint.
- You want to catch stale context or policy violations before they cause a deployment failure.

## Steps

1. Run `lets context authoring verify` to check context freshness. A stale context pack is a
   yellow signal; a missing or corrupted context pack is a red blocker.
2. Run `lets govern check` to verify governance posture. Any failed policy is a red blocker;
   warnings are yellow signals.
3. Run `lets run exec --goal deploy_service` with the `--dry-run` flag if supported by the
   configured deploy adapter. A non-zero exit or error output is a red blocker.
4. Aggregate all signals and produce the deploy readiness report using the status schema in
   [references/status-schema.md](references/status-schema.md): green (ready to deploy), yellow
   (proceed with caution — review warnings), red (blocked — fix issues before deploying).

## Outputs

A deploy readiness report with:

- **Status** — traffic-light: `GREEN`, `YELLOW`, or `RED`.
- **Blocking issues** — list of red findings that must be resolved before deploying (empty if green).
- **Warnings** — list of yellow findings that should be reviewed but do not block.
- **Checks passed** — list of checks that completed successfully.
