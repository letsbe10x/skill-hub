---
name: lets-brainstorm
description: "Use BEFORE any creative work — creating features, building components, adding functionality, modifying behavior, or resolving any open design question. Canonical brainstorming skill for letsbe10x. Supports Full Mode (governance-gated spec) and Light Mode (express brainstorm for low-risk, self-contained ideation). Produces a user-approved spec and routes to the correct downstream skill."
metadata:
  author: cogsmith-ai
  version: "0.2.0"
  tags: [exploration, design, spec, architecture, decisions, ideation, creative-work]
lifecycle: draft
source: https://github.com/letsbe10x/skills/blob/main/lets-brainstorm/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - I have an idea
  - I want to build
  - let's build
  - help me think through
  - brainstorm
  - quick brainstorm
  - express brainstorm
  - how should we approach
  - should we use X or Y
  - what's the best way to
  - what are our options
  - help me decide
  - let's explore
  - what's the trade-off
  - I'm not sure how to
  - which approach
  - new feature
  - add a feature
  - create a component
  - build a component
  - add functionality
  - modify behavior
  - change the behavior
  - before I start coding
  - before we implement
goals:
  - explore
outcome_runtime:
  open_agency_zones:
    - exploration_strategy
    - approach_generation
    - design_synthesis
  governed_action_zones:
    - spec_content_claims
    - downstream_routing_decision
  allowed_moves:
    - challenge_initial_framing
    - decompose_large_scope
    - propose_alternative_approaches
    - withhold_routing_until_spec_approved
  hard_limits:
    - do_not_write_spec_before_approach_confirmed
    - do_not_route_before_spec_passes_validation
  required_decision_frames:
    - exploration_type_classification
    - approach_selection
    - downstream_routing
  validation_gates:
    - spec_completeness_gate
    - user_approval_gate
  mutation_policy: read_only
  human_checkpoint_triggers:
    - scope_decomposition_needed
    - approach_selection
    - spec_approval
    - routing_confirmation
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

# lets-brainstorm

Drive the `explore` goal: turn an unresolved question into a validated spec artifact, then route
to the right downstream skill based on what the exploration reveals.

**This is the canonical brainstorming skill for letsbe10x.** Use it for *any* creative work —
features, components, functionality, behavior changes, architecture, technology choices, or any
open design question. In this workspace it supersedes `superpowers:brainstorming`; do not invoke
that skill when `lets-brainstorm` is available.

## Modes

| Mode | When | Questions | Approaches | Spec sections |
|---|---|---|---|---|
| **Full** (default) | Architecture, features with multi-component scope, cross-team impact, anything with production risk | 4 question areas, one per message | 2–3 alternatives with trade-offs | All required sections |
| **Light** (express brainstorm) | Self-contained single-file idea, small utility, throwaway script, clearly low-risk change, or the user explicitly asks for a "quick" / "express" brainstorm | Up to 3 focused questions, may be batched | 1 recommendation + 1 alternative | Minimum set (see Phase 5) |

**Mode is declared at the end of Phase 1**, after classification. Default is **Full**.
Switch to Light only when the exploration type is `direct` AND no cross-boundary impact is
detected, OR the user explicitly requests express mode. **Both modes require a user-approved
spec before routing** — Light does not mean skipping the spec; it means writing a smaller one.

## Exploration Law

**NO SPEC WITHOUT A CONFIRMED APPROACH.**
**NO ROUTING WITHOUT A VALIDATED, USER-APPROVED SPEC.**
**NO LIGHT MODE WHEN SCOPE EXPANDS.**

If Phase 3 (exploration) is not complete, you cannot write the spec.
If the spec has not passed `validate_spec.py` and user approval, you cannot route.
If Light Mode discovers multi-component scope, cross-service data flow, or security/compliance
implications, **stop and escalate to Full Mode** — restart from Phase 3 with the full flow.

## Anti-patterns

