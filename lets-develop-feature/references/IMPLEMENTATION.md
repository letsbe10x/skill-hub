# Implementation Stage — lets-develop-feature

Per-package execution protocol with spec re-read discipline, scope enforcement, and living artifact maintenance.

## Execution Protocol

Implementation proceeds work-package-by-work-package from the execution packet. No package is started until its dependencies are met.

### Per-Package Flow

```
For each work package:
  1. Pre-flight: verify dependencies met
  2. Spec re-read: re-read relevant spec/task section
  3. Execute: write code per methodology
  4. Verify: run package-specific verification
  5. Update: traceability + implementation notes
  6. Gate: package done or blocked
```

### Step 1 — Pre-flight

Before starting a package, confirm:
- All dependency packages are completed (not just started)
- Package verification criteria are still valid (no earlier package invalidated them)
- Service constraints are not in tension with this package's work

### Step 2 — Mandatory Spec Re-read

**At every milestone boundary (start of each work package), re-read the relevant section of the spec/task description.**

This is NOT optional. It catches:
- Drift between what you think the spec says and what it actually says
- Requirements you missed on first read
- Contradictions that emerge only when you reach that part of the implementation

See [SPEC-ALIGNMENT.md](SPEC-ALIGNMENT.md) for the full spec-alignment protocol.

### Step 3 — Execute

Follow the methodology assigned to this package:

| Methodology | Protocol |
|-------------|----------|
| **TDD** | Write failing test → implement → pass → refactor |
| **test-after** | Implement → write tests → verify |
| **integration** | Implement → integration test with real dependencies |
| **manual** | Implement → document manual verification steps |

See [METHODOLOGY.md](METHODOLOGY.md) for detailed methodology guidance.

### Step 4 — Verify

Run the package-specific verification from the execution packet:
- Execute the specified command(s)
- Confirm the expected result
- If verification fails: fix within package scope, do not proceed until passing

### Step 5 — Update Artifacts

After each package, update:
- **Traceability record:** which requirements are now covered
- **Implementation notes:** decisions made, deviations from plan (with justification)
- **Assumptions log:** mark validated/invalidated assumptions

### Step 6 — Package Gate

| Outcome | Action |
|---------|--------|
| Verification passes | Mark package completed, proceed to next |
| Verification fails, fixable in scope | Fix → re-verify |
| Verification fails, out of scope | Mark package BLOCKED, document blocker, stop |
| Spec contradiction discovered | HARD STOP — see Spec Contradiction Protocol below |

## Spec Contradiction Protocol

When code reveals something that contradicts the spec/task:

```
HARD STOP.

"Spec contradiction at package [N]:
  Spec says: [X]
  Code reveals: [Y]
  Impact: [what breaks if we proceed either way]

Options:
1. [Revise understanding of spec — spec is correct, my read was wrong]
2. [Revise approach — implement differently to satisfy spec]
3. [Surface to user — spec appears incorrect or ambiguous]

Recommendation: [which option and why]"
```

**NEVER silently proceed past a spec contradiction.** This is a hard limit.

## Scope Enforcement

### Hard Stops

Implementation must STOP and escalate when:
- A file not in the execution packet needs modification
- A package's LOC significantly exceeds estimate (>2x)
- A new dependency is needed that wasn't planned
- Work is needed that doesn't map to any work package

### Handling Scope Pressure

When you feel the pull to "just quickly fix this other thing":
1. Note the desire in implementation notes
2. Determine: is it blocking current package?
3. If blocking: add to assumptions as invalidated → may require re-planning
4. If not blocking: note as follow-up work in handoff → continue with current package

### Extra Files

If you must touch a file not in the packet:
1. Stop and note: "Package [N] needs file [X] not in packet"
2. Determine if it's a minor oversight (e.g., import in `__init__.py`) or scope expansion
3. Minor oversight: proceed but document in implementation notes
4. Scope expansion: escalate to user

## Living Artifact Discipline

### Implementation Notes

Maintain notes as you work. Record:
- Decisions made during implementation (the WHY, not the WHAT)
- Deviations from the plan (with justification)
- Touched critical paths (with preservation evidence)
- Preserved non-negotiables (with proof)

### Traceability Record

Keep a running map from requirements to code:

```markdown
| Requirement | Package | Code | Test | Status |
|-------------|---------|------|------|--------|
| Users can create invoices | #2 | billing/create.py:45-80 | test_create_invoice | Done |
| Invalid input rejected | #1 | validators/billing.py:12-30 | test_validate_input | Done |
| DB timeout handled | #3 | — | — | Pending |
```

## Execution Constraints

- Do not invent test results or claim untested confidence
- Do not weaken existing error handling
- Do not install new dependencies without explicit approval
- Do not run destructive commands without confirmation
- Use canonical project commands (Makefile, package.json, pyproject.toml) where they exist
- Extend existing patterns before inventing new abstractions
- Prefer the smallest safe change that satisfies the package

## Per-Rigor Adjustments

| Rigor | Notes |
|-------|-------|
| MINIMAL | Single pass, no formal traceability, quick verification |
| STANDARD | Per-package verification, notes maintained, spec re-read at boundaries |
| ELEVATED | Full traceability required, per-file confirmation for critical paths |
| FULL | Per-file confirmation, stacked PRs, all artifacts must be populated |

## Anti-patterns

- **Coding before reading** — always read the file before editing it
- **Skipping spec re-read** — drift happens; re-reading catches it
- **"I'll fix it later"** — either fix now or document as follow-up with justification
- **Silent scope expansion** — if it's not in the packet, stop and ask
- **Weakening error handling** — existing catches, retries, and fallbacks exist for a reason
- **Inventing results** — if you didn't run it, you don't know the result
- **Large packages** — if a package is growing beyond plan, stop and re-assess
