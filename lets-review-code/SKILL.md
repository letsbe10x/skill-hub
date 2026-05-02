---
name: lets-review-code
description: "Use after lets-verify-change passes to review code correctness, test coverage, and functional gaps. Drives the review-change goal and produces a findings report."
metadata:
  author: cogsmith-ai
  version: "1.0.0"
  tags: [review, code-quality, delivery]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-review-code/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
outcome_runtime:
  open_agency_zones:
    - review_strategy
    - defect_hypothesis_generation
    - reviewer_focus_selection
  governed_action_zones:
    - review_verdict
    - external_review_comment
  allowed_moves:
    - challenge_initial_framing
    - request_missing_diff_context
    - classify_false_positive
  hard_limits:
    - do_not_fabricate_evidence
    - do_not_claim_tests_passed_without_output
  required_decision_frames:
    - review_verdict
  validation_gates:
    - finding_evidence_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - unresolved_disagreement
    - compliance_risk
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

# lets-review-code

Lint the change, evaluate quality against the execution packet, and emit a review summary.

## When to use

- After `lets-verify-change` completes with tests passing or skipped
- Final step before raising a PR in the `pr-ship` workflow
- Part of a `pr-ship` workflow: lets-develop-feature → lets-verify-change → lets-review-code

## When not to use

- `lets-verify-change` has not run yet — run verification before code review.
- You only need to check PR structure (use `lets-review-pr` for that).

## Inputs

- Input: Verification status — tests must have passed or been skipped
- Input: Repo root path
- Input: The diff or list of changed files

## Example

```bash
# Review the staged change
git diff HEAD
# Run linter
uv run ruff check src/
```

Confirm before posting findings: "Are you ready to finalize the review? (y/n)"

---

## Phase 1 — Prerequisites check

Before reviewing, confirm:

1. Verification (`lets-verify-change`) completed with tests passing or skipped
2. No uncommitted work that should be part of this change

If tests are failing, go back to `lets-verify-change` and fix failures first.

---

## Phase 2 — Run linters

Run the project's linter(s) against the changed files:

```bash
# Ruff (Python):
uv run ruff check src/
# ESLint (JS/TS):
npx eslint src/
# Or use whatever linter the project configures
```

Capture exit codes and issue counts.

---

## Phase 3 — Review the diff

Read the full diff of changes:

```bash
git diff HEAD
# or: git diff --staged
```

Evaluate against the execution packet (task description and work packages from lets-develop-feature):

**`change_quality` verdict:**

| Value | Meaning | Action |
|-------|---------|--------|
| `acceptable` | Change surface present and verified | Proceed to raise PR |
| `insufficient` | No meaningful change surface detected | Re-examine scope; confirm intent with user |

**Finding severity:**

| `severity` | Meaning |
|------------|---------|
| `warn` | Non-blocking; note in PR description |
| `error` | Should be fixed before merging |

---

## Phase 4 — Address lint failures

When the linter exits non-zero:

1. Run the linter with auto-fix if available:
   ```bash
   # Ruff:
   uv run ruff check src/ --fix
   # ESLint:
   npx eslint src/ --fix
   ```
2. Fix any remaining issues manually
3. Re-run the linter to confirm clean exit

---

## Phase 5 — Raise PR

When `change_quality == "acceptable"` and no `error`-severity findings remain:

1. Stage the changes:
   ```bash
   git add -p   # review each hunk
   ```

2. Commit:
   ```bash
   git commit -m "feat: ${TASK_SUMMARY}"
   ```

3. Push and open PR:
   ```bash
   git push -u origin "$(git branch --show-current)"
   gh pr create \
     --title "$TASK_TITLE" \
     --body "$(cat <<'EOF'
   ## Summary
   - Work package 1 intent
   - Work package 2 intent

   ## Test status
   $TEST_STATUS — $PASSED_COUNT passed

   ## Review notes
   $WARNINGS
   EOF
   )"
   ```

Populate the PR body from the execution packet (`task`, `work_packages[*].intent`) and verification output (test counts).

---

## Anti-patterns

- **Approving without confirming test status** — verification status must be confirmed before approval.
- **Commenting on style without flagging functional gaps** — functional correctness takes precedence over style.
- **Marking review complete with unresolved blocking comments** — blocking comments must be resolved or acknowledged.
- **Fabricating evidence for a finding** — every finding must cite a real code location; do not fabricate evidence or invent line references.

## Outputs

- Output: A summary of lint results and change quality verdict
- Output: A PR raised via `gh pr create` when change quality is acceptable

Done when: no unresolved blocking comments remain and the PR has been raised.

## Hard rules

- Do not raise a PR if change quality is insufficient — re-examine the change scope.
- Do not raise a PR if any `error`-severity finding remains unresolved.
- Never commit on behalf of the user without showing the diff (`git diff --staged`) first.
- If the linter fails to detect the language, fallback to running `git diff HEAD` and reviewing the diff manually instead of skipping the review.
- If an error-severity finding cannot be auto-resolved, surface it to the user for manual review and wait for confirmation before proceeding.
