---
name: lets-spec-to-pr
description: "Use when you have an approved spec and want to implement it end-to-end from governance classification through PR creation. Combines change-code, verify-change, and review-change goals."
metadata:
  author: cogsmith-ai
  version: "1.0.0"
  tags: [spec, implementation, delivery]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-spec-to-pr/SKILL.md
compatibility:
  agents: [claude-code]
  requirements:
    - Claude Code Agent tool for parallel sub-agent dispatch
triggers:
  - implement this spec
  - spec to PR
  - build from spec
goals:
  - change_code
  - verify_change
outcome_runtime:
  open_agency_zones:
    - spec_decomposition
    - implementation_sequence_design
    - verification_strategy
  governed_action_zones:
    - filesystem_mutation
    - pull_request_creation
  allowed_moves:
    - split_scope_by_risk
    - request_missing_acceptance_criteria
    - block_on_unverifiable_requirement
  hard_limits:
    - do_not_fabricate_test_results
    - do_not_open_pr_without_verification_evidence
    - do_not_commit_secrets
  required_decision_frames:
    - spec_execution_strategy
  validation_gates:
    - verification_before_completion
    - pr_readiness_gate
  mutation_policy: additive_only
  human_checkpoint_triggers:
    - irreversible_mutation
    - missing_truth
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

## Verification Law

**NO PR WITHOUT PASSING VERIFICATION RUN.**

Do not open a PR without a fresh verification run confirming tests pass in this session.

## Overview

`lets-spec-to-pr` bridges the gap between a written specification and a merged pull request. It
parses a spec or PRD document, decomposes it into discrete implementation tasks, executes each task
through the `change_code` goal, verifies the result, and opens a PR — all in one orchestrated flow.

Each implementation task is tracked independently, giving full traceability from spec requirement
to code change.

## When to Use

- You have a finalized spec or PRD and want to move directly to implementation.
- A feature request has been written up and needs to be broken into code tasks.
- You want automated verification (tests pass, lint clean) before a PR is opened.
- You need full traceability: which spec requirement drove which code change.

## When not to Use

- The spec has not been approved yet — use `lets-create-plan` to draft and refine the plan first.
- You only need to verify an existing change without implementing (use `lets-verify-change`).

## Inputs

- Input: Approved spec or PRD document (file path, URL, or inline text)
- Input: Target branch name (optional — defaults to feature branch from spec name)
- Input: Repo root path

## Example

```bash
# Create feature branch from spec
git checkout -b feat/spec-name
# After implementation and verification:
gh pr create --title "feat: implement spec" --body "..."
```

Confirm before opening the PR: "Verification passed — ready to open PR? (y/n)"

## Steps

1. Read the spec document provided by the user — accept a file path, URL, or inline text.
2. Break the spec into discrete implementation tasks: one task per file group or self-contained
   feature unit. Use the decomposition guide in
   [references/task-decomposition-guide.md](references/task-decomposition-guide.md).
3. For each task: implement the changes described in the task. Log what files were changed for
   traceability back to the spec section.
4. After all tasks complete: run the full test suite to confirm tests pass, lint is clean, and
   no regressions were introduced.
5. Open a PR with the changes using `gh pr create`, linking each commit to its source task and
   spec section in the PR body.

## Anti-patterns

- **Starting implementation before reviewing the full spec** — read and understand the full spec before decomposing into tasks.
- **Raising a PR without a passing test run** — verification evidence is required before PR creation.
- **Treating spec ambiguity as a reason to skip steps** — surface ambiguity via `lets-create-plan` before proceeding.
- **Skipping the PR readiness check** — run `lets-verify-ready` to validate readiness before creating the PR.

## Outputs

- Output: A feature branch with commits corresponding to each implementation task.
- Output: A pull request opened via `gh pr create` with a body that maps each commit to its spec section.
- Output: Traceability from spec requirement to code change to verification result.

Done when: PR is created and verification evidence exists confirming tests pass.

## Error handling

- If implementation fails for a task, log the error and retry that task once before surfacing to the user.
- If verification fails, do not open the PR. Instead report the failure count and propose the next fix step.
- If `gh pr create` fails (e.g. branch already has PR), check for existing PR with `gh pr list` and update it instead.
