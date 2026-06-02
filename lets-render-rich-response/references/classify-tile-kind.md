# Classify tile kind

## Table of contents

1. [Kinds](#kinds)
2. [Decision tree](#decision-tree)
3. [Output](#output)

**Machine-readable:** [`assets/tile-kind-decision.yml`](../assets/tile-kind-decision.yml) and [`assets/component-catalog.yml`](../assets/component-catalog.yml).

## Kinds

| Kind | Use when | `RailMessageV2` shape |
|------|----------|------------------------|
| `text` | Prose is sufficient | `{ kind: "text", ... }` (legacy flat fields + `kind`) |
| `diff-view` | Before/after text comparison | `{ kind: "structured", schemaId: "diff-view", schemaVersion: "1.0.0", payload }` |
| `simple-form` | Collect ≤8 simple fields | `{ kind: "structured", schemaId: "simple-form", schemaVersion: "1.0.0", payload }` |
| `structured` | Host registry has `(schemaId, schemaVersion)` | Same as above with registered ids |
| `generated` | Custom UI; no fast-path or registry match | `{ kind: "generated", tile: GeneratedTileSpec }` |

Payload shapes (canonical):

- **diff-view:** `{ left, right, mode?, title? }` — see `DiffViewRenderer.tsx`
- **simple-form:** `{ fields, submitActionId?, submitLabel?, title? }` — see `SimpleFormRenderer.tsx`

## Decision tree

1. Before/after comparison only? → **diff-view** (not `generated`).
2. Collect user input with standard field types? → **simple-form** (not `generated`).
3. Else query host `StructuredRendererRegistry` — match? → **structured** with that schema.
4. Else need custom visual layout? → **generated**.
5. Else → **text**.

Fast-path renderers run **in the host** (no iframe, no bridge handshake). Prefer them whenever the intent fits.

## Output

```json
{
  "tileKind": "text | diff-view | simple-form | structured | generated",
  "reason": "one sentence",
  "schemaId": "only when structured",
  "schemaVersion": "only when structured"
}
```

Next: [`layout-envelope.md`](layout-envelope.md). Skip codegen for `text`, `diff-view`, and `simple-form`.
