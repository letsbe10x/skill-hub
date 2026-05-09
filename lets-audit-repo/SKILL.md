---
name: lets-audit-repo
description: Runs a governance audit against a repo and produces a gap report with remediation suggestions.
metadata:
  author: cogsmith-ai
  version: "1.0.0"
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


## Overview

`lets-audit-repo` runs a full governance audit against a repository and turns the raw audit output
into an actionable gap report. Each gap is paired with a concrete remediation suggestion — the
specific file, configuration change, or process fix needed to close it — and the gaps are
prioritised so the most impactful fixes come first.

Use this skill to establish a governance baseline for a new repo, to prepare for a compliance
review, or to catch drift from policy standards introduced by recent changes.

## When to Use

- A repo is being onboarded and needs a governance baseline.
- A compliance review or audit is scheduled and you need a pre-audit gap report.
- You suspect policy drift after a period of rapid development.
- You want to understand which governance rules a repo currently violates before enforcing them.

## Steps

1. Execute the governance audit goal against the target repo. The audit checks all configured
   policies against the repo's current state.
2. Parse the audit output for gaps and violations. A gap is any policy that is not satisfied;
   a violation is a gap that is actively enforced (i.e. would block a run or deploy).
3. For each gap: produce a remediation suggestion with the specific file or config change needed.
4. Produce a prioritised gap report: violations first (P0), then gaps that affect run execution
   (P1), then advisory gaps (P2).

## Outputs

A prioritised governance gap report containing:

- **P0 — Violations** — active policy failures that block runs or deploys. Each entry includes
  the policy name, the failing condition, and the remediation step.
- **P1 — Execution gaps** — policies not satisfied that degrade run quality or observability.
- **P2 — Advisory gaps** — best-practice policies not yet adopted, with low operational impact.
- **Summary** — total gap count by priority and an estimated remediation effort (hours).
