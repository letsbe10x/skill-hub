# Finding Consolidation — lets-review-pr

How to merge findings from multiple lenses into a single, deduplicated, severity-ranked report.

## Consolidation Principles

1. **Deduplicate, don't double-count** — same issue flagged by two lenses = one finding, not two
2. **Preserve the umbrella** — when local issues share a root cause, report the root cause
3. **Rank by impact** — CRITICAL > HIGH > MEDIUM > LOW; within severity, by confidence
4. **Credit sources** — note which lens(es) identified each finding
5. **Resolve conflicts** — when lenses disagree on severity, present both perspectives with evidence
6. **No new findings** — consolidation is editorial, not investigative

## Deduplication Rules

### Same Location, Same Issue
Two findings that cite the same file:line and describe the same defect:
- Keep the higher severity assessment
- Merge evidence from both lenses
- Use the more specific description
- Credit both lenses

### Same Location, Different Issues
Two findings that cite the same file:line but describe different concerns (e.g., correctness lens says "logic error," security lens says "injection risk"):
- Keep both as separate findings
- Note they are co-located (may share a fix)

### Same Root Cause, Multiple Locations
Multiple findings across different file:line locations that all stem from one missing pattern or design gap:
- Create an **umbrella finding** for the root cause
- List the individual locations as evidence
- Severity = highest among the constituent findings
- Confidence = weighted average of constituents

## Severity Normalization

All lenses use the same severity scale:

| Severity | Definition | Blocks approval? |
|----------|-----------|-----------------|
| **CRITICAL** | Exploitable security vuln, data loss in production path, crash under normal use | Yes — must fix |
| **HIGH** | Bug causing incorrect behavior that users will encounter | Yes — must fix |
| **MEDIUM** | Edge case bug, missing validation, significant tech debt, partial feature | No — flag for follow-up |
| **LOW** | Style, optimization opportunity, minor improvement | No — optional |

### Cross-Lens Severity Mapping

| Lens | CRITICAL | HIGH | MEDIUM | LOW |
|------|----------|------|--------|-----|
| Correctness | Crash in production path | Wrong results under normal use | Edge case wrong results | Cosmetic logic |
| Security | Exploitable vulnerability | Missing auth, secrets exposure | Weak validation, dependency risk | Hardening suggestion |
| Architecture | Architectural violation causing data integrity risk | Boundary violation with blast radius | Coupling concern, abstraction misfit | Style preference |
| API | Breaking change deployed without migration | Breaking change without version bump | Non-breaking but inconsistent | Naming suggestion |
| Completeness | No tests for security-critical code | No tests for core feature | Missing edge case tests | Missing optional tests |
| Complexity | Complexity causing correctness risk | Over-engineering with maintenance burden | Unnecessary indirection | Minor verbosity |

## Conflict Resolution

When lenses disagree:

### Severity Disagreement
- Present both assessments: "Correctness lens: HIGH (logic error). Architecture lens: MEDIUM (established pattern)."
- Include evidence for each position
- Final severity = higher of the two, unless the lower-severity assessment has stronger evidence

### Finding vs. False Positive
- If one lens flags an issue and another lens's context explains it:
  - Note both perspectives
  - If the explanation is convincing (cites framework guarantees, AGENTS.md convention), classify as FALSE_POSITIVE
  - If the explanation is speculative, keep as finding with caveat

## Report Structure

### Header
- PR identification
- Classification summary
- Pipeline mode and lenses run

### Findings Table
- Sorted: CRITICAL first, then HIGH, MEDIUM, LOW
- Within severity: sorted by confidence (highest first)
- Each row: index, severity, lens, location, title, confidence

### Finding Details
- One section per finding with full evidence
- Umbrella findings clearly marked with constituent locations

### Deferred Items
- Findings classified as DEFER (real but out of scope)
- Listed as informational only

### Strengths
- 2-3 specific positive observations (not filler)
- Must cite specific code/patterns that demonstrate quality

### Verdict
- Clear APPROVE / REQUEST_CHANGES / COMMENT
- One-sentence rationale citing the decisive factor

## Quality Checks

Before finalizing the consolidated report:

1. **No duplicate file:line** — same location should not appear in two findings
2. **No orphan severity** — every CRITICAL/HIGH finding has evidence + confidence ≥0.70
3. **No empty sections** — if no findings at a severity, omit that severity section
4. **No filler strengths** — if nothing genuinely good, say "No standout strengths noted"
5. **Verdict matches findings** — APPROVE requires zero CRITICAL/HIGH; REQUEST_CHANGES requires at least one
6. **Evidence traced** — every finding cites actual code, not hypothetical scenarios
