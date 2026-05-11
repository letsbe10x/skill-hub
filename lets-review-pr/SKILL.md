---
name: lets-review-pr
description: "Planner-driven PR review controlplane with repo context discovery, multi-lens reviewer routing, finding consolidation, spec alignment, and GitHub posting with structured verdicts. The canonical workflow for reviewing pull requests."
metadata:
  author: cogsmith-ai
  version: "3.1.0"
  tags: [review, pull-request, code-quality, architecture, security]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-review-pr/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - review this PR
  - review PR
  - review pull request
  - PR review
  - review PR #
  - give me a review
  - review before merge
  - review against spec
  - review against PRD
  - does this PR match the spec
  - verify implementation against spec
outcome_runtime:
  open_agency_zones:
    - review_strategy
    - diff_risk_analysis
    - finding_prioritization
    - reviewer_routing_decision
    - spec_gap_identification
    - invariant_violation_analysis
    - security_posture_assessment
    - pipeline_mode_selection
  governed_action_zones:
    - review_verdict
    - github_review_comment
  allowed_moves:
    - request_missing_diff_context
    - request_missing_spec_context
    - classify_false_positive
    - escalate_security_risk
    - escalate_invariant_violation
    - flag_spec_ambiguity
    - downgrade_false_positive
    - upgrade_missed_finding
  hard_limits:
    - do_not_fabricate_evidence
    - do_not_post_review_without_code_evidence
    - do_not_claim_tests_passed_without_output
    - do_not_claim_spec_compliance_without_code_evidence
    - do_not_approve_with_critical_findings
    - do_not_soften_blocking_severity
  required_decision_frames:
    - review_verdict
    - spec_compliance_verdict
  validation_gates:
    - finding_evidence_gate
    - spec_traceability_gate
    - classification_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - unresolved_disagreement
    - compliance_risk
    - architectural_invariant_violation
    - security_critical_finding
    - spec_deviation_on_p0_requirement
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

# lets-review-pr

Planner-driven PR review controlplane. Discovers repo context, classifies the PR, routes to appropriate lenses, verifies findings, consolidates into a severity-ranked report, checks spec alignment, and posts to GitHub. Operational detail in stage-specific references — this file is the contract.

---

## Stages & Gates

```
Stage 0: Fetch       → Get PR diff, metadata, commit history
Stage 1: Context     → Repo context discovery (AGENTS.md, module map, invariants)
Stage 2: Classify    → Pipeline mode selection + lens routing
Stage 3: Review      → Multi-lens review per routed lenses
Stage 4: Verify      → Classify findings (REAL / DEFER / FALSE_POSITIVE)
Stage 5: Consolidate → Deduplicate, rank, umbrella findings
Stage 6: Spec        → Spec alignment check (if PRD/spec linked)
Stage 7: Post        → Verdict + GitHub review posting
```

---

## When to Use

