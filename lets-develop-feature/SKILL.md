---
name: lets-develop-feature
description: "Full-lifecycle feature development with intake discovery, compositional delegation, staged execution, service-context binding, spec-alignment checking, architecture gates, and evidence-gated completion. Graduated rigor from trivial fixes to multi-slice features."
metadata:
  author: cogsmith-ai
  version: "5.2.0"
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
    fallback: inline_discovery
    context_pass: [intent_echo, discovery_signals]
  - trigger: existing_ux_surface
    delegate_to: lets-research-ux-walkthrough
    artifact_expected: friction-log.md
    resume_at: stage_4_architecture
    required: false
    depends_on: [no_approved_spec]
    context_pass: [intent_echo, upstream_spec]
  - trigger: complex_new_ux_surface
    delegate_to: devx-ui-ux
    artifact_expected: ux-design-brief.md
    resume_at: stage_3_plan
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
    - recommend_control_level
    - offer_optional_delegation
    - escalate_control_level
    - degrade_gracefully
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
    - do_not_plan_without_approved_spec_or_inline_discovery
    - do_not_complete_package_without_updating_state
    - do_not_resume_without_validating_state_against_code
  required_decision_frames:
    - implementation_strategy
    - architecture_decision
    - methodology_choice
    - control_level_selection
  validation_gates:
    - execution_packet_gate
    - verification_before_completion
    - governance_checkpoint
    - design_checkpoint
    - evidence_gate
    - service_context_gate
    - spec_alignment_gate
    - completion_quality_gate
    - state_consistency_gate
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

Feature development with intake discovery, upstream skill delegation, staged execution, and
evidence-gated completion. Graduated rigor for artifact depth, graduated control for interaction
depth.

---

## Phases & Stages

```
Phase 0: Intake & Discovery   → Understand user, detect signals, delegate or discover inline
Stage 1: Ground               → Read repo context + service constraints (BINDING)
Stage 2: Classify             → Determine rigor level (MINIMAL / STANDARD / ELEVATED / FULL)
Stage 3: Plan                 → Build execution packet from spec
Stage 4: Architecture         → Design gate (required | skipped with reason)
Stage 5: Checkpoint           → User reviews plan (control level determines behavior)
Stage 6: Implement            → Story tasks + packages, with spec re-read at each milestone
Stage 7: Test                 → Methodology-aware verification
Stage 8: Verify               → Compare delivered work against plan + spec + tasks + evidence
Stage 9: Complete             → Quality scorecard + handoff
```

**Every phase/stage** ends in one of: `completed` | `skipped` (with reason) | `blocked` (with blocker).

**Checkpointing:** Every stage transition updates `run-state.md`. Every package completion
updates both `run-state.md` and `story-tasks.md`. Status is always retrievable from
`run-state.md` without reading any other file. See [references/CHECKPOINTING.md](references/CHECKPOINTING.md).

---

## Resume Protocol

Before starting Phase 0, check for an existing run:

1. **Detect:** Look for `run-state.md` in the run directory. If found with `status != completed`, this is a resume.
2. **Validate:** Compare state against code reality (git log, test suite, story-tasks.md checkboxes).
3. **Present:** Tell the user where things stand — current stage, package, last action, next action, any discrepancies.
4. **Continue:** After acknowledgment, re-read the relevant spec section and resume from `next_action`.

If no `run-state.md` exists, this is a fresh run — proceed to Phase 0.

See [references/CHECKPOINTING.md](references/CHECKPOINTING.md) for the full protocol.

---

## Phase 0 — Intake & Discovery

Phase 0 is conversational. Its job is to ensure we have an approved spec before entering the
delivery pipeline. It adapts to context — heavy ceremony for ambiguous requests, near-invisible
for clear ones.

### Intent Confirmation

Before producing any artifacts, confirm you understood what the user wants.

**When the request is clear** (user names a specific spec, ticket, or feature key):
- Skip the echo. Acknowledge what you'll implement and move to signal detection.
- Example: User says "implement spec-042" → "I'll implement the rate limiter from spec-042. Let me check the repo context."

**When the request is ambiguous** (no spec referenced, vague scope):
- Echo intent back in plain language: "You want to [echo]. Is that right?"
- If user corrects: re-echo. If they confirm: continue.

### Signal Detection & Control

After intent is confirmed, assess two things in a single message:

**1. Do I have a spec?**
- Approved spec exists (in `.lets/`, `lets spec`, or user-referenced) → proceed to Stage 1
- No spec exists → need discovery (delegate or inline)

**2. What control level fits?**

