# Intake & Discovery — lets-develop-feature

Phase 0 protocol. This is the first thing that happens when the skill activates. Its job is to
understand the user, not to produce artifacts.

## Turn 1 — Intent Echo

Reflect the user's request back in plain language. Confirm you understood.

**Rules:**
- One sentence for simple requests, 2-3 for complex
- Use the user's language, not framework jargon (no "rigor levels", "execution packets", "service context")
- End with a confirmation question: "Is that right?" or "Did I get that right?"
- If the request is too ambiguous to echo confidently, ask ONE disambiguating question instead

**Format:**

```
"You want to [plain-language echo of intent]. Is that right?"
```

**Anti-patterns:**
- Showing governance checks, classification results, or stage labels
- Echoing more detail than the user gave (inventing scope)
- Asking "is this right?" when you should ask "which of these did you mean?"
- Skipping straight to signals or classification
- Mentioning Phase 0, control levels, or any internal skill vocabulary

## Turn 2 — Signals + Control Recommendation

After intent is confirmed, present three things in one message:

### 1. Spec Status (one line)

| Status | What to say |
|---|---|
| Approved spec exists | "I found an approved spec for this — I can plan from it directly." |
| Draft spec exists | "There's a draft spec but it hasn't been approved yet. I'll need to validate it with you." |
| No spec | "I don't see a spec for this — I'll need to explore the design with you first." |
| User referenced ticket/PRD | "I'll use [ticket/PRD] as the spec source." |

### 2. Discovery Signals (bullet list, max 5)

Present only signals that are TRUE for this request. Use plain language:

| Signal ID | What to say to the user |
|---|---|
| `no_approved_spec` | "No approved spec exists yet" |
| `ux_surface_detected` | "This touches user-facing UI/UX" |
| `competitive_context_needed` | "This is a net-new product surface — competitor context might help" |
| `persona_validation_needed` | "This introduces a new concept for users — persona validation could catch blind spots" |
| `prd_grooming_needed` | "The requirements look raw — they'd benefit from structured grooming first" |
| `cross_module` | "This crosses multiple modules/packages" |
| `public_api_change` | "This changes a public API surface" |
| `security_surface` | "This touches auth/security code" |
| `migration` | "This involves a data/schema migration" |

### 3. Control Recommendation (one sentence + question)

Based on signals, recommend a control level:

| Signals | Recommend | Reasoning template |
|---|---|---|
| Low risk, familiar pattern, spec exists | Autonomous | "This looks straightforward — I can plan and implement, then bring you the result for review." |
| Standard feature, moderate signals | Checkpoints | "I'd recommend bringing you the design and plan for approval before implementing." |
| High risk, novel, ambiguous, many signals | Collaborative | "This has enough complexity/risk that I'd suggest we explore each design decision together." |

End with: "Want me to proceed that way, or would you prefer more/less involvement?"

## Turn 3 — Delegation Plan

Match active signals against handoff declarations. Present the plan ONLY if delegations are triggered.

**Format:**

```
"Before I plan the implementation, I need to:
1. [required] [description] — [why]
2. [optional] [description] — [why, and that it's skippable]

Want me to proceed with all of these, or skip the optional ones?"
```

**Rules:**
- Required delegations cannot be skipped (user can't skip brainstorm when no spec exists)
- Optional delegations are offered, not imposed
- Present in dependency order (brainstorm before UX, since UX needs the spec)
- If NO delegations trigger (spec exists, signals are clean), skip Turn 3 entirely
- After user confirms, execute delegations sequentially
- Each delegation invokes the full target skill (it runs its own process)
- Collect artifacts into `.lets/runs/develop-feature/<run_id>/upstream/`
- Verify each artifact has `status: approved` before proceeding

**After all delegations complete:**

```
"Design exploration complete. I have:
- [list artifacts received]

Moving to grounding in the repo context and planning the implementation."
```

Then proceed to Stage 1.

## Signal Detection Protocol

Run these checks during Turn 2 (after intent confirmed):

### no_approved_spec
```
1. Check .lets/runs/ for existing spec.md with status: approved
2. Check if lets spec export matches the feature
3. Check if user referenced a ticket/PRD with acceptance criteria
4. If none found → signal fires
```

### ux_surface_detected
```
1. Does the request mention: UI, frontend, page, component, form, modal, dialog,
   user flow, screen, layout, design, style, responsive, accessibility?
2. Do target files live in: src/components/, src/pages/, src/views/, src/ui/,
   app/, frontend/, client/, or similar UI directories?
3. If yes to either → signal fires
```

### competitive_context_needed
```
1. Does the user mention competitors, alternatives, "how do others do this"?
2. Is this a net-new product surface with no existing pattern to follow?
3. If yes to either → signal fires
```

### persona_validation_needed
```
1. Does the request introduce a new user-facing concept or workflow?
2. Does the user mention target audience, segments, or "who is this for"?
3. If yes to either → signal fires
```

### prd_grooming_needed
```
1. Did the user paste raw partner/customer feedback?
2. Is the request an unstructured feature dump without acceptance criteria?
3. If yes to either → signal fires
```

## Phase 0 Skip Conditions

Phase 0 Turn 1 (intent echo) is NEVER skipped. The user always sees a reflection.

Phase 0 can be shortened to Turn 1 only when ALL of:
- An approved spec exists AND
- The user's request directly names the spec/feature AND
- Zero optional signals fire AND
- User has previously set control level for this run (resumption case)

In this case, after Turn 1 confirmation, proceed directly to Stage 1.

## Error Handling

- If user rejects intent echo → ask "What did you mean?" and re-echo
- If user rejects control recommendation → accept their choice, document it
- If user rejects delegation plan → proceed without optional delegations; required ones cannot be skipped (explain why)
- If delegated skill fails or produces draft (not approved) artifact → pause, ask user how to proceed
- If user says "just do it" or "skip all this" → set control to autonomous, but still require spec (delegate brainstorm in light mode)
