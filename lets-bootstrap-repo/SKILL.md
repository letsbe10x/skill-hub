---
name: lets-bootstrap-repo
description: "Use when setting up a new or incomplete repo with letsbe10x context. Runs the bootstrap-repo goal to establish context artifacts, pack configuration, and readiness baseline."
metadata:
  author: cogsmith-ai
  version: "1.0.0"
  tags: [onboarding, bootstrap, context]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-bootstrap-repo/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
outcome_runtime:
  open_agency_zones:
    - service_truth_discovery
    - context_pack_strategy
    - readiness_assessment
  governed_action_zones:
    - context_pack_mutation
    - maintainer_truth_recording
  allowed_moves:
    - ask_maintainer_for_truth
    - mark_context_degraded
    - recommend_bootstrap_sequence
  hard_limits:
    - do_not_invent_service_truth
    - do_not_overwrite_maintainer_attested_facts
    - do_not_commit_secrets
  required_decision_frames:
    - bootstrap_scope_decision
  validation_gates:
    - maintainer_attestation_gate
    - context_pack_verification_gate
  mutation_policy: additive_only
  human_checkpoint_triggers:
    - missing_truth
    - compliance_risk
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

# lets-bootstrap-repo

Make a repo AI-ready by capturing service truth and reporting readiness.

## When to use

- First time setting up a repo for letsbe10x
- Context artifacts are missing or stale
- User asks "onboard this repo" or "bootstrap letsbe10x here"

## When not to use

- Do not use when the repo already has trusted context and you only need a narrow content refresh.
- Skip this flow when the user only wants to inspect readiness without changing any context artifacts.

## Confirm before writing context artifacts

Ask: "Ready to bootstrap this repo? (y/n)"

---

## Phase 1 — Status check

Inspect the repo to determine what context artifacts already exist.

Check for the presence of: `service.yaml`, `engineering.yaml`, existing `AGENTS.md`, `CLAUDE.md`, and any CI configuration.

Present a status summary to the user:

```
Artifact          Present   Verified
service.yaml        ✗         ✗
engineering.yaml    ✗         ✗
AGENTS.md           ✗         —
```

**Decision:**
- All artifacts present and trusted → run a readiness assessment (Phase 5) and exit.
- Service facts present but engineering docs missing → skip to Phase 4, offer enrichment.
- Service facts missing → proceed to Phase 2.

---

## Phase 2 — Intake (service truth)

Ask the following questions **one at a time**. Do not batch them.

| # | Question | Feeds into |
|---|---|---|
| 1 | Who is approving this bootstrap? (email or handle) | Bootstrap approver record |
| 2 | What does this repo do in one sentence? | Service purpose — record it explicitly after Phase 3 |
| 3 | What are 2–5 invariants that must never regress? | Non-negotiables list |
| 4 | What are the 2–5 critical flows in this system? | Critical paths list |
| 5 | Governance posture? guarded, balanced, adaptive, experimental | Profile setting |
| 6 | Operational posture? intensive, managed, moderate, lightweight | Operational posture setting |

See `references/INTAKE.md` for how to present each question and validate the answers.

---

## Phase 3 — Record service truth

Record the answers from Phase 2 into `service.yaml` (or equivalent context artifact for the platform). Fields to populate:

- `service.purpose` — the one-sentence description
- `service.non_negotiables` — list of invariants
- `service.critical_paths` — list of critical flows
- `service.governance_profile` — the chosen posture
- `service.operational_posture` — the chosen posture
- `service.approved_by` — the approver from question 1

**If artifacts already exist:** show the diff between existing values and proposed new values before overwriting. Never overwrite without explicit user confirmation.

---

## Phase 4 — Optional enrichment

Ask:

> "Would you like me to generate AGENTS.md files for this repo and enrich the engineering context? This improves the quality of all future goal executions (yes or skip)."

If **yes**: invoke `lets-bootstrap-agents-md` skill.
If **skip**: proceed to Phase 5.

---

## Phase 5 — Readiness report

Scan the repo and produce a readiness summary:

- Which context artifacts are present and verified
- Per-pillar status (service facts, engineering docs, delivery config, observability)
- Top 3 gaps with suggested remediation steps
- Recommended next step

Present the readiness level (e.g. "L2 — partially bootstrapped") and score out of 100.

## Anti-patterns

- **Bootstrapping without running the status check** — Phase 1 status check determines what's already present.
- **Overwriting existing context artifacts without a diff** — check for existing files before writing.
- **Skipping the readiness report** — Phase 5 readiness report is not optional; it is the completion evidence.
- **Bypassing the maintainer attestation gate** — do not write or publish repo facts without maintainer attestation; unattested facts must be flagged as inferred.

## Outputs

- A current readiness report for the repo
- A clear decision on whether bootstrap, onboarding, or enrichment happened

Done when: Phase 5 readiness report has been shown to the user and any blocking bootstrap error has been surfaced explicitly.

See `references/OUTPUTS.md` for what verified and enriched mean and how to read the readiness report.

---

## Hard rules

- **Never overwrite existing artifacts without explicit confirmation from the user.**
- Never write to agent config directories as part of this bootstrap flow.
- Never commit on behalf of the user. Context artifacts remain user-owned.
- Readiness scoring is conservative: only verified artifacts count toward the score.
- If bootstrap fails mid-phase, surface the partial result and ask the user whether to retry or roll back: describe what was written and what was not.
- If context artifacts are corrupted, diagnose from available files (`service.yaml`, `engineering.yaml`) and re-run Phase 1 before retrying Phase 3.
