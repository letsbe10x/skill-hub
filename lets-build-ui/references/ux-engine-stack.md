---
purpose: Stack and package map for letsbe10x Agentic UX Engine consumers
lookup-by: repo | package_scope
baseline_sha: a4c7147
baseline_date: 2026-05-22
---

# @letsbe10x/ux-engine stack (lets-build-ui)

Use when the target app consumes `letsbe10x/ux-engine` packages or when editing the `ux-engine` monorepo.

**Authoritative grounding:** `ground-truth/features/agentic-ux-engine/docs/ux-engine-repo-baseline.md`

**Interaction model ADR:** `ground-truth/decisions/decision-031-ux-engine-ai-aware-interaction-model.md`

## Layer order (import)

```
@letsbe10x/ux-tokens/css/*.css
@letsbe10x/ux-primitives/styles.css
@letsbe10x/ux-patterns/styles.css
@letsbe10x/ux-widgets/styles.css
→ primitives / patterns / widgets / surfaces
```

## Packages @ `a4c7147` (actually shipped)

| Package | Version | Role |
|---------|---------|------|
| `ux-tokens` | 0.2.0 | Semantic `--ux-*` tokens + theme CSS |
| `ux-primitives` | 0.1.0 | Button, DataTable, StatusPill, Skeleton, CodeBlock |
| `ux-patterns` | 0.1.1 | Panel, FilterBar, EmptyState, TrustStrip, PageHeader, … |
| `ux-contracts` | 0.1.1 | Rail, trust, hitl, evidence, inbox, fleet, compare, audit, … |
| `ux-runtime` | 0.1.0 | DomainProfile + DomainActionSpec + 5 profiles + workbench demo |
| `ux-widgets` | 0.2.0 | WorkbenchLayout, TrustBar, Rail, Timeline, Gates, Artifacts, FlowCanvas, Inbox, Fleet, Compare, Audit |
| `ux-surfaces` | 0.1.0 | Five full-screen surfaces |

**Apps:** `apps/showcase`, `apps/lens-ui` (both on `main` @ `a4c7147`).

## Plan name ↔ code (do not file false “missing” bugs)

| You may read in v0 plans | In repo |
|--------------------------|---------|
| HitlDrawer | `GateViewerPanel` + hitl contracts |
| EvidenceExplorer | `ArtifactsPanel` + evidence contracts |
| Inbox keyboard | `useInboxKeyboard` on `InboxPanel` |
| Profile packages | `packages/runtime/src/profiles/*` |
| CommandPalette | **Not shipped** |
| WidgetMosaic / DashboardSurface | **Not shipped** |

## Direction v1 (decision-030 — do not override in polish passes)

- AI-Native Operator Console; dark-first; data-dense
- Inter + JetBrains Mono via tokens
- Semantic tokens only in components (`--ux-*`)

## lets-build-ui checkpoints (ux-engine)

1. Read **repo baseline** and confirm SHA.
2. Fill [`ux-engine-inventory.yml`](ux-engine-inventory.yml) using **actual exports**, not plan filenames.
3. Action changes: map through decision-031 Appendix A (`WidgetActionSpec` → `DomainActionSpec` / `RailAction`).
4. Four states per widget: loading / partial / ready / error.
5. `pnpm test` + `pnpm typecheck` in `ux-engine`; showcase or lens-ui for evidence.

## lets-build-ui vs Stage 9

| Work | Use |
|------|-----|
| Visual polish, tokens, a11y | `lets-build-ui` |
| Widget identity, BoardSurface, AO patterns | Stage 9 + decision-031 |
