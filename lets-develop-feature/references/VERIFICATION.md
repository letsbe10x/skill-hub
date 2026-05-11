# Verification Stage — lets-develop-feature

The verification stage is NOT "run tests again." It's a dedicated comparison of delivered work against the plan, service context, and scenario coverage.

## What Verification Checks

| Dimension | Question | Evidence required |
|-----------|----------|-------------------|
| **Plan adherence** | Did we implement what was planned? | Compare diff with packet file list |
| **Scenario coverage** | Are all scenarios from the matrix covered? | Test exists per scenario (or explicit defer) |
| **Service constraints** | Are non-negotiables preserved? | Specific code/test evidence per constraint |
| **Critical paths** | Are they still working? | Tests pass for critical path scenarios |
| **Scope discipline** | Did we stay in scope? | Diff matches packet (no extra files) |
| **Error handling** | Was existing error handling preserved or improved? | Diff shows no weakened catches |
| **Architecture** | Were design decisions followed? | Code structure matches architecture notes |
| **Test quality** | Do tests actually prove correctness? | Tests assert behavior, not just "no crash" |

## Verification Protocol

### Step 1: Run Commands

```bash
# Full test suite
pytest tests/ -q  # or project test command

# Lint
ruff check src/ 2>&1 || true

# Type check (if applicable)
mypy src/ 2>&1 || true

# Check diff matches scope
git diff --name-only  # compare against execution packet file list
```

### Step 2: Compare Against Plan

For each work package in the execution packet:
- Was it implemented? (check diff)
- Did verification pass? (check test output)
- Was methodology followed? (TDD = test-first evidence, test-after = existing tests still pass)

### Step 3: Verify Service Constraints

For each non-negotiable in the service context summary:
```
Non-negotiable: "Credentials injected at start, never env-read"
Evidence: grep -rn "os.environ\|os.getenv" src/auth/ → no matches in changed code
Status: PRESERVED
```

For each critical path touched:
```
Critical path: auth middleware (src/auth/middleware.py)
Evidence: test_auth_flow passes (15/15 assertions)
Status: UNBROKEN
```

### Step 4: Check Scenario Coverage

For each scenario in the matrix:
- Is there a test covering it? → name the test
- Is it explicitly deferred? → note why
- Is it missing without justification? → flag as gap

### Step 5: Verdict

| Verdict | Criteria |
|---------|----------|
| **ready** | All checks pass. Service constraints preserved. Critical paths unbroken. Scope respected. |
| **blocked** | Any check fails. Specify which and what needs fixing. |

## Verification Output Format

```markdown
## Verification Record

**Verdict:** ready | blocked
**Date:** [timestamp]

### Evidence
| Check | Command | Result |
|-------|---------|--------|
| Tests | `pytest tests/ -q` | 42 passed, 0 failed |
| Lint | `ruff check src/` | 0 errors |
| Type check | `mypy src/` | Success: 0 issues |

### Plan Adherence
| Package | Status | Evidence |
|---------|--------|----------|
| 1: Failing tests | Completed | test_billing.py: 3 tests pass |
| 2: Implementation | Completed | billing.py matches plan |
| 3: Wiring | Completed | routes.py registered |

### Service Constraint Verification
| Constraint | Status | Evidence |
|-----------|--------|----------|
| Engine isolation | Preserved | No new outward imports in engine/ |
| Credential injection | Preserved | No os.environ in auth/ |
| Critical path: auth | Unbroken | test_auth_flow: 15/15 pass |

### Scenario Coverage
| Scenario | Test | Status |
|----------|------|--------|
| Happy path | test_create_invoice | Covered |
| Invalid input | test_create_invoice_invalid | Covered |
| DB timeout | — | Deferred (follow-up ticket #456) |

### Scope Check
Files in diff: [list]
Files in packet: [list]
Match: yes | no (extra: [file])

### Residual Risks
- [any known gaps or lower-confidence areas]
```

## When Verification Blocks

If verification produces `blocked`:

1. Identify the specific failure
2. Determine if it's fixable within current scope
3. If fixable: fix → re-run affected verification checks → re-verdict
4. If not fixable: document as blocker in handoff → escalate to user

Do NOT:
- Mark as `ready` when checks are failing
- Skip verification because "it obviously works"
- Claim confidence without evidence
- Accept pre-existing failures as "not our problem" for critical paths we touched

## Relationship to lets-verify-change

`lets-verify-change` does a broader verification sweep. This stage is the INTERNAL verification before handoff:
- Stage 8 (this): "Did I implement what I planned?"
- `lets-verify-change`: "Is this change safe to ship?"

Both are needed. Stage 8 catches plan-deviation. `lets-verify-change` catches things the plan missed.
