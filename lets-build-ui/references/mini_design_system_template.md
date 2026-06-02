# Mini Design System (design-system-lite)

Goal: a small, enforceable token + component rule set that keeps UI consistent across pages.

## Direction v1

- Product type:
- Style keywords:
- Density:
- Motion level:
- Brand voice:

## Tokens (semantic, not raw)

### Color

- `color.surface`
- `color.surface.raised`
- `color.text.primary`
- `color.text.muted`
- `color.border`
- `color.primary`
- `color.primary.foreground`
- `color.destructive`
- `color.success`
- `color.warning`

Dark mode:
- Strategy: tonal palette (no pure inversion)
- Contrast targets: text ≥ 4.5:1, non-text UI ≥ 3:1

### Typography

- Base font size:
- Body line-height:
- Type scale: (e.g. 12/14/16/18/24/32)
- Heading font:
- Body font:
- Numerals: tabular for tables/prices/timers

### Spacing + Layout

- Spacing scale: (e.g. 4/8/12/16/24/32/48)
- Container widths:
- Breakpoints:

### Radius + Elevation

- Radius scale:
- Shadow/elevation rules:

### Motion

- Durations: (e.g. 150–300ms micro, ≤400ms transitions)
- Easing: (enter ease-out, exit ease-in)
- Reduced motion behavior:

## Component Rules (must be consistent)

### Buttons

- Variants: primary / secondary / ghost / destructive
- Default size + hit target: ≥ 44×44px (or equivalent)
- Focus state: visible, not removed
- Loading: spinner + disabled interaction

### Forms

- Labels: visible (no placeholder-only labels)
- Errors: adjacent to fields + actionable copy
- Keyboard: logical tab order + focus management for dialogs

### Navigation

- Current location indicator:
- Back behavior:
- Mobile nav pattern:

### States (required)

- Loading:
- Empty:
- Error:

## “Done” Criteria (minimum)

- Tokens applied; no raw hex/spacing scattered in components.
- Keyboard focus works; contrast meets targets.
- Responsive check passes at target widths.
- At least one representative flow tested end-to-end.
