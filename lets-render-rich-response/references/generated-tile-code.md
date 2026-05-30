# Generated tile code (React.createElement form)

## Table of contents

1. [Format rules](#format-rules)
2. [Allowed patterns](#allowed-patterns)
3. [Bridge API](#bridge-api)
4. [Spec fields](#spec-fields)

## Format rules

**Required:** `jsx` is a single expression string using `React.createElement` only (TQ2 — no in-iframe transpiler).

```javascript
React.createElement('div', { className: 'tile' },
  React.createElement('h2', null, 'Title'),
  React.createElement('p', null, 'Body')
)
```

**Forbidden in source string:** angle-bracket JSX (`<Div />`), `dangerouslySetInnerHTML`, `eval`, `Function`, dynamic `import`, `script`/`iframe` elements, `document.write`, `window.location =`, `__proto__`, `Object.defineProperty` — enforced by [`../scripts/validate-tile-jsx.py`](../scripts/validate-tile-jsx.py) (aligned with ux-engine `sandbox-escape.test.ts`).

Embed static data via `JSON.stringify` in literals; do not fetch credentials or PII inside the iframe.

## Allowed patterns

- `React.createElement(tag, props, ...children)`
- Literals, ternaries, `.map()` with `key` on children
- `Math.*`, `Date.*`, `JSON.parse` on embedded literals
- Event handlers that call `bridge.fetch` / `bridge.navigate` / `bridge.dispatchAction` only

## Bridge API

Globals inside the harness (not in host React tree):

```typescript
bridge.fetch(url, init?)      // url must be in tile allowlist ∩ host BridgePolicy
bridge.navigate(route)        // route must be allowlisted
bridge.dispatchAction(id, payload?)  // id must be in declaredActions
```

## Spec fields

See `GeneratedTileSpec` in [interaction-generative.ts](https://github.com/letsbe10x/ux-engine/blob/main/packages/contracts/src/interaction-generative.ts):

| Field | Required | Notes |
|-------|----------|-------|
| `tileId` | yes | Stable id for audit |
| `jsx` | yes | Pre-compiled createElement string |
| `label` | yes | Failed-tile chrome + a11y |
| `declaredActions` | yes | May be `[]` if no `dispatchAction` |
| `allowlist` | when using bridge.fetch/navigate | Intersected with host policy (`strict` mode) |
| `subjectRef`, `qualityGates`, `scope`, `recipeTrace` | optional | Stage 9 / recipe linkage |

### RunContext and audit fields

The `GeneratedTileSpec` itself does **not** carry `RunContext`. The host constructs
`RunContext = { runId, episodeId, tenantId }` from its own run state and passes it
directly to `RailMessageRenderer` (and transitively to `GeneratedTile`). This means
the agent only needs to populate the spec fields above; `runId` and `episodeId` flow
from the host at render time.

The host uses `RunContext` to populate audit records (`tile_rendered`,
`validation_failure`, etc.) — see [`audit-adapter-interface.md`](audit-adapter-interface.md)
for the full record shapes. When emitting a `validation_failure` record before publish
(agent-side), pass the `runId` and `episodeId` that were provided in the
`RichResponseRequest` that triggered generation.

Next: [`validate-tile-jsx.md`](validate-tile-jsx.md).
