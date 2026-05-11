# Review Lenses — lets-review-code

Detailed guidance for each review lens. Each lens answers ONE primary question and has defined patterns to check.

## Lens Operating Principles

1. **One question per lens** — stay focused on your primary question
2. **Evidence before assertion** — every finding must cite file:line with real code
3. **Impact over best-practice** — explain WHY it matters for THIS system, not generic rules
4. **Confidence explicit** — declare certainty 0.0–1.0
5. **Challenge yourself** — include how each finding could be wrong
6. **No motivational fluff** — findings only, direct and specific
7. **Pattern search** — finding one instance → search for the pattern across the codebase

---

## Lens 1: Correctness & Logic

**Primary question:** Does the code do what it claims to do?

### Critical Patterns

| Pattern | What to look for | Impact |
|---------|-----------------|--------|
| Off-by-one | Loop bounds, slice indices, range calculations | Silent wrong results |
| Null safety | Optional values accessed without check | Runtime crash |
| Type confusion | String where int expected, wrong enum variant | Undefined behavior |
| Error swallowing | Bare except, empty catch, `_ = err` | Silent failures |
| Return value ignored | Function returns error/status but caller ignores | Missed failures |
| TOCTOU | Check-then-act without atomicity | Race condition |
| Resource leak | Open without close, especially in error paths | Resource exhaustion |
| State corruption | Mutation in unexpected scope, shared mutable state | Data integrity |
| Dead code | Defined but unreachable, set but never read | Maintenance confusion |
| Inconsistent semantics | Same concept defined differently in different places | Logic errors |

### Verification Protocol

For each suspected correctness issue:
1. Read the full function containing the issue
2. Trace all callers — does any caller handle the case?
3. Check test coverage — is there a test that would catch this?
4. Look for project conventions — is this an established pattern?

---

## Lens 2: Security

**Primary question:** Can this code be exploited or does it leak sensitive data?

### Threat Model

| Vector | What to look for | Severity if found |
|--------|-----------------|-------------------|
| SQL injection | String concatenation in queries, unparameterized | CRITICAL |
| Command injection | Shell=True, string-formatted commands, unsanitized args | CRITICAL |
| Path traversal | User input in file paths without canonicalization | CRITICAL |
| SSRF | User-controlled URLs fetched server-side | HIGH |
| Auth bypass | Missing permission check, wrong role comparison | CRITICAL |
| Secrets in code | API keys, tokens, passwords, connection strings | HIGH |
| PII exposure | Personal data in logs, error messages, or broad responses | HIGH |
| Weak crypto | MD5/SHA1 for security, ECB mode, hardcoded keys/IVs | HIGH |
| Deserialization | pickle.loads(), yaml.load() on untrusted input | CRITICAL |
| Open redirect | User input in redirect targets without allowlist | MEDIUM |
| Missing rate limits | Auth endpoints, expensive operations without throttle | MEDIUM |
| Dependency risk | New dep with known CVEs, typosquatting potential | MEDIUM |

### Security Review Protocol

1. **Map the trust boundary** — where does untrusted input enter?
2. **Trace data flow** — from entry to storage/output, is it sanitized?
3. **Check auth chain** — is every privileged operation gated?
4. **Verify secrets handling** — are they in env/vault, not code?
5. **Assess dependency** — any new deps? Check for CVEs.

---

## Lens 3: Architecture & Design

**Primary question:** Is this the right design for the problem?

### Assessment Criteria

| Criterion | Good signal | Bad signal |
|-----------|-------------|------------|
| Responsibility | Module does one thing well | God class, mixed concerns |
| Coupling | Depends on interfaces, not implementations | Imports internals of other modules |
| Cohesion | Related code together | Scattered across modules |
| Abstraction level | Right complexity for the problem | Premature generalization OR missing abstraction |
| Extensibility | Known requirements fit without rewrite | Hardcoded for single case |
| Layer discipline | Each layer has clear role | Controller has business logic, model makes HTTP calls |
| Boundary clarity | Clean seam between modules | Shared mutable state, circular deps |

### Architecture Smell Detector

- **Feature envy** — a method uses more data from another class than its own
- **Shotgun surgery** — one conceptual change requires touching many files
- **Parallel inheritance** — adding a subclass in one hierarchy requires adding in another
- **Refused bequest** — subclass ignores most of parent's interface
- **Message chains** — a.b().c().d() (tight coupling to structure)
- **Speculative generality** — abstraction with one implementation and no planned second

---

## Lens 4: API & Contracts

**Primary question:** Will this break callers or violate contracts?

