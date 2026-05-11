---
name: lets-review-code
description: "Multi-lens code review with planner-driven depth selection, 6 review lenses, AI failure-mode detection, finding verification, and evidence-quality discipline. Produces severity-ranked findings with confidence scores and gates PR creation on zero blocking issues."
metadata:
  author: cogsmith-ai
  version: "3.1.0"
  tags: [review, code-quality, delivery, security, architecture]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-review-code/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - review this code
  - review the latest commit
  - code review
  - is this ready to merge
  - check this before PR
  - deep review
  - review for correctness
  - review for security
outcome_runtime:
  open_agency_zones:
    - review_strategy
    - defect_hypothesis_generation
    - reviewer_focus_selection
    - classification_depth_decision
    - change_risk_analysis
    - lens_prioritization
  governed_action_zones:
    - review_verdict
    - external_review_comment
  allowed_moves:
    - challenge_initial_framing
    - request_missing_diff_context
    - classify_false_positive
    - escalate_security_risk
    - escalate_architectural_violation
    - flag_ai_failure_mode
  hard_limits:
    - do_not_fabricate_evidence
    - do_not_claim_tests_passed_without_output
    - do_not_skip_linter
    - do_not_soften_blocking_findings
    - do_not_approve_with_unverified_claims
  required_decision_frames:
    - review_verdict
    - classification_verification
  validation_gates:
    - finding_evidence_gate
    - lint_gate
    - classification_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - unresolved_disagreement
    - compliance_risk
    - architectural_invariant_violation
    - security_critical_finding
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

# lets-review-code

Multi-lens code review with intelligent depth selection. Classifies the change, selects review depth, runs specialized lenses, verifies findings against actual code, and produces a severity-ranked report. Operational detail in phase-specific references — this file is the contract.

---

## Phases & Gates

```
Phase 1: Classify    → Determine change type, scale, risk, depth
Phase 2: Context     → Build repo context brief (AGENTS.md, module map, hotspots)
Phase 3: Lint        → Mandatory lint gate (never skipped)
Phase 4: Multi-Lens  → Run activated lenses per depth decision
Phase 5: Verify      → Verify each finding against actual code
Phase 6: Consolidate → Deduplicate, rank by severity, umbrella findings
Phase 7: Verdict     → PASS / PASS_WITH_NOTES / FAIL
Phase 8: Fix         → Auto-fix or escalate blocking findings
```

---

## When to Use

- After `lets-verify-change` completes with tests passing or skipped
- Final quality gate before raising a PR
- Part of: lets-develop-feature → lets-verify-change → **lets-review-code**
- When you want a thorough review beyond surface-level lint

## When Not to Use

- `lets-verify-change` has not run yet — run verification first
- Reviewing an existing PR from GitHub (use `lets-review-pr`)
- Single-line config tweak with no logic impact

---

## Depth Selection (Phase 1)

Classify the change, then select depth. See [references/PLANNER.md](references/PLANNER.md) for the full classification matrix.

| Depth | When | Active lenses |
|-------|------|---------------|
| **FULL** | >300 LOC, security-touching, new public API, migration, multi-module | All 6 + AI failure-mode |
| **STANDARD** | 50–300 LOC, typical feature/bugfix | Correctness, Security, Completeness + AI failure-mode |
| **LIGHT** | <50 LOC, config/docs/test-only | Correctness + quick security scan |

**Gate overrides** force deeper review regardless of scale:
- Security gate: touches auth/crypto/secrets → Security lens at FULL depth
- Architecture gate: new abstraction, cross-boundary → Architecture lens
- API gate: public interface change → API lens
- AI failure gate: code appears generated → AI failure-mode scan

State classification before proceeding:
> **Classification: STANDARD** — 142 lines across 5 files, touches business logic.

---

## Lint Gate (Phase 3 — mandatory)

**Never skipped.** Detect linter from config, run against changed files only, record new issues vs. pre-existing. Only new issues count toward verdict.

```bash
# Example: Python with ruff
ruff check $(git diff --name-only HEAD~1 -- '*.py') 2>&1 || true
```

---

## Multi-Lens Review (Phase 4)

Run each activated lens. Each answers ONE primary question. See [references/LENSES.md](references/LENSES.md) for detailed patterns and verification protocols per lens.

| Lens | Primary question |
|------|-----------------|
| **Correctness** | Does the code do what it claims? |
| **Security** | Can this be exploited or does it leak data? |
| **Architecture** | Is this the right design at the right level? |
| **API & Contracts** | Will this break callers or violate contracts? |
| **Completeness** | Is this production-ready? |
| **Complexity** | Is this more complex than necessary? |
| **AI Failure-Mode** | Does this exhibit patterns common in generated code? |

