---
name: lets-develop-feature
description: "Full-lifecycle feature development with staged execution, service-context binding, spec-alignment checking, architecture gates, and evidence-gated completion. Graduated rigor from trivial fixes to multi-slice features."
metadata:
  author: cogsmith-ai
  version: "4.1.0"
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
    - do_not_implement_with_unresolved_critical_clarifications
    - do_not_expand_scope_silently
    - do_not_skip_verification
    - do_not_skip_failed_checklists_without_user_acknowledgement
    - do_not_weaken_error_handling
    - do_not_ignore_service_context
    - do_not_leave_stages_implicit
    - do_not_proceed_past_spec_contradiction
    - do_not_treat_unmapped_tasks_as_complete
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
Stage 3: Plan           → Spec readiness + execution packet + story tasks + scenarios
Stage 4: Architecture   → Design gate (required | skipped with reason)
Stage 5: Checkpoint     → User reviews plan (STANDARD+)
Stage 6: Implement      → Story tasks + packages, with spec re-read at each milestone
Stage 7: Test           → Methodology-aware verification
Stage 8: Verify         → Compare delivered work against plan + spec + tasks + evidence
Stage 9: Complete       → Quality scorecard + handoff
```

**Every stage** ends in one of: `completed` | `skipped` (with reason) | `blocked` (with blocker).

**No stage is ever left implicit.** The handoff shows all 9 stages accounted for.

---

## Spec-Driven Mode

This skill is spec-driven when a spec exists and spec-constructing when it does not.

When the `lets` CLI is available, prefer Core primitives over ad hoc files:

```bash
lets spec status --format json
lets spec export <feature_key>
lets journey init <feature_key> --repo-root .
lets journey status <journey_id>
```

Use the results to populate the `.lets/runs/develop-feature/<run_id>/` artifacts. The spec workspace is the authority for WHAT and WHY, the execution packet is the authority for HOW, the story task list is the authority for ordered implementation, and the handoff/evidence records are the authority for completion.

If no formal spec exists, derive a bounded spec-readiness record from the user's request before planning. Critical clarifications block implementation; non-critical assumptions may proceed only when documented in the assumptions log and traceability record.

Core state model:

- **`.lets/` workflow harness:** repo-local, resumable skill state and artifact checklist.
- **`lets spec`:** ground-truth-compatible feature/spec source when available.
- **`lets journey`:** link between spec, governed runs, receipts, and exported evidence.
- **Coordination concepts:** task dependencies, blockers, attention items, and follow-ups represented in story tasks and handoff, not as a separate source of truth.
- **Handoffs and evidence:** Stage 9 passes a concrete handoff to `lets-verify-change`; engine receipts and evidence bundles are referenced when available.

---

## Repo-Local Run State (`.lets/`) (Recommended)

Store the run’s working artifacts *in the repo* so the workflow is resumable and auditable:

```
.lets/
  runs/
    develop-feature/
      latest
      <run_id>/
        run-state.json
        spec-readiness.md
        clarifications.md
        service-context.md
        execution-packet.md
        story-tasks.md
        design-artifacts.md
        journey-link.md
        scenario-matrix.md
        traceability.md
        verification-record.md
        handoff.md
