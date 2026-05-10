# Outputs Reference — lets-bootstrap-repo

## Artifacts written

All artifacts are written under `.letsbe10x/` in the repo root. The user owns these files and should commit them.

| Path | What it is |
|---|---|
| `.letsbe10x/context/sources/service.yaml` | Maintainer-confirmed service truth: non_negotiables, critical_paths, governance posture, analysis block |
| `.letsbe10x/context/verified/service.json` | Trust record: verified sections, workflow_context, trust_level = "verified" |
| `.letsbe10x/context/sources/engineering.yaml` | Auto-discovered engineering facts: entrypoints, module_roots, test_framework, linter |
| `.letsbe10x/context/verified/engineering.json` | Verified engineering pack (trust_level = "verified"; enriched fields empty until agents-md-bootstrap runs) |
| `.letsbe10x/context/sources/delivery.yaml` | Auto-discovered delivery facts: CI system, release process |
| `.letsbe10x/context/verified/delivery.json` | Verified delivery pack |
| `.letsbe10x/context/sources/observability.yaml` | Auto-discovered observability: runbooks, dashboards, metrics endpoint |
| `.letsbe10x/context/verified/observability.json` | Verified observability pack |
| `.letsbe10x/memory/*.md` | Retained decisions seeded at onboard: Service profile, Governance posture, Detected critical paths, Module structure, Test framework |

## What "verified" means

A pack is `trusted: true` when its `trust_level` field equals `"verified"` in the JSON artifact. This means the pack was written by the `letsbe10x` bootstrap process and passes schema validation.

## What "enriched" means

The engineering pack is `enriched: true` when `workflow_context.engineering.repo_summary` is non-empty. This happens only after `lets-bootstrap-agents-md` has run Phase 8 (`lets context enrich --pack engineering`).

## Readiness levels

| Level | Condition |
|---|---|
| L0 | No context artifacts present |
| L1 | service pack trusted |
| L2 | service + engineering packs trusted |
| L3 | service + engineering + delivery packs trusted |
| L3+ | All packs trusted + engineering enriched |

Readiness score (0–100) is weighted: service = 40pts, engineering = 20pts, delivery = 20pts, observability = 20pts. Only trusted packs score.
