# Verification Stage — lets-develop-feature

The verification stage is NOT "run tests again." It's a dedicated comparison of delivered work against the spec, story tasks, plan, service context, scenario coverage, and available Core evidence links.

## What Verification Checks

| Dimension | Question | Evidence required |
|-----------|----------|-------------------|
| **Plan adherence** | Did we implement what was planned? | Compare diff with packet file list |
| **Spec readiness** | Were critical clarifications resolved? | `spec-readiness.md` and `clarifications.md` |
| **Task completion** | Are story tasks complete with evidence? | `story-tasks.md` checked items and task evidence |
| **Scenario coverage** | Are all scenarios from the matrix covered? | Test exists per scenario (or explicit defer) |
| **Service constraints** | Are non-negotiables preserved? | Specific code/test evidence per constraint |
| **Critical paths** | Are they still working? | Tests pass for critical path scenarios |
| **Scope discipline** | Did we stay in scope? | Diff matches packet (no extra files) |
| **Error handling** | Was existing error handling preserved or improved? | Diff shows no weakened catches |
| **Architecture** | Were design decisions followed? | Code structure matches architecture notes |
| **Test quality** | Do tests actually prove correctness? | Tests assert behavior, not just "no crash" |
| **Journey/evidence linkage** | Can downstream verification find the run context? | `journey-link.md`, receipts, evidence bundle references |

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
- Do its mapped task IDs show completion evidence?

### Step 2b: Compare Against Spec and Tasks

For each requirement and user story:
- Is every required story task complete or explicitly deferred?
- Does every completed task map to a requirement, scenario, or infrastructure need?
- Are critical clarifications resolved in `clarifications.md`?
- Are assumptions validated, invalidated, or carried as residual risk?

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
- Is there a completed task covering it? → name the task ID
- Is it explicitly deferred? → note why
- Is it missing without justification? → flag as gap

### Step 4b: Check Core Linkage

When Core artifacts are available, verify that `journey-link.md` names the relevant IDs or explains why they were skipped:

```bash
lets journey status <journey_id>
lets run receipt <run_id>
lets run export-evidence <run_id>
lets journey export <journey_id> --update-pointer
```

Do not fail a standalone skill run solely because the CLI is unavailable. Do fail if the run claimed Core evidence exists but the referenced artifact cannot be found or verified.

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

### Spec and Task Adherence
| Item | Status | Evidence |
|------|--------|----------|
| Critical clarifications | Resolved | clarifications.md |
| Story task completion | Completed | story-tasks.md T001-T008 checked |
| Requirement mapping | Complete | traceability.md |

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
| Scenario | Task | Test | Status |
|----------|------|------|--------|
| Happy path | T003 | test_create_invoice | Covered |
| Invalid input | T002 | test_create_invoice_invalid | Covered |
| DB timeout | T005 | — | Deferred (follow-up ticket #456) |

### Core Linkage
| Primitive | Identifier | Status |
|-----------|------------|--------|
| Feature key | my-feature | linked |
| Journey | journey-123 | linked |
| Evidence bundle | run-456-evidence.tar.gz | exported |

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
- Treat checked-off tasks as evidence unless each task names proof
- Accept pre-existing failures as "not our problem" for critical paths we touched

## Relationship to lets-verify-change

`lets-verify-change` does a broader verification sweep. This stage is the INTERNAL verification before handoff:
- Stage 8 (this): "Did I implement what I planned?"
- `lets-verify-change`: "Is this change safe to ship?"

Both are needed. Stage 8 catches plan-deviation. `lets-verify-change` catches things the plan missed.
