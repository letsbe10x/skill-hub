# Spec Alignment Review — lets-review-pr

How to verify implementation against a linked PRD or spec.

## When to Run

Spec alignment is triggered when:
- PR body contains a PRD reference (patterns: `prd-NNN`, `PRD-NNN`, `PRD NNN`, `spec:`, `implements #NNN`)
- User explicitly requests spec alignment review
- PR title mentions "implement" + a feature name that matches a known spec

## Locating the Spec

```bash
# Search common spec locations
find . -path "*/prds/*" -o -path "*/features/*" -o -path "*/specs/*" -o -path "*/ground-truth/*" | sort

# Try to match the referenced ID
find . -name "*${SPEC_ID}*" -type f

# Check for linked issues
gh pr view $PR_ID --json body | grep -oE "(prd|PRD|spec)[- ]?[0-9]+"
```

If spec cannot be located:
- Note "Spec referenced but not found at expected locations"
- Skip spec alignment
- Proceed with normal code review

## Spec Extraction

From the located spec file, extract:

### Requirements by Priority

| Priority | Definition |
|----------|-----------|
| **P0** | Must-have for this milestone; blocking if missing |
| **P1** | Should-have; important but can be follow-up |
| **P2** | Nice-to-have; acceptable to defer |

For each requirement, record:
- ID (if numbered in spec)
- Description
- Acceptance criteria (if specified)
- Priority

### Contracts

If the spec defines:
- API interfaces (endpoints, methods, parameters, responses)
- Data schemas (fields, types, constraints)
- Error contracts (error codes, messages, behavior)
- Integration protocols (message formats, sequencing)

### Non-Functional Requirements

- Performance constraints (latency, throughput)
- Security requirements (auth model, data classification)
- Observability requirements (metrics, logging, tracing)
- Rollback/migration requirements

## Alignment Analysis

### Requirement Coverage

For each P0/P1 requirement:

| Requirement | Status | Evidence | Notes |
|------------|--------|----------|-------|
| [Req description] | Implemented / Partial / Missing / Deviated | `file:line` or "not found" | [explanation if partial/deviated] |

**Status definitions:**
- **Implemented** — code fulfills the requirement with evidence at specific file:line
- **Partial** — some aspects implemented, others missing (list what's missing)
- **Missing** — no implementation found for this requirement
- **Deviated** — implementation differs from spec (explain the deviation)

### Contract Compliance

For each specified contract:

```markdown
### Contract: [name]

| Element | Spec says | Implementation does | Match? |
|---------|-----------|--------------------| -------|
| [method/field/endpoint] | [spec definition] | [actual implementation] | Yes/No/Partial |
```

### Architectural Invariant Check

Cross-reference with AGENTS.md invariants:

| Invariant | Spec requirement | Implementation | Compliant? |
|-----------|-----------------|----------------|-----------|
| [invariant] | [how spec expects it honored] | [what code actually does] | Yes/No |

Common invariants to check:
- Engine isolation (no outward deps from core engine)
- Principal separation (credentials injected, not env-read)
- Subprocess safety (list args, never shell strings)
- Fail-closed security
- Tightening-only policy hierarchy
- Layer discipline (each layer has clear role)

### Security Posture

If the spec mentions security:
- Input validation present for all specified entry points?
- Auth model matches spec?
- Data classification respected? (PII handling, encryption)
- Credential handling matches specified approach?

## Spec Verdict

```markdown
## Spec Alignment Verdict

**Spec:** [spec ID / title]
**P0 coverage:** X/Y implemented (Z%)
**P1 coverage:** X/Y implemented (Z%)
**Contract compliance:** [FULL / PARTIAL / INCOMPLETE]
**Invariant compliance:** [PASS / VIOLATIONS FOUND]

### Missing P0 Requirements
- [Req]: [what's missing]

### Deviations (deliberate or accidental)
- [Req]: spec says [X], implementation does [Y]

### Verdict: [COMPLIANT / PARTIALLY_COMPLIANT / NON_COMPLIANT]
[One-sentence rationale]
```

## Impact on PR Verdict

| Spec status | Effect on PR verdict |
|-------------|---------------------|
| Missing P0 requirement | REQUEST_CHANGES (unless user confirms it's intentional) |
| Deviation from spec on P0 | REQUEST_CHANGES (unless documented as deliberate) |
| Missing P1 requirement | COMMENT (note for follow-up) |
| Contract non-compliance | REQUEST_CHANGES |
| Invariant violation | REQUEST_CHANGES (CRITICAL severity) |
| All P0/P1 covered, contracts match | No negative impact |

## Anti-patterns

- **Claiming compliance without evidence** — every "Implemented" status must cite file:line
- **Ignoring deviations** — a deviation isn't automatically wrong, but it must be flagged
- **Spec as oracle** — specs can be wrong or outdated; flag clear impossibilities
- **Missing = blocking** — not all missing requirements are the PR's fault; check if they're planned for a different PR
