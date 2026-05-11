# Review Planner — lets-review-code

Decision logic for classifying changes and selecting review depth + active lenses.

## Classification Dimensions

### 1. Change Type

| Type | Signals | Default depth |
|------|---------|---------------|
| **feature** | New files, new exports, new routes/endpoints | STANDARD+ |
| **bugfix** | Fixes in existing logic, regression tests added | STANDARD |
| **refactor** | Same behavior, different structure, tests unchanged | STANDARD |
| **performance** | Algorithmic changes, caching, query optimization | STANDARD |
| **config** | Config files, env vars, feature flags | LIGHT |
| **dependency** | Lock files, version bumps, new imports | LIGHT (unless new dep) |
| **migration** | Schema changes, data transforms | FULL |
| **api-change** | Public interface modifications | FULL |
| **docs** | README, comments, docstrings only | LIGHT |
| **test** | Test files only, no production code | LIGHT |

### 2. Scale

| Scale | LOC changed | Files changed |
|-------|-------------|---------------|
| tiny | <20 | 1-2 |
| small | 20-100 | 1-5 |
| medium | 100-300 | 3-10 |
| large | 300-1000 | 10-30 |
| massive | >1000 | >30 |

### 3. Risk Profile

Scan changed files for risk markers:

| Risk area | File patterns / keywords | Weight |
|-----------|------------------------|--------|
| Auth/security | `auth`, `token`, `session`, `permission`, `crypto`, `secret` | HIGH |
| Payment/billing | `payment`, `billing`, `charge`, `subscription`, `invoice` | HIGH |
| Data pipeline | `migration`, `schema`, `etl`, `transform`, `pipeline` | HIGH |
| Shared utilities | `utils/`, `common/`, `shared/`, `lib/` | MEDIUM |
| API contracts | `api/`, `routes/`, `schema`, `openapi`, `graphql` | MEDIUM |
| New dependencies | New entries in lock files, new imports from unknown packages | MEDIUM |
| Error handling | `except`, `catch`, `error`, `retry`, `fallback` | LOW |
| Concurrency | `async`, `thread`, `lock`, `mutex`, `queue`, `pool` | MEDIUM |
| PII/sensitive | `email`, `password`, `ssn`, `address`, `phone` | HIGH |

### 4. Cognitive Complexity Signals

| Signal | Indicates | Effect |
|--------|-----------|--------|
| New abstractions introduced | Design decisions need architecture review | +Architecture lens |
| Concurrency patterns | Race conditions possible | +Correctness depth |
| State management changes | Invariant violations possible | +Correctness depth |
| Cross-module changes | Coupling/boundary violations possible | +Architecture lens |
| Performance-critical paths | Correctness under load matters | +Completeness depth |
| Security operations | Must be correct first time | +Security lens (FULL) |

## Depth Decision Matrix

```
IF risk == HIGH for any area:
  depth = FULL (override scale)

ELIF type in [migration, api-change]:
  depth = FULL

ELIF scale in [large, massive]:
  depth = FULL

ELIF type in [config, docs, test, dependency] AND no risk markers:
  depth = LIGHT

ELIF scale == tiny AND no risk markers:
  depth = LIGHT

ELSE:
  depth = STANDARD
```

## Lens Activation

| Lens | FULL | STANDARD | LIGHT | Gate override |
|------|------|----------|-------|---------------|
| Correctness | Yes | Yes | Yes | Always on |
| Security | Yes | Yes | Quick scan | HIGH risk in auth/crypto/input |
| Architecture | Yes | No | No | New abstractions, cross-module |
| API & Contracts | Yes | No | No | Public interface changes |
| Completeness | Yes | Yes | No | Feature or bugfix type |
| Complexity | Yes | No | No | New abstractions, deep nesting |
| AI Failure Mode | Yes | Yes | No | Code appears generated |

## Gate Overrides

Gates activate lenses regardless of depth:

1. **Security gate**: Any file touching auth, crypto, secrets, input validation → Security (FULL depth)
2. **Architecture gate**: New module, new abstraction, cross-boundary change → Architecture lens
3. **API gate**: Public interface change, schema change, breaking change → API lens
4. **Complexity gate**: Deep nesting (>3 levels), new abstraction with unclear motivation → Complexity lens
5. **AI failure gate**: Polish without tests, broad catches, unused helpers, import bloat → AI failure scan

## Output

The planner produces:

```json
{
  "classification": {
    "type": "feature",
    "scale": "medium",
    "risk": "medium",
    "complexity_signals": ["new_abstractions", "cross_module"]
  },
  "depth": "FULL",
  "active_lenses": ["correctness", "security", "architecture", "api", "completeness", "complexity"],
  "gate_overrides": ["architecture_gate: new abstraction in shared module"],
  "ai_failure_scan": true,
  "rationale": "Medium feature with new abstractions crossing module boundaries — requires full depth"
}
```
