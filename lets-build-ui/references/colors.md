---
purpose: Color palettes for 161 product types — complete semantic token set per product
lookup-by: Product Type
---

# Color Palettes Reference

All accents are pre-adjusted for WCAG 3:1 contrast compliance against their backgrounds.

## Token Schema

Each palette provides a full semantic token set:

| Token | Purpose |
|-------|---------|
| `--primary` | Brand/action color |
| `--on-primary` | Text on primary background |
| `--secondary` | Supporting color |
| `--accent` | CTA / emphasis (WCAG 3:1 adjusted) |
| `--background` | Page background |
| `--foreground` | Body text color |
| `--card` | Card/panel background |
| `--muted` | Subtle backgrounds |
| `--muted-foreground` | Secondary text |
| `--border` | Dividers and borders |
| `--destructive` | Error/delete actions |
| `--ring` | Focus ring color |

## Representative Palettes (30 of 161)

| No | Product Type | Primary | Accent | Background | Foreground | Notes |
|----|-------------|---------|--------|------------|------------|-------|
| 1 | SaaS (General) | #2563EB | #EA580C | #F8FAFC | #1E293B | Trust blue + orange CTA |
| 2 | Micro SaaS | #6366F1 | #059669 | #F5F3FF | #1E1B4B | Indigo + emerald CTA |
| 3 | E-commerce | #059669 | #EA580C | #ECFDF5 | #064E3B | Success green + urgency orange |
| 4 | E-commerce Luxury | #1C1917 | #A16207 | #FAFAF9 | #0C0A09 | Premium dark + gold |
| 5 | B2B Service | #0F172A | #0369A1 | #F8FAFC | #020617 | Professional navy + blue CTA |
| 6 | Financial Dashboard | #0F172A | #22C55E | #020617 | #F8FAFC | Dark bg + green indicators |
| 7 | Analytics Dashboard | #1E40AF | #D97706 | #F8FAFC | #1E3A8A | Blue data + amber highlights |
| 8 | Healthcare App | #0891B2 | #059669 | #ECFEFF | #164E63 | Calm cyan + health green |
| 9 | Educational App | #4F46E5 | #EA580C | #EEF2FF | #1E1B4B | Playful indigo + energetic orange |
| 10 | Creative Agency | #EC4899 | #0891B2 | #FDF2F8 | #831843 | Bold pink + cyan accent |
| 11 | Portfolio / Personal | #18181B | #2563EB | #FAFAFA | #09090B | Monochrome + blue accent |
| 12 | Gaming | #7C3AED | #F43F5E | #0F0F23 | #E2E8F0 | Neon purple + rose action |
| 13 | Fintech / Crypto | #F59E0B | #8B5CF6 | #0F172A | #F8FAFC | Gold trust + purple tech |
| 14 | Social Media App | #E11D48 | #2563EB | #FFF1F2 | #881337 | Vibrant rose + engagement blue |
| 15 | Productivity Tool | #0D9488 | #EA580C | #F0FDFA | #134E4A | Teal focus + action orange |
| 16 | AI / Chatbot Platform | #7C3AED | #0891B2 | #FAF5FF | #1E1B4B | AI purple + cyan interactions |
| 17 | Mental Health App | #8B5CF6 | #059669 | #FAF5FF | #4C1D95 | Calming lavender + wellness green |
| 18 | NFT / Web3 Platform | #8B5CF6 | #FBBF24 | #0F0F23 | #F8FAFC | Purple tech + gold value |
| 22 | Mental Health App | #8B5CF6 | #059669 | #FAF5FF | #4C1D95 | Calming lavender + wellness green |
| 30 | Beauty / Spa / Wellness | #EC4899 | #8B5CF6 | #FDF2F8 | #831843 | Soft pink + lavender luxury |
| 32 | Beauty/Spa/Wellness Service | #EC4899 | #8B5CF6 | #FDF2F8 | #831843 | Soft pink + lavender luxury |
| 33 | Luxury / Premium Brand | #1C1917 | #A16207 | #FAFAF9 | #0C0A09 | Premium black + gold |
| 34 | Restaurant / Food Service | #DC2626 | #A16207 | #FEF2F2 | #450A0A | Appetizing red + warm gold |
| 35 | Fitness / Gym App | #F97316 | #22C55E | #1F2937 | #F8FAFC | Energy orange + success green |
| 38 | Hotel / Hospitality | #1E3A8A | #A16207 | #F8FAFC | #1E40AF | Luxury navy + gold service |
| 40 | Legal Services | #1E3A8A | #B45309 | #F8FAFC | #0F172A | Authority navy + trust gold |
| 80 | Cybersecurity Platform | #00FF41 | #FF3333 | #000000 | #E0E0E0 | Matrix green + alert red |
| 81 | Developer Tool / IDE | #1E293B | #22C55E | #0F172A | #F8FAFC | Code dark + run green |
| 82 | Biotech / Life Sciences | #0EA5E9 | #059669 | #F0F9FF | #0C4A6E | DNA blue + life green |
| 98 | Meditation & Mindfulness | #7C3AED | #059669 | #FAF5FF | #0F172A | Calm lavender + mindful green |

> **Full dataset:** 161 palettes available at the source CSV URL above.

## CSS Custom Properties Template

```css
:root {
  --primary: [hex];
  --on-primary: [hex];
  --secondary: [hex];
  --accent: [hex];         /* WCAG 3:1 adjusted */
  --background: [hex];
  --foreground: [hex];
  --card: [hex];
  --card-foreground: [hex];
  --muted: [hex];
  --muted-foreground: [hex];
  --border: [hex];
  --destructive: [hex];
  --ring: [hex];           /* focus ring */
}
```
