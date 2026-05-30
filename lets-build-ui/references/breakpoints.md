---
purpose: Standard responsive breakpoints and mobile-first rules for the evidence gate
lookup-by: Breakpoint name
---

# Breakpoints Reference

## Standard Breakpoints

Test and verify at all four breakpoints unless the product is explicitly desktop-only or native mobile.

| Name | Width | Primary Target | Common Issues to Check |
|------|-------|---------------|----------------------|
| mobile-sm | 375px | iPhone SE, small Android | Overflow, touch targets < 44px, hidden CTAs, font too small |
| tablet | 768px | iPad portrait, large Android | Column collapse, nav behavior, image sizing |
| laptop | 1024px | iPad landscape, small laptop | Side-by-side layout, sidebar behavior |
| desktop | 1440px | Standard desktop/laptop | Max-width container, wide-screen whitespace |

## Mobile-First CSS Pattern

```css
/* Mobile base (no media query) */
.component { ... }

/* Tablet and up */
@media (min-width: 768px) { .component { ... } }

/* Laptop and up */
@media (min-width: 1024px) { .component { ... } }

/* Desktop and up */
@media (min-width: 1440px) { .component { ... } }
```

## Tailwind Equivalents

```
Default (mobile):   no prefix
sm: 640px           not in standard 4-point set — use sparingly
md: 768px           → tablet
lg: 1024px          → laptop
xl: 1280px          → between laptop and desktop
2xl: 1440px+        → desktop (add to tailwind.config if needed)
```

## Responsive Audit Checklist (Step 2)

For each breakpoint, verify:

- [ ] No horizontal scroll
- [ ] All CTAs visible and tappable (≥ 44px)
- [ ] Typography legible (body ≥ 16px)
- [ ] Images not stretched or cropped unexpectedly
- [ ] Navigation accessible (hamburger on mobile opens correctly)
- [ ] Forms single-column on mobile, inputs full-width
- [ ] Tables either scroll horizontally or reflow to card layout
- [ ] Modal/sheet fits viewport with dismiss affordance visible

## Container Max Widths (Convention)

```
Content:  max-width: 1200px, centered, padding: 0 1.5rem
Prose:    max-width: 72ch (readable line length)
Narrow:   max-width: 600px (forms, auth, focused flows)
Wide:     max-width: 1400px (dashboards, full-bleed layouts)
```
