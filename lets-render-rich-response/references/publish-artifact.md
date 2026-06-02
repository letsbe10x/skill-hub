# Publish rail message and audit

## Table of contents

1. [Publish sequence](#publish-sequence)
2. [Audit records](#audit-records)
3. [Host integration](#host-integration)

## Publish sequence

1. **Append message** — Write the finalized `RailMessageV2` to the run's message stream using the host integration you have (gt-ui, control-plane, test harness). This skill does not define a Python `run_artifact` API.
2. **Structured fast-path** — No separate tile registry; the message carries `payload`.
3. **Generated** — Message includes full `GeneratedTileSpec`; host `RailMessageRenderer` mounts `GeneratedTile`.
4. **Confirm render path** — Host should call `AuditAdapter.recordTileRendered` after successful render (not when the agent merely drafted JSX).

## Audit records

Canonical shapes: `GeneratedTileAuditRecord` in `interaction-generative.ts`.

**tile_rendered** (host, after render):

```typescript
{
  kind: "tile_rendered",
  tileId: string,
  runId: string,
  episodeId: string,
  renderDurationMs: number,
  timestamp: string  // ISO-8601
}
```

**validation_failure** (agent or host, on reject):

```typescript
{
  kind: "validation_failure",
  tileId: string,
  runId: string,      // from RunContext.runId — required for audit chain linkage
  episodeId: string,  // from RunContext.episodeId — required for audit chain linkage
  reason: string,     // e.g. "eval()" from ban list
  timestamp: string
}
```

Reference implementation: [gt-ui `tileAuditAdapter.ts`](https://github.com/letsbe10x/ground-truth/blob/main/apps/gt-ui/src/agenticUxHost/tileAuditAdapter.ts).

## Host integration

| Host | Notes |
|------|-------|
| gt-ui | Feature flag + `tileAuditAdapter` |
| showcase | `Track2DemoPanel` for manual verification |
| core goals (future) | `rich-response-publish` per stage-10 plan |

On publish failure: prose fallback + `validation_failure` with `reason: "publish_error"`. Never leave the turn without a `summary` text message.
