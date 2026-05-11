# Report — lets-assess-ai-readiness

## Report Structure

### Intake Card (Phase 1 — always shown first)

```
## Repo Profile

| Field | Value |
|-------|-------|
| Repo | {name} |
| Ecosystem | {language} / {package_manager} |
| Shape | {monorepo|service|library|tool} |
| Build surface | {Makefile|package.json|pyproject.toml|...} |
| CI | {system} ({present|absent}) |
| Context artifacts | {list or "none"} |
```

### Summary Card (Phase 4 — primary output)

```
## AI Readiness Report — {repo_name}

**Overall: {level} ({label})** → next: {next_level} ({next_label})

| Pillar | Level | Score | Status |
|--------|-------|-------|--------|
| Feedback Velocity | L{n} | {score}/{max} | {bar} |
| Error Signal Clarity | L{n} | {score}/{max} | {bar} |
| Determinism | L{n} | {score}/{max} | {bar} |
| Change Safety | L{n} | {score}/{max} | {bar} |
| Context Discoverability | L{n} | {score}/{max} | {bar} |
| Pattern Consistency | L{n} | {score}/{max} | {bar} |
| Recovery Cost | L{n} | {score}/{max} | {bar} |
| Environment Independence | L{n} | {score}/{max} | {bar} |
```

### Blockers to Next Level (most important section)

```
## Blockers to {next_level} ({next_label})

| # | Check | Pillar | Evidence | Fix |
|---|-------|--------|----------|-----|
| 1 | {check_id} | {pillar} | {what was observed} | {concrete remediation} |
| 2 | ... | ... | ... | ... |

**Cheapest path to {next_level}:** Fix checks 1-3 above (estimated effort: {hours}h).
```

This section is the primary decision tool. Present blockers sorted by:
1. Required gates first (these literally block level achievement)
2. Then by weight (highest-impact fixes first)
3. Then by estimated effort (cheapest first for equal weight)

### Advisory Notes (non-gating, evidence-based)

```
## Advisory

These findings are based on heuristic analysis and do NOT gate your maturity level.
They represent improvement opportunities.

| Signal | Pillar | Confidence | Observation | Suggestion |
|--------|--------|:---:|-------------|------------|
| {id} | {pillar} | {0.X} | {what was observed} | {improvement} |
```

Rules for advisory notes:
- Must cite specific file path or observed behavior
- Must include confidence score
- Must clearly state this is non-gating
- Should be limited to 5-7 most impactful observations

### Detailed Findings (appendix, only if requested)

```
## Detailed Findings

### {Pillar Name}

| Check | Status | Min Level | Required | Evidence | Remediation |
|-------|--------|-----------|----------|----------|-------------|
| {id} | PASS/FAIL/UNKNOWN | L{n} | yes/no | {evidence} | {fix} |
```

---

## Level Derivation Logic

Present the derivation explicitly:

```
## Level Derivation

- Context level: L{n} (based on verified packs: {list})
- Agent levels by pillar:
  - Feedback Velocity: L{n}
  - Error Signal Clarity: L{n}
  - ...
- Agent level (min of pillar levels): L{n}
- Overall level: min(context L{n}, agent L{n}) = L{n}
- Limiting factor: {pillar or context}
```

---

## Output Formats

### Default: Markdown (human-readable)

Show the Summary Card + Blockers + Advisory. Detailed findings available on request.

### Structured: JSON (for tooling/dashboards)

```json
{
  "schema_version": "ai-readiness.v1",
  "generated_at": "ISO-8601",
  "repo": {"name": "", "root": "", "ecosystem": "", "shape": ""},
  "overall": {
    "level": "L2",
    "label": "Documented",
    "next_level": "L3",
    "score": 62,
    "max_score": 100,
    "limiting_factor": "feedback_velocity"
  },
  "pillars": {
    "feedback_velocity": {"level": "L2", "score": 9, "max_score": 15},
    ...
  },
  "blockers": [
    {"check_id": "...", "pillar": "...", "evidence": "...", "remediation": "..."}
  ],
  "advisory": [
    {"signal": "...", "pillar": "...", "confidence": 0.7, "observation": "...", "suggestion": "..."}
  ],
  "findings": [...]
}
```

---

## Comparison Mode (multi-repo)

When assessing multiple repos, present a comparison table:

```
## Portfolio Readiness

| Repo | Overall | Feedback | Errors | Determinism | Safety | Context | Patterns | Recovery | Env |
|------|---------|----------|--------|-------------|--------|---------|----------|----------|-----|
| repo-a | L3 | L4 | L3 | L3 | L3 | L3 | L3 | L2 | L3 |
| repo-b | L1 | L2 | L1 | L2 | L1 | L1 | L2 | L1 | L2 |
```

Highlight the limiting pillar for each repo.
