---
name: lets-verify-ready
description: "Use to confirm a change is ready to ship — all checks pass, no red flags are active. Invoke before merging or deploying."
metadata:
  author: cogsmith-ai
  version: "1.0.0"
  tags: [verification, completion, quality-gate]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-verify-ready/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - done
  - complete
  - all tests pass
  - ready to merge
  - ready to commit
  - ship it
outcome_runtime:
  open_agency_zones:
    - verification_scope_selection
    - evidence_interpretation
  governed_action_zones:
    - completion_claim
    - verification_claim
  allowed_moves:
    - request_missing_command_output
    - block_completion_on_failed_checks
  hard_limits:
    - do_not_claim_success_without_command_output
    - do_not_ignore_failing_checks
  required_decision_frames:
    - verification_readiness_decision
  validation_gates:
    - verification_evidence_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `lets` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

# lets-verify-ready

Run verification commands and read their output before claiming anything is done.

## Overview

Claiming work is complete without verification is dishonesty, not efficiency. Agents and developers naturally express satisfaction before confirming results. This skill enforces the discipline: evidence before claims, always.

**Core principle:** If you have not run the verification command in this turn, you cannot claim it passes.

**Violating the letter of this rule is violating the spirit of this rule.**

## When to Use

- About to say "done", "complete", "all tests pass", or any equivalent
- About to commit, push, or open a PR
- After an agentic worker reports success on a subtask
- After implementing a fix and before reporting the fix works
- After any delegation where you trusted an agent's success report

## When Not to Use

- You are still implementing or debugging and are not about to make a success claim.
- You need a planning artifact rather than an evidence gate (use a planning skill first).

## Inputs

- Input: The claim you intend to make (tests pass, build passes, requirements met, fixed)
- Input: The exact command(s) that prove the claim
- Input: The terminal output from the current turn

## Steps

1. **Identify** — What command proves the claim? Name it explicitly before running anything.

2. **Run** — Execute the full command. No partial runs, no cached output, no terminal scrollback.

3. **Read** — Read the full output. Check the exit code. Count failures. Do not skim.

4. **Verify** — Does the output confirm the claim? If the answer is "probably" or "seems to", that is a NO.

5. **Claim** — Only after steps 1–4 is a completion claim permitted.

### Verification patterns by claim type

| Claim | Verification command | What to check |
|---|---|---|
| "Tests pass" | Run test suite | See `N of N pass`, zero failures |
| "Build passes" | Run build | Exit code 0, no errors |
| "Requirements met" | Re-read plan → checklist | Every item ticked |
| "Agent completed task" | Check VCS diff | Actual changes match stated changes |
| TDD regression | Write → Run (pass) → Revert → Run (MUST fail) → Restore → Run (pass) | Fail step must fail |

## Red Flags — STOP

These phrases mean you are about to violate this skill. Stop immediately.

- "Should pass", "probably works", "seems to"
- "Great!", "Perfect!", "Done!" before running verification
- "The agent said it passed" without checking the diff
- Relying on the previous run's output (must be fresh)
- Partial verification ("ran a few tests")

## Outputs

- Output: A fresh verification command run in the current turn
- Output: Exact pass/fail counts or exit codes reported inline
- Output: A completion claim that cites the verification output, or an honest status report of what failed
- Done when: The claim is backed by a command run in this turn and the output is explicitly quoted or summarized with counts/exit code.

## Example

```bash
uv run pytest -q
```

## Anti-patterns

- **Claiming success from a previous turn's output** — blocked. Verification output must be fresh from this turn; cached or scroll-back output does not count.
- **Partial verification ("ran a few tests")** — blocked. Run the full suite; do not declare readiness on a subset.

## Error handling

- If the verification command fails, do not claim success. Instead: report the failure count, capture the first failing stack trace, and propose the next smallest repro step.
- If the failure is ambiguous, run a narrower check as a fallback (for example: the single failing test file), then retry the full verification.
- If the verification output is missing (command not run in this turn), ask to run it now instead of guessing.
