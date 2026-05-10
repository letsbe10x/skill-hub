# Skill Shapes

Use this chooser before drafting a new skill or heavily reshaping an existing one.

Pick the closest shape first. Only mix patterns when there is a clear reason — say which shape is primary and which behaviors are borrowed secondarily.

---

## Workflow Orchestrator

**Use when:**
- the skill coordinates a multi-step delivery or investigation lane
- the skill routes between stages, checkpoints, or decision points
- the main value is process shape, not one tool or one output artifact

**What to learn from analogs:**
- how they describe stage routing and boundaries
- how they keep `SKILL.md` thin while delegating details to `references/`
- how they avoid collapsing several workflows into one vague lane

**Expected structure:**
- thin `SKILL.md` with routing boundaries and stage flow
- detailed procedures in `references/`
- optional `assets/` for stage artifacts
- skill-local `scripts/` only when the helper is skill-specific
- an explicit intake card and at least one checkpoint approval step for non-trivial work
- a clear artifact/memory contract (where evidence lives when done)
- a structured-first output contract (Observed/Evidence before Inferred/Recommendations)

**Common anti-patterns:**
- turning the skill into a long wall of instructions instead of a thin orchestrator
- embedding repo-wide runtime logic that belongs in a shared surface
- overlapping heavily with another workflow lane without updating boundary checks
- chat-only "memory" with no artifacts, making the workflow brittle across interruptions

---

## Tool Wrapper

**Use when:**
- the skill primarily teaches the agent how to use one CLI or API surface
- the boundary is about task/tool fit rather than multi-stage workflow ownership
- the skill depends on command patterns, schema discovery, or query shaping

**What to learn from analogs:**
- how they explain task/tool fit directly
- how they separate command guidance from workflow orchestration
- when templates help more than long narrative instructions

**Expected structure:**
- concise `SKILL.md` focused on when to reach for the tool
- detailed command guidance or schemas in `references/`
- no extra templates unless the tool regularly emits reusable artifacts
- promote reusable executable behavior to a shared surface when it exists
- a structured-first output contract (Observed/Evidence before Inferred/Recommendations)

**Common anti-patterns:**
- turning a tool wrapper into a general workflow lane
- burying command semantics in the main skill body instead of `references/`
- hard-coding machine-local or repo-local paths into portable instructions

---

## Document Synthesizer

**Use when:**
- the skill turns evidence into a maintained written artifact
- the main output is a doc, rules file, ADR, PRD, README, or runbook
- the skill boundary is defined by artifact type more than by runtime tool choice

**What to learn from analogs:**
- how they gather source evidence before drafting
- how they define an explicit output artifact
- how they avoid turning into a generic writing assistant

**Expected structure:**
- `SKILL.md` explains source gathering, synthesis boundary, and output contract
- `references/` holds checklists, source hierarchy, and drafting rules
- `assets/` holds reusable output skeletons when they speed up consistent authoring
- a structured-first doc plan card (intent, sources, outline) before prose drafts

**Common anti-patterns:**
- broadening the skill into generic "help me write things"
- mixing documentation synthesis with implementation workflow ownership
- treating one-off prose guidance as a reason to create a new shared skill

---

## Meta / Bootstrap

**Use when:**
- the skill helps create, scaffold, bootstrap, govern, or reshape other shared surfaces
- the user is defining structure, contracts, or repo-wide enablement rather than executing a single lane
- the skill may need research or comparative reasoning before drafting

**What to learn from analogs:**
- how they enable repo-wide adoption without losing a clear contract boundary
- how they combine scaffold helpers, references, and templates coherently
- how they connect authoring guidance to the host repo's validation and install surfaces

**Expected structure:**
- thin `SKILL.md` with strong decision rules and boundary language
- `references/` for contribution contract, shapes, eval gates, and research mode
- `scripts/` for deterministic scaffolding or validation helpers
- `assets/` for starter files or briefs
- a structured-first decision card (Observed vs Inferred + artifacts-first)

**Common anti-patterns:**
- inventing a brand-new structure when an existing bootstrap pattern already fits
- skipping repo-surface wiring because the skill is "just guidance"
- merging several adjacent meta responsibilities into one vague catch-all

---

## Decision Rule

If two shapes both seem plausible, choose the one that best answers:

1. What is the user really trying to accomplish?
2. What neighboring skill should NOT trigger?
3. What is the dominant output shape?

Only combine shapes when the dominant shape alone would be misleading. When you do combine them, say which is primary.

## Exemplar Rule

Treat local examples as exemplars, not pieces to blend together. Use this order:

1. find the closest structural match
2. borrow its boundary language
3. borrow one or two supporting patterns only when there is a concrete gap

If you are tempted to merge patterns from three or more skills, stop and re-check whether the new skill is too broad.
