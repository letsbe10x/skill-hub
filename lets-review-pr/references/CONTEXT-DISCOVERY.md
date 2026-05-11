# Repo Context Discovery — lets-review-pr

How to build a context brief that prevents false positives and ensures architectural awareness before reviewing.

## Why Context Matters

Reviewing a PR without understanding the repo produces:
- False positives from unfamiliar conventions
- Missed issues from not understanding critical paths
- Wrong severity from not knowing what's production-facing
- Architectural complaints about established patterns

## Context Discovery Steps

### Step 1: Read Repo Identity

```bash
# Priority order — stop at first available
cat AGENTS.md 2>/dev/null          # Best: explicit agent guidance
cat CLAUDE.md 2>/dev/null          # Good: AI-specific instructions
cat CONTRIBUTING.md 2>/dev/null    # Good: contribution standards
cat README.md 2>/dev/null | head -100  # Fallback: general overview
```

Extract:
- Repo kind (service / library / CLI / SDK / monorepo)
- Primary language and framework
- Architecture decisions and constraints
- Security invariants
- Testing philosophy

### Step 2: Infer Module Map

```bash
# Top-level structure
ls -la
find . -maxdepth 2 -type d | grep -v node_modules | grep -v .git | grep -v __pycache__

# For Python
find . -maxdepth 2 -name "__init__.py" | sort

# For TypeScript/JS
find . -maxdepth 2 -name "index.ts" -o -name "index.js" | sort

# For Go
find . -maxdepth 2 -name "main.go" | sort
```

Build a mental map:
- Which modules exist?
- What does each own?
- Which are touched by this PR?
- What are the boundaries between them?

### Step 3: Identify Critical Paths

Assess which of the changed files are in critical paths:

| Path type | How to identify | Review implication |
|-----------|----------------|-------------------|
| Auth/security | `auth/`, `security/`, `middleware/auth` | Any bug = vulnerability |
| Data layer | `models/`, `schema/`, `migrations/`, `db/` | Any bug = data corruption |
| Payment | `billing/`, `payment/`, `subscription/` | Any bug = financial loss |
| Public API | `api/`, `routes/`, `handlers/`, `controllers/` | Any bug = consumer-facing |
| Shared utilities | `utils/`, `common/`, `shared/`, `lib/` | Blast radius is wide |
| Infrastructure | `deploy/`, `infra/`, `ci/`, `Dockerfile` | Any bug = outage risk |

### Step 4: Understand Conventions

```bash
# Recent commits for style
git log --oneline -15

# Test patterns
find . -path "*/test*" -name "*.py" | head -5 | xargs head -30 2>/dev/null
find . -path "*/test*" -name "*.ts" | head -5 | xargs head -30 2>/dev/null

# Error handling patterns
grep -rn "class.*Error\|class.*Exception" --include="*.py" . | head -10
grep -rn "throw new\|raise " --include="*.py" --include="*.ts" . | head -10
```

Understand:
- How does this repo handle errors? (custom types? status codes? result types?)
- How does it test? (unit? integration? e2e? mocks? fixtures?)
- What's the naming convention? (snake_case? camelCase? module prefixes?)
- What's the commit style? (conventional commits? free-form?)

### Step 5: Check for Review Obligations

Does AGENTS.md specify:
- Areas that require specific review focus?
- Security invariants that must never be violated?
- Boundary rules (what can import what)?
- Performance budgets?
- Testing requirements for certain paths?

## Context Brief Format

Produce a brief covering:

```markdown
## Context Brief

**Repo:** [name] ([kind])
**Language:** [primary lang] + [framework]
**Architecture:** [brief description of structure]

### Modules Touched
- [module]: [responsibility] — [risk level for this PR]

### Invariants to Verify
- [invariant from AGENTS.md or conventions]

### Critical Paths Affected
- [path]: [why it's critical]

### Conventions to Respect
- Error handling: [pattern]
- Testing: [pattern]
- Naming: [convention]

### Review Focus
- [specific area requiring attention based on context]
```

## Common Repo Kinds

| Kind | Review emphasis |
|------|----------------|
| **Service** | Runtime correctness, resource lifecycle, error handling, observability |
| **Library** | API design, backward compatibility, documentation, edge cases |
| **CLI** | User input validation, error messages, exit codes |
| **SDK** | Consistency across operations, error mapping, retry semantics |
| **Monorepo** | Cross-module impact, shared dependency changes, boundary respect |

## Anti-patterns

- **Skipping context** — reviewing without reading AGENTS.md produces false positives
- **Assuming conventions** — different repos handle errors, testing, and boundaries differently
- **Ignoring module boundaries** — what looks like duplication might be intentional isolation
- **Applying wrong mental model** — a library PR needs different review than a service PR
