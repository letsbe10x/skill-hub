# Finding Verification Protocol — lets-review-code

Every finding must survive verification before reaching the final report. This document defines the verification process.

## The Problem

Code review generates hypotheses. Many initial observations turn out to be false positives when full context is examined. Posting unverified findings wastes author time and erodes trust in the review process.

## Verification Steps

For each potential finding from lens analysis:

### Step 1: Re-read Full Context

```bash
# Read the full file at the finding location (not just the diff hunk)
cat <file> | head -n <line+50> | tail -n 100
```

- Read 50+ lines above and below the flagged location
- Look for: error handling elsewhere, pattern established earlier in file, framework guarantees

### Step 2: Trace Callers and Callees

```bash
# Find all callers of the function/method
grep -rn "<function_name>" --include="*.py" .
grep -rn "<function_name>" --include="*.ts" .
```

- Does a caller already handle the case you're flagging?
- Does a callee guarantee the precondition you think is missing?
- Is there middleware/framework that handles this concern?

### Step 3: Check Project Conventions

- Read AGENTS.md — are there explicit rules about this pattern?
- Check existing code — is this an established convention in the project?
- Review test patterns — does the test suite treat this as expected behavior?

### Step 4: Classify

| Classification | Criteria | Include in report? |
|---------------|----------|-------------------|
| **REAL** | Issue verified with concrete evidence; no contextual explanation found | Yes — affects verdict |
| **DEFER** | Real concern but out of scope for this change (pre-existing, different module) | Yes — informational only |
| **FALSE_POSITIVE** | Initial concern explained by context, conventions, or framework guarantees | No |

## Evidence Requirements

Every REAL finding must include:

| Field | Required | Description |
|-------|----------|-------------|
| **file:line** | Yes | Exact location verified against actual file content |
| **code snippet** | Yes | The actual code (not fabricated) showing the issue |
| **impact** | Yes | Concrete consequence for THIS system (not generic) |
| **confidence** | Yes | 0.0–1.0 certainty |
| **caveat** | Yes | What couldn't be fully verified |
| **challenge** | Yes | How this finding could be wrong |

### Confidence Calibration

| Confidence | Meaning | When to use |
|-----------|---------|-------------|
| 0.95–1.0 | Certain — verified in code, impact is clear | Bug with test showing failure |
| 0.80–0.94 | High — strong evidence, minor uncertainty | Logic issue, couldn't trace all callers |
| 0.60–0.79 | Medium — likely issue, context may explain | Pattern smells wrong but could be intentional |
| 0.40–0.59 | Low — possible issue, significant uncertainty | Suspicion without strong code evidence |
| <0.40 | Speculative | Do NOT include as finding — mention as question at most |

**Rule: Findings with confidence <0.60 should not be severity CRITICAL or HIGH.**

## Deduplication

When multiple lenses flag the same location:
1. Keep the highest-severity assessment
2. Merge evidence from both lenses
3. Credit both lenses in the finding
4. Do not list as two separate findings

## Umbrella Findings

When multiple local findings share one root cause:
1. Identify the shared design gap (e.g., "no error handling contract")
2. Report the umbrella finding once at the appropriate severity
3. List local manifestations as evidence items
4. Do NOT list 5 separate findings for the same gap

## Anti-patterns in Verification

- **Lazy verification** — reading only the flagged line, not surrounding context
- **Confirmation bias** — looking for evidence that confirms the finding, not evidence that disproves it
- **Confidence inflation** — marking uncertain findings as high-confidence to make them seem important
- **Scope creep** — flagging pre-existing issues that aren't related to this change
- **Framework ignorance** — flagging patterns that the framework handles (e.g., null safety in Kotlin, ownership in Rust)
