# Simplicity Check

Run this before adding phases, helper files, or new abstractions to a skill.

## Pressure Test

Ask these questions in order:

1. Is this the simplest shape that still fits the problem?
2. Is any new section teaching something the model already knows?
3. Does each reference file carry one real concern, or is it moving clutter out of `SKILL.md`?
4. Is a helper script truly repeated, deterministic, or fragile enough to justify itself?
5. Is this skill's boundary clearly narrower than the nearest neighboring skill?

If you hesitate on more than one question, simplify before continuing.

## Common Anti-Patterns

Cut or rework the skill if you see these:

- a generic description that could trigger for several neighboring skills
- more phases than the task actually needs
- reference files created only to restate obvious guidance
- scripts that exist only to wrap a simple shell command
- multiple shapes mixed together without a clear primary pattern
- long policy or formatting instructions the model can already follow naturally

## Minimalism Rules

- Prefer one strong exemplar over averaging several skills together
- Prefer one concise reference over several with weak separation
- Prefer one deterministic helper over repeated ad hoc shell logic
- Prefer no script over a script that adds ceremony without reliability
- Prefer a narrower skill boundary with clear routing over a broad catch-all skill

## Final Challenge

Before calling the skill done, write one sentence answering:

> "This skill boundary could be wrong if ..."

Then state what evidence would change your recommendation — what would make you narrow, broaden, or merge this skill with a neighbor.

Include this as the closing challenge statement in your result summary.
