# Completion Stage — lets-develop-feature

Quality scorecard, handoff packet, and stage status table. The final gate before the run is considered done.

## Quality Scorecard

Before declaring completion, score the delivery across 4 dimensions. This is required for STANDARD+ rigor.

### Scoring Rubric

#### Spec Adherence (0–5)

| Score | Criteria |
|-------|----------|
| 0 | Major requirements missing or contradicted |
| 1 | Multiple requirements missing without justification |
| 2 | Some requirements missing; most implemented |
| 3 | All requirements addressed; minor gaps documented |
| 4 | All requirements implemented with evidence; gaps deferred with justification |
| 5 | Every requirement ALIGNED in spec check; no gaps, no ambiguity |

#### Test Coverage (0–5)

| Score | Criteria |
|-------|----------|
| 0 | No tests written or all tests failing |
| 1 | Tests exist but weak (no meaningful assertions, mock-heavy) |
| 2 | Happy path covered; failure/edge cases missing |
| 3 | Happy + failure covered; some edge cases missing |
| 4 | Scenario matrix substantially covered; deferred items justified |
| 5 | Full scenario matrix covered with meaningful assertions per scenario |

#### Service Constraint Preservation (0–5)

| Score | Criteria |
|-------|----------|
| 0 | Non-negotiable violated |
| 1 | Non-negotiable at risk, no preservation evidence |
| 2 | Non-negotiables likely preserved but no explicit proof |
| 3 | Non-negotiables preserved with evidence; critical paths not tested |
| 4 | Non-negotiables preserved; critical paths tested; one gap in evidence |
| 5 | Full preservation proof for all non-negotiables; critical paths verified with test evidence |

*If no service context exists (no AGENTS.md, no non-negotiables):* Score 5 by default — this dimension doesn't apply.

#### Scope Discipline (0–5)

| Score | Criteria |
|-------|----------|
| 0 | Major scope expansion without approval; unplanned files throughout |
| 1 | Significant unplanned work; scope boundary violated |
| 2 | Some scope creep; most work within packet |
| 3 | Minor deviations documented; all major work within packet |
| 4 | Diff matches packet closely; one minor addition documented |
| 5 | Diff exactly matches execution packet; no unplanned additions |

### Pass Threshold

**≥16/20 = ready for handoff.**
**<16/20 = blocked.** Identify specific gaps and determine if they're fixable in current scope.

### Scorecard Format

```markdown
## Quality Scorecard

| Dimension | Score | Evidence |
|-----------|-------|----------|
| Spec adherence | 4/5 | All requirements ALIGNED except #7 (DEFERRED: follow-up ticket) |
| Test coverage | 4/5 | 8/9 scenarios covered; DB timeout deferred |
| Service constraint preservation | 5/5 | Engine isolation preserved (no outward imports); auth critical path passes |
| Scope discipline | 5/5 | Diff matches packet exactly |
| **Total** | **18/20** | **PASS — ready for handoff** |
```

## Stage Status Table

Every run must account for all 9 stages. No stage is ever left implicit.

### Format

```markdown
## Stage Status

| Stage | Status | Notes |
|-------|--------|-------|
| 1. Ground | completed | Service context: 2 non-negotiables, 1 critical path |
| 2. Classify | completed | feature / small / medium-risk / STANDARD |
| 3. Plan | completed | 4 work packages, 6 scenarios |
| 4. Architecture | skipped | No new abstractions, no boundary changes |
| 5. Checkpoint | completed | User approved 2025-03-15 |
| 6. Implement | completed | 4/4 packages done |
| 7. Test | completed | 12 tests pass, 0 fail |
| 8. Verify | completed | Verdict: ready |
| 9. Complete | completed | Score: 18/20 PASS |
```

Valid statuses:
- `completed` — stage finished successfully
- `skipped` — stage intentionally not executed (MUST include reason)
- `blocked` — stage cannot complete (MUST include blocker)

## Handoff Packet

The handoff is what goes to the next step in the delivery chain (typically `lets-verify-change` or PR creation).

### Required Contents

| Section | Content |
|---------|---------|
| **Summary** | One-paragraph description of what was delivered |
| **Stage status** | Full 9-stage table |
| **Quality scorecard** | 4-dimension scores with evidence |
| **Files changed** | List of all modified/created/deleted files |
| **Verification evidence** | Key test commands and their results |
| **Residual risks** | Known gaps, deferred items, lower-confidence areas |
| **Follow-up items** | Work intentionally deferred (with justification) |
| **Service context verdict** | Non-negotiables preserved? Critical paths unbroken? |

### Handoff Template

Use `assets/templates/handoff.template.md` as a starting point.

## Per-Rigor Completion Requirements

| Rigor | Scorecard | Stage table | Handoff |
|-------|-----------|-------------|---------|
| MINIMAL | Not required | Required (many stages "skipped") | Brief summary |
| STANDARD | Required (≥16/20) | Required | Full handoff |
| ELEVATED | Required (≥16/20) | Required | Full handoff + traceability |
| FULL | Required (≥16/20) | Required | Full handoff + traceability + design decisions |

## When Completion Blocks

If the scorecard is <16/20:

1. Identify which dimension(s) are low
2. Determine specific gaps
3. Assess: fixable in current scope?
4. If yes: fix → re-score → re-assess
5. If no: document as blocked in handoff → escalate to user with specific gap list

Common blockers and fixes:

| Low dimension | Typical fix |
|---------------|-------------|
| Spec adherence | Implement missing requirement or document as DEFERRED |
| Test coverage | Add tests for uncovered scenarios |
| Service constraints | Add preservation evidence (grep, test) |
| Scope discipline | Remove unplanned code or document with justification |

## Handoff to Next Stage

The delivery chain after `lets-develop-feature`:

```
lets-develop-feature → lets-verify-change → lets-review-code → PR
```

The handoff packet gives `lets-verify-change` everything it needs to assess whether the change is safe to ship. Stage 8 (internal verification) answers "did we build what we planned?" while `lets-verify-change` answers "is what we built safe to ship?"

## Anti-patterns

- **Skipping the scorecard** — it exists to catch gaps before handoff, not to add ceremony
- **Inflating scores** — score honestly; a 3 is fine if justified
- **Leaving stages implicit** — "I assume that was done" is not valid; mark it explicitly
- **Empty residual risks** — every non-trivial change has residual risk; name it
- **Handoff without evidence** — commands and their output, not "I ran tests and they passed"
- **Claiming completion when blocked** — <16/20 means blocked, not "mostly done"
