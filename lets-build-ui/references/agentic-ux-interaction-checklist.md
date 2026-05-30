# Agentic UX interaction model checklist (decision-031)

Apply when implementing or reviewing **Stage 9** work or any change that affects widget
addressability, actions, quality chrome, boards, or AO proposal UX.

Authority: `ground-truth/decisions/decision-031-ux-engine-ai-aware-interaction-model.md`

## Before coding

- [ ] Read `ux-engine-repo-baseline.md` — use **plan ↔ code mapping**; do not require plan filenames if alias shipped
- [ ] Action changes mapped: `WidgetActionSpec` → `DomainActionSpec` / `RailAction` / `InboxAction`
- [ ] No new execution path that bypasses `executableRef` + host adapter

## Per widget retrofit

- [ ] `WidgetIdentity` published on mount; unregistered on unmount
- [ ] `instanceId` stable across re-renders; duplicate registration rejected
- [ ] Semantic chrome shows `label` + `subjectRef` disambiguation
- [ ] Actions in co-located `*.actions.ts`; rendered from declaration, not hidden onClick-only
- [ ] States: loading → partial → ready → error without remount thrash
- [ ] Per-widget error boundary (failure contained)

## CompareView bellwether (required for Stage 9 acceptance)

- [ ] Left and right sides have distinct `instanceId` and action sets
- [ ] Command Palette lists both sides by semantic name (when CommandPalette lands)
- [ ] One action uses `executableRef` to rail; E2E asserts audit uses `action_id`

## QualityChrome (not TrustBar for new consumers)

- [ ] Consumes `QualityGates` map; profile selects gates per artifact kind
- [ ] Run adapter is thin wrapper over run-shaped pills
- [ ] control-plane / gt-ui migrations import `QualityChrome`

## BoardSurface (when in scope)

- [ ] Distinct from DashboardSurface and WidgetMosaic (see Appendix B)
- [ ] `PlacedWidget.instanceId` minted at placement
- [ ] Persistence via consumer `BoardStorageAdapter`; scope server-authoritative
- [ ] Ephemeral expiry + Keep affordance wired

## Security

- [ ] ScopeChip reflects server state; promotion only after API success
- [ ] No palette action without `executableRef` calling host adapters for mutations

## Evidence (lets-build-ui ship gate)

- [ ] `pnpm test` + `pnpm typecheck` in ux-engine green
- [ ] Showcase or lens-ui screenshot for changed surfaces
- [ ] axe-core green on new/changed patterns
- [ ] Storybook story for each new state
