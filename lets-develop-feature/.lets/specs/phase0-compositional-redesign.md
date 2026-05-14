---
artifact_type: spec
produced_by: lets-brainstorm
produced_at: 2026-05-14T00:00:00Z
status: approved
approval_source: user
---

# Spec: Compositional Redesign of lets-develop-feature

## Problem

lets-develop-feature is a monolithic pipeline that jumps from silent grounding (Stages 1-2) to
artifact production (Stage 3) without ever having a conversation with the user. There is:

- No intake card reflecting the user's intent back
- No negotiation of how involved the user wants to be
- No directed discovery questions before planning
- No delegation to existing discovery skills (brainstorm, research, UX)
- No assumption surfacing before the plan crystallizes

The user's first interaction point is Stage 5 (Checkpoint) — by which point a finished plan is
being presented, not explored together.

## Approach

Add **Phase 0: Intake & Discovery** as a conversational prelude that:

1. Echoes intent back (spec-kit style phased: confirm intent first, then present signals)
2. Detects discovery signals and recommends a control level (hybrid: recommend + confirm)
3. Delegates to upstream skills via handoff declarations (spec-kit style frontmatter triggers)
4. Collects approved artifacts before resuming the delivery pipeline

Introduce **control level** as a new axis orthogonal to rigor — rigor determines artifact depth,
control determines interaction depth (autonomous / checkpoints / collaborative).

## Design Decisions

| Decision | Chosen | Alternatives rejected | Why |
|---|---|---|---|
| Entry point | lets-develop-feature stays orchestrator | Delivery-only (requires lets-start-here always) | User muscle memory; single skill handles full lifecycle |
| Intake style | Spec-kit phased (2 turns before delegation) | Single-turn card; minimal reflection | Confirms intent before overwhelming with signals |
| Control negotiation | Hybrid (recommend + confirm) | Explicit 3-tier choice; inferred-only | Reduces friction while preserving user agency |
| Delegation mechanism | Handoff declarations in frontmatter | Inline if/then; registry file | Declarative, extensible, no body changes to add skills |
| Spec artifact | Sits alongside spec-readiness (translation layer) | Replaces spec-readiness | Catches conflicts between brainstorm output and repo reality |

## Success Criteria

1. User's first interaction is a plain-language echo of their intent — no process jargon
2. User explicitly chooses (or confirms) their involvement level before any planning
3. When no spec exists, lets-brainstorm is invoked — not internal spec-construction
4. Optional research/UX skills are offered when signals warrant them
5. Control level gates stage interactions throughout the pipeline
6. FULL rigor forces minimum checkpoints control (safety invariant)
7. All existing delivery behavior (Stages 1-9) continues to work unchanged
8. New guardrails prevent skipping intake or planning without approved spec

## Scope Boundary (NOT in scope)

- Rewriting lets-brainstorm itself
- Changing the handoff-to-lets-verify-change contract
- Modifying the quality scorecard dimensions
- Adding new rigor levels
- Runtime automation of signal detection (stays checklist-based)

## Testing Approach

- **Scenario: No spec exists** → Phase 0 detects, delegates to brainstorm, receives spec, resumes at Stage 1
- **Scenario: Spec already exists** → Phase 0 Turn 1 confirms intent, Turn 2 shows signals (no delegation needed), proceeds to Stage 1
- **Scenario: UX surface detected** → Phase 0 offers optional UX delegation after brainstorm completes
- **Scenario: User chooses autonomous** → Stages skip pauses except hard-stops
- **Scenario: User chooses collaborative** → Each stage pauses for input
- **Scenario: User escalates mid-run** → Control switches from current stage forward
- **Scenario: FULL rigor + autonomous requested** → Auto-escalate to checkpoints with warning
