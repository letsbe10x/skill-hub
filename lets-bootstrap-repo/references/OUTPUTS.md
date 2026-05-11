# Outputs Reference — lets-bootstrap-repo

## Artifacts Written

All artifacts are written under `.letsbe10x/` in the repo root. The user owns these files and should commit them.

| Path | What it is | Phase |
|------|-----------|-------|
| `.letsbe10x/context/sources/service.yaml` | Maintainer-confirmed service truth | Phase 3 |
| `.letsbe10x/context/verified/service.json` | Trust record with verification timestamp | Phase 3 |
| `.letsbe10x/context/sources/engineering.yaml` | Auto-discovered engineering facts | Phase 4 |
| `.letsbe10x/context/verified/engineering.json` | Verified engineering pack | Phase 4 |
| `.letsbe10x/context/sources/delivery.yaml` | Auto-discovered delivery facts | Phase 4 |
| `.letsbe10x/context/verified/delivery.json` | Verified delivery pack | Phase 4 |
| `.letsbe10x/context/sources/observability.yaml` | Auto-discovered observability facts | Phase 4 |
| `.letsbe10x/context/verified/observability.json` | Verified observability pack | Phase 4 |
| `AGENTS.md` / per-module `AGENTS.md` | Agent guidance (via lets-bootstrap-agents-md) | Phase 5 |
| `docs/coding-rules.md` | Extracted coding standards | Phase 5 |

## What "verified" means

A pack is trusted when its `trust_level` field equals `"verified"` in the JSON artifact. This means:
- Written by the bootstrap process
- Passes schema validation
- Maintainer confirmed the source facts

## What "inferred" means

Discovered facts (Phase 4) start as `trust_level: "inferred"`. They become verified when:
- User explicitly confirms them, OR
- They pass automated validation against repo state

Inferred facts do NOT count toward readiness score.

## Readiness Levels

| Level | Condition |
|-------|-----------|
| **L0** | No context artifacts present |
| **L1** | Service pack verified |
| **L2** | Service + engineering packs verified |
| **L3** | Service + engineering + delivery packs verified |
| **L3+** | All packs verified + engineering enriched (AGENTS.md present) |

## Scoring Weights

| Pillar | Weight | What earns points |
|--------|--------|-------------------|
| Service | 40 | Verified `service.yaml` with all required fields |
| Engineering | 20 | Verified `engineering.yaml` + optionally AGENTS.md |
| Delivery | 20 | Verified `delivery.yaml` with CI config |
| Observability | 20 | Verified `observability.yaml` with ≥1 dashboard or runbook |

**Total: 100 points.** Only verified artifacts score.

## Readiness Report Format

```
## Readiness Report — <repo-name>

Level: L2 (service + engineering verified)
Score: 60/100

| Pillar         | Status    | Score |
|---------------|-----------|-------|
| Service        | Verified  | 40/40 |
| Engineering    | Verified  | 20/20 |
| Delivery       | Missing   |  0/20 |
| Observability  | Missing   |  0/20 |

### Top gaps
1. <gap description> → <remediation>
2. <gap description> → <remediation>
3. <gap description> → <remediation>

### Recommended next action
<single actionable step>
```
