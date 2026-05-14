# Planning Stage — lets-develop-feature

How to build the execution packet from an approved spec, decompose into story tasks, build
scenario coverage, define assumptions, and run the checkpoint.

## Entry Condition

By the time Stage 3 activates, an approved spec MUST already exist — either:

- Produced by `lets-brainstorm` (via Phase 0 delegation)
- Produced by inline discovery (Phase 0 fallback)
- Pre-existing in `lets spec` workspace or referenced PRD/ticket
- Provided directly by the user

Stage 3 does NOT construct specs. If no spec exists at Stage 3 entry, something went wrong in
Phase 0 — stop and return to Phase 0.

## Spec vs Service Context

If service context (Stage 1) conflicts with the spec, surface the conflict to the user:
- Narrow scope to avoid the conflict
- Accept with documented risk
- Send back to discovery to revise the spec

Don't silently proceed past a conflict. But don't over-validate — if the spec was produced by
brainstorm with repo context, most conflicts were already caught. Only flag genuinely new
information from AGENTS.md that brainstorm couldn't have known.

If the `lets` CLI is available:

```bash
lets spec status --format json
lets spec export <feature_key>
lets journey init <feature_key> --repo-root .
```

### Spec Quality Checklist

- [ ] WHAT and WHY are clear before HOW
- [ ] User stories or user-facing scenarios are identifiable
- [ ] Functional requirements are testable and unambiguous
- [ ] Success or acceptance criteria are measurable
- [ ] Scope boundary is clear
- [ ] Security, privacy, compliance, data, or auth concerns are identified
- [ ] Critical clarifications are resolved or explicitly blocking
- [ ] Non-critical assumptions are documented

### Clarification Discipline

Ask for at most three critical clarifications at once. Prioritize in this order:

1. Scope boundary
2. Security, privacy, auth, or compliance impact
3. Public API, schema, or data contract impact
4. User experience and acceptance behavior

If more than three unclear items exist, make reasonable defaults for lower-impact items and record them in the assumptions log.

## Execution Packet

The execution packet is the contract between planning and implementation. It must be complete enough that implementation can proceed without re-discovery.

### Required Sections

| Section | Purpose | When |
|---------|---------|------|
| **Task summary** | One-line intent | Always |
| **Spec source** | Authority for WHAT/WHY | Always |
| **User stories** | Independently testable value slices | STANDARD+ |
| **Work packages** | Ordered list of implementation units | STANDARD+ |
| **Story tasks** | Task checklist with dependencies and mappings | STANDARD+ |
| **Scenario matrix** | Coverage before coding | STANDARD+ |
| **Design artifacts** | Research/data-model/contracts/quickstart inventory | ELEVATED+ |
| **Journey link** | Spec, run, handoff, and evidence linkage | ELEVATED+ |
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
- Requirement, story, or scenario mapping

### Work Package Ordering Principles

1. **Risk-first:** High-risk packages early (fail fast)
2. **Foundation-first:** Shared utilities before consumers
3. **Test-first packages before test-after:** Establish invariants early
4. **Critical path packages get extra attention:** More granular verification

## Story Task Breakdown

For STANDARD+ rigor, create `story-tasks.md` before implementation. Tasks are organized around independently testable user stories or value slices, not just files.

### Task Format

```markdown
- [ ] T001 [US1] Add input validation in src/validators.py — maps to: FR-1, Scenario 2
- [ ] T002 [P] [US1] Add validation tests in tests/test_validators.py — maps to: FR-1, Scenario 2
```

Rules:

- Every task starts with a checkbox and stable task ID.
- Include `[P]` only when the task can run in parallel without shared-file or dependency conflicts.
- Include a story label for story-phase work (`[US1]`, `[US2]`, etc.).
- Include exact file paths when known.
- Every task maps to a requirement, user story, scenario, or documented infrastructure need.

### MVP First

Identify the smallest independently testable story that delivers value. Put it first unless risk-first ordering requires a narrow foundation package before it. Later stories should remain independently verifiable whenever possible.

## Scenario Matrix Integration

The scenario matrix (see [SCENARIO-MATRIX.md](SCENARIO-MATRIX.md)) must be produced BEFORE implementation starts. Each scenario must trace to a user story, task, and work package.

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
3. **Spec readiness** — source, checklist status, unresolved clarifications
4. **Work packages and story tasks** — ordered list with methodology and mappings
5. **Scenario coverage** — key scenarios (link to full matrix)
6. **Key assumptions** — especially low-confidence ones
7. **Service constraints** — non-negotiables that bind the run
8. **Core linkage** — feature key, journey ID, run/evidence expectations when available
9. **Architecture decision** — gate opened or skipped with reason
10. **Risks** — what could go wrong, how we mitigate

### Checkpoint Quality Checklist

Before presenting, verify:

- [ ] Every work package has verification criteria
- [ ] Every story task maps to a requirement, scenario, or infrastructure need
- [ ] Scenario matrix covers at least happy + failure + edge
- [ ] Critical clarifications are resolved or explicitly blocking
- [ ] Service constraints from Stage 1 are carried forward
- [ ] Journey/evidence linkage is recorded or explicitly skipped
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
- **Task list without traceability** — tasks must map back to requirements/scenarios or documented infrastructure needs
- **Critical clarifications left open** — unresolved scope/security/API questions block implementation
- **No scope boundary** — unbounded scope invites creep
- **Ignoring service constraints** — if Stage 1 captured non-negotiables, they must appear in the packet
- **Methodology arbitrarily assigned** — TDD for correctness-critical, test-after for straightforward wiring
