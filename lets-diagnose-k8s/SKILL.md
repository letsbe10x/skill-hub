---
name: lets-diagnose-k8s
description: "Use this skill whenever the user wants to check Kubernetes health or diagnose a service running on Kubernetes — including pod status, crashloops, OOMKills, stuck or failed deployments, image pull errors, or recent warning events. Trigger on casual phrasing like 'is the deploy done', 'why is the pod restarting', 'did the rollout succeed', 'something is wrong with the service', or 'check if it is up'. Read-only — never mutates cluster state."
metadata:
  author: letsbe10x
  version: "0.1.0"
  tags: [observability, kubernetes, watchtower]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-diagnose-k8s/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
  requirements:
    - "adapter capability: k8s"
triggers:
  - kubectl
  - pod status
  - deployment rollout
  - crashloop
  - is the rollout healthy
goals:
  - inspect_service
outcome_runtime:
  open_agency_zones:
    - resource_scope_selection
    - rollout_health_assessment
  validation_gates:
    - surface_readiness_gate

    - pod_state_claim
    - rollout_health_claim
  allowed_moves:
    - narrow_namespace_or_selector
    - pivot_to_events
    - request_missing_capability
  hard_limits:
    - do_not_restart_pods
    - do_not_scale_deployments
    - do_not_modify_configmaps_or_secrets
    - do_not_claim_healthy_without_events_and_pod_status
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
    - destructive_action_requested
---

## Investigation Law

**NO "ROLLOUT HEALTHY" CLAIM WITHOUT BOTH POD READINESS AND RECENT EVENT STREAM REVIEW.**

Pod `Ready=True` alone does not rule out CrashLoopBackOff history, OOMKilled, ImagePullBackOff, Evicted replicas, init container failures, or a stalled rollout with progressDeadlineExceeded. Events AND pod status are both required before any health claim.

## Overview

`lets-diagnose-k8s` reads the k8s surface of the watchtower capability contract. It surfaces pod state, deployment rollout status, and recent events — enough to decide whether Kubernetes is a contributor to a degraded service verdict. Read-only by invariant; destructive actions (rollback, restart, scale) route to the on-call lead, not this skill.

## When to Use

- A deploy is rolling and you need `kubectl rollout status` equivalent state.
- A service is degraded and you suspect pod-level symptoms (crashloop, OOM, image pull).
- You need the recent event stream for a namespace or workload.
- Do NOT use for alerts / metrics / logs — use the sibling surface skills or fan out through `lets-watch-service`.

## Steps

1. **Identify scope** — service name and namespace (if known). `K8sHealthResult` answers all three common question types in one response:
   - Pods: phase counts, restart counts, container states
   - Rollout: replica counts, rollout conditions, progress
   - Events: recent warning/error events for the workload or namespace

2. **Run the probe** `lets inspect surface k8s --service $SERVICE --namespace $NAMESPACE` — the typed `K8sHealthResult` response carries `running` / `pending` / `failed` / `total_restarts` / `oom_kills` / `recent_events` — all three question types (pods, rollout, events) are answered in a single call.
3. **Handle probe status** — before doing anything else:
   - `ok` → proceed
   - `not_ready` → stop, report `UNKNOWN` with probe detail
   - `error` → retry once with narrower selector; if still error, report `UNKNOWN`

4. **Health claims require BOTH pod counts AND events** — if producing any "healthy" or "degraded" verdict, you MUST inspect both pod phase counts and `recent_events` from the same response. Pod counts alone are never sufficient.

5. **Check for hidden failure signals** — even when pods show `running` and no `failed`, scan `recent_events` for: `OOMKilled`, `CrashLoopBackOff`, `ImagePullBackOff`, `Evicted`, `BackOff`. Any of these in the window invalidates a healthy claim. `total_restarts > 0` or `oom_kills > 0` are also signal.

6. **Emit the k8s card.**

## Anti-patterns

- **Running `kubectl delete` / `kubectl rollout undo` / `kubectl scale`** — blocked. Do not restart pods. Do not scale deployments. Do not modify configmaps or secrets. Destructive actions require on-call lead sign-off outside this skill.
- **Calling raw `kubectl` instead of `lets inspect surface k8s`** — blocked. The capability is the seam.
- **Claiming rollout health from `Ready=True` without inspecting events** — blocked. Do not claim healthy without events and pod status; events are required.
- Don't infer rollout success from pod count alone — e.g., 3/3 pods ready during a rolling deploy doesn't mean the new version is fully rolled out; old replicas may still be serving
- Don't produce a verdict without stating the time window — a "healthy" claim without a timestamp anchor is meaningless; a service that was healthy at T-30m may be degrading now

## Outputs

- Output: **Pod summary** — count by phase (Running / Pending / CrashLoopBackOff / etc.) with per-pod restart counts.
- Output: **Rollout status** — desired vs ready vs available replicas; rollout conditions.
- Output: **Recent events** — warning/error events in window, grouped by reason.
- Output: **Probe status** — `ok` | `not_ready` | `error`.
## Output Format — K8s Card

```
### K8s Card: {service} / {namespace}

**Probe status**: ok | not_ready | error
**Queries run**: pods ✓ | rollout ✓ | events ✓  (check all that were run)

#### Pod Summary
| Phase | Count | Restarts (max) |
|-------|-------|----------------|
| Running | N | N |
| Pending | N | — |
| CrashLoopBackOff | N | N |

#### Rollout Status
Desired: N | Ready: N | Available: N
Conditions: {list}

#### Recent Events (warnings only)
| Time | Reason | Object | Message |
|------|--------|--------|---------|

#### Verdict
HEALTHY | DEGRADED | UNKNOWN — <1–2 sentence rationale>
```

Done when: the k8s card is produced, or UNKNOWN is recorded with probe detail.
