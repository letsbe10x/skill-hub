---
purpose: UI style reference — description, best-fit use cases, key effects, and what to avoid
lookup-by: Style
---

# UI Styles Reference

Use this during Step 3 to validate or refine the style recommendation from `product-types.md`.
Each style includes best-fit industries, key visual characteristics, implementation effects,
and anti-patterns specific to that style.

## General Styles

| # | Style | Best For | Visual Characteristics | Key Effects | Avoid |
|---|-------|----------|----------------------|-------------|-------|
| 1 | Minimalism / Swiss Style | Enterprise SaaS, dashboards, documentation | White space, strict grid, monochrome + 1 accent | Subtle hover, clean transitions 150ms | Decorative elements, heavy shadows |
| 2 | Neumorphism | Wellness, meditation, health apps | Soft extruded surfaces, monochrome palette | Soft box-shadow inset/outset, no harsh borders | Dark mode, low contrast (fails WCAG) |
| 3 | Glassmorphism | Modern SaaS, fintech dashboards | Frosted glass card, blur backdrop, translucency | backdrop-filter blur 12-20px, subtle border | Overuse on text-heavy surfaces |
| 4 | Brutalism | Design portfolios, artistic projects | High contrast, raw typography, visible grid | Bold hover color swap, no animation | Readability-sacrificing layouts |
| 5 | Neubrutalism | Gen Z brands, startups | Bold black borders, flat color fills, offset shadows | Hard box-shadow offset, color swap on hover | Subtle / soft aesthetics |
| 6 | Claymorphism | EdTech, children's apps, playful SaaS | Inflated 3D-ish shapes, vivid pastel fills | Smooth scale on hover, bounce spring | High-stakes / financial contexts |
| 7 | Soft UI Evolution | Modern enterprise, wellness SaaS | Soft shadows, subtle depth, organic shapes | transition 200-300ms, gentle scale 1.02 | Harsh borders, dark mode by default |
| 8 | Vibrant & Block-based | Startups, creative agencies | Bold color blocks, strong contrast, grid | Color block swap on hover | Muted palettes, serif-only |
| 9 | Aurora UI | Modern SaaS, creative agencies | Gradient mesh backgrounds, glowing accents | Animated gradient, glow keyframes | Overuse causing eye fatigue |
| 10 | Dark Mode (OLED) | Dev tools, coding platforms, night apps | Near-black bg (#0a0a0a), bright accent | Reduced luminance animations, glow | Pure black bg causes halation issues |
| 11 | AI-Native UI | AI products, chatbots, copilots | Clean white/dark, subtle indigo/purple accent, streaming text | Typing indicator, token streaming, subtle glow | Heavy decoration, competing chrome |
| 12 | Bento Box Grid | Dashboards, product pages, portfolios | Modular card grid, varied card sizes, clean dividers | Card hover lift (translateY -2px, shadow +), no animation | Unequal padding, inconsistent card radii |
| 13 | Flat Design | Web apps, startup MVPs, mobile | No shadows, strong color, iconography-first | Color transition on state change, no depth | Skeuomorphic detail |
| 14 | Accessible & Ethical | Government, healthcare, education | High contrast, large text, clear focus states | Focus ring 3px offset, visible skip links | Animation without prefers-reduced-motion |
| 15 | Glassmorphism Dark | Premium SaaS, analytics | Dark translucent card, bright neon accent | backdrop-filter, neon border glow | Overuse losing depth perception |

## Landing Page Styles

| # | Style | Pattern | Best For |
|---|-------|---------|----------|
| 1 | Hero-Centric + Social Proof | Hero → features → testimonials → CTA | B2C, wellness, beauty, services |
| 2 | Feature-Matrix | Hero → feature grid → comparison → pricing → CTA | B2B SaaS, developer tools |
| 3 | Problem-Solution | Pain point → solution reveal → proof → CTA | Niche SaaS, consulting |
| 4 | Visual Storytelling | Full-bleed scroll narrative → product moments → CTA | Luxury, travel, editorial |
| 5 | Community-Led | Social proof first → mission → join CTA | Marketplaces, communities, nonprofits |
| 6 | Product Demo-Led | Hero with embedded demo/video → features → pricing | Developer tools, AI products |
| 7 | Minimalist One-Pager | Headline → one value prop → single CTA | Early-stage startups, waitlists |
| 8 | Conversion-Optimized | Above-fold CTA → trust signals → repeated CTAs | E-commerce, high-intent landing |

## Dashboard / BI Styles

| # | Style | Best For |
|---|-------|----------|
| 1 | Data-Dense Dashboard | Complex multi-metric analysis |
| 2 | Executive Dashboard | C-suite KPI summaries |
| 3 | Real-Time Monitoring | Ops, DevOps, infrastructure |
| 4 | Drill-Down Analytics | Detailed data exploration |
| 5 | User Behavior Analytics | UX research, product analytics |
| 6 | Financial Dashboard | Finance, accounting, revenue |
| 7 | Sales Intelligence | CRM, pipeline, quota tracking |
| 8 | Predictive Analytics | Forecasting, ML model outputs |