---

## Finding Verification (Phase 5)

**Every finding must survive verification before reaching the report.** See [references/VERIFICATION.md](references/VERIFICATION.md) for the full protocol.

For each potential finding:
1. Re-read the actual source file (not just the diff)
2. Check 50+ lines of surrounding context
3. Trace callers/callees — does a caller handle the case?
4. Check project conventions (AGENTS.md, existing patterns)
5. Classify: **REAL** | **DEFER** | **FALSE_POSITIVE**

For REAL findings, also record:
- **Confidence** (0.0–1.0)
- **Evidence** (exact file:line + observed behavior)
- **Caveat** (what couldn't be verified)
- **Challenge** (how this finding could be wrong)

---

## Consolidation (Phase 6)

### Severity

| Severity | Meaning | Blocks? |
|----------|---------|---------|
| **CRITICAL** | Security vuln, data loss, crash in production path | Yes |
| **HIGH** | Bug causing incorrect behavior under normal use | Yes |
| **MEDIUM** | Edge case, missing validation, significant tech debt | No |
| **LOW** | Style, minor optimization, nitpick | No |

### Rules
- Same location flagged by multiple lenses → keep highest severity, merge evidence
- Multiple findings sharing one root cause → report as **umbrella finding**
- Use [assets/templates/review-report.template.md](assets/templates/review-report.template.md) for report structure

---

## Verdict (Phase 7)

| Verdict | Criteria |
|---------|----------|
| **PASS** | Zero CRITICAL or HIGH findings |
| **PASS_WITH_NOTES** | Zero blocking, some MEDIUM findings |
| **FAIL** | One or more CRITICAL or HIGH findings |

State explicitly:
> **Verdict: PASS** — No blocking issues. 2 MEDIUM findings noted for follow-up.

---

## Fix or Escalate (Phase 8)

When blocking findings exist:
1. Auto-fixable lint → fix (`ruff check --fix`)
2. Code bugs with confidence ≥0.85 → fix, re-run tests, re-lint
3. Design issues or low-confidence → surface to user with options

After fixing, restart from Phase 3 (lint gate) through the full pipeline.

---

## Error Handling

- If linter is not configured: note "No linter configured" and proceed (Phase 3 still runs, just records absence)
- If diff fetch fails: ask for commit range or file list
- If file context is unavailable for verification: note in caveat, lower confidence
- If findings conflict between lenses: note both perspectives with evidence in the report

---

## Anti-patterns

- **Skipping the linter** — mandatory, always
- **Approving without test confirmation** — verification must be confirmed
- **Generic findings** — every finding must explain impact for THIS system, not cite general rules
- **Findings without evidence** — must cite file:line with actual code
- **False confidence** — if you can't verify, lower confidence and note caveat
- **Reviewing only the diff** — always read full file context
- **Ignoring AI failure modes** — generated code is often plausible but wrong
- **Style over substance** — correctness and security take precedence over formatting
- **Symptoms instead of root causes** — umbrella findings, not 5 duplicates

---

## Outputs

- Output: Change classification (type: feature/bugfix/refactor/config/test/docs, depth: FULL/STANDARD/LIGHT, risk signals)
- Output: Lint results (exit code, new issue count vs pre-existing)
- Output: Severity-ranked findings table with confidence scores (0.0–1.0) and file:line evidence
- Output: Detailed finding reports with evidence, caveats, challenges, and fix suggestions
- Output: Formal verdict (PASS / PASS_WITH_NOTES / FAIL) with rationale

Done when: Verdict is issued, and either ready to ship (PASS) or blocking issues are surfaced to user (FAIL).

---

## References (Progressive Disclosure)

Read each reference only when its phase activates — not upfront.

| Reference | When to read |
|-----------|-------------|
| [PLANNER.md](references/PLANNER.md) | Phase 1 — classification matrix, depth decision, gate overrides |
| [LENSES.md](references/LENSES.md) | Phase 4 — detailed patterns and checks per lens |
| [VERIFICATION.md](references/VERIFICATION.md) | Phase 5 — finding verification protocol, confidence calibration |

## Templates & Scripts

| Asset | Purpose | Used in |
|-------|---------|---------|
| [assets/templates/review-report.template.md](assets/templates/review-report.template.md) | Report structure | Phase 6 |
| [assets/templates/finding.schema.json](assets/templates/finding.schema.json) | Finding data schema | Phase 5/6 |
| [scripts/classify_change.sh](scripts/classify_change.sh) | Automated change classification | Phase 1 |
