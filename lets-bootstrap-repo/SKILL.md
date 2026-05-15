---
name: lets-bootstrap-repo
description: "Bootstrap a repository for AI readiness by capturing maintainer-confirmed service truth, detecting staleness, running discovery, and reporting readiness. Conversational intake with choice menus, optional enrichment via AGENTS.md generation and coding standards extraction."
metadata:
  author: cogsmith-ai
  version: "2.0.0"
  tags: [onboarding, bootstrap, context, readiness]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-bootstrap-repo/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - bootstrap this repo
  - onboard this repo
  - make this repo AI-ready
  - bootstrap letsbe10x here
  - set up repo context
  - capture service truth
outcome_runtime:
  open_agency_zones:
    - service_truth_discovery
    - context_pack_strategy
    - readiness_assessment
    - enrichment_scope_decision
    - staleness_detection
  governed_action_zones:
    - context_pack_mutation
    - maintainer_truth_recording
  allowed_moves:
    - ask_maintainer_for_truth
    - mark_context_degraded
    - recommend_bootstrap_sequence
    - recommend_enrichment_depth
    - flag_stale_artifact
  hard_limits:
    - do_not_invent_service_truth
    - do_not_overwrite_maintainer_attested_facts
    - do_not_commit_secrets
    - do_not_commit_on_behalf_of_user
    - do_not_write_to_agent_config_directories
  required_decision_frames:
    - bootstrap_scope_decision
    - enrichment_depth_decision
  validation_gates:
    - maintainer_attestation_gate
    - context_pack_verification_gate
    - readiness_scoring_gate
  mutation_policy: additive_only
  human_checkpoint_triggers:
    - missing_truth
    - compliance_risk
    - stale_overwrite
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `lets` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

# lets-bootstrap-repo

Make a repository AI-ready by capturing maintainer-confirmed service truth, detecting context gaps, and reporting readiness. Conversational intake with choice menus and recommended defaults. Operational detail in phase-specific references — this file is the contract.

---

## Pipeline

```
Phase 1: Status       → Detect existing artifacts, classify present/verified/stale/missing
Phase 2: Intake       → Ask clarifying questions with choice menus (one at a time)
Phase 3: Record       → Write service truth to context artifacts
Phase 4: Discovery    → Auto-discover engineering, delivery, observability facts
Phase 5: Enrichment   → Optional: AGENTS.md generation, coding standards, architecture docs
Phase 6: Readiness    → Score and report readiness level
```

---

## When to Use

- First time setting up a repo for AI-assisted development
- Context artifacts are missing or stale
- User asks "onboard this repo" or "bootstrap letsbe10x here"
- After cloning a repo that lacks AGENTS.md or service context

## When Not to Use

- Repo already has well-maintained context and user didn't ask to update
- You only need to generate AGENTS.md (use `lets-bootstrap-agents-md`)
- You only need a code review or feature implementation

---

## Operating Principles

1. **Maintainer attestation first** — no service fact recorded without explicit user confirmation
2. **Choice menus with defaults** — every multi-option question presents concrete choices with a recommended default
3. **Staleness-aware** — detect and surface stale artifacts before overwriting
4. **Conservative scoring** — only verified artifacts count toward readiness; scaffolds and inferred facts do not
5. **One question at a time** — never batch intake questions
6. **Additive-only** — never overwrite existing artifacts without showing diff and getting confirmation

---

## Mode Detection

Check for existing context artifacts:

| State | Action |
|-------|--------|
| No artifacts present | Fresh bootstrap — run all phases |
| Artifacts present but stale | Staleness report → ask re-verify or re-bootstrap |
| Artifacts present and verified | Readiness report only (Phase 6) → offer enrichment |

Present an intake card before proceeding:

```
Repo: {repo-name}
Artifact          Present   Verified   Stale
service.yaml        ✗         ✗         —
engineering.yaml    ✗         ✗         —
AGENTS.md           ✗         —         —
```

---

## Phase Contracts (Summary)

### Phase 1 — Status Check

Inspect the repo for: `service.yaml`, `engineering.yaml`, `AGENTS.md`, `CLAUDE.md`, CI configuration, `Makefile`, `pyproject.toml`.

**Decision tree:**
- All artifacts present and trusted → Phase 6 only, offer enrichment
- Service facts present but stale → ask: re-verify (recommended) or re-bootstrap with force?
- Service facts missing → proceed to Phase 2

### Phase 2 — Intake (Service Truth)

Ask questions **one at a time**. Each question has a choice menu with recommended default.

See [references/INTAKE.md](references/INTAKE.md) for the full question set, choice menus, validation rules, and staleness handling.

