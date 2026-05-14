---
name: lets-develop-feature
description: "Full-lifecycle feature development with intake discovery, compositional delegation, staged execution, service-context binding, spec-alignment checking, architecture gates, and evidence-gated completion. Graduated rigor from trivial fixes to multi-slice features."
metadata:
  author: cogsmith-ai
  version: "5.0.0"
  tags: [implementation, change-management, delivery, governance, architecture, intake, discovery]
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
handoffs:
  - trigger: no_approved_spec
    delegate_to: lets-brainstorm
    artifact_expected: spec.md
    resume_at: stage_1_ground
    required: true
    mode_override: null
    context_pass: [intent_echo, discovery_signals]
  - trigger: ux_surface_detected
    delegate_to: lets-research-ux-walkthrough
    artifact_expected: friction-log.md
    resume_at: stage_4_architecture
    required: false
    depends_on: [no_approved_spec]
    context_pass: [intent_echo, upstream_spec]
  - trigger: competitive_context_needed
    delegate_to: lets-research-competitive-scan
    artifact_expected: comparison.md
    resume_at: stage_3_plan
    required: false
    context_pass: [intent_echo, discovery_signals]
  - trigger: persona_validation_needed
    delegate_to: lets-persona-simulate
    artifact_expected: persona-report.md
    resume_at: stage_3_plan
    required: false
    depends_on: [no_approved_spec]
    context_pass: [upstream_spec]
  - trigger: prd_grooming_needed
    delegate_to: lets-research-prd-grooming
    artifact_expected: requirements.md
    resume_at: stage_3_plan
    required: false
    context_pass: [intent_echo, discovery_signals]
outcome_runtime:
  open_agency_zones:
    - implementation_strategy
    - risk_decomposition
    - test_strategy
    - architecture_decision
    - work_package_ordering
    - methodology_selection
    - scenario_coverage
    - control_level_recommendation
    - signal_detection
    - delegation_ordering
  governed_action_zones:
    - filesystem_mutation
    - dependency_change
    - external_side_effect
    - schema_migration
    - public_api_change
    - upstream_skill_invocation
  allowed_moves:
    - challenge_initial_framing
    - reorder_work_by_risk
    - request_missing_context
    - propose_scope_cut
    - escalate_architecture_concern
    - request_design_checkpoint
    - block_on_missing_evidence
    - trigger_spec_revision
    - recommend_control_level
    - offer_optional_delegation
    - escalate_control_level
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
    - do_not_skip_intent_echo
    - do_not_plan_without_approved_spec
    - do_not_select_control_level_without_user_confirmation
  required_decision_frames:
    - implementation_strategy
    - architecture_decision
    - methodology_choice
    - control_level_selection
    - delegation_plan
  validation_gates:
    - intent_confirmation_gate
    - control_level_gate
    - delegation_completion_gate
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
    - control_level_override
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

# lets-develop-feature

Compositional feature development with intake discovery, upstream skill delegation, staged
execution, and evidence-gated completion. Each phase/stage has explicit state. Operational
detail lives in phase-specific references — this file is the contract.

---

## Phases & Stages

```
Phase 0: Intake & Discovery   → Understand user, detect signals, delegate to upstream skills
  Turn 1: Intent echo         → Confirm understanding
  Turn 2: Signals + control   → Recommend involvement level
  Turn 3: Delegation plan     → Invoke upstream skills, collect artifacts

Stage 1: Ground               → Read repo context + service constraints (BINDING)
Stage 2: Classify             → Determine rigor level (MINIMAL / STANDARD / ELEVATED / FULL)
Stage 3: Plan                 → Validate spec against service context, produce execution packet
Stage 4: Architecture         → Design gate (required | skipped with reason)
Stage 5: Checkpoint           → User reviews plan (control level determines behavior)
Stage 6: Implement            → Story tasks + packages, with spec re-read at each milestone
Stage 7: Test                 → Methodology-aware verification
Stage 8: Verify               → Compare delivered work against plan + spec + tasks + evidence
Stage 9: Complete             → Quality scorecard + handoff
```

**Every phase/stage** ends in one of: `completed` | `skipped` (with reason) | `blocked` (with blocker).

**No stage is ever left implicit.** The handoff shows all phases and stages accounted for.

---

## Phase 0 — Intake & Discovery

Phase 0 is conversational. Its job is to understand the user and route to the right discovery
skills before any artifacts are produced. It replaces the old "spec-constructing" behavior with
compositional delegation.