- Reviewing any PR before merging (yours or others')
- Enforcing a structured review quality bar
- Getting a second opinion on a manually reviewed PR
- Validating implementation against a spec/PRD
- CI-integrated review gate (block merge without structured review)

## When Not to Use

- Reviewing local uncommitted code before creating a PR (use `lets-review-code`)
- The PR contains secrets or sensitive material you cannot process
- You only need formatting/nit feedback with no correctness analysis

---

## Stage 0 — Fetch PR & Metadata

```bash
gh pr view $PR_ID --json number,title,body,baseRefName,headRefName,files,additions,deletions,commits,labels,author
gh pr diff $PR_ID
```

Extract: title, body (claims), file list with stats, commit history, labels, spec/PRD references (patterns: `prd-NNN`, `spec:`, `closes #`).

---

## Stage 1 — Repo Context Discovery

Build a context brief to reduce false positives and ensure architectural awareness. See [references/CONTEXT-DISCOVERY.md](references/CONTEXT-DISCOVERY.md) for the full protocol.

**Produce a brief covering:**
1. Repo kind — service / library / CLI / monorepo
2. Module map — which modules are touched
3. Architectural invariants — from AGENTS.md
4. Hotspots — changed files in critical paths?
5. Testing conventions — how does this repo test?
6. Review obligations — AGENTS.md review requirements

---

## Stage 2 — Classify & Route

Determine pipeline mode and active lenses. See [references/PLANNER.md](references/PLANNER.md) for the full classification matrix and gate override logic.

### Pipeline Modes

| Mode | When | Lenses |
|------|------|--------|
| **FULL** | Large, high-risk, multi-module, security-touching, new public API | All 6 + AI failure + spec alignment |
| **STANDARD** | Medium features, bugfixes, moderate refactors | General + Code + Security + Completeness |
| **LIGHT** | Small/config/docs/test-only/deps | General + Code (quick pass) |
| **TARGETED** | Specific obvious concern | 2-3 relevant lenses only |

### Mandatory Gate Overrides

| Gate | Trigger | Activates |
|------|---------|-----------|
| Security | Touches auth/crypto/secrets | Security lens (FULL) |
| Architecture | New modules, cross-boundary | Architecture lens |
| API | Public interface changes | API lens |
| AI failure | Code appears generated | AI failure-mode scan |
| Spec deviation | PRD linked + unclear match | Spec alignment (Stage 6) |

State routing:
> **Pipeline: STANDARD** — 180 LOC feature, touches business logic and API.
> **Active lenses:** General, Code, Security, Completeness, API (gate: public interface change)

---

## Stage 3 — Multi-Lens Review

Run each activated lens. Each answers ONE primary question. See [references/PLANNER.md](references/PLANNER.md) for lens details.

| Lens | Primary question |
|------|-----------------|
| **General** | Does the PR do what it claims, and only what it claims? |
| **Code** | Is the implementation correct and reliable? |
| **Security** | Can this be exploited or does it leak data? |
| **Architecture** | Is this the right design at the right level? |
| **API & Contracts** | Will this break callers or violate contracts? |
| **Completeness** | Is this production-ready? |
| **AI Failure-Mode** | Patterns common in generated code? |

---

## Stage 4 — Classify Findings

**Every finding must survive verification.** For each finding:

1. Re-read the actual source file (not just diff)
2. Check 50+ lines of surrounding context
3. Trace callers/callees
4. Check project conventions (AGENTS.md, existing patterns)
5. Classify:

| Classification | Meaning | Report? | Blocks? |
|---------------|---------|---------|---------|
| **REAL** | Verified, concrete impact | Yes | If CRITICAL/HIGH |
| **DEFER** | Real but out of scope for this PR | Yes (info) | No |
| **FALSE_POSITIVE** | Explained by context | No | No |

For REAL findings: confidence (0.0–1.0), evidence (file:line), fix suggestion, challenge (how it could be wrong).

---

## Stage 5 — Consolidate & Rank

See [references/CONSOLIDATION.md](references/CONSOLIDATION.md) for deduplication rules and umbrella finding patterns.

### Severity

| Severity | Blocks approval? |
|----------|-----------------|
| **CRITICAL** | Yes — security vuln, data loss, crash |
| **HIGH** | Yes — bug under normal use |
| **MEDIUM** | No — edge case, tech debt |
| **LOW** | No — style, nitpick |

### Rules
- Same location from multiple lenses → keep highest severity, merge evidence
- Multiple findings sharing one root cause → umbrella finding
- Use [assets/templates/pr-review-report.template.md](assets/templates/pr-review-report.template.md) for report structure

---

## Stage 6 — Spec Alignment (if PRD/spec linked)

**Only runs when a PRD/spec is referenced or explicitly requested.** See [references/SPEC-ALIGNMENT.md](references/SPEC-ALIGNMENT.md) for the full protocol.

For each P0/P1 requirement in the spec:

| Requirement | Status | Evidence |
|------------|--------|----------|
| [from spec] | Implemented / Partial / Missing | `file:line` or "not found" |

Also check architectural invariants from AGENTS.md. Violations are CRITICAL findings.

> **Spec compliance: PARTIAL** — 8/10 P0 requirements implemented. 2 missing.

---

## Stage 7 — Verdict & Post

### Verdict

| Condition | Verdict |
|-----------|---------|
| Zero CRITICAL + zero HIGH | **APPROVE** |
| Zero blocking + some MEDIUM | **COMMENT** (approve with suggestions) |
| Any CRITICAL or HIGH unresolved | **REQUEST_CHANGES** |
| P0 spec requirements missing | **REQUEST_CHANGES** |

### GitHub Posting

**Checkpoint:** Always confirm before posting:
> "Ready to post this review to GitHub as REQUEST_CHANGES? (y/n)"

```bash
gh pr review $PR_ID --request-changes --body "$REVIEW_BODY"
```

Use [assets/templates/github-review-comment.template.md](assets/templates/github-review-comment.template.md) for posted review format.

---

## Error Handling

- If diff fetch fails: ask for PR URL or number, retry with corrected identifier
- If PR identifier is ambiguous: list matching PRs, ask user to pick one
- If GitHub auth is missing for posting: produce review body + exact `gh` command user can run manually
- If spec is referenced but not found: skip Stage 6, note "spec not located" in report
- If PR is very large (>1000 LOC): warn user, suggest splitting; review if they confirm
- If finding verification cannot access source file: lower confidence, note in caveat — do not fabricate evidence
- If lenses produce conflicting assessments: note both perspectives with evidence, let severity win

---

## Anti-patterns

- **Approving with unresolved CRITICAL/HIGH** — every blocking finding must be resolved
- **Reviewing only the diff** — always read AGENTS.md, full source files, module boundaries
- **Generic findings** — cite specific code, specific attack, specific impact
- **Fabricating evidence** — never invent line numbers or snippets
- **Style-heavy reviews** — correctness and security take precedence
- **Posting without confirmation** — always checkpoint before GitHub writes
- **Treating all PRs the same** — config changes don't need the same depth as security features
- **Symptoms instead of root causes** — report the root cause once, not 5 duplicates
- **Performative approval** — LGTM without structured findings is never acceptable

---

## Outputs

- Output: PR classification (type: feature/bugfix/refactor/config/docs/test/dependency/migration, scale: tiny/small/medium/large/very-large, risk: low/medium/high/critical, pipeline: FULL/STANDARD/LIGHT/TARGETED)
- Output: Context brief (repo kind, module map, architectural invariants from AGENTS.md)
- Output: Severity-ranked findings table with confidence scores (0.0–1.0) and file:line evidence
- Output: Spec compliance assessment (FULL/PARTIAL/MISSING with requirement count) — only if PRD linked
- Output: Verdict (APPROVE / REQUEST_CHANGES / COMMENT) with one-sentence rationale
- Output: GitHub review comment posted to PR (if user confirms posting)

Done when: Review includes an explicit verdict with evidence-backed rationale, and either posting is confirmed or review body is delivered to user.

---

## References (Progressive Disclosure)

Read each reference only when its stage activates — not upfront.

| Reference | When to read |
|-----------|-------------|
| [CONTEXT-DISCOVERY.md](references/CONTEXT-DISCOVERY.md) | Stage 1 — building the repo context brief |
| [PLANNER.md](references/PLANNER.md) | Stage 2 — classification matrix, pipeline mode, gate overrides |
| [CONSOLIDATION.md](references/CONSOLIDATION.md) | Stage 5 — deduplication, umbrella findings, severity normalization |
| [SPEC-ALIGNMENT.md](references/SPEC-ALIGNMENT.md) | Stage 6 — requirement traceability, invariant checking |
| [review-prompt.md](references/review-prompt.md) | Stage 3 — lens-specific review guidance |

## Templates & Scripts

| Asset | Purpose | Used in |
|-------|---------|---------|
| [assets/templates/pr-review-report.template.md](assets/templates/pr-review-report.template.md) | Full review report structure | Stage 5 |
| [assets/templates/github-review-comment.template.md](assets/templates/github-review-comment.template.md) | GitHub posting format | Stage 7 |
| [assets/templates/finding.schema.json](assets/templates/finding.schema.json) | Finding data schema | Stage 4/5 |
| [assets/templates/classification.schema.json](assets/templates/classification.schema.json) | Classification data schema | Stage 2 |
| [scripts/fetch_pr_context.sh](scripts/fetch_pr_context.sh) | PR metadata fetching | Stage 0 |
| [scripts/verify_findings.sh](scripts/verify_findings.sh) | Finding verification helpers | Stage 4 |
| [scripts/post_review.sh](scripts/post_review.sh) | GitHub review posting | Stage 7 |