| Control level | When | Effect on stages |
|---|---|---|
| **Autonomous** | Low risk, spec exists, familiar pattern | Skip Stage 5. Auto-resolve architecture. Bring user the result. |
| **Checkpoints** | Standard features, moderate risk | Stage 5 presents plan. Architecture gate pauses if opened. |
| **Collaborative** | Novel, risky, ambiguous, user preference | Each stage pauses for input. Design section-by-section. |

Recommend a level with one-sentence reasoning. User confirms or overrides.

**Safety invariant:** FULL rigor forces minimum Checkpoints. ELEVATED + Autonomous gets a warning.

**Control is not locked.** User can escalate ("walk me through this") or de-escalate ("just go ahead") at any point. Hard-stops (spec contradiction, security, irreversible ops) always pause regardless of control level.

### Discovery: Delegation or Inline

When no approved spec exists, you need discovery. Two paths:

**Path A — Delegate to lets-brainstorm** (preferred when available):
Invoke `lets-brainstorm` with the confirmed intent. It runs its full process (clarifying
questions, approaches, design sections, user approval) and returns an approved spec. You resume
at Stage 1 with that spec.

**Path B — Inline discovery** (fallback when lets-brainstorm is unavailable, or for very small changes):
Ask up to 3 clarifying questions prioritized by:
1. Scope boundary — what's in, what's out
2. Success criteria — how do we know it's done
3. Key constraint — security, performance, compatibility

From the answers, produce a brief inline spec (problem, approach, success criteria, scenarios).
Present it: "Here's what I'll build. Does this match?" On confirmation, proceed to Stage 1.

