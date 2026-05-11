# Review Planner — lets-review-pr

Decision logic for classifying PRs and routing to appropriate review lenses.

## PR Classification

### Dimension 1: Type

Infer from PR title, body, labels, and file patterns:

| Type | Signals |
|------|---------|
| **feature** | New files, new exports, PR title starts with "feat:" or "add" |
| **bugfix** | PR title starts with "fix:", "hotfix:", references issue |
| **refactor** | PR title starts with "refactor:", same test count, structure changes |
| **performance** | "perf:", benchmarks added, algorithmic changes |
| **config** | Only .toml/.yaml/.json/.env files changed |
| **dependency** | Lock files, go.sum, package.json (deps section only) |
| **migration** | Schema files, alembic/, flyway/, migration scripts |
| **api-change** | OpenAPI spec, route definitions, public interface changes |
| **docs** | Only .md/.rst/.txt files changed |
| **test** | Only test files changed, no production code |
| **security** | Auth/crypto/secrets files, security labels |

### Dimension 2: Scale

| Scale | LOC (additions + deletions) | Files |
|-------|---------------------------|-------|
| tiny | <20 | 1-2 |
| small | 20-100 | 1-5 |
| medium | 100-300 | 3-10 |
| large | 300-1000 | 10-30 |
| very-large | >1000 | >30 |

### Dimension 3: Risk

| Risk | Trigger |
|------|---------|
| **critical** | Touches auth + data layer, or touches crypto, or migration with no rollback |
| **high** | Auth OR payment OR shared utilities with many consumers |
| **medium** | Business logic, API contracts, new dependencies |
| **low** | Config, docs, tests, style-only changes |

### Dimension 4: Complexity

| Complexity | Signal |
|-----------|--------|
| **gnarly** | New concurrency, new state machines, cross-module data flow |
| **complex** | New abstractions, multi-module changes, significant error handling |
| **moderate** | Standard feature work within one module |
| **straightforward** | Mechanical changes, pattern following |

## Pipeline Mode Selection

```
IF risk == critical OR scale == very-large OR type == migration:
  mode = FULL

ELIF risk == high OR scale == large OR complexity in [gnarly, complex]:
  mode = FULL

ELIF type in [docs, test, config] AND risk == low:
  mode = LIGHT

ELIF scale == tiny AND risk == low AND complexity == straightforward:
  mode = LIGHT

ELIF specific_concern_obvious:
  mode = TARGETED (only relevant 2-3 lenses)

ELSE:
  mode = STANDARD
```

## Lens Activation Table

| Lens | FULL | STANDARD | LIGHT | TARGETED |
|------|------|----------|-------|----------|
| General (intent/scope) | Yes | Yes | Yes | If scope concern |
| Code (correctness) | Yes | Yes | Quick | If logic concern |
| Security | Yes | Yes | Quick scan | If security concern |
| Architecture | Yes | No | No | If design concern |
| API & Contracts | Yes | No | No | If interface concern |
| Completeness | Yes | Yes | No | If coverage concern |
| AI Failure Mode | Yes | Yes | No | If code looks generated |

## Mandatory Gate Triggers

These force activation of specific lenses regardless of pipeline mode:

### Gate 1: Security
**Trigger:** Changed files contain auth, crypto, secrets handling, input validation, deserialization, or delivery surface (Dockerfile, CI config, deploy scripts)
**Activates:** Security lens at FULL depth
**Rationale:** Security issues are binary — either secure or not. No LIGHT mode for security-touching code.

### Gate 2: Architecture
**Trigger:** New module introduced, cross-boundary import added, new abstraction layer, layer violation detected
**Activates:** Architecture lens
**Rationale:** Structural decisions compound — catching them early is exponentially cheaper.

### Gate 3: API & Contracts
**Trigger:** Public interface method added/removed/changed, schema file modified, breaking change signal, error type/code changed
**Activates:** API lens
**Rationale:** Breaking changes affect downstream consumers who aren't in this PR.

### Gate 4: Complexity
**Trigger:** New abstraction with unclear motivation, nesting depth >3 introduced, cyclomatic complexity visibly high
**Activates:** Complexity lens
**Rationale:** Over-engineering is subtle and compounds into maintenance burden.

### Gate 5: AI Failure Mode
**Trigger:** Code exhibits AI generation patterns (polish without tests, broad catches with no evidence, unused helpers, import bloat)
**Activates:** AI failure-mode scan
**Rationale:** AI-generated code optimizes for looking correct rather than being correct.

### Gate 6: Spec Deviation
**Trigger:** PR body references a spec/PRD AND implementation doesn't obviously match stated requirements
**Activates:** Spec alignment (Stage 6)
**Rationale:** Specs are contracts; deviations must be deliberate and documented.

## Planner Output Format

```json
{
  "pr_number": 1234,
  "classification": {
    "type": "feature",
    "scale": "medium",
    "risk": "medium",
    "complexity": "moderate"
  },
  "pipeline_mode": "STANDARD",
  "active_lenses": ["general", "code", "security", "completeness"],
  "gate_overrides": [
    {"gate": "security", "reason": "touches auth middleware", "lens_added": "security_full"}
  ],
  "ai_failure_scan": false,
  "spec_alignment": false,
  "spec_ref": null,
  "rationale": "Medium feature PR touching business logic. Security gate triggered by auth file change.",
  "focus_areas": ["auth flow correctness", "error handling in new endpoint"],
  "context_needed": ["read auth middleware contract", "check existing error patterns"]
}
```

## Special Cases

### Very Large PRs (>1000 LOC)
- Warn the user that thorough review of very large PRs is unreliable
- Suggest splitting if possible
- If user confirms, run FULL mode but note reduced confidence in findings
- Focus on: architectural coherence, security, breaking changes

### Single-file Hotfix
- Even if tiny, check: was this the right fix? Does it have a regression test?
- LIGHT mode but with targeted correctness check

### Dependency-only Updates
- Check for known CVEs in new versions
- Check for breaking API changes in major version bumps
- Check lock file consistency
- LIGHT mode unless major version bump

### Revert PRs
- Verify the revert is clean (no partial reverts)
- Check that the revert doesn't break other changes that depended on the reverted commit
- LIGHT mode
