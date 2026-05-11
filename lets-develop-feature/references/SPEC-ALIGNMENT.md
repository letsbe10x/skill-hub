# Spec-Alignment Protocol — lets-develop-feature

Continuous alignment between implementation and specification. Applies during Stage 6 (implementation) and Stage 8 (verification).

## Why Spec Alignment Matters

Without deliberate re-reading, implementation drifts from the spec:
- You remember what you THINK the spec says, not what it actually says
- Early decisions constrain later code in ways that contradict requirements
- Ambiguities only surface when you try to implement the specific behavior
- The longer drift goes undetected, the more expensive the fix

## The Protocol

### Phase 1 — Before Each Work Package (Stage 6)

At the start of every work package:

1. **Identify** which spec requirements this package addresses
2. **Re-read** the relevant section of the spec/task description (not from memory)
3. **Confirm** your approach still aligns with what the spec says
4. **Note** any ambiguity or tension discovered during the re-read

This takes 30 seconds. Skipping it risks hours of rework.

### Phase 2 — During Implementation (Stage 6)

While coding, watch for these contradiction signals:

| Signal | Example | Action |
|--------|---------|--------|
| Spec says X, code needs Y | "Spec says synchronous, but the API is async" | STOP — surface contradiction |
| Spec is silent on a case | "Spec doesn't say what happens on timeout" | Note ambiguity, implement defensively, flag in notes |
| Spec contradicts itself | "Section 2 says required, section 4 says optional" | STOP — surface contradiction |
| Spec assumes something false | "Spec assumes field exists, but schema has no such field" | STOP — surface contradiction |

### Phase 3 — On Contradiction (Stage 6)

When a contradiction is discovered:

```
HARD STOP.

"Spec contradiction discovered:
  Location: [which spec section / which code file]
  Spec says: [exact text or requirement]
  Reality: [what the code/system actually requires]
  
  Options:
  1. My understanding is wrong — re-read shows [alternative interpretation]
  2. Approach needs revision — can satisfy spec by [different approach]
  3. Spec needs revision — [why the spec appears incorrect]
  
  Recommendation: [1/2/3] because [reasoning]"
```

**Proceed only after resolution.** Resolution is one of:
- **Re-interpretation:** Your read of the spec was wrong; corrected understanding allows continuation
- **Approach change:** Different implementation strategy satisfies the spec
- **Spec override:** User confirms the spec is wrong/outdated; document the deviation
- **Scope cut:** Contradicted requirement is deferred with user agreement

### Phase 4 — Post-Implementation Verification (Stage 8)

After all packages are complete, perform a requirement-by-requirement check:

```markdown
## Spec Alignment Check

| # | Requirement | Spec source | Implemented? | Evidence | Status |
|---|-------------|-------------|--------------|----------|--------|
| 1 | Users can create invoices | Task §2.1 | Yes | billing/create.py + test_create | ALIGNED |
| 2 | Input validation per schema | Task §2.2 | Yes | validators/billing.py | ALIGNED |
| 3 | Rate limiting per tenant | Task §3.1 | Partial | middleware added, no test | GAP |
| 4 | Audit log on create | Task §2.3 | No | — | MISSING |
```

Every requirement gets one of:
- **ALIGNED** — implemented with evidence
- **GAP** — partially implemented, needs follow-up
- **MISSING** — not implemented at all
- **DEFERRED** — explicitly cut from scope with reason
- **CONTRADICTED** — spec was revised during implementation

### Phase 4 Verdict

| Result | Criteria |
|--------|----------|
| **Pass** | All requirements ALIGNED or DEFERRED with justification |
| **Gaps exist** | Some requirements are GAP — fixable in current scope? |
| **Blocked** | Requirements MISSING without justification — cannot complete |

## Spec Sources

The "spec" may be any of:
- A formal specification document
- A task description from the user
- A ticket/issue body
- A PRD section
- Acceptance criteria in a story

Whatever the source, treat it as the authority for WHAT should be built. Implementation decides HOW, not WHETHER.

## Handling Absent Specs

When no formal spec exists (e.g., user says "add a billing endpoint"):
- The user's description IS the spec
- Extract implicit requirements (input validation, error handling, etc.)
- Surface what you're inferring: "I'm assuming [X] based on [Y]. Correct?"
- These inferences go in the assumptions log

## Spec Revision Flow

When a spec needs revision (user agrees the spec is wrong):

1. Document the original spec text
2. Document what's wrong and why
3. Document the revised understanding
4. Get user confirmation of the revision
5. Update the spec alignment check to reflect the revision
6. Continue implementation with revised understanding

The revision itself is not a problem. **Silently deviating without documenting is the problem.**

## Integration with Service Context

Spec alignment and service context can conflict:
- Spec says "store tokens in session" → service context says "credentials injected at start, never stored"
- In this case: service context wins (non-negotiables are non-negotiable)
- Surface the tension, implement per service context, document the spec deviation

## Anti-patterns

- **"I already read it"** — re-read anyway; memory is unreliable
- **"It's obviously what they mean"** — ambiguity should be noted, not assumed away
- **"I'll check at the end"** — early detection saves rework
- **"The spec is wrong so I'll just do the right thing"** — get confirmation first
- **"This is close enough"** — close is not aligned; document the gap
- **"The spec doesn't say NOT to do this"** — scope is what the spec says TO do, not unbounded
