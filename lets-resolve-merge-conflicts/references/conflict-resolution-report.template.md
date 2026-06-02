# Conflict Resolution Report

## Context

- Mode: merge / rebase
- Base ref: (example `main`)
- Incoming ref: (example `feature/xyz`)
- Merge base: (commit hash)
- Conflicted files: (list)

## Non-negotiables (Must Preserve)

- (Behavior constraints)
- (API / schema constraints)
- (Rollout / flags / observability constraints)
- (Test / verification constraints)

## Intent Summary

### Base-side intent (what changed since merge base, and why)

- (Bullets)

### Incoming-side intent (what changed since merge base, and why)

- (Bullets)

## Overlap Inventory (Merge-base view)

- Shared files/directories (from merge-base inventory)
- Overlap classification per area: independent / complementary / competing / policy-conflict

## Resolution Strategy (Per Area)

For each conflict area, record:
- Strategy: manual integration / ours / theirs / re-sequence / escalate
- Rationale (one paragraph)
- Files/units impacted

## Integration Notes

- Key semantic decisions made (functions/classes/schemas changed)
- Tests/docs/config/migrations updated alongside code
- Any follow-ups deferred (with explicit user confirmation if applicable)

## Validation

- Commands run (copy/paste output or summarize precisely)
- Results (pass/fail)
- If validation is pending: exact plan + where it will run (CI, local env, etc.)

## Risks / Open Questions

- (List)

## Approval Record

- Strategy checkpoint approved: yes/no
- History rewrite approved (if applicable): yes/no + reason

