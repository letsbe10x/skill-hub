# Scenario Matrix — lets-develop-feature

How to systematically cover happy path, failure modes, and edge cases before implementation.

## Why Scenarios Matter

Implementation without scenario thinking produces code that:
- Works for the happy path but breaks on errors
- Handles obvious cases but misses boundaries
- Passes tests but fails in production under load/concurrency

The scenario matrix ensures you've THOUGHT about these cases before coding.

## When to Produce a Scenario Matrix

| Rigor | Required? |
|-------|-----------|
| MINIMAL | No — too much overhead for trivial changes |
| STANDARD | Yes — at least 1 happy + 1 failure + 1 edge |
| ELEVATED | Yes — comprehensive coverage |
| FULL | Yes — comprehensive + concurrency/scale scenarios |

## Scenario Categories

### Happy Path
Normal successful operation. The expected use case.

| Question | Example |
|----------|---------|
| What's the normal input? | Valid user ID, correct auth token |
| What's the expected output? | 200 OK with user data |
| What side effects occur? | Database updated, event emitted |

### Failure Modes
Things that go wrong. External failures, invalid input, unavailable dependencies.

| Question | Example |
|----------|---------|
| What if input is invalid? | Missing required field → 400 with error message |
| What if dependency is down? | Database timeout → 503 with retry-after |
| What if auth fails? | Invalid token → 401, no data leaked |
| What if data doesn't exist? | Unknown ID → 404 |
| What if operation partially fails? | Payment charged but notification failed → compensate |

### Edge Cases
Boundary conditions, unusual but valid inputs, race conditions.

| Question | Example |
|----------|---------|
| Boundary values? | Empty list, max integer, unicode characters |
| Concurrent access? | Two requests updating same record simultaneously |
| Large input? | 10K items in a list, 1MB payload |
| Repeated operation? | Idempotent? What happens on retry? |
| Time-sensitive? | Timezone edge, DST transition, leap year |
| Null/missing? | Optional field absent vs. explicitly null |

## Matrix Format

| # | Scenario | Type | Input | Expected Output | Error Handling | Test Coverage |
|---|----------|------|-------|-----------------|----------------|---------------|
| 1 | Normal user fetch | happy | Valid user_id | 200 + user data | N/A | test_get_user_happy |
| 2 | User not found | failure | Invalid user_id | 404 + error message | Log warning | test_get_user_not_found |
| 3 | Database timeout | failure | Valid user_id, DB slow | 503 + retry-after | Log error, circuit break | test_get_user_db_timeout |
| 4 | Empty user_id | edge | "" | 400 + validation error | N/A | test_get_user_empty_id |
| 5 | Concurrent updates | edge | Two PATCH same user | Last-write-wins (or conflict) | 409 if conflict mode | test_concurrent_update |

## Scenario → Work Package Mapping

Each scenario should trace to a work package in the execution packet:

| Scenario | Covered by package | How |
|----------|-------------------|-----|
| #1 Happy path | Package 2 (implement handler) | Main implementation |
| #2 Not found | Package 2 (implement handler) | Error branch in handler |
| #3 DB timeout | Package 3 (error handling) | Timeout wrapper + circuit breaker |
| #4 Empty input | Package 1 (validation) | Input validation middleware |
| #5 Concurrent | Package 4 (concurrency) | Optimistic locking in model |

## Scenario Discovery Techniques

### Start with the Interface

```
For each input:
  - What's the valid range?
  - What happens at the boundaries?
  - What happens outside the range?
  
For each output:
  - What are all possible outputs?
  - When does each occur?
  
For each side effect:
  - What if it fails?
  - What if it's slow?
  - Is it idempotent?
```

### Failure Mode Enumeration

```
For each external dependency:
  - Unavailable (connection refused)
  - Slow (timeout)
  - Wrong response (corrupted data)
  - Partial failure (some items succeed, some fail)

For each stateful operation:
  - Concurrent modification
  - Repeated submission (idempotency)
  - Interrupted mid-operation (crash recovery)
```

### Boundary Value Analysis

```
For each numeric parameter:
  - 0, 1, max-1, max, max+1
  
For each string parameter:
  - "", single char, very long, unicode, special chars
  
For each collection:
  - Empty, single item, many items, duplicate items
  
For each optional:
  - Present, absent, null (if distinct from absent)
```

## Scenarios and Service Context

When service context identifies critical paths, ensure the scenario matrix covers:
- Normal operation of the critical path (happy)
- Failure of the critical path (what breaks?)
- Recovery of the critical path (how do we get back to normal?)

## Anti-patterns

- **Happy path only** — the matrix must include at least one failure and one edge case
- **Scenarios without test mapping** — every scenario should trace to either a test or an explicit "deferred" note
- **Deferred without justification** — if a scenario is deferred, say why and when it'll be addressed
- **Scenarios after implementation** — the matrix should be produced BEFORE coding, not after (it informs the implementation)
- **Generic scenarios** — "what if it fails?" is not a scenario. "What if the Stripe API returns 429 rate limit?" is.
