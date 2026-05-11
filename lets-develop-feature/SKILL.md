---
name: lets-develop-feature
description: "Full-lifecycle feature development with staged execution, service-context binding, spec-alignment checking, architecture gates, and evidence-gated completion. Graduated rigor from trivial fixes to multi-slice features."
metadata:
  author: cogsmith-ai
  version: "4.0.0"
  tags: [implementation, change-management, delivery, governance, architecture]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-develop-feature/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - implement this
  - build this feature
  - make this change
  - develop this
  - code this up
  - implement the spec
  - execute the plan
  - build this
  - implement the feature
  - code this feature
outcome_runtime:
  open_agency_zones:
    - implementation_strategy
    - risk_decomposition
    - test_strategy
    - architecture_decision
    - work_package_ordering
    - methodology_selection
    - scenario_coverage
  governed_action_zones:
    - filesystem_mutation
    - dependency_change
    - external_side_effect
    - schema_migration
    - public_api_change
  allowed_moves:
    - challenge_initial_framing
    - reorder_work_by_risk
    - request_missing_context
    - propose_scope_cut
    - escalate_architecture_concern
    - request_design_checkpoint
    - block_on_missing_evidence
    - trigger_spec_revision
  hard_limits:
    - do_not_bypass_policy_gates
    - do_not_fabricate_test_results
    - do_not_commit_secrets
    - do_not_implement_before_packet_presented
    - do_not_expand_scope_silently
    - do_not_skip_verification
    - do_not_weaken_error_handling
    - do_not_ignore_service_context
    - do_not_leave_stages_implicit
    - do_not_proceed_past_spec_contradiction
  required_decision_frames:
    - implementation_strategy
    - architecture_decision
    - methodology_choice
  validation_gates:
    - execution_packet_gate
    - verification_before_completion
    - governance_checkpoint
    - design_checkpoint
    - evidence_gate
    - service_context_gate
    - spec_alignment_gate
    - completion_quality_gate
  mutation_policy: additive_only
  human_checkpoint_triggers:
    - irreversible_mutation
    - compliance_risk
    - critical_path_modification
    - architecture_boundary_change
    - public_api_surface_change
    - service_nonnegotiable_tension
    - spec_deviation_discovered
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

# lets-develop-feature

Staged feature development with service-context binding, spec-alignment checking, and evidence-gated completion. Each stage has explicit state. Operational detail lives in phase-specific references — this file is the contract.

---

## Stages & Gates

```
Stage 1: Ground         → Read repo context + service constraints (BINDING)
Stage 2: Classify       → Determine rigor level (MINIMAL / STANDARD / ELEVATED / FULL)
Stage 3: Plan           → Execution packet + scenarios + assumptions
Stage 4: Architecture   → Design gate (required | skipped with reason)
Stage 5: Checkpoint     → User reviews plan (STANDARD+)
Stage 6: Implement      → Per-package, with spec re-read at each milestone
Stage 7: Test           → Methodology-aware verification
Stage 8: Verify         → Compare delivered work against plan + spec + service context
Stage 9: Complete       → Quality scorecard + handoff
```

**Every stage** ends in one of: `completed` | `skipped` (with reason) | `blocked` (with blocker).

**No stage is ever left implicit.** The handoff shows all 9 stages accounted for.

---

## When to Use

- Implementing a feature, bugfix, or refactor that touches production code
- Any change that benefits from structured planning before coding
- Delivery chain: **lets-develop-feature** → lets-verify-change → lets-review-code

## When Not to Use

- Verifying an existing change → `lets-verify-change`
- Reviewing a PR → `lets-review-pr`
- Single-line zero-risk typo fix → just fix it
- Research/discovery without implementing → `lets-brainstorm`

---

## Graduated Rigor

| Level | When | Stages active | Detail |
|-------|------|---------------|--------|
| **MINIMAL** | Trivial + low risk + mechanical | 1,2,3(minimal),6,8(quick),9 | [CLASSIFICATION.md](references/CLASSIFICATION.md) |
| **STANDARD** | Typical feature/bugfix | All stages, arch may be skipped | Full packet + scenarios |
| **ELEVATED** | Cross-module, new abstractions, API | All stages, arch required | Design checkpoint + traceability |
| **FULL** | Large, critical, irreversible | All + per-file confirmation | Stacked PRs + quality scorecard |

See [references/CLASSIFICATION.md](references/CLASSIFICATION.md) for classification matrix and gate overrides.

---

## Stage Contracts (Summary)

### Stage 1 — Ground in Repo + Service Context

Read AGENTS.md, extract non-negotiables, critical paths, boundaries. These BIND the run.

**Output:** Service context summary. See [references/SERVICE-CONTEXT.md](references/SERVICE-CONTEXT.md).

### Stage 2 — Classify & Select Rigor

Classify by type/scale/risk/complexity. Apply gate overrides.

**Output:** Classification + rigor level. See [references/CLASSIFICATION.md](references/CLASSIFICATION.md).

### Stage 3 — Plan

Produce execution packet with work packages, scenario matrix, assumptions.

**Output:** Execution packet, scenario matrix, assumptions log. See [references/PLANNING.md](references/PLANNING.md).

### Stage 4 — Architecture Gate

