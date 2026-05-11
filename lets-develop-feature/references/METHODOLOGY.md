# Methodology Guide — lets-develop-feature

How to select and apply the right development methodology for each work package.

## Methodology Selection

### Default: Repo-Native Validation

The default is **NOT** blanket TDD. The default is: use whatever validation approach the repo already uses.

```bash
# Discover repo methodology
cat AGENTS.md 2>/dev/null | grep -i "test\|tdd\|coverage"
ls tests/ test/ spec/ __tests__/ 2>/dev/null
cat pyproject.toml 2>/dev/null | grep -A5 "\[tool.pytest"
cat package.json 2>/dev/null | grep -A3 "\"test\""
```

### When to Use TDD

Use TDD (write failing test first → implement → pass) when ALL of:

1. The change introduces **new behavior** (not modifying existing)
2. The acceptance criteria are **clear and testable** (inputs → outputs)
3. The repo **has a test framework configured** and actively used
4. You can write a **meaningful failing test** before implementation

AND any of:
- AGENTS.md specifies TDD
- The spec has explicit acceptance criteria that map directly to assertions
- The behavior is pure (input → output, no side effects)
- You're implementing a contract/interface from a spec

### When to Use Test-After

Use test-after (implement → verify existing tests → add new tests for gaps) when:

- Modifying existing code that already has tests
- The change is a refactor (behavior preserved, tests should still pass)
- The change is a bugfix for which you'll add a regression test after fixing
- The interaction is complex (integration, multiple services, UI state)

### When to Use Integration Testing

Use integration tests when:

- Wiring a new endpoint/route (test the HTTP layer end-to-end)
- Connecting to an external service (test with mock/stub at boundary)
- Database operations (test with real DB or in-memory equivalent)
- Message queue interactions (test produce/consume cycle)

### When to Use Manual Verification

Use manual verification when:

- Config changes (verify the system starts correctly)
- Build/deploy changes (verify the build succeeds)
- UI changes that can't be tested headlessly
- Documentation changes (visual review)

## Per-Package Methodology Declaration

In the execution packet, declare methodology per work package:

| # | Files | Methodology | Why |
|---|-------|-------------|-----|
| 1 | tests/test_calc.py | TDD | New pure function with clear spec |
| 2 | src/calculator.py | TDD | Implementing to pass tests from #1 |
| 3 | src/api/routes.py | Integration-test | Wiring endpoint, need HTTP-layer verification |
| 4 | config/settings.toml | Manual | Config change, verify service starts |

## TDD Protocol (when selected)

```
1. Write the test
   - One test per acceptance criterion
   - Use descriptive test names that describe the scenario
   - Assert the expected behavior, not implementation details
   
2. Run the test — it MUST fail
   - If it passes without implementation, the test is wrong or the feature exists
   - The failure message should indicate what's missing
   
3. Implement the minimum code to pass
   - Don't over-implement — just make the test pass
   - No premature optimization or generalization
   
4. Run the test — it MUST pass
   - If it fails, fix the implementation (not the test)
   
5. Refactor if needed
   - Only after tests are green
   - Run tests after refactoring to verify no regression
```

## Test Quality Standards

Regardless of methodology, tests must:

| Standard | Good | Bad |
|----------|------|-----|
| **Assert behavior** | `assert result == expected_value` | `assert not threw` |
| **Independent** | Each test can run alone | Tests depend on execution order |
| **Descriptive** | `test_returns_error_when_user_not_found` | `test_1`, `test_error` |
| **Focused** | One assertion per test (or one logical behavior) | 20 assertions in one test |
| **No test-implementation coupling** | Tests the interface | Tests internal state/private methods |
| **Real edge cases** | Empty input, null, boundary values, unicode | Only happy path |

## Verification Commands

Every work package must have a verification command. Common patterns:

```bash
# Python
pytest tests/test_specific.py -v       # specific test file
pytest tests/ -q                       # full suite
pytest tests/ -k "test_name"           # specific test
ruff check src/                        # linting
mypy src/                              # type checking

# TypeScript/JavaScript
npx jest tests/specific.test.ts        # specific test
npm test                               # full suite
npx eslint src/                        # linting
npx tsc --noEmit                       # type checking

# Go
go test ./pkg/specific/...             # specific package
go test ./...                          # all packages
golangci-lint run                      # linting

# General
make test                              # project-specific
make lint                              # project-specific
```

## Anti-patterns

- **TDD everything** — TDD is powerful but not universal. Config changes, refactors, and integration work often benefit from test-after.
- **Tests that test mocks** — mocking the thing you're trying to test proves nothing.
- **Tests weaker than the spec** — if the spec says "must handle unicode," test with unicode.
- **Verification = "it should work"** — run the command, show the output.
- **Skipping verification between packages** — each package must verify before moving to the next.
- **Implementation without understanding tests** — read existing tests before modifying code they cover.
