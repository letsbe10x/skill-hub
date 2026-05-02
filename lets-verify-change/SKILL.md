---
name: lets-verify-change
description: "Use after lets-develop-feature completes and before lets-review-code. Drives the verify-change goal to run tests and produce a verification report. Do not invoke without implementation being complete."
metadata:
  author: cogsmith-ai
  version: "1.0.0"
  tags: [testing, verification, delivery]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-verify-change/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
outcome_runtime:
  open_agency_zones:
    - verification_strategy
    - risk_based_test_selection
  governed_action_zones:
    - verification_claim
  allowed_moves:
    - request_missing_test_surface
    - narrow_verification_to_risk
  hard_limits:
    - do_not_claim_success_without_command_output
    - do_not_ignore_failing_checks
  required_decision_frames:
    - verification_scope
  validation_gates:
    - verification_evidence_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
    - unresolved_disagreement
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

## Verification Law

**NO COMPLETION CLAIM WITHOUT FRESH VERIFICATION RUN.**

If you have not run the verification command in this response, you cannot report it as passing.
"Should pass", "likely passes", "passed last time" are not verification evidence.

# lets-verify-change

Run tests against the current change and record the verification result for the review stage.

## When to use

- After `lets-develop-feature` has run and the implementation work packages are complete
- Before `lets-review-code` — the review stage reads the verification status from this stage's handoff
- Part of a `pr-ship` workflow: lets-develop-feature → lets-verify-change → lets-review-code

---

## Inputs

- Input: Implementation status — `lets-develop-feature` must have completed
- Input: Repo root path

## Phase 1 — Prerequisites check

Before running, confirm:

1. Implementation work packages from the execution packet are done
2. There are no uncommitted changes that were not part of the planned implementation

If implementation is not complete, invoke `lets-develop-feature` first. Confirm before proceeding: "Has `lets-develop-feature` completed? (y/n)"

---

## Phase 2 — Run the test suite

Detect the project's test runner and run it:

```bash
# Python (pytest):
uv run pytest tests -v
# or:
python -m pytest tests -v

# JavaScript/TypeScript:
npm test

# Rust:
cargo test

# Go:
go test ./...
```

Capture the full output. Do not skim or scroll past failures.

**Expected output indicators:**
- Pass: `N passed, 0 failed, 0 errors`
- Fail: any `FAILED` lines or non-zero exit code
- Skipped: no test runner detected or no test files found

---

## Phase 3 — Interpret test status

| `test_status` | Meaning | Action |
|---------------|---------|--------|
| `passed` | All tests pass | Proceed to lets-review-code |
| `failed` | One or more tests failed | Fix failures before proceeding |
| `skipped` | No test runner detected | Proceed with a note; add tests if possible |

---

## Phase 4 — Fix test failures (if failed)

When tests fail:

1. Read the failure output carefully — identify the failing test name and the assertion that failed
2. Run the failing test in isolation to see full output:
   ```bash
   # Pytest — run single failing test:
   uv run pytest tests/test_foo.py::test_bar -v
   # Jest — run single failing test:
   npx jest --testNamePattern "test name"
   ```
3. Fix the failing tests or the implementation bug causing them
4. Re-run the full test suite after fixing

Do not proceed to lets-review-code with failing tests.

---

## Phase 5 — No test runner detected

When no test command is detected:

Check the repo for test configuration: look for `pytest.ini`, `pyproject.toml [tool.pytest]`, `jest.config.*`, `package.json` test scripts, `Makefile` test targets.

If no test configuration exists, note in the handoff that no automated verification was possible and proceed to lets-review-code with this caveat.

---

## Phase 6 — Handoff to lets-review-code

When tests are passing or skipped, invoke `lets-review-code`.

---

## Example

```bash
# Full verification run for a Python project
uv run pytest tests -v --tb=short
```

## Anti-patterns

- **Reporting "tests should pass" without running them** — blocked. Run verification before claiming it.
- **Marking complete before reading full test output** — blocked. Read the full output including failure details.
- **Proceeding to lets-review-code with failing tests** — blocked.
- **Running verification once and skipping re-run after fixes** — re-run is required after each fix.

## Hard rules

- Do not proceed to lets-review-code if tests are failing.
- Re-run the full test suite after every fix — do not assume the fix worked without confirmation.

Done when: tests are confirmed passing (or skipped with documented reason) from a verification run executed in this session.
