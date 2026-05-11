# Planning Stage — lets-develop-feature

How to produce the execution packet, build scenario coverage, define assumptions, and run the checkpoint.

## Execution Packet

The execution packet is the contract between planning and implementation. It must be complete enough that implementation can proceed without re-discovery.

### Required Sections

| Section | Purpose | When |
|---------|---------|------|
| **Task summary** | One-line intent | Always |
| **Work packages** | Ordered list of implementation units | STANDARD+ |
| **Scenario matrix** | Coverage before coding | STANDARD+ |
| **Assumptions log** | What we're betting on | STANDARD+ |
| **Scope boundary** | What is NOT in scope | ELEVATED+ |
| **Dependencies** | What must exist before each package | ELEVATED+ |
| **Service constraints** | Non-negotiables that bind this run | When service context exists |
| **Architecture notes** | Design decisions (or "gate skipped: [reason]") | When gate opens |

### Work Package Structure

Each work package is a self-contained unit of work:

```markdown
| # | Package | Files | Methodology | Depends on | Verification |
|---|---------|-------|-------------|------------|--------------|
| 1 | Input validation | src/validators.py | TDD | — | test_validators pass |
| 2 | Core handler | src/handler.py | test-after | #1 | test_handler pass |
| 3 | Route wiring | src/routes.py | test-after | #2 | integration test pass |
| 4 | Error handling | src/errors.py | TDD | #2 | error scenarios pass |
```

**Every package must specify:**
- What files it touches (blast radius)
- Methodology (TDD, test-after, integration, manual)
- Dependencies (which earlier packages must be done)
- Verification criteria (how we know it's done)

### Work Package Ordering Principles

1. **Risk-first:** High-risk packages early (fail fast)
2. **Foundation-first:** Shared utilities before consumers
3. **Test-first packages before test-after:** Establish invariants early
4. **Critical path packages get extra attention:** More granular verification

## Scenario Matrix Integration

The scenario matrix (see [SCENARIO-MATRIX.md](SCENARIO-MATRIX.md)) must be produced BEFORE implementation starts. Each scenario must trace to a work package.

### Minimum Coverage by Rigor

| Rigor | Happy | Failure | Edge | Concurrency |
|-------|-------|---------|------|-------------|
| MINIMAL | — | — | — | — |
| STANDARD | ≥1 | ≥1 | ≥1 | if applicable |
| ELEVATED | comprehensive | comprehensive | comprehensive | if applicable |
| FULL | comprehensive | comprehensive | comprehensive | required |

## Assumptions Log

Every plan rests on assumptions. Make them explicit so they can be validated during implementation.

### Format

```markdown
## Assumptions

| # | Assumption | Confidence | Validation | Impact if wrong |
|---|------------|------------|------------|-----------------|
| 1 | User model has email field | HIGH | Read model file | Blocks package #2 |
| 2 | Rate limiter is per-tenant | MEDIUM | Check middleware | Changes approach for #3 |
| 3 | Existing tests cover auth flow | LOW | Run test suite | Need to write new tests |
```

### Handling Invalidated Assumptions

When implementation reveals an assumption is wrong:
1. STOP at current package boundary
2. Update assumptions log (mark INVALIDATED)
3. Assess impact on remaining packages
4. If plan change is minor: note in decision log, continue
5. If plan change is significant: return to checkpoint (Stage 5)

## Checkpoint (Stage 5)

### What to Present

Present the execution packet to the user for review. The presentation must include:

1. **Task summary** — what are we doing and why
2. **Classification** — rigor level and rationale
3. **Work packages** — ordered list with methodology per package
4. **Scenario coverage** — key scenarios (link to full matrix)
5. **Key assumptions** — especially low-confidence ones
6. **Service constraints** — non-negotiables that bind the run
7. **Architecture decision** — gate opened or skipped with reason
8. **Risks** — what could go wrong, how we mitigate

### Checkpoint Quality Checklist

Before presenting, verify:

- [ ] Every work package has verification criteria
- [ ] Scenario matrix covers at least happy + failure + edge
- [ ] Service constraints from Stage 1 are carried forward
- [ ] Low-confidence assumptions are flagged
- [ ] Scope boundary is explicit (what we will NOT do)
- [ ] Dependencies between packages are clear
- [ ] Methodology per package is justified (not arbitrary)

### User Responses

| Response | Action |
|----------|--------|
| Approve | Proceed to Stage 6 |
| Adjust scope | Update packet → re-present affected sections |
| Add scenario | Update matrix → update affected packages |
| Challenge assumption | Validate immediately if possible, or mark as risk |
| Reject approach | Return to Stage 3 with feedback |

### Skipping the Checkpoint

The checkpoint can be skipped ONLY when:
- Rigor = MINIMAL (trivial, low-risk, mechanical)
- Rigor = STANDARD AND risk = LOW AND complexity = mechanical

When skipped, note: `Stage 5: skipped (MINIMAL rigor, low-risk mechanical change)`

## Execution Packet Template

Use `assets/templates/execution-packet.template.md` as a starting point. The template provides the structure; fill in the content based on the specific task.

## Anti-patterns

- **Packages too large** — if a package spans >5 files or >200 LOC, decompose further
- **Missing verification criteria** — "it works" is not a criterion; specify what passes
- **Assumptions left implicit** — every "I think X" must be in the assumptions log
- **Scenario matrix after coding** — it must inform implementation, not document it
- **No scope boundary** — unbounded scope invites creep
- **Ignoring service constraints** — if Stage 1 captured non-negotiables, they must appear in the packet
- **Methodology arbitrarily assigned** — TDD for correctness-critical, test-after for straightforward wiring
