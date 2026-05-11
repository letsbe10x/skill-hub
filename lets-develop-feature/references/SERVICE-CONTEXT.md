# Service Context — lets-develop-feature

How to read, bind, and verify service context throughout a development run.

## What is Service Context?

Service context is the set of maintainer-confirmed constraints that BIND an implementation run. It represents operational expectations that cannot be violated regardless of what the task description says.

## Sources

| Source | Priority | Contains |
|--------|----------|----------|
| **AGENTS.md** (Security Invariants section) | Highest | Hard constraints: boundary rules, credential handling, subprocess safety |
| **AGENTS.md** (Architecture section) | High | Module boundaries, dependency direction, layer discipline |
| **AGENTS.md** (Testing section) | Medium | What must be tested, test patterns expected |
| **README.md** (Operations section) | Medium | Deployment model, rollout constraints |
| **Existing code patterns** | Lower | Established conventions (error handling, logging, naming) |

## Non-Negotiables

Non-negotiables are constraints that **cannot be violated under any circumstance**. Violating one = run is BLOCKED.

### Common Non-Negotiables

| Category | Examples |
|----------|---------|
| **Security** | "Credentials injected at start, never env-read at point of use" |
| **Isolation** | "Engine has no outward deps on sdlc/platform/external" |
| **Safety** | "Subprocess args as list, never shell strings" |
| **Policy** | "Security evaluation is fail-closed" |
| **Hierarchy** | "Overlays can only restrict (tighten), never loosen" |

### How to Detect Non-Negotiables

```bash
# Look for explicit markers in AGENTS.md
grep -iE "must never|cannot|invariant|non-negotiable|forbidden|always must" AGENTS.md

# Look for security sections
grep -A 20 "Security Invariants" AGENTS.md

# Look for boundary rules
grep -A 10 "Boundaries\|Ownership\|Isolation" AGENTS.md
```

## Critical Paths

Critical paths are code paths where bugs have outsized impact. Extra verification is required when touching them.

### Identifying Critical Paths

| Signal | How to detect |
|--------|---------------|
| CRITICAL marker in code | `grep -rn "CRITICAL\|DO NOT MODIFY" <files>` |
| Auth/security flow | Files in `auth/`, `security/`, `permission/` directories |
| Payment/billing flow | Files in `payment/`, `billing/`, `checkout/` |
| Data integrity | Migration files, schema changes, data transforms |
| Public API surface | Route handlers, endpoint definitions |
| Shared utilities with 5+ importers | `grep -rl "import <module>" . | wc -l` |

### Critical Path Obligations

When your change touches a critical path:

1. **Explicit acknowledgment** in execution packet: "Touches critical path: [path]. Mitigation: [plan]"
2. **Extra verification**: specific tests covering the critical path
3. **Preservation proof** in verification: "Critical path [X] still works — evidence: [test output]"

## Binding Protocol

### At Run Start (Stage 1)

1. Read AGENTS.md fully
2. Extract non-negotiables → write into service context summary
3. Extract critical paths → note which are touched by this change
4. Extract architecture boundaries → note which constrain this change
5. Extract testing expectations → feed into methodology selection

### During Implementation (Stage 6)

Before each edit, check:
- "Does this edit violate any non-negotiable?" → If yes, STOP. Find alternative.
- "Does this edit touch a critical path?" → If yes, ensure extra verification.
- "Does this edit cross an architecture boundary?" → If yes, justify in decision log.

### At Verification (Stage 8)

For each non-negotiable that could have been affected:
- "Is this still preserved?" → Cite evidence (test, code inspection, git diff)

For each critical path touched:
- "Does it still work?" → Cite evidence (specific test passing)

## Service Context Summary Template

```markdown
## Service Context (binds this run)

### Non-Negotiables
1. [constraint]: [source: AGENTS.md line N]
2. [constraint]: [source: AGENTS.md line N]

### Critical Paths Touched
- [path/module]: [why critical] — Verification: [how we'll prove it's unbroken]

### Architecture Boundaries
- [rule]: [how it constrains this change]

### Testing Expectations
- [expectation]: [how it affects our methodology]

### Rollout Constraints
- [constraint]: [how it affects change structure]
```

## When Service Context is Violated

If during implementation you discover a tension between the task and a service constraint:

```
STOP.
"Service context tension: The task requires [X], but non-negotiable [Y] prevents this.

Options:
1. [Alternative approach that respects the constraint]
2. [Request explicit override from maintainer]
3. [Reduce scope to avoid the tension]

Which approach?"
```

**Never silently violate a non-negotiable. Block and escalate.**

## Anti-patterns

- **Treating service context as optional background** — it's binding, not informational
- **Skipping the verification check** — every touched non-negotiable needs preservation proof
- **Assuming constraints from memory** — re-read AGENTS.md every run; things change
- **Violating and asking forgiveness** — non-negotiables are non-negotiable
- **Treating critical paths as "normal code"** — they exist because bugs there have outsized impact
