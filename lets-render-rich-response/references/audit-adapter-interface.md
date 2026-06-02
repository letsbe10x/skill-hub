# AuditAdapter Interface

The host must implement `AuditAdapter` from `@letsbe10x/ux-contracts` and pass it to
`RailMessageRenderer` and `GeneratedTile`. The interface has four methods:

| Method | Record type | When |
|--------|-------------|------|
| `recordTileRendered(record)` | `TileRenderedRecord` | After successful tile paint |
| `recordTileAction(record)` | `TileActionRecord` | After every dispatch (ok or denied) |
| `recordBridgeViolation(record)` | `BridgeViolationRecord` | When bridge rejects a request |
| `recordValidationFailure(record)` | `ValidationFailureRecord` | When JSX fails AST validation |

All methods may return `Promise<void> | void`.

### TileRenderedRecord fields
- `kind: "tile_rendered"`
- `tileId: string` — from `GeneratedTileSpec.tileId`
- `runId: string` — from `RunContext.runId`
- `episodeId: string` — from `RunContext.episodeId`
- `renderDurationMs: number`
- `timestamp: string` — ISO-8601

### TileActionRecord fields
- `kind: "tile_action"`
- `tileId: string`
- `actionId: string`
- `result: "ok" | "denied"`
- `reason?: string` — populated on denial
- `timestamp: string`

### ValidationFailureRecord fields
- `kind: "validation_failure"`
- `tileId: string`
- `runId: string` — from RunContext
- `episodeId: string` — from RunContext
- `reason: string` — which banned construct was found
- `timestamp: string`

### BridgeViolationRecord fields
- `kind: "bridge_violation"`
- `tileId: string`
- `violationKind: "origin_mismatch" | "url_denied" | "route_denied" | "unknown"`
- `detail: string`
- `timestamp: string`
