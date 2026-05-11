# Pillars — lets-assess-ai-readiness

Each pillar measures a distinct dimension of agent effectiveness. Level progression is cumulative (L3 implies L2 implies L1).

---

## 1. Feedback Velocity

**Core question:** Can an agent validate a change in under 60 seconds?

Not "do tests exist" but "can an agent get a trustworthy pass/fail signal quickly for a scoped change?"

| Level | Criteria |
|-------|----------|
| L0 | No automated validation discoverable |
| L1 | Tests exist but only run as a monolithic suite (>5 min) |
| L2 | Scoped test execution possible (can run tests for a single module/file) |
| L3 | Fast scoped feedback (<60s); file-to-test mapping follows a discoverable convention |
| L4 | Layered validation pyramid (unit <10s, integration <60s, e2e <5min) clearly separated |
| L5 | Incremental validation (<5s for type/lint, <15s for unit); agent can choose confidence vs speed |

**Deterministic checks:**
- Test runner command discoverable from config (Makefile, package.json scripts, pyproject.toml)
- Test path filtering supported (runner accepts file/directory arguments)
- Test file naming convention consistent (>80% follow one pattern)
- CI config shows test step with measurable duration

**Heuristic signals:**
- Presence of "fast"/"smoke"/"unit" vs "full"/"integration"/"e2e" targets
- Watch mode or incremental tooling configured
- Ratio of source files with a corresponding test file

---

## 2. Error Signal Clarity

**Core question:** When something fails, can an agent diagnose WHY without human interpretation?

Agents fail because they can't parse ambiguous failure output into actionable next steps.

| Level | Criteria |
|-------|----------|
| L0 | Failures produce no useful output or opaque exit codes |
| L1 | Errors exist but are noisy (500 lines for one failure, no file references) |
| L2 | Errors reference file:line; linter output is parseable |
| L3 | Errors are actionable (show expected vs actual; suggest fix direction) |
| L4 | Errors are categorized (your-code vs environment vs flaky vs upstream) |
| L5 | Errors are machine-parseable (structured JSON/SARIF output available) |

**Deterministic checks:**
- Linter supports structured output format (--format json, --reporter json, SARIF)
- Test runner produces diff output on assertion failures (not just "failed")
- Type checker produces file:line:column references
- Distinct exit codes for different failure categories

**Heuristic signals:**
- Signal-to-noise ratio in a sample CI failure (actionable lines vs total output)
- Error messages contain suggestion or fix hint
- Build/test failures isolate the failing component (not "build failed" with no detail)

---

## 3. Determinism & Reproducibility

**Core question:** Given identical inputs, does the repo produce identical outputs?

Flakiness destroys feedback loop trust. An agent that sees "test passed, then failed, then passed" learns nothing.

| Level | Criteria |
|-------|----------|
| L0 | No lockfile; tests hit live APIs; time-dependent assertions |
| L1 | Dependencies pinned (lockfile) but execution may vary (ordering, races) |
| L2 | Reproducible on same machine (seeded randomness, fixed ordering) |
| L3 | Reproducible across environments (containerized; CI matches local) |
| L4 | Flakiness tracked and quarantined (known-flaky marked/skipped) |
| L5 | Determinism enforced (hermetic builds; test isolation verified; no shared mutable state) |

**Deterministic checks:**
- Lockfile present and committed (not in .gitignore)
- Lockfile not stale vs manifest (no drift)
- Test config shows isolation markers (parallel-safe, no shared state)
- No `.env` without `.env.example` (required vars documented)

**Heuristic signals:**
- Network calls in test files without corresponding mock/stub imports
- Time-dependent patterns in test assertions (time.now, Date.now, Instant.now)
- Flaky/retry annotations present (indicates known non-determinism)
- Tests import shared mutable fixtures (global state risk)

---

## 4. Change Safety & Blast Radius

**Core question:** Can an agent predict the impact of a change?

Low coupling and clear boundaries mean a mistake in module A doesn't cascade to module B.

| Level | Criteria |
|-------|----------|
| L0 | Monolithic; any change can break anything; no module boundaries |
| L1 | Logical separation exists (directories) but cross-imports unrestricted |
| L2 | Boundaries documented (module responsibilities described, public APIs identified) |
| L3 | Boundaries enforced (import restrictions, layer rules, interface contracts) |
| L4 | Changes are scopeable (module X change only needs module X tests for confidence) |
| L5 | Impact is computable (dependency graph tooling; affected-test detection available) |

**Deterministic checks:**
- Architectural boundary enforcement configured (import lint rules, internal packages)
- Interface/contract files at module boundaries
- Circular dependency detection configured
- PR size guidelines documented or enforced

**Heuristic signals:**
- Average fan-in/fan-out of top-level modules (import graph density)
- Percentage of tests that must run for a random single-file change
- Dependency graph tooling present (madge, deptry, go mod graph)
- Cross-module imports as ratio of total imports

---

## 5. Context Discoverability

**Core question:** Can an agent find what it needs without asking a human?

The ratio of implicit (tribal) knowledge to explicit, findable knowledge.

