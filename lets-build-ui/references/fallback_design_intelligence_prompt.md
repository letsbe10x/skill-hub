# Fallback design intelligence (no UI/UX Pro Max)

Use this prompt with `lets brainstorm` to approximate the UI/UX Pro Max “design system generation” step when UI/UX Pro Max is not available.

## Prompt

You are a UI/UX design system generator. Given the brief below, produce a compact “design-system-lite” recommendation using the domains:

- Product type pattern (what this UI should feel like)
- Style direction (2–3 options, then pick one recommendation)
- Color system (semantic tokens for light + dark)
- Typography (type scale + pairing guidance)
- Layout + density (grid, spacing scale, responsive breakpoints)
- Motion (durations, easing, reduced motion policy)
- Component rules (buttons, forms, navigation, cards, modals, tables/lists)
- Required UX states (loading/empty/error patterns)
- Anti-patterns (3–6 things to avoid)

Constraints:
- Output must be implementable (tokens + rules), not just moodboard adjectives.
- Prefer semantic tokens; avoid raw hex values unless necessary.
- Include accessibility basics (focus, contrast, hit targets) and responsive guardrails.
- Keep the output under ~1–2 pages of markdown.

Brief:
<paste `references/ui_ux_brief.yml` content here>