### Breaking Change Detection

| Change | Breaking? | Migration needed? |
|--------|-----------|-------------------|
| Remove public method/field | Yes | Deprecation period |
| Rename public method/field | Yes | Alias + deprecation |
| Change parameter type | Yes | Overload or default |
| Add required parameter | Yes | Default value |
| Change return type | Yes | Versioning |
| Change error types/codes | Likely | Document + grace period |
| Add optional field | No | — |
| Add new method | No | — |

### Contract Consistency Checks

1. **Error contract** — do new error types follow existing patterns? (codes, messages, structure)
2. **Schema evolution** — are new fields optional? Is there a migration path?
3. **Behavioral contract** — does the implementation match documented guarantees?
4. **Version discipline** — if versioned, is the version bumped?
5. **Provider parity** — if multiple providers exist, do all handle this?

---

## Lens 5: Completeness

**Primary question:** Is this production-ready?

### Production Readiness Checklist

| Area | What to verify |
|------|----------------|
| Test coverage | Tests exist for the claimed feature, not just happy path |
| Error paths | Failure modes are tested (timeout, invalid input, unavailable dep) |
| Edge cases | Boundary values, empty/null/large inputs, unicode, concurrent |
| Observability | Errors logged with context, key operations have metrics/traces |
| Documentation | New config documented, API docs updated, README current |
| Migration | Deployment ordering clear (schema first? flag first? both?) |
| Rollback | Can this be reverted without data loss? |
| Feature flag | Is there a kill switch for risky new behavior? |

### Test Quality Assessment

| Quality signal | Good | Bad |
|---------------|------|-----|
| Assertions | Test verifies behavior, not implementation | `assert not threw` |
| Isolation | Tests are independent, order doesn't matter | Shared mutable state |
| Naming | Test name describes the scenario | `test_1`, `test_feature` |
| Coverage | Happy + sad + edge paths covered | Only happy path |
| Mocking | Mock at boundaries only | Mock the thing being tested |

---

## Lens 6: Complexity & Simplification

**Primary question:** Is this more complex than it needs to be?

### Complexity Signals

| Signal | Threshold | Implication |
|--------|-----------|-------------|
| Nesting depth | >3 levels | Extract to named function |
| Function length | >50 lines | Likely doing multiple things |
| Parameter count | >5 params | Likely missing a concept/struct |
| Cyclomatic complexity | >10 paths | Hard to test all paths |
| Abstraction layers | >3 for simple operation | Over-engineering |
| Files touched for one concept | >5 | Shotgun surgery |

### Over-Engineering Patterns

- **Framework for one use** — building infrastructure for hypothetical future needs
- **Premature abstraction** — interface/protocol with only one implementation
- **Configuration theater** — making everything configurable when only one value is used
- **Defensive excess** — retry/fallback around code that can't fail in context
- **Custom over stdlib** — reimplementing what the standard library provides
- **Indirection without value** — wrapper that just calls through without adding behavior

### Simplification Opportunities

When flagging complexity, always suggest the simpler alternative:
- Deep nesting → early returns
- Long function → extract named steps
- Many params → parameter object
- Custom code → stdlib equivalent
- Wrapper with no logic → direct use
- Abstract class with one child → concrete class

---

## AI Failure-Mode Lens

**Primary question:** Does this code exhibit patterns common in AI-generated code that looks correct but isn't?

### AI Failure Patterns

| Pattern | How to detect | Why it matters |
|---------|---------------|----------------|
| Polish without purpose | Clean code with no tests, unused helpers | Looks good, does nothing |
| Defensive theater | try/catch/retry with no evidence of the failure mode | Hides real errors behind generic handling |
| Weakened tests | Assertions check looser conditions than the spec | Tests pass but don't prove anything |
| Zombie code | Branches/flags/params never exercised by any caller | Maintenance burden, confusion |
| Import bloat | Heavy library for trivial operation | Dependency risk, build time |
| Plausible-but-wrong | Correct-looking edge case handling that mishandles encoding/timezone/locale/float | Production bugs in rare cases |
| Symmetry addiction | Unnecessary parallel structures "for consistency" | Coupling, maintenance burden |
| Comment-driven | Comments describe what code does (not why) | Comments will drift from code |

### Detection Protocol

1. For each new function/class: who calls it? If nobody, flag as zombie.
2. For each try/catch: what failure mode is it guarding against? Can that actually happen here?
3. For each test: does it assert the spec requirement, or something weaker?
4. For each import: is the full library needed, or just one trivial function?
5. For each abstraction: is there more than one implementation? Is a second planned?