| Level | Criteria |
|-------|----------|
| L0 | No documentation; patterns only discoverable by reading all code |
| L1 | Docs exist but are stale (>6 months since update) or contradict code |
| L2 | Key decisions recorded; commands documented; agent guidance present |
| L3 | Context is layered and scoped (module-level docs, not just root-level) |
| L4 | Context is verified (example commands run; cross-references valid; staleness detected) |
| L5 | Context is self-maintaining (docs tested in CI; generated from code; auto-refreshed) |

**Deterministic checks:**
- README exists with runnable commands (fenced code blocks with language annotation)
- AGENTS.md or agent guidance file present
- Module-level documentation ratio (modules with local docs vs total modules)
- Doc freshness (last doc modification vs last code modification in same area)

**Heuristic signals:**
- ADR/decision records present and recent (within 6 months)
- "Why" comments at non-obvious decision points in code
- Commands in docs actually match available Makefile/script targets
- Coding rules or conventions documented with evidence

---

## 6. Pattern Consistency

**Core question:** Is there exactly one obvious way to do each thing?

Multiple valid patterns force agents to guess. Guesses compound into drift.

| Level | Criteria |
|-------|----------|
| L0 | Every file does things differently; no discernible convention |
| L1 | Patterns exist (inferable from 5+ files) but not documented |
| L2 | Patterns documented ("how to add a new X" guides exist) |
| L3 | Patterns enforced (linters catch deviations; generators/templates exist) |
| L4 | Patterns are singular (one way per concern; deviations annotated as legacy) |
| L5 | Pattern compliance measured (metrics track adoption; legacy explicitly migrating) |

**Deterministic checks:**
- Formatter + linter configured and enforced (not just present, but in CI)
- Code generation / scaffolding tooling present (generators, templates)
- Test file organization follows ONE convention (not mixed co-located and separate)
- Consistent file naming within each directory (snake_case or camelCase, not both)

**Heuristic signals:**
- Number of distinct error handling approaches (should be 1-2, not 5)
- Number of distinct import/dependency injection patterns
- "Adding a New X" guide exists for the most common contribution type
- Legacy code explicitly marked (deprecated annotations, migration plans)

---

## 7. Recovery Cost & Reversibility

**Core question:** How expensive is a mistake to undo?

Cheap recovery means an agent can be bolder. Expensive recovery demands more caution (and more human oversight).

| Level | Criteria |
|-------|----------|
| L0 | Mistakes are catastrophic (direct prod access; destructive migrations; no staging) |
| L1 | Mistakes caught late (only production reveals issues; no pre-merge validation) |
| L2 | Mistakes caught at PR time (CI blocks merge; review required) |
| L3 | Mistakes cheap to revert (single-command revert; feature flags; reversible migrations) |
| L4 | Mistakes contained (canary/progressive rollout; blast radius limited by design) |
| L5 | Self-healing (automated rollback on error spike; circuit breakers) |

**Deterministic checks:**
- Pre-merge CI that blocks on failure (required status checks)
- Feature flag framework in use (config files or flag references in code)
- Database migrations have corresponding down/rollback migrations
- Deployment config supports rollback (k8s rollout undo, blue-green)

**Heuristic signals:**
- Documented rollback procedure
- Average PR size (smaller = cheaper revert)
- Staging/preview environment referenced in CI or docs
- Progressive deployment strategy documented

---

## 8. Environment Independence

**Core question:** Can an agent operate without external state it cannot create, inspect, or reset?

External dependencies (real databases, third-party API keys, specific production data) block agent autonomy.

| Level | Criteria |
|-------|----------|
| L0 | Cannot run without production credentials or pre-existing data |
| L1 | Partial local operation (some tests work; integration tests need external systems) |
| L2 | Local dev documented (docker-compose or equivalent; .env.example with all vars) |
| L3 | External deps abstractable (mock/stub adapters; tests run fully offline) |
| L4 | Environment declarative (single command for complete working environment) |
| L5 | Zero-state bootstrap (fresh clone to passing tests with zero manual steps) |

**Deterministic checks:**
- .env.example or equivalent with all required variables listed
- Container configuration present (docker-compose, devcontainer, Dockerfile)
- Setup command documented and runnable from README
- No secret values in committed test fixtures

**Heuristic signals:**
- Steps from fresh clone to passing tests (parse setup guide)
- External service calls in tests behind mockable interfaces
- Test fixtures/factories for data dependencies (no pre-existing DB reliance)
- CI runs without needing secrets for the test suite (public repo CI passes)

---

## Pillar Weights (default)

Not all pillars matter equally for every repo. Default weights for scoring:

| Pillar | Default weight | Rationale |
|--------|---------------|-----------|
| Feedback Velocity | 15 | Critical path for agent iteration |
| Error Signal Clarity | 10 | Multiplier on feedback loop value |
| Determinism | 15 | Foundation of trustworthy feedback |
| Change Safety | 15 | Determines acceptable agent autonomy |
| Context Discoverability | 15 | Reduces wrong decisions |
| Pattern Consistency | 10 | Reduces compound errors |
| Recovery Cost | 10 | Determines acceptable risk level |
| Environment Independence | 10 | Determines bootstrapping friction |

Repos may adjust weights based on primary agent use case:
- **Feature development:** weight Pattern Consistency and Change Safety higher
- **Bug fixing:** weight Error Signal Clarity and Feedback Velocity higher
- **Refactoring:** weight Change Safety and Determinism higher