### Turn 1 — Intent Echo

Reflect the user's request back in plain language. No process jargon. Confirm understanding.

```
"You want to [plain-language echo]. Is that right?"
```

**Turn 1 is NEVER skipped.** Even when a spec exists, confirm what the user is asking for.

See [references/INTAKE.md](references/INTAKE.md) for rules, anti-patterns, and error handling.

### Turn 2 — Signals + Control Recommendation

After intent is confirmed, present:
1. Spec status (one line)
2. Discovery signals (bullet list of what you detected)
3. Control recommendation with reasoning
4. Confirmation question

Control levels:
- **Autonomous** — "I'll plan and implement, bring you the result"
- **Checkpoints** — "I'll bring you the design and plan for approval"
- **Collaborative** — "We'll explore each decision together"

See [references/CONTROL-LEVEL.md](references/CONTROL-LEVEL.md) for recommendation logic and stage × control matrix.

### Turn 3 — Delegation Plan

Match active signals against `handoffs:` declarations in frontmatter. Present delegation plan.
Execute confirmed delegations. Collect approved artifacts.

Skip Turn 3 if no delegations trigger (spec exists, signals are clean).

See [references/DELEGATION.md](references/DELEGATION.md) for handoff contract, artifact format, and execution protocol.

**Phase 0 output:** Confirmed intent, chosen control level, collected upstream artifacts (in `intake/` and `upstream/` directories).

---

## Spec-Driven Mode

This skill is **always spec-driven**. It does not construct specs internally.

- When a spec exists: use it directly
- When no spec exists: delegate to `lets-brainstorm` (via handoff declaration)
- When requirements are raw: delegate to `lets-research-prd-grooming`

The spec is the authority for WHAT and WHY. The execution packet is the authority for HOW.
The story task list is the authority for ordered implementation.

When the `lets` CLI is available, prefer Core primitives:

```bash
lets spec status --format json
lets spec export <feature_key>
lets journey init <feature_key> --repo-root .
lets journey status <journey_id>
```

---

## Repo-Local Run State (`.lets/`)

Store the run's working artifacts in the repo so the workflow is resumable and auditable:

```
.lets/
  runs/
    develop-feature/
      latest
      <run_id>/
        intake/
          intent-echo.md
          discovery-signals.json
          control-level.md
          delegation-plan.md
        upstream/
          spec.md
          friction-log.md
          comparison.md
          persona-report.md
          requirements.md
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

---

## When to Use

- Implementing a feature, bugfix, or refactor that touches production code
- Any change that benefits from structured planning before coding
- When no spec exists (Phase 0 will delegate to discovery skills)
- Delivery chain: **lets-develop-feature** → lets-verify-change → lets-review-code

## When Not to Use

- Verifying an existing change → `lets-verify-change`
- Reviewing a PR → `lets-review-pr`
- Single-line zero-risk typo fix → just fix it
- Research/discovery without implementing → `lets-brainstorm`
- Pure exploration with no implementation intent → `lets-brainstorm`

---

## Graduated Rigor (Artifact Depth)

| Level | When | Stages active | Detail |
|-------|------|---------------|--------|
| **MINIMAL** | Trivial + low risk + mechanical | 0,1,2,3(minimal),6,8(quick),9 | [CLASSIFICATION.md](references/CLASSIFICATION.md) |
| **STANDARD** | Typical feature/bugfix | All stages, arch may be skipped | Full packet + scenarios |
| **ELEVATED** | Cross-module, new abstractions, API | All stages, arch required | Design checkpoint + traceability |
| **FULL** | Large, critical, irreversible | All + per-file confirmation | Stacked PRs + quality scorecard |

See [references/CLASSIFICATION.md](references/CLASSIFICATION.md) for classification matrix and gate overrides.

## Control Level (Interaction Depth)

| Level | When recommended | Effect |
|-------|-----------------|--------|
| **Autonomous** | Low risk, spec exists, familiar pattern | Skip pauses except hard-stops |
| **Checkpoints** | Standard features, moderate risk | Plan gate + architecture decisions |
| **Collaborative** | Novel/risky/ambiguous, user preference | Every boundary is a conversation |

Rigor and control are orthogonal. See [references/CONTROL-LEVEL.md](references/CONTROL-LEVEL.md) for the full matrix.

**Safety invariant:** FULL rigor forces minimum Checkpoints control.

---

## Stage Contracts (Summary)

### Stage 1 — Ground in Repo + Service Context

Read AGENTS.md, extract non-negotiables, critical paths, boundaries. These BIND the run.

**Control behavior:**
- Autonomous/Checkpoints: silent
- Collaborative: present summary, ask "anything to add?"

**Output:** Service context summary. See [references/SERVICE-CONTEXT.md](references/SERVICE-CONTEXT.md).

### Stage 2 — Classify & Select Rigor

Classify by type/scale/risk/complexity. Apply gate overrides. Inherit control level from Phase 0.

**Control behavior:**
- Autonomous/Checkpoints: silent (shown in Stage 5)
- Collaborative: present for confirmation

**Output:** Classification + rigor level. See [references/CLASSIFICATION.md](references/CLASSIFICATION.md).

### Stage 3 — Plan

Validate the upstream spec against service context (spec-readiness). Resolve conflicts between
spec intent and repo reality. Build the execution packet from the validated spec.

Stage 3 no longer constructs specs. It translates an approved spec into an implementable plan.

**Inputs:** `upstream/spec.md` + `service-context.md` + optional enrichment artifacts
**Output:** Spec-readiness record, execution packet, story tasks, scenario matrix, assumptions log.

See [references/PLANNING.md](references/PLANNING.md).

### Stage 4 — Architecture Gate

Opens when: new abstraction, boundary change, API change, schema change. Answer the 6 gate questions.

**Control behavior:**
- Autonomous: auto-resolve, log decisions
- Checkpoints: pause if gate opens
- Collaborative: always present

**Output:** Architecture notes (or explicit `skipped` with reason). See [references/ARCHITECTURE-GATE.md](references/ARCHITECTURE-GATE.md).

### Stage 5 — Checkpoint

Present plan to user for review.

**Control behavior:**
- Autonomous: **skip**
- Checkpoints: present full packet, wait for approval
- Collaborative: present section-by-section, each package gets confirmation

**Output:** User approval. See [references/PLANNING.md](references/PLANNING.md).

### Stage 6 — Implement

Execute story tasks and work packages in dependency order. **Mandatory spec re-read at each milestone boundary.** Mark completed task items, record blockers, stop on spec contradiction.

**Control behavior:**
- Autonomous: no mid-run pauses except hard-stops
- Checkpoints: pause on blockers or assumption invalidation
- Collaborative: pause at each package boundary

**Output:** Code changes + living artifacts. See [references/IMPLEMENTATION.md](references/IMPLEMENTATION.md).

### Stage 7 — Test

Methodology-aware testing per work package.

**Control behavior:**
- Autonomous: report failures only
- Checkpoints: report summary
- Collaborative: walk through coverage vs scenario matrix

**Output:** Test results + coverage evidence. See [references/METHODOLOGY.md](references/METHODOLOGY.md).

### Stage 8 — Verify

Compare delivered work against plan, spec, story tasks, service context, scenario coverage.

**Control behavior:**
- Autonomous: surface only if verdict = BLOCKED
- Checkpoints: present verdict with evidence summary
- Collaborative: full per-requirement comparison

**Output:** Verification verdict (ready | blocked). See [references/VERIFICATION.md](references/VERIFICATION.md).

### Stage 9 — Complete

Quality scorecard. Handoff packet with full stage status.

**Control behavior:**
- Autonomous: present final summary
- Checkpoints: present scorecard + result
- Collaborative: scorecard review before handoff confirmation

**Output:** Scorecard + handoff. See [references/COMPLETION.md](references/COMPLETION.md).

---

## Spec-Alignment Protocol

When a spec exists (always, post-Phase-0), implementation must align to it continuously:

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
| 16 | I will NOT produce artifacts before confirming I understood the user's intent (Phase 0 Turn 1) |
| 17 | I will NOT begin planning without an approved spec — either pre-existing or produced by a delegated discovery skill |
| 18 | I will NOT select a control level without presenting my recommendation to the user |

---

## Completion Quality Scorecard

Before handoff, score the delivery (STANDARD+ rigor):

| Dimension | 0–5 | Criteria |
|-----------|-----|----------|
| **Spec adherence** | | Does implementation match the spec? |
| **Test coverage** | | Are scenarios from the matrix covered? |
| **Service constraint preservation** | | Are non-negotiables honored with evidence? |
| **Scope discipline** | | Did we stay within the execution packet? |

**Pass threshold: ≥16/20.** Below threshold = `blocked`, identify gaps.

See [references/COMPLETION.md](references/COMPLETION.md) for full scoring rubric.

---

## Error Handling

- If AGENTS.md is missing: proceed without service context, note `Stage 1: completed (no AGENTS.md — no service constraints bound)`
- If user rejects intent echo: ask "What did you mean?" and re-echo
- If user rejects control recommendation: accept their choice, log it
- If delegated skill fails: pause, explain, ask user how to proceed
- If delegated skill produces draft (not approved): pause, ask user to approve or re-run
- If user says "just do it" mid-Phase-0: set autonomous, but still require spec (brainstorm in light mode)
- If spec/task description is ambiguous: Phase 0 catches this — delegate to brainstorm
- If critical clarifications remain: mark Stage 3 blocked (brainstorm should have resolved these)
- If a spec contradiction is discovered mid-implementation: HARD STOP — surface it
- If a work package verification fails: fix within scope or mark BLOCKED
- If quality scorecard < 16/20: mark delivery BLOCKED — identify specific gaps
- If an assumption is invalidated: stop at package boundary, assess impact, re-plan if significant

---

## Anti-patterns

- **Implementing before presenting the packet** — the plan exists to catch problems before they become code
- **Skipping Phase 0 intent echo** — never assume you understood correctly
- **Constructing specs internally** — delegate to brainstorm; that's its job
- **Selecting control level without asking** — always present your recommendation
- **Skipping spec re-read** — memory drifts; re-reading at boundaries catches contradictions early
- **Silent scope expansion** — touching files not in the packet without stopping to ask
- **Weakening error handling** — existing catches, retries, and fallbacks exist for a reason
- **Fabricating test results** — if you didn't run it, you don't know the result
- **Leaving stages implicit** — every stage must be explicitly completed, skipped with reason, or blocked
- **Ignoring service context** — non-negotiables from AGENTS.md are binding, not advisory
- **Claiming untested confidence** — score honestly; gaps are better documented than hidden
- **Treating rigor as control** — rigor is artifact depth; control is interaction depth; they're orthogonal

---

## Outputs

- Intent echo record (confirmed understanding)
- Control level decision (with reasoning and user confirmation)
- Delegation plan and collected upstream artifacts
- Service context summary (non-negotiables, critical paths)
- Change classification (type, scale, risk, rigor)
- Spec-readiness record (validates upstream spec against service context)
- Execution packet with scenarios and assumptions
- Story task list with dependency order, parallel markers, and independent test criteria
- Design artifact inventory
- Journey link (feature key, journey ID, evidence references when available)
- Architecture notes (or explicit skip)
- Per-package verification evidence
- Traceability record (requirement → code → test)
- Spec alignment check results
- Verification verdict (ready | blocked)
- Quality scorecard (≥16/20 to pass)
- Phase/stage status table (Phase 0 + all 9 stages accounted for)
- Handoff to lets-verify-change

---

## References (Progressive Disclosure)

Read each reference only when its phase/stage activates — not upfront.

| Reference | When to read |
|-----------|-------------|
| [INTAKE.md](references/INTAKE.md) | Phase 0 — intent echo, signals, delegation protocol |
| [DELEGATION.md](references/DELEGATION.md) | Phase 0 Turn 3 — handoff contract and artifact format |
| [CONTROL-LEVEL.md](references/CONTROL-LEVEL.md) | Phase 0 Turn 2 — control level selection and stage matrix |
| [CLASSIFICATION.md](references/CLASSIFICATION.md) | Stage 2 — selecting rigor level |
| [SERVICE-CONTEXT.md](references/SERVICE-CONTEXT.md) | Stage 1 — reading service constraints |
| [PLANNING.md](references/PLANNING.md) | Stage 3/5 — validating spec and building the plan |
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

| Asset | Purpose | Used in |
|-------|---------|---------|
| [workflow/templates/intake/intent-echo.md](workflow/templates/intake/intent-echo.md) | Intent echo record | Phase 0 Turn 1 |
| [workflow/templates/intake/discovery-signals.json](workflow/templates/intake/discovery-signals.json) | Signal detection results | Phase 0 Turn 2 |
| [workflow/templates/intake/control-level.md](workflow/templates/intake/control-level.md) | Control level decision | Phase 0 Turn 2 |
| [workflow/templates/intake/delegation-plan.md](workflow/templates/intake/delegation-plan.md) | Delegation execution record | Phase 0 Turn 3 |
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
