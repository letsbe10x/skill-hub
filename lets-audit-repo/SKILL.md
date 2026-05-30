---
name: lets-audit-repo
description: "Use when you need a governance baseline, compliance-readiness check, or policy-drift report for a repository. Invoke before platform onboarding, compliance reviews, or after rapid development. Do not use when you only need to understand codebase structure — use lets-onboard-repo instead."
metadata:
  author: letsbe10x
  version: "1.0.2"
  tags: [audit, governance, ai-readiness]
lifecycle: published
source: https://github.com/letsbe10x/skill-hub/blob/main/lets-audit-repo/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - audit this repo
  - governance audit
  - compliance check
goals:
  - audit_governance
outcome_runtime:
  open_agency_zones:
    - governance_gap_analysis
    - remediation_prioritization
  governed_action_zones:
    - governance_gap_claims
    - remediation_recommendation
  allowed_moves:
    - challenge_repository_readiness
    - request_missing_context_pack
    - rank_gaps_by_risk
  hard_limits:
    - do_not_fabricate_policy_findings
    - do_not_hide_compliance_risk
  required_decision_frames:
    - audit_prioritization_decision
  validation_gates:
    - audit_evidence_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
    - compliance_risk
---

## Audit Law

**NO AUDIT FINDING WITHOUT RUNNING THE GOAL AND CITING ITS OUTPUT.**

Every gap, violation, and remediation suggestion must trace to a real audit output line. If the goal cannot run, report the prerequisite failure — do not substitute heuristic reasoning for a real audit.

## Overview

`lets-audit-repo` runs a full governance audit against a repository and turns the raw audit output
into an actionable gap report. Each gap is paired with a concrete remediation suggestion — the
specific file, configuration change, or process fix needed to close it — and the gaps are
prioritised so the most impactful fixes come first.

Use this skill to establish a governance baseline for a new repo, to prepare for a compliance
review, or to catch drift from policy standards introduced by recent changes.

## Phase 0 — Load workflow context (optional)

If letsbe10x is installed and an active run directory exists, read
context artifacts before executing the audit:

```bash
# Only if the lets CLI is installed:
lets run list --format json 2>/dev/null | jq '.[0].run_dir // empty'
```

When a run directory is found, read `workflow_context.json` and
`classification.json` from it. Extract `must_preserve`, `defaults`,
`engineering.doctrine_sources`, and `governance_verdict`. If
`governance_verdict == "BLOCK"`: stop. Embed `must_preserve.critical_paths`
in context for all subsequent phases.

If letsbe10x is not installed, or no active run exists, skip Phase 0
silently and proceed with the standalone audit below.

---

## When to Use

- A repo is being onboarded to the letsbe10x platform and needs a governance baseline.
- A compliance review or audit is scheduled and you need a pre-audit gap report.
- You suspect policy drift after a period of rapid development.
- You want to understand which governance rules a repo currently violates before enforcing them.

## When Not to Use

- You only need to understand codebase structure — use `lets-onboard-repo` instead.
- The repo has never been configured for the letsbe10x platform — bootstrap it first with `lets-bootstrap-repo`.
- You want to fix known gaps immediately without a full audit — go directly to the remediation step.
- You are running automated compliance checks with an external framework that already produces its own reports.

## Steps

1. **Input:** repo root path (default: current directory).

   **Execute the audit.** Two paths:

   - **Platform-accelerated (if letsbe10x is installed):**
     ```bash
     lets run exec --goal audit_governance
     ```
     Captures the full policy stack against the repo's current state.

   - **Standalone (no platform dependencies):**
     Walk the repo and check each of the following directly. The agent
     performs these checks; no runtime required.

     | Category | Check | Source |
     |---|---|---|
     | Identity | `README.md` exists, ≥40 lines, has install + usage sections | `cat README.md` |
     | Identity | `LICENSE` file present (SPDX-recognised) | filesystem |
     | Identity | `.gitignore` present and language-appropriate | filesystem |
     | Agents | `AGENTS.md` or `CLAUDE.md` present at repo root | filesystem |
     | Tests | `tests/`, `test/`, `spec/`, or `__tests__/` directory present | filesystem |
     | Tests | At least one test file referenced from a CI workflow | grep CI YAML |
     | CI | `.github/workflows/` directory with ≥1 workflow | filesystem |
     | CI | Workflow runs on push and pull_request | `cat workflows/*.yml` |
     | Security | `SECURITY.md` present | filesystem |
     | Security | No tokens / API keys in tracked files | `git grep -E '(api[_-]?key|token|secret)\s*=\s*"'` |
     | Conduct | `CODE_OF_CONDUCT.md` present | filesystem |
     | Dependencies | Lockfile present (`uv.lock`, `package-lock.json`, `Cargo.lock`, …) | filesystem |
     | Dependencies | `pyproject.toml` / `package.json` declares author + license | parse manifest |
     | Branch | Default branch protected (best-effort via `gh api repos/:owner/:repo/branches/main/protection`) | gh CLI |
     | Releases | `CHANGELOG.md` present or release tags exist | filesystem + `git tag` |
     | Docs | `docs/` directory present OR README is comprehensive | filesystem |

     Each missing or failing check counts as a gap.

   **Output:** raw gap list — each entry pairs a check name with its
   pass/fail/skip status and the evidence that produced the result
   (file path, command output, or "not found").

