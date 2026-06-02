---
purpose: Stack-specific component and tooling guidance for UI implementation
lookup-by: Stack
---

# Stack Guidelines Reference

Use during Step 3 to add stack-specific constraints and tooling to the direction and
execution packet. If the stack is unknown, ask during scope discovery.

| # | Stack | Component Approach | Styling | State | Notes |
|---|-------|-------------------|---------|-------|-------|
| 1 | React + Vite | Functional components, hooks | CSS Modules or Tailwind | Zustand / Jotai | Use `clsx` for conditional classes; avoid inline styles |
| 2 | Next.js (App Router) | Server + Client components | Tailwind CSS | Server state via RSC; Zustand for client | Mark `"use client"` only where needed; prefer RSC for static UI |
| 3 | Next.js (Pages Router) | Functional components | Tailwind / styled-components | SWR / React Query + Zustand | `_document.tsx` for global font loading |
| 4 | shadcn/ui | Extend Radix UI primitives | Tailwind + CSS variables for tokens | Radix state primitives | Use `cn()` utility; tokens via `--radius`, `--background` CSS vars |
| 5 | Astro | Islands architecture | Scoped CSS / Tailwind | Nano Stores for shared state | Use `.astro` components for static; React/Vue islands for interactive |
| 6 | Vue 3 / Nuxt 3 | Composition API, `<script setup>` | Tailwind / UnoCSS / CSS Modules | Pinia | Use `defineProps` + `withDefaults`; Nuxt auto-imports |
| 7 | Svelte / SvelteKit | Svelte components | Scoped CSS or Tailwind | Svelte stores | `$:` reactive declarations; transitions built-in |
| 8 | HTML + Tailwind | Semantic HTML | Tailwind utility classes | Alpine.js for interactivity | Use `@apply` sparingly; component via partial includes |
| 9 | Angular | Standalone components (v17+) | Angular Material / Tailwind | NgRx / Signals | Use `OnPush` change detection; inject services via `inject()` |
| 10 | Laravel (Blade) | Blade components + Livewire | Tailwind CSS | Livewire / Alpine.js | `@volt` for inline Livewire; Folio for page-based routing |
| 11 | React Native | Native components | StyleSheet / NativeWind | Zustand / Context | Use `Platform.select` for OS differences; test on both iOS/Android |
| 12 | Flutter | Widget composition | ThemeData + ColorScheme | Riverpod / Bloc | Use `Theme.of(context)` for tokens; avoid magic numbers |
| 13 | SwiftUI | View composition | SwiftUI modifiers + `.foregroundStyle` | `@State` / `@Observable` | Follow Apple HIG spacing (4pt grid); use `.tint` for accent |
| 14 | Jetpack Compose | Composable functions | Material3 + `MaterialTheme` | `remember` / `ViewModel` | Use `dp` units; follow Material You dynamic color |
| 15 | Nuxt UI | `<UButton>`, `<UCard>` etc. | Tailwind + Nuxt UI tokens | Pinia + `useAsyncData` | Override via `app.config.ts` ui key; use `variant` prop pattern |
| 16 | **@letsbe10x/ux-engine** | Import from `@letsbe10x/ux-primitives`, `ux-patterns`, `ux-widgets`, `ux-surfaces` | **`--ux-*` semantic tokens only** via `@letsbe10x/ux-tokens` | `ux-runtime` profiles + TanStack Query in consumers | See [`ux-engine-stack.md`](ux-engine-stack.md); Direction v1 dark-first; Stage 9 interaction model is separate from visual polish |

## Token Integration by Stack

| Stack | Token Pattern |
|-------|--------------|
| React/Next/Astro/Svelte + Tailwind | CSS custom properties → `tailwind.config.js` `theme.extend.colors` |
| shadcn/ui | CSS vars in `globals.css` `:root` and `.dark` selectors |
| Flutter | `ThemeData.colorScheme` + `TextTheme` |
| SwiftUI | `Color` asset catalog + `@Environment(\.colorScheme)` |
| React Native + NativeWind | CSS vars not available; use theme context object |
| Angular Material | `mat-theme-overrides` in `styles.scss` |
| @letsbe10x/ux-engine | `@letsbe10x/ux-tokens/css/*.css` → extend only in `packages/tokens`; consumers import emitted CSS |
