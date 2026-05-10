# Skill Authoring Guide

Use this loop when creating or revising a skill in skill-hub.

## 0. Start With an Intake Card

Before touching any file, pin down:

- new skill vs update to an existing one
- target skill name and nearest neighboring skills (routing boundary)
- expected outputs — what exists on disk when done
- mutation posture — read-only, additive, or writes to external state
- one blocking question if anything is unclear (ask one at a time)

For workflow-shaped skills, also confirm: does this skill need an explicit approval checkpoint before any mutation step?

## 1. Capture Intent

Lock in four facts before drafting:

- what the skill enables an agent to do
- when it should trigger instead of a neighboring skill
- what output or artifact the user should expect (and where it lives)
- whether the work belongs in a shared skill or stays in a narrower local surface

Trigger boundaries must be specific enough to exclude nearby skills. If the request sounds like "compile coding rules" or "generate docs", prefer an existing skill over a new overlapping surface.

If the scope is still fuzzy, switch to discovery mode first. See `discovery-mode.md`.

## 2. Find the Nearest Analog

Read 2–3 existing skills with a similar shape before drafting. Use `skill-shapes.md` as the chooser — pick by shape, not by keyword:

- workflow orchestrator — multi-step delivery or investigation lane
- tool wrapper — teaches the agent how to use one CLI or API surface
- document synthesizer — turns evidence into a maintained written artifact
- meta/bootstrap — scaffolds, governs, or reshapes other shared surfaces

Prefer reusing an established pattern over inventing a new style. Borrow from the closest skill first, then justify any intentional deviation.

When choosing analogs, prefer:
1. closest structural match
2. cleanest boundary language
3. thinnest successful `SKILL.md`

## 2a. Discovery Mode (When Needed)

Switch into discovery mode when the request is about brainstorming, landscape research, or "what should exist" rather than "write the skill now". See `discovery-mode.md` for the full flow.

Discovery mode produces a brief covering: problem framing, local skill priors, external comparables, architecture options, recommended approach, and proposed skill boundary.

## 3. Choose the Right Structure

Before writing files, decide where each piece of behavior belongs:

- repeated deterministic logic used only by this skill → `scripts/`
- reusable runtime others may call directly → promote to a shared surface
- deep procedures, schemas, or policy notes → `references/`
- copyable starter files or output skeletons → `assets/templates/`

Keep `SKILL.md` thin. Reach for bundled resources only when they reduce repetition. One command or short shell sequence stays in prose — do not add a script for it.

Prefer file-backed artifacts over chat-only state. Anything that must survive an interruption goes to disk.

## 4. Draft the Skill

Write `SKILL.md` as a thin orchestrator:

- `name` must match the folder name exactly
- `description` must explain both what it does and when to use it
- body focused on workflow stages, routing decisions, and boundaries
- include a type-aware `## Outputs` section (structured-first: Observed/Evidence vs Inferred/Recommendations, or Ideation-first for research shapes)
- deep procedures and long checklists go into `references/`, not inline
- use `{PLACEHOLDER}` style tokens — never angle-bracket style

Default to the repo's explicit/manual posture for workflow skills. Keep descriptions concrete enough that trigger fixtures can exercise them.

If discovery mode ran first, draft from the approved recommendation, not from raw notes.

Before expanding the skill, run the pressure test in `simplicity-check.md`. Prefer the simplest shape and smallest file surface that still protects the boundary.

## 5. Wire Repo Surfaces

For a new skill, update every affected surface in the same change when those surfaces exist:

- `Makefile` — add an install target
- `README.md` — add a catalog row
- trigger fixtures — add or update `tests/skill-triggers/{skill-name}.json`
- install smoke coverage when the skill gets its own `make` target

These are part of the skill-hub contribution contract, not optional polish.

## 6. Run Quality Gates

See `quality-checklist.md` for the full gate list. Minimum bar for a new skill:

```bash
# structural gate — must pass before opening a PR
forge check lets-{name}/SKILL.md --baselines-dir .forge/baselines

# smoke bench — confirms the skill routes correctly
forge bench lets-{name} --suite smoke
```

If routing boundaries changed, decide whether trigger fixtures are enough or whether a versioned boundary dataset is needed. See `evaluation-gate.md`.

## 7. Simplify Before Calling It Done

Run through `simplicity-check.md`. The most common failure mode is overbuilding:

- too many phases
- too many helper files
- a description broad enough to trigger for neighboring skills
- scripts for tasks that should stay as plain instructions

Cut before you add.

## 8. Present the Result

Summarize:

- what skill was added or changed
- whether discovery mode ran and what it concluded
- why this shape was chosen
- which repo surfaces were updated
- what validation ran
- any remaining routing or boundary risks

End with one explicit challenge statement: why this skill boundary could still be wrong, and what evidence would make you narrow, broaden, or merge it with a neighboring skill.

## Rules

- Keep the skill portable — never hard-code repo paths inside `SKILL.md`
- Do not add `README.md` or non-canonical root files inside the skill folder
- Prefer existing skill evidence over generic advice when making structure decisions
- If a workflow boundary changed, say explicitly whether trigger fixtures or eval datasets need updates
- Do not silently skip Makefile or README surfaces that skill-hub treats as part of its contribution contract
- For workflow skills: include an explicit intake card and at least one checkpoint approval step before broad mutations
- Prefer file-based artifacts for durable state — do not rely on chat residue for anything that must survive an interruption