2. **Input:** gap list from step 1.

   Classify each gap by severity:
   - **P0 (violation):** blocks CI, deploys, or governance enforcement
     (e.g. no LICENSE, secrets committed, no CI on PRs).
   - **P1 (execution):** degrades run quality or observability
     (e.g. no CHANGELOG, missing test coverage, no SECURITY.md).
   - **P2 (advisory):** best-practice not yet adopted
     (e.g. no CODE_OF_CONDUCT, no docs/ directory if README is thin).

   **Output:** structured gap list with severity assigned.

3. **Input:** classified gap list from step 2; remediation patterns
   from [`references/remediation-patterns.md`](references/remediation-patterns.md).

   For each gap, produce a remediation suggestion with the specific
   file or config change needed. Reference the patterns file for
   canonical solutions to common gaps.

   **Output:** gap list annotated with remediation steps and estimated
   effort (in hours).

4. **Input:** annotated gap list from step 3.

   Produce the prioritised gap report: violations first (P0), then
   execution gaps (P1), then advisory gaps (P2). Each section lists
   the gap, evidence, remediation, and effort estimate.

   **Output:** prioritised gap report with summary line stating total
   gap count per severity and estimated total remediation effort.

## Checkpoints

Before delivering the gap report, confirm with the user:
> "Audit complete — `$VIOLATION_COUNT` violations, `$GAP_COUNT` total gaps found. Ready to present the prioritised report? (y/n)"

If the user responds no, ask what scope to focus on before presenting.

## Error Handling

- If the platform-accelerated path (`lets run exec --goal audit_governance`)
  fails: report the failure mode (missing config, locked workspace,
  policy load error) and fall back to the standalone check list. Do
  not abort the audit — the standalone path produces a valid report
  without the platform.
- If `references/remediation-patterns.md` is missing: produce remediations
  from first principles and note that the patterns file is absent.
- If `gh` is not on PATH: skip the branch-protection check and mark it
  `skipped (gh required)`. Do not invent a result.
- If a check would fail because the repo uses a different convention
  (e.g. `LICENCE` vs `LICENSE`, or `.coc.md` vs `CODE_OF_CONDUCT.md`):
  recognise the alternate file and pass the check. Document the
  alternate name in the report.
- If `governance_verdict == "BLOCK"` was set in Phase 0: stop and
  surface the block reason. Fallback: ask the user if they want to
  run the audit in read-only inspection mode instead.
- If the audit returns zero gaps: verify each check actually ran
  (not silently skipped) before reporting "no gaps found". A clean
  audit must list every check it ran with a pass/skip status.

## Anti-patterns

- **Fabricating gaps or violations** — every finding must trace to the audit output; invented findings are worse than a partial report.
- **Skipping P0 violations** — violations that block runs must always appear in the report; never omit them for brevity.
- **Treating P2 advisory gaps as optional** — the full report must include all three priority tiers, even if tiers are empty.
- **Running audit steps before completing Phase 0** — governance verdict check must happen first; an auditor that bypasses its own governance check is not trustworthy.
- **Claiming "audit passed" with zero output** — a silent no-op is not a clean audit; verify the goal produced output before concluding.

## Outputs

A prioritised governance gap report containing:

- **P0 — Violations** — active policy failures that block runs or deploys. Each entry includes
  the policy name, the failing condition, and the remediation step.
- **P1 — Execution gaps** — policies not satisfied that degrade run quality or observability.
- **P2 — Advisory gaps** — best-practice policies not yet adopted, with low operational impact.
- **Summary** — total gap count by priority and an estimated remediation effort (hours).

Done when: the report is delivered, all three priority tiers are represented (even if empty), and the user has acknowledged the P0 violations.

## Example

```text
User: audit this repo before we onboard it to the platform
Response: runs Phase 0 governance check, executes lets run exec --goal audit_governance, parses
output, presents prioritised P0/P1/P2 gap report with remediation suggestions, then confirms
with user "(y/n)" before finalising.
```
