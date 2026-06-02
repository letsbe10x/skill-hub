# Observability Bundle

SRE / on-call workflows for log search, metric inspection, alert
management, service health, deploys, and incident triage. Pairs with
the adapters under `../adapters/observability/` (Splunk, Prometheus,
Jaeger, Grafana) and the matching sandboxes under
`../sandboxes/observability/`.

## Install

```bash
npx github:letsbe10x/skill-hub install observability --agent cursor
```

Change `--agent cursor` to `--agent claude-code`, `--agent codex`, or
`--agent copilot`.

## Included workflows

| Workflow | Purpose |
|----------|---------|
| `lets-search-logs` | Search / investigate service logs (Splunk-style backends) |
| `lets-inspect-metrics` | Service health via metric queries (Prometheus-style backends) |
| `lets-manage-alerts` | Check firing alerts, silences, recent state changes |
| `lets-watch-service` | Live read on service health pre/post-deploy |
| `lets-deploy-check` | Pre-deploy verification + governance gate |
| `lets-triage-incident` | Structured incident response (alert firing / on-call active) |
| `lets-diagnose-k8s` | Kubernetes service-level health diagnosis |

## Typical flows

```
# pre-deploy
lets-deploy-check → lets-watch-service

# incident
lets-triage-incident → lets-search-logs / lets-inspect-metrics → lets-manage-alerts

# health check
lets-watch-service → lets-search-logs / lets-inspect-metrics / lets-diagnose-k8s
```

## Pairs well with

- The four observability adapters under `adapters/observability/`:
  Splunk, Prometheus, Jaeger, Grafana. The skills call backend-native
  commands today (`lets inspect surface logs`, etc.); platform-agnostic
  rewriting to call `lets-<backend>` shims is tracked in PRD-178 Phase 3.
- The matching sandboxes under `sandboxes/observability/` for end-to-end
  local validation before pointing at a production backend.

## Status note

These skills were authored in `letsbe10x/skills` and ship with `lets`
CLI invocations (`lets inspect surface logs`, etc.). They work today
when the `lets` CLI is available alongside skill-hub. PRD-178 Phase 3
covers the platform-agnostic rewrite — invoking the adapter shims
directly so the skills run with **only** skill-hub installed, per
decision-024.
