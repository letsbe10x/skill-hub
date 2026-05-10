# Skill Contract

Rules for every skill contributed to skill-hub. Read before adding or restructuring a skill.

## Canonical Layout

Each skill folder contains only:

- `SKILL.md` — required
- `references/` — optional, for deep procedures, schemas, and policy notes
- `scripts/` — optional, for deterministic helpers tied to this skill only
- `assets/` — optional, for copyable templates and starter files

Do not add `README.md`, `docs/`, ad hoc `templates/`, or stray root files inside the skill folder.

## Frontmatter Rules

- `name` must match the folder name exactly
- folder name follows the `lets-{verb}` convention
- `description` must explain both the capability and the trigger context
- `metadata.version` is required on any skill with `lifecycle: published`
- keep the description concise enough to be maintainable but explicit enough for trigger tests

## Thin-Orchestrator Rule

`SKILL.md` carries:

- purpose
- workflow stages
- trigger boundaries
- required validations
- links to skill-local references or templates

Move deep procedures and long examples into `references/`. The body should be readable in under two minutes.

## Where Logic Lives

Use this table before adding any file:

| Situation | Home |
|---|---|
| Repeated deterministic transformation used only by this skill | `scripts/` |
| Complex parsing, file I/O, or validation for this skill | `scripts/` |
| Shared runtime behavior multiple skills may call directly | promote to a shared surface |
| One command or one short shell sequence | keep in `SKILL.md` prose |
| Deep guidance, schemas, or policy notes | `references/` |
| Copyable starter files or output skeletons | `assets/` |
| Generic writing or formatting guidance | keep in prose, do not add a script |

If the script would exist only to wrap a single simple command, do not create it.

## Shared Surface Updates

When adding a new skill, update every relevant shared surface in the same change:

- `Makefile` — install target
- `README.md` — catalog row
- trigger fixture — `tests/skill-triggers/{skill-name}.json`
- install smoke coverage when the repo treats the install target as a stable contract

Skipping these usually leaves the skill undiscoverable or unmaintained.

If the new skill introduces a meaningful routing boundary overlap with an existing skill, also consider adding a versioned routing-eval dataset when the repo supports it.

## What Not To Do

- do not hard-code repo-traversal paths inside `SKILL.md`
- do not duplicate long reference content in both `SKILL.md` and `references/`
- do not create skills for team-only schemas or one-off local knowledge
- do not add a new script just to wrap a simple existing command
- do not add non-canonical root files inside the skill folder