**Optional enrichment delegations** (offer, don't impose):
- New UX surface → "This introduces new UI — want me to brainstorm the UX design first?"
- Existing UX surface → "Want me to run a UX friction analysis on the current flow?"
- Competitive gap → "Should I scan competitors for this surface?"
- Persona question → "Want persona validation on this?"

If user declines or skill is unavailable: skip, note it, move on.

### Phase 0 outputs (optional audit trail)

If you want resumable/auditable state, write to `.lets/runs/develop-feature/<run_id>/intake/`.
This is optional — the essential state is the approved spec (wherever it lives) and the chosen
control level (which you carry forward in context).

---

## Spec-Driven Mode

After Phase 0, an approved spec MUST exist — either:
- Pre-existing (user referenced it, or it was in `.lets/` / `lets spec`)
- Produced by `lets-brainstorm` delegation
- Produced inline during Phase 0 fallback

The spec is the authority for WHAT and WHY. The execution packet is the authority for HOW.

When the `lets` CLI is available:
```bash
lets spec status --format json
lets spec export <feature_key>
lets journey init <feature_key> --repo-root .
```

---

## When to Use

- Implementing a feature, bugfix, or refactor that touches production code
- Any change that benefits from structured planning before coding
- When no spec exists (Phase 0 handles discovery)
- Delivery chain: **lets-develop-feature** → lets-verify-change → lets-review-code

## When Not to Use

- Verifying an existing change → `lets-verify-change`
- Reviewing a PR → `lets-review-pr`
- Single-line zero-risk typo fix → just fix it
- Exploration without implementation intent → `lets-brainstorm`

---

## Graduated Rigor (Artifact Depth)

| Level | When | Stages active | Detail |
|-------|------|---------------|--------|
| **MINIMAL** | Trivial + low risk + mechanical | 0,1,2,3(minimal),6,8(quick),9 | [CLASSIFICATION.md](references/CLASSIFICATION.md) |
| **STANDARD** | Typical feature/bugfix | All stages, arch may be skipped | Full packet + scenarios |
| **ELEVATED** | Cross-module, new abstractions, API | All stages, arch required | Design checkpoint + traceability |
| **FULL** | Large, critical, irreversible | All + per-file confirmation | Stacked PRs + quality scorecard |

See [references/CLASSIFICATION.md](references/CLASSIFICATION.md) for classification matrix and gate overrides.

---

## Stage Contracts

### Stage 1 — Ground in Repo + Service Context

Read AGENTS.md, extract non-negotiables, critical paths, boundaries. These BIND the run.

- Collaborative: present summary, ask "anything to add?"
- Otherwise: silent.

**Output:** Service context summary. See [references/SERVICE-CONTEXT.md](references/SERVICE-CONTEXT.md).
**Checkpoint:** Update `run-state.md` → Stage 1 completed, record non-negotiable count + critical paths found.

### Stage 2 — Classify & Select Rigor

Classify by type/scale/risk/complexity. Apply gate overrides.

- Collaborative: present for confirmation.
- Otherwise: silent (shown in Stage 5).

**Output:** Classification + rigor level. See [references/CLASSIFICATION.md](references/CLASSIFICATION.md).
**Checkpoint:** Update `run-state.md` → Stage 2 completed, record classification + rigor. Initialize `run-state.md` if not yet created (STANDARD+ rigor creates it here; MINIMAL may skip).

### Stage 3 — Plan

Build the execution packet from the approved spec. If service context (Stage 1) reveals
conflicts with the spec, surface them — either revise scope, accept with documented risk, or
send back to discovery.

Stage 3 does NOT construct specs. It translates an approved spec into an implementable plan.

**Output:** Execution packet, story tasks, scenario matrix, assumptions log. See [references/PLANNING.md](references/PLANNING.md).
**Checkpoint:** Update `run-state.md` → Stage 3 completed, populate package table + task table + artifacts table. All artifacts now cross-referenced.

### Stage 4 — Architecture Gate

Opens when: new abstraction, boundary change, API change, schema change.

- Autonomous: auto-resolve, log decisions.
- Checkpoints: pause if gate opens.
- Collaborative: always present.

**Output:** Architecture notes (or explicit `skipped`). See [references/ARCHITECTURE-GATE.md](references/ARCHITECTURE-GATE.md).
**Checkpoint:** Update `run-state.md` → Stage 4 completed or skipped (with reason), record design decisions.

### Stage 5 — Checkpoint

Present plan to user for review.

- Autonomous: **skip.**
- Checkpoints: present full packet, wait for approval.
- Collaborative: present section-by-section.

**Output:** User approval. See [references/PLANNING.md](references/PLANNING.md).
**Checkpoint:** Update `run-state.md` → Stage 5 completed (with approval timestamp) or skipped.

### Stage 6 — Implement

Execute story tasks in dependency order. **Spec re-read at each milestone boundary.**

- Autonomous: no pauses except hard-stops.
- Checkpoints: pause on blockers or assumption invalidation.
- Collaborative: pause at each package boundary.

**Per-package checkpointing:** After each package completes, update BOTH `run-state.md` (package row + task rows) AND `story-tasks.md` (checkboxes). Record verification result inline. This is the critical resumability seam — a new session can pick up at the next package.

**Output:** Code changes. See [references/IMPLEMENTATION.md](references/IMPLEMENTATION.md).
**Checkpoint:** Update `run-state.md` → per-package progress, current_package counter, next_action. Stage 6 completed only when all packages done.

### Stage 7 — Test

Methodology-aware testing per work package.

- Autonomous: report failures only.
- Checkpoints: report summary.
- Collaborative: walk through coverage vs scenario matrix.

**Output:** Test results + coverage evidence. See [references/METHODOLOGY.md](references/METHODOLOGY.md).
**Checkpoint:** Update `run-state.md` → Stage 7 completed, record test counts + pass/fail.

### Stage 8 — Verify

Compare delivered work against plan, spec, story tasks, service context, scenario coverage.

- Autonomous: surface only if verdict = BLOCKED.
- Checkpoints: present verdict with evidence.
- Collaborative: full per-requirement comparison.

**Output:** Verification verdict (ready | blocked). See [references/VERIFICATION.md](references/VERIFICATION.md).
**Checkpoint:** Update `run-state.md` → Stage 8 completed with verdict. Write `verification-record.md`. Cross-check all artifact consistency (see CHECKPOINTING.md).

### Stage 9 — Complete

Quality scorecard. Handoff packet.

- Autonomous: present final summary.
- Checkpoints: present scorecard.
- Collaborative: scorecard review before handoff.

**Output:** Scorecard + handoff. See [references/COMPLETION.md](references/COMPLETION.md).
**Checkpoint:** Update `run-state.md` → Stage 9 completed, status → `completed`. Write `handoff.md`. Final artifact consistency check.

---

## Architecture Visualization (Living Artifact)

Architecture diagrams are not a one-shot artifact — they evolve as the feature moves through
the pipeline. Produce diagrams when the feature's complexity warrants them (STANDARD+ rigor
with cross-module scope or new abstractions).

### When to produce

| Stage | What to diagram | Why |
|---|---|---|
| Phase 0 (brainstorm) | Proposed component/flow sketch | Helps user evaluate approach before committing |
| Stage 3 (plan) | Execution architecture — what will be built, how pieces connect | Makes the plan concrete and reviewable |
| Stage 4 (arch gate) | Boundary diagram — what crosses what, dependency direction | Answers the gate questions visually |
| Stage 6 (implement) | Update diagram if implementation diverges from plan | Keeps the diagram truthful |
| Stage 9 (handoff) | Final state diagram | What was actually delivered |