- **Routing to lets-develop-feature without a spec** — a confirmed approach and validated spec are required before any implementation skill is invoked.
- **Asking multiple questions at once (Full Mode)** — one question per message in Full Mode. Light Mode may batch up to 3 focused questions.
- **Treating exploration type as obvious** — classify it in Phase 1. A "simple feature" may reveal itself as a product question once context is loaded.
- **Always routing to lets-create-plan** — the correct downstream skill depends on what the exploration reveals; see `references/routing-guide.md`.
- **Staying in Light Mode when scope grows** — if you discover multi-component impact, cross-boundary data flow, or compliance risk mid-exploration, escalate to Full Mode. Do not write a light spec for a heavy problem.
- **Using superpowers:brainstorming inside letsbe10x** — `lets-brainstorm` is the canonical skill in this workspace. Its Light Mode covers the same ground for low-risk ideation while preserving the spec + approval gates.

## When to Use

- Any creative work is beginning — features, components, added functionality, behavior modifications.
- The right approach, architecture, or solution is not yet agreed.
- A decision must be made before implementation can begin.
- A request is ambiguous enough that starting to build would risk rework.
- The user asks for a "quick brainstorm" on a small idea (use Light Mode).

## When Not to Use

- A spec and approach are already approved — invoke `lets-create-plan` directly.
- The change is a mechanical single-file edit with zero design decisions (rename a variable, bump a dependency, fix a typo).
- The request is product opportunity discovery from an existing solution or hypothesis — use `lets-opportunity-discovery`.
- You are in pure debugging / triage territory — use `lets-triage-issue` or `lets-triage-incident`.

---

## Phase 1 — Classify exploration type, select mode, and load repo context

**Classify the exploration before asking any questions.** The type determines which questions matter and where the exploration routes.

Read: existing specs, ADRs, and plans in `docs/`; recent commits; established patterns in the codebase.

Classify into one of:

| Type | Signal | Default downstream | Default mode |
|---|---|---|---|
| `feature` | New behaviour or component with clear implementation scope | `lets-create-plan` | Full |
| `architecture` | System-level decision affecting multiple components or teams | `lets-create-plan` | Full |
| `product` | Outcome is unclear; needs problem–solution fit before a spec makes sense | `lets-opportunity-discovery` | Full |
| `direct` | Small, well-bounded, immediately implementable after spec | `lets-spec-to-pr` | Light |

### Mode selection rules

- If exploration type is `direct` AND no signal of cross-boundary impact (single file or module, no schema change, no security/compliance surface) → **Light Mode**.
- If the user explicitly asks for "quick brainstorm", "express brainstorm", "keep it light", or similar → **Light Mode** (still honor escalation rules below).
- Otherwise → **Full Mode**.
- If any of these is present, force **Full Mode** regardless: security/compliance surface touched, migration required, public API change, multi-team ownership.

Present both the classification and the mode to the user before proceeding:

> "This looks like a **[type]** exploration. I'll run it in **[Light | Full]** mode and route to **[downstream skill]** once we have an approved spec. Does that sound right?"

Wait for confirmation. If the user disagrees with either the type or the mode, adjust. The user may *downgrade* Full → Light only when none of the force-Full conditions apply. They may always *upgrade* Light → Full.

---

## Phase 2 — Scope check

Assess whether this is a single coherent exploration or multiple independent ones.

If the request spans multiple independent subsystems (e.g. "build a platform with auth, billing, and analytics"), stop and propose decomposition:
- Name each sub-project.
- Clarify how they relate and in what order they should be explored.
- Confirm with the user which one to start.

Each sub-project runs its own full brainstorm → spec → downstream cycle.

**Light Mode note:** if Phase 2 requires decomposition, escalate to Full Mode before continuing. A request large enough to need decomposition is not a Light exploration.

---

## Phase 3 — Exploration

### Full Mode

Ask one question per message. Prefer multiple-choice when options are enumerable.

Cover, in this order:
1. **Problem** — what specific problem does this solve, and for whom? What breaks or degrades without it?
2. **Constraints** — performance, compatibility, deployment environment, security, team bandwidth.
3. **Success criteria** — what does done look like? How would you know it's working?
4. **Scope boundary** — what is explicitly out of scope for this exploration?

