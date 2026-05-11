# Change Classification — lets-develop-feature

Decision logic for classifying changes and selecting the appropriate rigor level.

## Classification Dimensions

### Type

| Type | Signals | Default rigor |
|------|---------|---------------|
| **feature** | New capability, new files, new routes/endpoints | STANDARD+ |
| **bugfix** | Existing behavior wrong, regression fix | STANDARD |
| **refactor** | Same behavior, different structure | STANDARD |
| **performance** | Algorithmic change, caching, optimization | STANDARD |
| **migration** | Schema change, data transform | ELEVATED+ |
| **config** | Configuration, feature flags, env vars | MINIMAL |

### Scale

| Scale | LOC estimate | Files | Typical rigor |
|-------|-------------|-------|---------------|
| **trivial** | <20 | 1-2 | MINIMAL |
| **small** | 20-100 | 2-5 | STANDARD |
| **medium** | 100-500 | 5-10 | STANDARD or ELEVATED |
| **large** | >500 | >10 | ELEVATED or FULL |

### Risk Assessment

Scan for these signals in the task description AND target files:

| Signal | Risk | How to detect |
|--------|------|---------------|
| CRITICAL PATH markers | HIGH | `grep -rn "CRITICAL\|DO NOT MODIFY\|security review" <files>` |
| Security/auth code | HIGH | Files in `auth/`, `security/`, `crypto/`, `permission/` |
| Database migration | HIGH | `migrations/` directory, `ALTER TABLE`, `DROP` |
| Public API change | HIGH | Route definitions, OpenAPI, exported interfaces |
| External side effects | HIGH | HTTP calls to external services, queue publishing |
| Irreversible operations | CRITICAL | DELETE, DROP, data destruction |
| Shared interface (3+ importers) | MEDIUM | `grep -rn "from.*<module>.*import" .` |
| Cross-module change | MEDIUM | Changes span multiple top-level directories |
| New dependency | MEDIUM | New import not in lock file |
| Concurrency | MEDIUM | async/thread/lock/queue/pool patterns |
| Config-only | LOW | Only touches `.yaml`/`.toml`/`.json`/`.env` |
| Test-only | LOW | Only touches `tests/` or `test_*` files |
| Documentation-only | LOW | Only touches `.md`/`.rst` files |

### Complexity

| Level | Signals |
|-------|---------|
| **mechanical** | Pattern-following, copy-paste-adapt, no decisions needed |
| **moderate** | Standard feature work, some decisions, within one module |
| **complex** | New abstractions, cross-module coordination, multiple stakeholders |
| **gnarly** | Concurrency, state machines, performance-sensitive, unknown territory |

## Rigor Selection Matrix

```
IF risk == CRITICAL:
  rigor = FULL

ELIF risk == HIGH OR scale == large:
  rigor = ELEVATED (minimum)
  rigor = FULL if complexity >= complex

ELIF type == migration:
  rigor = ELEVATED

ELIF (type in [config] AND risk == LOW) OR scale == trivial:
  rigor = MINIMAL

ELIF risk == LOW AND scale == small AND complexity == mechanical:
  rigor = STANDARD (can skip design checkpoint)

ELSE:
  rigor = STANDARD
```

## Rigor Level Details

### MINIMAL
- Packet: one-liner (task + file + verification)
- Design checkpoint: skip
- Governance: proceed without asking
- Evidence: single verification run
- Traceability: not required

### STANDARD
- Packet: full work packages table
- Design checkpoint: implicit (decisions noted in packet)
- Governance: risk acknowledgment (medium asks, low proceeds)
- Evidence: per-package verification
- Traceability: not required (but recommended for medium risk)

### ELEVATED
- Packet: full with dependencies and scope boundary
- Design checkpoint: MANDATORY (architecture gate questions)
- Governance: explicit approval for high-risk items
- Evidence: per-package + final suite
- Traceability: required
- Stacked PRs: considered for >500 LOC

### FULL
- Packet: full with all sections populated
- Design checkpoint: MANDATORY + user approval
- Governance: explicit confirmation per critical-path file
- Evidence: per-package + final suite + lint + type check
- Traceability: required with design decisions and scope changes
- Stacked PRs: required for >500 LOC or >10 files

## Gate Overrides

These force rigor escalation regardless of scale:

| Gate | Trigger | Forces |
|------|---------|--------|
| **Security gate** | Touches auth, crypto, or secrets handling | ELEVATED minimum |
| **Architecture gate** | New abstraction, boundary change, layer violation | Design checkpoint |
| **Migration gate** | Schema change, data transform, irreversible op | ELEVATED minimum |
| **API gate** | Public interface change, breaking change | Design checkpoint |
| **Dependency gate** | New external dependency | Security review in packet |

## Output

State classification clearly:

```
Classification: feature / medium / medium-risk / STANDARD
Signals: cross-module change (src/api/ + src/models/), shared interface (models.User imported by 5 modules)
Rigor: STANDARD with design checkpoint (architecture gate: cross-module)
```
