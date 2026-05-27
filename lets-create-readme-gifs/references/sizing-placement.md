# Sizing & Placement

The dimensions of the demo and where it sits in the README — both copied
from what consistently works in the field, with the reasoning.

## Source vs displayed dimensions

VHS renders at a *source* resolution. The README displays the GIF at a
specified `width` in HTML. These are different numbers.

**For terminal demos (the common case):**

| Use case | VHS source size | README `<img width=>` |
|---|---|---|
| Single-line CLI demo (gum, mods style) | 800×400 | 600 |
| Multi-line install/output demo (skill-hub style) | 1000×420 | 900 |
| Long-output demo (>15 lines visible at once) | 1200×600 | 900 |
| Compact "right of tagline" layout (starship style) | 800×500 | 400 (floated right) |

Why source > displayed: high-DPI sharpness. Rendering at 1000×420 and
displaying at 900px means the GIF looks crisp on Retina/4K screens.

**For product-UI demos:**

| Use case | Source size | Displayed |
|---|---|---|
| Single-pane web app | 1280×800 | 900 |
| Side-by-side editor (Excalidraw style) | 1600×900 | 900 |

## Why 600–900px is the sweet spot

| Width | Effect |
|---|---|
| <600px | Demo gets dominated by surrounding markdown — reader's eye doesn't stop on it |
| 600–900px | Sweet spot — gum, mods, vhs, freeze, oterm all here |
| 100% / full-bleed | Heavy, pushes value-prop paragraph off-screen, looks unpolished on wide monitors |
| >1000px displayed | Triggers GitHub's "container overflow" on mobile — README scrolls horizontally |

## Aspect ratio

| Content shape | Recommended ratio | Examples |
|---|---|---|
| Short CLI command + 5-line output | 16:9 (1000×560) | gum, mods |
| Install/listing demo (12+ lines) | 1000×420 (~2.4:1) | skill-hub, gh CLI |
| One-screen TUI app | 16:10 (1280×800) | lazygit, lazydocker |
| Single-line transformation demo | 2:1 (1000×500) | freeze |

Avoid 1:1 squares — they read like product screenshots, not demos.

## Placement in the README

Line numbers in the rendered README, top-down:

```
Line 1-3:   <h1 align="center">project-name</h1>
            <p align="center"><em>One-line tagline.</em></p>

Line 5-7:   <p align="center"><img src="assets/demo.gif" width="900"></p>     ← DEMO HERE

Line 9-15:  <p align="center"> [badge 1] [badge 2] [badge 3] [badge 4] </p>

Line 17-22: <p align="center"> Install · Bundles · Why · Catalog </p>

Line 24:    ---  (horizontal rule)

Line 26+:   existing README body
```

This places the demo within the first ~15 lines — well inside the mobile
fold. Matches the placement in `oterm` (line 7), `zellij` (line 13),
`vhs` (line 14), `gum` (line 16). `lazygit` and `tRPC` go further down
(~line 28) but still work because they're already known projects.

## Anti-patterns

- **GIF before the title.** Reader doesn't know what they're looking at.
- **GIF after the badges.** Pushes the demo below the mobile fold.
- **Bare markdown image syntax** (`![](demo.gif)`) — renders at GIF's source
  width, which is usually too big. Always wrap in
  `<p align="center"><img width="...">`.
- **No `alt` text.** Accessibility miss; also costs you SEO.
- **`width="100%"`.** Full-bleed reads as heavy. Cap at 900.
- **Different sizes on mobile vs desktop without `<picture>`.** If you
  bother to support both, use `<picture>` with media queries.

## When to use `<picture>` for responsive sizing

Use when:
- The desktop demo is >800px wide and feels too dense on mobile
- You have both a light-theme and dark-theme version

Don't use when:
- One image works fine at all sizes (90% of the time — start here)

Example (the soft-serve pattern):

```html
<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/demo-dark.gif">
    <source media="(prefers-color-scheme: light)" srcset="assets/demo-light.gif">
    <img src="assets/demo.gif" width="900" alt="...">
  </picture>
</p>
```
