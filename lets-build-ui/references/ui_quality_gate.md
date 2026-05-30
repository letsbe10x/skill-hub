# UI Quality Gate (ship checklist)

Use this as the final pass before claiming UI work is “done”.

## Accessibility (must-pass)

- Keyboard navigation works (including modals/menus).
- Visible focus states exist and are not removed.
- Interactive hit targets are at least ~44×44px (or equivalent).
- Forms have labels; errors are adjacent and actionable.
- Color contrast meets minimum targets (text ≥ 4.5:1; non-text UI ≥ 3:1).

## Responsiveness (must-pass)

- No horizontal scrolling at target mobile width.
- Layout works at smallest mobile and common desktop widths.
- Touch interactions don’t rely on hover-only cues.
- Fixed headers/footers don’t hide content; safe areas respected where relevant.

## Visual Consistency (must-pass)

- Semantic tokens used (color/spacing/type), not random one-offs.
- One style direction (no mixed “design languages”).
- Spacing rhythm is consistent across sections and components.
- Button/link hierarchy is clear (primary vs secondary is obvious).

## UX States (must-pass)

- Loading states exist for async surfaces.
- Empty states exist and are helpful (not blank).
- Error states exist with a recovery path.

## Performance (should-pass)

- Images are optimized and sized; avoid layout shift where possible.
- Avoid heavy animations; respect reduced motion.
- No obvious interaction jank (especially on mobile).
