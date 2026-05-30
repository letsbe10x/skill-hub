# Layout and RailMessageV2 envelope

## Table of contents

1. [Surface selection](#surface-selection)
2. [Required fields](#required-fields)
3. [Kind-specific fields](#kind-specific-fields)

## Surface selection

| Classification | Default surface | Notes |
|----------------|-----------------|-------|
| `generated` | Rail | Board when run sets `layoutHint: "board"` |
| `diff-view` | Rail | — |
| `simple-form` | Rail | Modal when `layoutHint: "modal"` (host support) |
| `text` | Rail | — |

## Required fields

Every `RailMessageV2` variant needs:

- `messageId` — unique per message
- `runId` — producing run
- `summary` — plain-text fallback (screen readers, non-rich clients)

`RailStructuredMessage` and `RailGeneratedMessage` also need:

- `episodeId`
- `emittedAt` — ISO-8601 UTC

Types: [interaction-generative.ts](https://github.com/letsbe10x/ux-engine/blob/main/packages/contracts/src/interaction-generative.ts).

## Kind-specific fields

### `kind: "structured"`

```json
{
  "kind": "structured",
  "schemaId": "diff-view",
  "schemaVersion": "1.0.0",
  "label": "human title",
  "payload": {}
}
```

### `kind: "generated"`

```json
{
  "kind": "generated",
  "tile": {
    "tileId": "run-<runId>-tile-001",
    "jsx": "React.createElement(...)",
    "label": "accessible title",
    "declaredActions": [],
    "allowlist": { "fetchUrls": [], "navigateRoutes": [] }
  }
}
```

### `kind: "text"`

Use legacy `RailTextMessage` shape with `kind: "text"` discriminant.

Next: generated path → [`generated-tile-code.md`](generated-tile-code.md); all paths → [`publish-artifact.md`](publish-artifact.md) after validation.
