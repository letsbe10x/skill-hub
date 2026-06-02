---
name: lets-manage-alerts
description: "Use this skill whenever the user wants to check whether alerts are firing, review recent alert history, or find out who got paged and where alerts route. Trigger on incident phrasing like 'is anything firing', 'did we page anyone', 'was there an alert during the deploy', 'who is on call for this', 'check if alerts went off', or 'are we paging right now'. Read-only — never silences or edits alert rules."
metadata:
  author: letsbe10x
  version: "0.1.0"
  tags: [observability, alerts, watchtower]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-manage-alerts/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
  requirements:
    - "adapter capability: alerts"
triggers:
  - check alerts
  - is anything paging
  - alert history
  - alert routing
goals:
  - inspect_service
outcome_runtime:
  open_agency_zones:
    - alert_scope_selection
    - paging_severity_assessment
  validation_gates:
    - surface_readiness_gate

    - alert_state_claim
  allowed_moves:
    - narrow_time_window
    - request_missing_capability
  hard_limits:
    - do_not_mutate_alert_rules
    - do_not_silence_alerts
    - do_not_claim_quiet_without_probe_success
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
---

## Investigation Law

**NO "ALL QUIET" CLAIM WITHOUT THE ALERTS CAPABILITY RETURNING A SUCCESSFUL PROBE.**

A timeout, empty response, not_ready, or stale last-sync is NOT evidence of silence — it is absence of evidence. Report UNKNOWN and escalate to lets-watch-service.

## Overview

`lets-manage-alerts` reads the alerts surface of the watchtower capability contract. It answers "what is firing, what fired recently, and where does it route?" Read-only by invariant; mutation is never within scope.

## Note
`lets-watch-service` is the fan-out orchestrator skill — use it when you need metrics, logs, k8s, and alerts correlated in a single investigation rather than querying each surface individually.

## When to Use

- You are triaging and need the list of currently firing alerts for a service.
- You need the last N hours of alert history to correlate with a change.
- You need to confirm the routing target (PagerDuty/Slack/email) for an alert.
- Do NOT use when you also need metrics, logs, or k8s context — route through `lets-watch-service`.

## Steps

1. **Identify scope** — service name, time window, and question type:
   - `firing` — what alerts are active right now
   - `history` — what fired in the window
   - `routing` — where does an alert route (channel, on-call target)
2. **Run the probe** `lets inspect surface alerts --service $SERVICE --window-hours $HOURS` — the alerts capability adapter handles provider specifics (Grafana alerting, Splunk alerts, Prometheus Alertmanager). Output is JSON by default; pass `--format human` for a structured card.
3. **Handle probe status first:**
   - `ok` → proceed
   - `not_ready` → stop, report `UNKNOWN`, recommend re-run through `lets-watch-service`
   - `error` → retry once; if still error, report `UNKNOWN` with error detail — do NOT infer silence

4. **Silence requires explicit empty list, not absence of response** — probe must return `ok` with an empty firing set. Anything else is `UNKNOWN`.

5. **Emit the alert card.**


## Anti-patterns

- **Attempting to silence or edit an alert** — blocked. Do not mutate alert rules. Do not silence alerts. This skill is read-only.
- **Inferring "quiet" from a probe failure** — blocked. Do not claim quiet without probe success; missing signal is UNKNOWN.
- **Calling Alertmanager / Splunk alert APIs directly** — blocked. The `lets inspect surface alerts` capability is the seam.
- Don't treat routing information as current on-call truth — alert routing config tells you the channel or service, not necessarily who is on-call right now. On-call schedules rotate; if the user needs to know who to contact, that requires a separate on-call lookup, not this skill.
- Don't surface alert rule config details as health evidence — knowing that an alert rule exists for a condition is not the same as knowing it fired. Don't conflate "there is an alert configured for high error rate" with "high error rate was detected."

## Outputs

- Output: **Currently firing** — list of active alerts with severity, age, route.
- Output: **Recent history** — alerts in window grouped by rule.
- Output: **Routing** — per-alert destination (PagerDuty service, Slack channel, on-call user).
- Output: **Probe status** — `ok` | `not_ready` | `error`.

## Output Format — Alert Card

```
### Alert Card: {service} / {window}

**Probe status**: ok | not_ready | error
**Probe sync timestamp**: {timestamp} | stale | unknown

#### Currently Firing
| Alert rule | Severity | Age | Route |
|------------|----------|-----|-------|
| ...        | critical/warning | Nm | PD:service / Slack:#channel |

(none firing — confirmed by probe)

#### Recent History ({window})
| Alert rule | Fired at | Resolved at | Duration |
|------------|----------|-------------|----------|

#### Routing
| Alert rule | Destination | On-call target |
|------------|-------------|----------------|

#### Verdict
FIRING ({N} active) | QUIET (confirmed) | UNKNOWN — {reason}
```

Done when: the alert card is produced or `UNKNOWN` is recorded with the probe error.