```

**Optional helper (letsbe10x):** if you have the `lets` CLI available, you can scaffold these files:

```bash
lets develop-feature init <slug>
lets develop-feature status
lets develop-feature check
```

If you don’t have `lets`, create the directory manually and start from the templates in `assets/templates/`.

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

Establish spec readiness, resolve critical clarifications, produce the execution packet, and decompose work into user-story task slices with scenario coverage.

**Output:** Spec-readiness record, clarifications log, execution packet, story tasks, scenario matrix, assumptions log. See [references/PLANNING.md](references/PLANNING.md).

### Stage 4 — Architecture Gate

Opens when: new abstraction, boundary change, API change, schema change. Answer the 6 gate questions.

**Output:** Architecture notes (or explicit `skipped` with reason). See [references/ARCHITECTURE-GATE.md](references/ARCHITECTURE-GATE.md).

### Stage 5 — Checkpoint

Present plan to user for review. Validate completeness.

**Output:** User approval. See [references/PLANNING.md](references/PLANNING.md).

### Stage 6 — Implement

Execute story tasks and work packages in dependency order. **Mandatory spec re-read at each milestone boundary.** Mark completed task items, record blockers as attention items, and stop on spec contradiction.

**Output:** Code changes + living artifacts (traceability, notes). See [references/IMPLEMENTATION.md](references/IMPLEMENTATION.md).

### Stage 7 — Test

Methodology-aware testing per work package.

**Output:** Test results + coverage evidence. See [references/METHODOLOGY.md](references/METHODOLOGY.md).

### Stage 8 — Verify

Compare delivered work against plan, spec, story tasks, service context, scenario coverage, and available journey/evidence links. Not "run tests again" — a dedicated comparison.

**Output:** Verification verdict (ready | blocked). See [references/VERIFICATION.md](references/VERIFICATION.md).

### Stage 9 — Complete

Quality scorecard. Handoff packet with full stage status.

**Output:** Scorecard + handoff. See [references/COMPLETION.md](references/COMPLETION.md).

---

## Spec-Alignment Protocol

When a spec/task description exists, implementation must align to it continuously:

1. **Before each work package:** Re-read the relevant section of the spec
2. **Before each story task:** Confirm requirement/story/scenario mapping
3. **During implementation:** If code reveals spec contradiction → STOP
4. **On contradiction:** Surface it, update spec understanding or revise approach
5. **At verification:** Check each spec requirement against implemented code and evidence

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
| 13 | I will NOT implement while critical clarifications remain unresolved |
| 14 | I will NOT skip a failed checklist without explicit user acknowledgement |
| 15 | I will NOT mark tasks complete unless each task maps to a requirement, story, scenario, or documented infrastructure need |

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

## Error Handling

- If AGENTS.md is missing: proceed without service context, note `Stage 1: completed (no AGENTS.md — no service constraints bound)`
- If spec/task description is ambiguous: extract inferred requirements, surface to user for confirmation before implementing
- If critical clarifications remain after spec readiness: mark Stage 3 blocked and ask the user to resolve them
- If a checklist has incomplete blocking items: stop and ask whether to fix the checklist or proceed with documented risk
- If a spec contradiction is discovered mid-implementation: HARD STOP — surface it, do not silently proceed
- If a work package verification fails: fix within scope or mark BLOCKED — do not skip to next package
- If quality scorecard < 16/20: mark delivery BLOCKED — identify specific gaps before attempting fix
- If an assumption is invalidated during implementation: stop at package boundary, assess impact, re-plan if significant
- If forge check fails on the delivered code: fix lint/type/test issues before proceeding to completion

---

## Anti-patterns

- **Implementing before presenting the packet** — the plan exists to catch problems before they become code
- **Skipping spec re-read** — memory drifts; re-reading at boundaries catches contradictions early
- **Silent scope expansion** — touching files not in the packet without stopping to ask
- **Weakening error handling** — existing catches, retries, and fallbacks exist for a reason
- **Fabricating test results** — if you didn't run it, you don't know the result
- **Leaving stages implicit** — every stage must be explicitly completed, skipped with reason, or blocked
- **Ignoring service context** — non-negotiables from AGENTS.md are binding, not advisory
- **Claiming untested confidence** — score honestly; gaps are better documented than hidden

---

## Outputs

- Service context summary (non-negotiables, critical paths)
- Change classification (type, scale, risk, rigor)
- Spec-readiness record and clarifications log
- Execution packet with scenarios and assumptions
- Story task list with dependency order, parallel markers, and independent test criteria
- Design artifact inventory (research decisions, data model, contracts, quickstart, or explicit skips)
- Journey link (feature key, journey ID, engine run IDs, evidence references when available)
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

Read each reference only when its stage activates — not upfront.

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

## Templates & Scripts

Use these to scaffold artifacts — do not invent formats from scratch.

| Asset | Purpose | Used in |
|-------|---------|---------|
| [assets/templates/execution-packet.template.md](assets/templates/execution-packet.template.md) | Execution packet structure | Stage 3 |
| [assets/templates/handoff.template.md](assets/templates/handoff.template.md) | Handoff packet structure | Stage 9 |
| [assets/templates/traceability.template.md](assets/templates/traceability.template.md) | Implementation traceability record | Stage 6 |
| [workflow/templates/spec-readiness.md](workflow/templates/spec-readiness.md) | Spec readiness and checklist state | Stage 3 |
| [workflow/templates/clarifications.md](workflow/templates/clarifications.md) | Critical clarification tracking | Stage 3 |
| [workflow/templates/story-tasks.md](workflow/templates/story-tasks.md) | Requirement/story/task decomposition | Stage 3/6 |
| [workflow/templates/design-artifacts.md](workflow/templates/design-artifacts.md) | Research, model, contract, quickstart inventory | Stage 3/4 |
| [workflow/templates/journey-link.md](workflow/templates/journey-link.md) | Core journey/evidence/run linkage | Stage 3/8/9 |
| [scripts/classify_risk.sh](scripts/classify_risk.sh) | Automated risk signal scanning | Stage 2 |
| [scripts/check_blast_radius.sh](scripts/check_blast_radius.sh) | Importer analysis for blast radius | Stage 2/3 |
