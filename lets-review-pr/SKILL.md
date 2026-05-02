---
name: lets-review-pr
description: "Use when posting a GitHub PR review after lets-review-code has run. Posts findings as a GitHub review comment with approval or changes-requested verdict."
metadata:
  author: cogsmith-ai
  version: "1.0.0"
  tags: [review, pull-request, code-quality]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-review-pr/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - review this PR
  - review PR
goals:
  - review_change
outcome_runtime:
  open_agency_zones:
    - review_strategy
    - diff_risk_analysis
    - finding_prioritization
  governed_action_zones:
    - review_verdict
    - github_review_comment
  allowed_moves:
    - request_missing_diff_context
    - classify_false_positive
    - escalate_security_risk
  hard_limits:
    - do_not_fabricate_evidence
    - do_not_post_review_without_code_evidence
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

## Overview

`lets-review-pr` automates the PR review workflow: it fetches the diff for a pull request, analyses
the changes, and formats the result as a structured review comment. The review covers correctness,
test coverage, style, and risk — with an explicit approve or request-changes recommendation at the
end.

The skill can optionally post the review directly to GitHub via `gh pr review`, making it usable
as a one-command review gate in CI or as an interactive tool for on-demand review.

## When to Use

- You want a consistent, structured review of any PR before merging.
- You are a maintainer reviewing a contributor's PR and want a first-pass analysis.
- You want to enforce a review quality bar in CI (block merge without a structured review).
- You need a second opinion on a PR you have already reviewed manually.

## When Not to Use

- The PR contains secrets or sensitive material you are not allowed to process in this environment.
- You only need formatting or nit-level feedback and do not want a full risk/correctness assessment.

## Inputs

- Input: PR identifier (URL, number, or branch ref)
- Input: Review preferences (strictness, areas of focus, whether posting is allowed)

## Steps

1. Get the PR diff: run `gh pr diff $PR_NUMBER` or use the GitHub adapter if configured. Accept a PR
   URL, PR number, or branch name as input.
2. Analyse the diff for correctness, test coverage, style, and risk. Use the review prompt in
   [references/review-prompt.md](references/review-prompt.md).
3. Format the output as a structured review using three sections: **Summary** (one paragraph),
   **Section comments** (per-file or per-hunk observations), and **Recommendation**
   (approve / request-changes / comment, with rationale).
4. Optionally post the review to GitHub: run `gh pr review $PR_NUMBER --body "$REVIEW_BODY"` with
   `--approve` or `--request-changes` based on the recommendation.

## Checkpoints

- Confirm (y/n): post the review comment to GitHub. If the user does not confirm, produce the review body only.

## Error handling

- If fetching the diff fails or the PR identifier is ambiguous, ask for a PR URL or PR number and retry.
- If posting is requested but authentication is missing, do not post; return the review body and the exact command the user can run.

## Anti-patterns

- **Approving a PR with an unresolved blocking comment** — every BLOCK-severity finding must be resolved before approval.
- **Reviewing only the diff without reading context** — read the repo's AGENTS.md or README for architectural context before reviewing.
- **Posting a GitHub review without a complete findings summary** — the review comment must include all findings.
- **Fabricating evidence for a finding** — every comment must cite real code; do not fabricate evidence or invent line numbers that do not exist.

## Outputs

A structured PR review containing:

- Output: **Summary** — overall assessment of the change: what it does, risk level, and quality signal.
- Output: **Section comments** — per-file or per-hunk observations flagging issues, questions, or praise.
- Output: **Recommendation** — one of: `APPROVE`, `REQUEST_CHANGES`, or `COMMENT`, with a one-sentence
  rationale.

Done when: The review includes an explicit recommendation and cites at least one concrete risk and one concrete strength from the diff.

If `--post` is requested and confirmed, the review is also posted to GitHub as a PR review comment.

## Example

```text
User: review PR 1234 and do not post
Response: provides Summary, Section comments, and Recommendation, then stops without calling gh.
```