### Diagram types (pick what fits)

| Type | Use when | Format |
|---|---|---|
| Component diagram | Multiple modules/services interact | Mermaid, ASCII, or dot |
| Sequence diagram | Request flow matters (APIs, async) | Mermaid |
| Data flow diagram | Data transformation pipeline | Mermaid or ASCII |
| Entity relationship | New data model or schema change | Mermaid |
| State machine | Complex state transitions | Mermaid or dot |

### Rules

- Use text-based formats (Mermaid, dot, ASCII) — they version-control and diff cleanly
- Start simple. Add detail only when it clarifies, not when it decorates.
- Update the diagram when reality diverges from it. A stale diagram is worse than none.
- For MINIMAL rigor: skip entirely. For STANDARD: optional. For ELEVATED/FULL: at least one
  diagram at Stage 3 and one at Stage 9.
- Store diagrams in the spec workspace alongside other run artifacts.

---

## UX Design (Layered)

When a feature introduces or modifies user-facing surfaces, UX design happens at two layers:

### Layer 1 — In the spec (always, when UI is involved)

When `lets-brainstorm` produces the spec for a feature with UI surface, it MUST include:

- **UX flow** — screen-to-screen navigation, entry/exit points
- **Interaction model** — what the user does, what the system responds
- **Key screen descriptions** — what information is shown, what actions are available
- **Error/empty states** — what happens when things go wrong or data is missing

This is part of the spec, not a separate artifact. If brainstorm produced a spec without these
sections for a UI feature, flag it as a gap before planning.

### Layer 2 — Optional delegation for complex UI (devx-ui-ux)

For complex UI surfaces (multi-screen flows, design system impact, accessibility requirements,
responsive behavior), offer delegation to `devx-ui-ux`:

```
"This feature has significant UI complexity — want me to produce a design system
 brief with component hierarchy, accessibility requirements, and interaction patterns
 before I plan the implementation?"
```

What devx-ui-ux produces:
- Design system tokens (if new surface)
- Component hierarchy and responsibility map
- Accessibility requirements checklist
- Responsive behavior rules
- Interaction patterns and state management approach

This feeds into Stage 3's execution packet — the work packages reference the design brief
for implementation guidance.

### Signal: When to offer Layer 2

- Feature introduces 3+ new screens or components
- Feature changes navigation structure
- Feature introduces a new interaction pattern (drag-drop, real-time, multi-step form)
- Feature has accessibility compliance requirements
- User explicitly mentions wireframes, mockups, or design system

---

## Spec-Alignment Protocol

Implementation must align to the spec continuously:

1. **Before each work package:** Re-read the relevant spec section
2. **During implementation:** If code reveals spec contradiction → STOP
3. **On contradiction:** Surface it. Do not silently proceed.
4. **At verification:** Check each requirement against delivered code

See [references/SPEC-ALIGNMENT.md](references/SPEC-ALIGNMENT.md).

---

## Negative Guardrails

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
| 15 | I will NOT mark tasks complete unless mapped to a requirement, story, or scenario |
| 16 | I will NOT begin planning without an approved spec (from delegation or inline discovery) |
| 17 | I will NOT complete a package without updating run-state.md and story-tasks.md |
| 18 | I will NOT resume a run without validating state against code reality |

---

## Completion Quality Scorecard

Before handoff, score the delivery (STANDARD+ rigor):

| Dimension | 0–5 | Criteria |
|-----------|-----|----------|
| **Spec adherence** | | Does implementation match the spec? |
| **Test coverage** | | Are scenarios from the matrix covered? |
| **Service constraint preservation** | | Are non-negotiables honored? |
| **Scope discipline** | | Did we stay within the execution packet? |

**Pass threshold: ≥16/20.** Below = `blocked`.

See [references/COMPLETION.md](references/COMPLETION.md).

---

## Graceful Degradation

| Condition | Behavior |
|---|---|
| `lets-brainstorm` not available | Use inline discovery (Path B in Phase 0) |
| Optional enrichment skill not available | Skip, note it, proceed |
| `lets` CLI not available | Use manual file-based state instead |
| AGENTS.md missing | Proceed without service context, note it |
| Spec ambiguous after inline discovery | Ask one more round of clarification, then proceed with documented assumptions |

The skill never blocks on a missing upstream skill. Required delegations have inline fallbacks.

---

## Error Handling