| # | Question | Required |
|---|----------|----------|
| 1 | Approver identity | Yes |
| 2 | One-sentence repo description | Yes |
| 3 | Non-negotiables (2–7 invariants) | Yes |
| 4 | Critical flows (2–7 paths) | Yes |
| 5 | Repo type (choice menu) | Yes |
| 6 | Governance posture (choice menu) | Yes |
| 7 | Operational posture (choice menu) | Yes |

### Phase 3 — Record Service Truth

Write answers to context artifacts. If artifacts already exist, show diff before overwriting.

Fields: `service.purpose`, `service.type`, `service.non_negotiables`, `service.critical_paths`, `service.governance_profile`, `service.operational_posture`, `service.approved_by`.

### Phase 4 — Discovery

Auto-discover from repo structure:
- **Engineering:** entrypoints, module roots, test framework, linter, package manager
- **Delivery:** CI system, release process, deploy targets
- **Observability:** runbooks, dashboards, metrics endpoints (if present)

Mark discovered facts as `inferred` until user verifies.

### Phase 5 — Enrichment (optional)

Ask which enrichment depth the user wants:

| Depth | What it does |
|-------|-------------|
| **Skip** | Proceed to readiness report |
| **AGENTS.md only** (Recommended) | Invoke `lets-bootstrap-agents-md` |
| **Full** | AGENTS.md + coding standards extraction + architecture doc scaffold |

See [references/ENRICHMENT.md](references/ENRICHMENT.md) for coding standards extraction protocol and architecture scaffolding.

### Phase 6 — Readiness Report

Score and report:
- Per-pillar status (service, engineering, delivery, observability)
- Readiness level (L0–L3+)
- Score (0–100, weighted)
- Top 3 gaps with remediation steps
- Recommended next action

See [references/OUTPUTS.md](references/OUTPUTS.md) for readiness levels, scoring weights, and artifact layout.

---

## Error Handling

- If no Makefile/pyproject.toml/CI found: note sparse engineering discovery, rely on README and directory structure
- If user provides fewer than 2 non-negotiables: prompt once more — "Can you add at least one more? Non-negotiables gate AI mutations."
- If existing artifacts are corrupted: diagnose from available files, re-run Phase 1 before retrying
- If enrichment fails mid-phase: surface partial result, ask retry or skip

---

## Anti-patterns

- **Bootstrapping without status check** — Phase 1 determines what already exists
- **Batching intake questions** — ask one at a time, validate before next
- **Overwriting without diff** — always show what will change before writing
- **Skipping readiness report** — Phase 6 is the completion evidence
- **Inventing service truth** — unattested facts must be flagged as `inferred`
- **Scoring inferred facts** — only verified artifacts earn readiness score
- **Committing on behalf of user** — context artifacts remain user-owned

---

## Outputs

- Output: Intake card showing present/verified/stale/missing status
- Output: Context artifacts (`service.yaml`, `engineering.yaml`, optionally `delivery.yaml`, `observability.yaml`)
- Output: Readiness report with level (L0–L3+), score (0–100), top gaps, next action

Done when: Phase 6 readiness report has been shown to the user and any blocking bootstrap error has been surfaced explicitly.

---

## References (Progressive Disclosure)

Read each reference only when its phase activates — not upfront.

| Reference | When to read |
|-----------|-------------|
| [INTAKE.md](references/INTAKE.md) | Phase 2 — question set, choice menus, validation, staleness handling |
| [ENRICHMENT.md](references/ENRICHMENT.md) | Phase 5 — coding standards extraction, AGENTS.md handoff, architecture scaffold |
| [OUTPUTS.md](references/OUTPUTS.md) | Phase 6 — artifact layout, readiness levels, scoring weights |

## Templates & Scripts

| Asset | Purpose | Used in |
|-------|---------|---------|
| [assets/templates/readiness-report.template.md](assets/templates/readiness-report.template.md) | Readiness report structure | Phase 6 |
| [assets/templates/service-yaml.template.yaml](assets/templates/service-yaml.template.yaml) | Service context artifact template | Phase 3 |
| [scripts/check_repo_status.sh](scripts/check_repo_status.sh) | Detect existing artifacts and their staleness | Phase 1 |

## Hard Rules

- Never overwrite existing artifacts without explicit confirmation and diff
- Never write to agent config directories as part of bootstrap
- Never commit on behalf of the user — context artifacts are user-owned
- Readiness scoring is conservative: only verified artifacts count
- If bootstrap fails mid-phase, surface partial result with what was/wasn't written
- Staleness requires explicit user decision: re-verify or re-bootstrap
