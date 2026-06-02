# Design System Storage (MASTER + Overrides)

When UI work spans multiple pages/flows, keep a simple, enforceable “design-system-lite” in the target repo so future work stays consistent.

## Recommended structure (in the target repo)

- Create a folder named `design-system`.
- Inside it, keep a `MASTER.md` file as the global source of truth.
- Add a `pages` subfolder with one markdown file per page/flow (named after the page/flow).

## Retrieval rule

- If a page override exists, it **wins** for that page/flow.
- Otherwise, use `MASTER.md`.

## Why this helps

- Keeps token decisions stable across iterations.
- Allows justified exceptions without forking the whole system.
- Makes reviews easier (“does this change violate MASTER?”).
