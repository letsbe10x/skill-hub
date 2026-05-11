# Handoff Protocol — lets-develop-feature

How to produce clean handoffs to downstream skills (lets-verify-change, lets-review-code).

## Handoff Chain

```
lets-develop-feature → lets-verify-change → lets-review-code → lets-review-pr
```

Each skill consumes the output of the previous. The handoff must be self-contained — the receiving skill should not need to re-discover context.

## Handoff Artifact

### Required Fields

| Field | Always? | Description |
|-------|---------|-------------|
| task_summary | Yes | One-sentence: what was implemented |
| rigor_level | Yes | MINIMAL / STANDARD / ELEVATED / FULL |
| packages_completed | Yes | X/Y count |
| test_status | Yes | Pass/fail counts from final verification |
| lint_status | Yes | Clean / N issues |
| git_diff_stat | Yes | Summary of changes |
| verification_commands | Yes | Commands the verifier should run |
| concerns_for_verification | Yes | Anything the verifier should pay attention to |
| design_decisions | ELEVATED+ | Key architectural decisions made |
| scope_changes | If any | Scope expansions that were approved |
| known_limitations | If any | Deferred items or partial implementations |
| traceability | ELEVATED+ | Full traceability record |

### Handoff Format

```markdown
## Handoff: lets-develop-feature → lets-verify-change

**Task:** [what was implemented]
**Rigor:** [level]
**Classification:** [type / scale / risk]
**Packages:** [X/Y completed]

### Evidence
- **Tests:** [pass_count passed, fail_count failed]
- **Lint:** [clean / N issues (N fixable)]
- **Type check:** [clean / N issues] (if applicable)

### Changes
```
[git diff --stat output]
```

### Verification Commands
```bash
[exact commands to run for full verification]
```

### Design Decisions (ELEVATED/FULL)
| Decision | Approach | Rationale |
|----------|----------|-----------|
| [what] | [chosen] | [why] |

### Scope Changes
- [any approved expansions]

### Known Limitations
- [anything deferred or incomplete]

### Concerns for Verification
- [specific things to check]
- [edge cases that weren't fully tested]
- [areas where confidence is lower]
```

## What NOT to Include in Handoff

- Raw command outputs (keep it summary-level)
- Full file contents (the diff is enough)
- Exploration notes from Phase 2 (only conclusions carry forward)
- Alternative designs that were rejected (only the chosen approach matters)

## Handoff Quality Checklist

Before handing off, verify:

- [ ] All packages in the packet are marked as completed
- [ ] Verification commands were actually run (not just listed)
- [ ] Test output shows concrete pass/fail counts
- [ ] No TODO or FIXME items left without acknowledgment
- [ ] Scope boundary matches what was approved in the packet
- [ ] If scope expanded, expansion was approved
- [ ] Git state is clean (no uncommitted debris)

## Failure Handoff

If implementation cannot be completed:

```markdown
## Handoff: lets-develop-feature → BLOCKED

**Task:** [what was attempted]
**Status:** BLOCKED at package [N]
**Reason:** [concrete blocker]

### Completed
- Packages 1-[N-1] completed with verification

### Blocker
- [What failed and why]
- [What was tried]
- [What's needed to unblock]

### Recovery Options
1. [Option A]: [description]
2. [Option B]: [description]
```

## Evidence Standards

### What Counts as Evidence

| Evidence | Acceptable | Not acceptable |
|----------|-----------|----------------|
| Test result | `pytest: 15 passed, 0 failed` (actual output) | "Tests should pass" |
| Lint result | `ruff: 0 errors` (actual output) | "Code looks clean" |
| Build result | `build succeeded in 12s` (actual output) | "Build should work" |
| Type check | `mypy: Success: no issues` (actual output) | "Types look correct" |

### Evidence Freshness

Evidence must be from THIS session:
- Run commands after implementation, not before
- If you made changes after running tests, re-run them
- Stale evidence (from before the last edit) doesn't count
