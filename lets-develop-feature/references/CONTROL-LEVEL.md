# Control Level — lets-develop-feature

Control level determines how much the user is consulted during the run. It is orthogonal to
rigor (which determines artifact depth). Together they form a 2D space:

- **Rigor** = what gets produced (MINIMAL → FULL)
- **Control** = who decides when (Autonomous → Collaborative)

## Control Levels

### Autonomous

"Bring me the result."

- Best for: trusted patterns, low risk, spec already approved, user is busy
- Phase 0: Turn 1 only (echo + confirm). Skip Turn 2-3 if spec exists and signals clean.
- Stage 5 checkpoint: skipped
- Architecture gate: auto-resolved (decisions logged)
- Implementation: no mid-run pauses except hard-stops
- Verification: only surfaced if verdict = BLOCKED
- User sees: final summary + handoff

### Checkpoints

"Bring me the plan and key decisions."

- Best for: standard features, moderate risk, balanced involvement
- Phase 0: full (all turns)
- Stage 5 checkpoint: presents full packet, waits for approval
- Architecture gate: pauses if triggered
- Implementation: pauses only on blockers or assumption invalidation
- Verification: presents verdict with evidence summary
- User sees: plan approval + architecture decisions + final result

### Collaborative

"Explore with me step by step."

- Best for: novel/risky/ambiguous work, learning, high-stakes decisions
- Phase 0: full (all turns)
- Stage 1: presents service-context summary for review
- Stage 2: presents classification for confirmation
- Stage 3: presents spec-readiness findings, pauses on LOW-confidence assumptions
- Stage 4: always presents, even if trivially skipped. Walks through alternatives.
- Stage 5: presents section-by-section, each work package gets confirmation
- Stage 6: pauses at each package boundary
- Stage 7: walks through coverage against scenario matrix
- Stage 8: presents full per-requirement comparison
- Stage 9: scorecard presented for review before handoff
- User sees: everything, with gates at each boundary

## Stage × Control Matrix

| Stage | Autonomous | Checkpoints | Collaborative |
|---|---|---|---|
| Phase 0 Turn 1 | **Always** | **Always** | **Always** |
| Phase 0 Turn 2 | Skip if spec exists + clean signals | **Always** | **Always** |
| Phase 0 Turn 3 | Skip if no delegations | **Always** (if delegations) | **Always** (if delegations) |
| 1 Ground | Silent | Silent | Present summary, ask "anything to add?" |
| 2 Classify | Silent | Silent (shown in Stage 5) | Present for confirmation |
| 3 Plan | Silent | Silent (shown in Stage 5) | Pause on LOW-confidence assumptions |
| 4 Architecture | Auto-resolve, log | Pause if gate opens | Always present |
| 5 Checkpoint | **Skip** | **Present + wait** | **Present section-by-section** |
| 6 Implement | Execute all | Pause on blockers only | Pause at package boundaries |
| 7 Test | Run, report failures only | Run, report summary | Walk through coverage |
| 8 Verify | Surface only if BLOCKED | Present verdict + evidence | Full per-requirement comparison |
| 9 Complete | Present final summary | Present scorecard + result | Scorecard review before handoff |

## Recommendation Logic

Based on discovery signals from Phase 0 Turn 2:

```
IF spec_exists AND risk_signals == 0:
    recommend = autonomous
    reason = "straightforward — spec is approved and no risk signals detected"

ELIF risk_signals >= 3 OR any_signal_is_critical OR no_spec_and_ambiguous:
    recommend = collaborative
    reason = "[specific signals] suggest we should explore each decision together"

ELSE:
    recommend = checkpoints
    reason = "[specific signals] — I'll bring you the design and plan for approval"
```

Critical signals that force collaborative recommendation:
- `security_surface` + `public_api_change`
- `migration` + `cross_module`
- Request is ambiguous enough that intent echo required disambiguation

## Override Mechanics

Control level is NOT locked for the duration of the run.

### User escalates

User says "wait", "walk me through this", "hold on", "let me see that":
- Switch to collaborative from current stage forward
- No re-run of past stages
- Log override in `control-level.md`

### User de-escalates

User says "just go ahead", "looks good, proceed", "I trust you":
- Switch to autonomous or checkpoints from current stage forward
- Log override in `control-level.md`

### Hard-stop always escalates

These conditions force a pause REGARDLESS of control level:
- Spec contradiction discovered
- Service constraint (non-negotiable) violated
- Blocked verification verdict
- Security/auth code modification without explicit acknowledgment
- Irreversible operation (DELETE, DROP, migration)

Hard-stops are not subject to "autonomous" override. They represent safety invariants.

## Interaction with Rigor

| Combination | Valid? | Behavior |
|---|---|---|
| MINIMAL + Autonomous | Yes | Fastest path: echo intent, classify, implement, verify |
| MINIMAL + Collaborative | Yes (unusual) | User wants visibility into a trivial change |
| STANDARD + any | Yes | Normal operation |
| ELEVATED + Autonomous | Caution | Warn: "This is elevated-risk. Autonomous means I'll make architecture decisions without asking. Are you sure?" |
| FULL + Autonomous | **Invalid** | FULL rigor requires per-file confirmation — auto-escalate to Checkpoints minimum. Inform user. |
| FULL + Checkpoints | Yes | Plan gate + architecture gate + final verification |
| FULL + Collaborative | Yes | Maximum ceremony: every boundary is a conversation |

## Storage

```markdown
# .lets/runs/develop-feature/<run_id>/intake/control-level.md

---
control_level: checkpoints
recommended_by: signal_analysis
confirmed_by: user
confirmed_at: <ISO timestamp>
overrides: []
---

**Signals at decision time:**
- cross_module
- public_api_change
- no_approved_spec

**Recommendation:** checkpoints
**Reasoning:** Cross-module feature with public API impact — plan approval before implementation.
**User response:** confirmed

## Override Log

| Timestamp | Stage | Old level | New level | Trigger |
|---|---|---|---|---|
| (populated if user escalates/de-escalates) |
```

## Brainstorm Mode Mapping

When `lets-brainstorm` is delegated to and no `mode_override` is set:

| Control level | Brainstorm mode | Effect |
|---|---|---|
| Autonomous | Light | Batched questions, minimal spec, fast |
| Checkpoints | Light (escalates to Full if scope grows) | Standard exploration |
| Collaborative | Full | One question per message, full spec sections, section-by-section approval |