Stop asking when you have enough to propose distinct, concrete approaches.

**Propose 2–3 approaches** with explicit trade-offs. Lead with your recommendation and state why. Get the user to confirm a direction before moving to Phase 4.

### Light Mode

Ask up to 3 focused questions. They MAY be batched in a single message if each is short and independent. Cover only what is load-bearing:

1. **Problem + who it serves** — one line each.
2. **Success signal** — how will you know it worked?
3. **Any constraint you already know** — skip if none.

Then propose **1 recommended approach plus 1 alternative** in one message with one-line trade-offs. Get confirmation.

**Escalation watch:** if answers reveal multi-component scope, schema migration, security/compliance surface, or cross-service data flow → stop, tell the user "this is larger than it looked — switching to Full Mode" and restart Phase 3 in Full Mode.

---

## Phase 4 — Design convergence

### Full Mode

With the approach confirmed, work through the design section by section. Present each section, ask whether it looks right, and wait before continuing.

| Section | What to cover |
|---|---|
| Architecture | Components, responsibilities, boundaries |
| Data model | Entities, relationships, storage — omit if stateless |
| Component design | Each unit's interface, dependencies, isolation invariant |
| Data flow | Request → processing → response, including error paths |
| Error handling | How failures surface and recover |
| Testing approach | Unit, integration, and acceptance scenarios by name |

Design for isolation: each component has one purpose, communicates through defined interfaces, and can be understood without reading its internals.

In existing codebases: follow established patterns. Include targeted improvements only when they directly serve this goal.

### Light Mode

Present a single condensed design block in one message covering:
- **Approach** — one paragraph describing what we'll build and why.
- **Touch points** — the files/modules that will change (must stay small; if the list grows, escalate).
- **Testing** — named scenarios, unit or integration.

Ask "Does this look right?" and wait for confirmation before Phase 5.

---

## Phase 5 — Spec production and validation

### Full Mode

Use `assets/spec-template.md` as the starting structure. Fill every applicable section. Remove sections that genuinely do not apply. Leave no placeholders — TBD is a gate failure.

Save to:
```
docs/specs/YYYY-MM-DD-<topic>.md
```

Then validate:
```bash
python3 skills/lets-brainstorm/scripts/validate_spec.py docs/specs/YYYY-MM-DD-<topic>.md
```

### Light Mode

Use `assets/light-spec-template.md` as the starting structure. Required sections:

```
## Problem
## Approach
## Success Criteria
## Testing Approach
```

`## Open Questions` is optional in Light Mode, but if present all items must be resolved
(same rule as Full Mode). Fill each section concisely (a few sentences to a short paragraph).
Leave no placeholders.

Save to:
```
docs/specs/YYYY-MM-DD-<topic>.md
```

Validate with the `--light` flag:
```bash
python3 skills/lets-brainstorm/scripts/validate_spec.py --light docs/specs/YYYY-MM-DD-<topic>.md
```

### Both modes

Fix every reported issue and re-run until the validator exits 0. Do not proceed with a failing spec.

Commit:
```bash
git add docs/specs/YYYY-MM-DD-<topic>.md
git commit -m "spec: <topic>"
```

---

## Phase 6 — User review gate

> "Spec written and committed to `<path>`. Please review it — let me know if you want any changes before I route to the next step."

Wait for explicit approval. If changes are requested, update the spec, re-run `validate_spec.py`, and ask again.

---

## Phase 7 — Route to downstream skill

Consult `references/routing-guide.md` to confirm the correct downstream skill for the exploration type classified in Phase 1. Present the routing decision to the user, then invoke the target skill.

---

## Outputs

- Output: Committed spec at `docs/specs/YYYY-MM-DD-<topic>.md` — validated and user-approved
- Output: Routing decision logged (exploration type → downstream skill)
- Done when: `validate_spec.py` exits 0, user has approved, and the downstream skill has been invoked
