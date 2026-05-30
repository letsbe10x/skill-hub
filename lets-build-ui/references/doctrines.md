# Doctrines (front-end quality)

These doctrines keep “UI polish” work from devolving into random tweaks.

## Evidence before changes

- Do not recommend UI changes without at least one of: screenshots, a URL, a local dev server, or a design mock.
- Separate observation from inference. Log what you saw and why it matters.

## Direction before tokens

- Lock **Direction v1** (style keywords, density, motion level, brand voice) before touching shared styling.
- If the direction changes mid-stream, treat it as a new iteration and update the brief + token spec explicitly.

## Architecture before polish (when UX is unclear)

- If users can’t find things, flows are confusing, or states surprise the user: do not “polish” first.
- Map the **navigation + IA** and **data flow + states** (see `ux_architecture.md`) to reduce structural confusion before cosmetic changes.

## Tokens before components

- Prefer semantic tokens (e.g. `color.surface`, `color.text.primary`) over raw values in components.
- Change order: tokens → primitives → components → pages/flows.

## Purpose alignment per work package

- Every work package must state which pain point / north-star task it improves (from the brief).
- If a change doesn’t improve a north-star task, it must be explicitly justified (e.g., accessibility fix, performance fix).

## Accessibility is a hard gate

- Visible focus is non-negotiable.
- Hit targets must be touch-safe.
- Contrast must meet minimum targets (treat failures as “must fix”).

## Shipping discipline

- Always include state coverage (loading/empty/error) for touched surfaces.
- Use a final checklist pass (see `ui_quality_gate.md`) and run `lets verify-ready` when you need a hard evidence checkpoint.

## Packs (optional but recommended)

If you are operating inside the letsbe10x ecosystem, install the engineering bundle packs for stronger defaults:

```bash
lets pack install --bundle engineering
```

This brings in the standard engineering/service/delivery/observability context packs referenced across the skills library.
