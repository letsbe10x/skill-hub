# Priority Checks (what to fix first)

When time is limited, use this order to avoid “pretty but broken” UI work.

| Priority | Category | Must-have checks | Common anti-patterns |
|---:|---|---|---|
| 1 | Accessibility | Visible focus, keyboard nav, labels, contrast | Removing focus rings, icon-only buttons with no label |
| 2 | Touch + interaction | Touch-safe targets, clear pressed/disabled/loading states | Hover-only affordances, tiny icon buttons |
| 3 | State coverage | Loading/empty/error for touched surfaces | Blank screens, errors with no recovery |
| 4 | Layout + responsive | No horizontal scroll, stable headers/footers, readable typography | Fixed pixel layouts, content hidden behind fixed bars |
| 5 | Token consistency | Semantic tokens for color/type/spacing | Random hex values and one-off spacing |
| 6 | Information hierarchy | Clear primary CTA, scanning-friendly headings/spacing | CTA buried, “everything is loud” |
| 7 | Forms + feedback | Visible labels, inline validation, actionable errors | Placeholder-only labels, errors only at top |
| 8 | Navigation | Clear current location, predictable back behavior | Unclear active states, surprise navigation |
| 9 | Motion | Subtle durations/easing, reduced motion support | Over-animated UI, layout-janky animations |
| 10 | Performance | Avoid layout shift, no jank on scroll | Animating layout props, heavy effects everywhere |