- User rejects intent echo → ask "What did you mean?" and re-echo
- User rejects control recommendation → accept their choice
- Delegated skill fails → fall back to inline discovery
- Delegated skill produces draft (not approved) → ask user to approve or proceed with risk noted
- User says "just do it" → set autonomous, use inline discovery if no spec
- Spec contradiction mid-implementation → HARD STOP, surface it
- Work package verification fails → fix within scope or mark BLOCKED
- Quality scorecard < 16/20 → mark delivery BLOCKED, identify gaps
- Assumption invalidated → stop at package boundary, assess impact, re-plan if significant

---

## Anti-patterns

- **Implementing before presenting the packet** — the plan catches problems before they become code
- **Constructing specs internally without user input** — delegate to brainstorm or do inline discovery with the user
- **Skipping spec re-read** — memory drifts; re-reading catches contradictions early
- **Silent scope expansion** — touching files not in the packet without asking
- **Fabricating test results** — if you didn't run it, you don't know the result
- **Leaving stages implicit** — every stage must be explicitly completed, skipped, or blocked
- **Loading all references upfront** — read only when the stage activates
- **Ceremony for clear requests** — if user names a spec, don't echo it back as a question
- **Blocking on missing optional skills** — degrade gracefully, always
- **Deferring state updates** — update run-state.md at the transition, not "later"
- **Resuming without validation** — state file may be stale; always check against code

---

## Run State — Spec-Colocated, Not Target-Repo

Run artifacts live alongside the spec, NOT in the target repo being modified. Features can span
multiple repos — the spec is the stable anchor.

**Where to store:**
- If `lets spec` workspace exists: use it (the spec workspace owns the run)
- If a dedicated spec directory exists (e.g., `ground-truth/features/`): store there
- If this skill is running standalone: use `/tmp/<feature-slug>/` or a workspace-level
  `.lets/runs/` directory outside the target repo
- Last resort only: `.lets/runs/` in the target repo (single-repo, single-feature changes)

```
<spec-workspace>/runs/develop-feature/<run_id>/
  run-state.md      (SINGLE SOURCE OF TRUTH — always current)
  intake/           (Phase 0 audit trail — optional)
  upstream/         (artifacts from delegated skills — optional)
  execution-packet.md
  story-tasks.md
  scenario-matrix.md
  verification-record.md
  handoff.md
```

**`run-state.md` is the anchor.** It is:
- Updated at every stage transition and package completion
- The first file read on resume
- The only file needed to answer "what's the current status?"
- Cross-referenced to all other artifacts (with paths and statuses)

The essential state is: approved spec, control level, and execution packet. The context window
holds working memory; `run-state.md` holds durable memory. When context is about to be lost,
ensure `run-state.md` is current — it's the bridge to the next session.

---

## References (Progressive Disclosure)

Read each reference only when its stage activates — not upfront.

| Reference | When to read |
|-----------|-------------|
| [CHECKPOINTING.md](references/CHECKPOINTING.md) | Resume, and any stage transition — state management |
| [CLASSIFICATION.md](references/CLASSIFICATION.md) | Stage 2 — selecting rigor level |
| [SERVICE-CONTEXT.md](references/SERVICE-CONTEXT.md) | Stage 1 — reading service constraints |
| [PLANNING.md](references/PLANNING.md) | Stage 3/5 — building the plan |
| [ARCHITECTURE-GATE.md](references/ARCHITECTURE-GATE.md) | Stage 4 — design decisions |
| [IMPLEMENTATION.md](references/IMPLEMENTATION.md) | Stage 6 — per-package discipline |
| [METHODOLOGY.md](references/METHODOLOGY.md) | Stage 7 — test methodology |
| [SPEC-ALIGNMENT.md](references/SPEC-ALIGNMENT.md) | Stage 6/8 — checking against spec |
| [VERIFICATION.md](references/VERIFICATION.md) | Stage 8 — verification protocol |
| [COMPLETION.md](references/COMPLETION.md) | Stage 9 — quality scorecard and handoff |
| [SCENARIO-MATRIX.md](references/SCENARIO-MATRIX.md) | Stage 3 — building scenario coverage |
| [STACKED-PRS.md](references/STACKED-PRS.md) | Stage 6 — decomposing large changes |
| [HANDOFF.md](references/HANDOFF.md) | Stage 9 — handoff packet format |

## Scripts

| Script | Purpose | Used in |
|--------|---------|---------|
| [scripts/classify_risk.sh](scripts/classify_risk.sh) | Automated risk signal scanning | Stage 2 |
| [scripts/check_blast_radius.sh](scripts/check_blast_radius.sh) | Importer analysis for blast radius | Stage 2/3 |