Opens when: new abstraction, boundary change, API change, schema change. Answer the 6 gate questions.

**Output:** Architecture notes (or explicit `skipped` with reason). See [references/ARCHITECTURE-GATE.md](references/ARCHITECTURE-GATE.md).

### Stage 5 — Checkpoint

Present plan to user for review. Validate completeness.

**Output:** User approval. See [references/PLANNING.md](references/PLANNING.md).

### Stage 6 — Implement

Execute work packages in order. **Mandatory spec re-read at each milestone boundary.** Stop on spec contradiction.

**Output:** Code changes + living artifacts (traceability, notes). See [references/IMPLEMENTATION.md](references/IMPLEMENTATION.md).

### Stage 7 — Test

Methodology-aware testing per work package.

**Output:** Test results + coverage evidence. See [references/METHODOLOGY.md](references/METHODOLOGY.md).

### Stage 8 — Verify

Compare delivered work against plan, spec, service context, scenario coverage. Not "run tests again" — a dedicated comparison.

**Output:** Verification verdict (ready | blocked). See [references/VERIFICATION.md](references/VERIFICATION.md).

### Stage 9 — Complete

Quality scorecard. Handoff packet with full stage status.

**Output:** Scorecard + handoff. See [references/COMPLETION.md](references/COMPLETION.md).

---

## Spec-Alignment Protocol

When a spec/task description exists, implementation must align to it continuously:

1. **Before each work package:** Re-read the relevant section of the spec
2. **During implementation:** If code reveals spec contradiction → STOP
3. **On contradiction:** Surface it, update spec understanding or revise approach
4. **At verification:** Check each spec requirement against implemented code

**Spec contradiction = hard stop.** Never silently proceed past a deviation.

See [references/SPEC-ALIGNMENT.md](references/SPEC-ALIGNMENT.md) for the full protocol.

---

## Negative Guardrails (What I REFUSE To Do)

| # | Guardrail |
|---|-----------|
| 1 | I will NOT implement before presenting the execution packet |
| 2 | I will NOT expand scope without stopping and asking |
| 3 | I will NOT weaken existing error handling |
| 4 | I will NOT ignore service context constraints |
| 5 | I will NOT fabricate test results or claim untested confidence |
| 6 | I will NOT leave stages implicit — every stage is completed or explicitly skipped |
| 7 | I will NOT commit secrets |
| 8 | I will NOT re-plan inside implementation (stop and update the plan) |
| 9 | I will NOT skip reading files before editing them |
| 10 | I will NOT proceed past a spec contradiction without surfacing it |
| 11 | I will NOT claim completion without running the quality scorecard |
| 12 | I will NOT soften findings or imply confidence I don't have |

---

## Completion Quality Scorecard

Before handoff, score the delivery (STANDARD+ rigor):

| Dimension | 0–5 | Criteria |
|-----------|-----|----------|
| **Spec adherence** | | Does implementation match the task/spec? |
| **Test coverage** | | Are scenarios from the matrix covered? |
| **Service constraint preservation** | | Are non-negotiables honored with evidence? |
| **Scope discipline** | | Did we stay within the execution packet? |

**Pass threshold: ≥16/20.** Below threshold = `blocked`, identify gaps.

See [references/COMPLETION.md](references/COMPLETION.md) for full scoring rubric.

---

## Outputs

- Service context summary (non-negotiables, critical paths)
- Change classification (type, scale, risk, rigor)
- Execution packet with scenarios and assumptions
- Architecture notes (or explicit skip)
- Per-package verification evidence
- Traceability record (requirement → code → test)
- Spec alignment check results
- Verification verdict (ready | blocked)
- Quality scorecard (≥16/20 to pass)
- Stage status table (all 9 accounted for)
- Handoff to lets-verify-change

---

## References (Progressive Disclosure)

| Reference | When to read |
|-----------|-------------|
| [CLASSIFICATION.md](references/CLASSIFICATION.md) | Stage 2 — selecting rigor level |
| [SERVICE-CONTEXT.md](references/SERVICE-CONTEXT.md) | Stage 1 — reading service constraints |
| [PLANNING.md](references/PLANNING.md) | Stage 3/5 — building and reviewing the plan |
| [ARCHITECTURE-GATE.md](references/ARCHITECTURE-GATE.md) | Stage 4 — design decisions |
| [IMPLEMENTATION.md](references/IMPLEMENTATION.md) | Stage 6 — per-package implementation discipline |
| [METHODOLOGY.md](references/METHODOLOGY.md) | Stage 7 — test methodology selection |
| [SPEC-ALIGNMENT.md](references/SPEC-ALIGNMENT.md) | Stage 6/8 — checking against spec |
| [VERIFICATION.md](references/VERIFICATION.md) | Stage 8 — verification protocol |
| [COMPLETION.md](references/COMPLETION.md) | Stage 9 — quality scorecard and handoff |
| [SCENARIO-MATRIX.md](references/SCENARIO-MATRIX.md) | Stage 3 — building scenario coverage |
| [STACKED-PRS.md](references/STACKED-PRS.md) | Stage 6 — decomposing large changes |
| [HANDOFF.md](references/HANDOFF.md) | Stage 9 — handoff packet format |
