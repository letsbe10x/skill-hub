---
artifact_type: spec
produced_by: lets-brainstorm
produced_at: 2026-05-21T00:00:00Z
status: approved
approval_source: user
---

# lets-build-ui: Self-Contained Design Intelligence — Light Spec

**Date:** 2026-05-21
**Mode:** Light
**Status:** Approved
**Author:** cogsmith-ai

---

## Problem

`lets-build-ui` Step 3 (design intelligence) delegates entirely to an external `uipro` CLI
or falls back to unstructured brainstorm. This creates a hard external dependency with no
guaranteed fallback quality. The skill also lacks stack-specific guidance, explicit
breakpoints, inline UX rules, and chart/dashboard coverage — all present in the
`ui-ux-pro-max` reference implementation. The goal is to make the skill fully self-contained
by embedding curated design intelligence in companion reference files, while keeping the core
SKILL.md lean (~250 lines).

## Approach

Add a `references/` subdirectory (alongside existing references) with 7 new files:
`product-types.md`, `styles.md`, `fonts.md`, `ux-rules.md`, `stacks.md`, `breakpoints.md`,
`charts.md`. Rewrite Step 3 in SKILL.md to perform deterministic lookup against these files
rather than shelling out to uipro or brainstorm. Add explicit breakpoints to Step 2
(responsive audit). Add conditional chart step to Step 7. Remove `uipro_sidecar.md` and
`fallback_design_intelligence_prompt.md` references from the process text (files can remain
for legacy). Bump version to 0.7.0. Update forge baseline.

## Success Criteria

- Step 3 references only `references/product-types.md`, `references/styles.md`,
  `references/fonts.md`, `references/stacks.md` — no uipro CLI dependency
- `references/ux-rules.md` contains ≥20 prioritized named rules with WCAG/HIG/MD citations
- `references/product-types.md` covers ≥20 representative product categories
- `references/breakpoints.md` names 375/768/1024/1440 explicitly
- `references/charts.md` covers ≥10 chart types
- `forge check` structural_score ≥ 0.606 (no regression)

## Testing Approach

- **Manual:** invoke skill on a sample request ("build a landing page for a wellness spa"),
  confirm agent reads product-types.md and returns a concrete design system output
- **forge:** `forge check lets-build-ui/SKILL.md` passes with no ratchet regression
