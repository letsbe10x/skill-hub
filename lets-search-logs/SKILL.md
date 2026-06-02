---
name: lets-search-logs
description: "Use this skill whenever the user wants to search, inspect, or investigate service logs — including finding errors, tracing requests by correlation/trace ID, debugging incidents, checking service health via log evidence, or counting error occurrences. Trigger even for casual phrasing like 'what went wrong', 'why did X fail', 'check the logs for Y', or 'did service Z have errors between 2-4am'. Splunk/watchtower is the backend; this skill is read-only and handles index coverage validation automatically."
metadata:
  author: letsbe10x
  version: "0.1.0"
  tags: [observability, logs, splunk, watchtower]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-search-logs/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
  requirements:
    - "adapter capability: logs"
triggers:
  - search logs
  - splunk query
  - find this error
  - correlation id
goals:
  - inspect_service
outcome_runtime:
  open_agency_zones:
    - query_scope_selection
    - pattern_assessment
  validation_gates:
    - surface_readiness_gate

    - log_evidence_claim
  allowed_moves:
    - narrow_time_window
    - pivot_to_correlation_id
    - request_missing_capability
  hard_limits:
    - do_not_exfiltrate_pii
    - do_not_claim_no_errors_without_index_coverage
  mutation_policy: read_only
  human_checkpoint_triggers:
    - missing_truth
    - sensitive_data_exposure
---

## Investigation Law

**NO "NO ERRORS FOUND" CLAIM WITHOUT CONFIRMED INDEX COVERAGE FOR THE WINDOW.**

A query that returned zero hits against an index that has no events in the window is not evidence of health. Confirm index coverage (event count > 0) before any silence claim.

## Overview

`lets-search-logs` reads the logs surface of the watchtower capability contract. Splunk is the backend today; the capability is structured so additional log backends (Loki, CloudWatch) can be introduced without changing this skill. Read-only by invariant.

## When to Use

- You have a time window and an error string or correlation id to search for.
- You need to count error occurrences by sourcetype for a service.
- You are correlating a metric dip with underlying log events.
- Do NOT use for alerts (`lets-manage-alerts`), metrics (`lets-inspect-metrics`), or pod state (`lets-diagnose-k8s`).

## Steps

1. Identify the service, index/sourcetype (if known), time window, and search pattern or correlation id.
2. Run `lets inspect surface logs --service $SERVICE --since $WINDOW --pattern $PATTERN` — `$WINDOW` is relative (`15m`, `2h`, `1d`); `$PATTERN` is a backend-native filter (SPL fragment for Splunk, grep for other backends). Output is JSON; `--format human` emits a card.
3. Verify index coverage — confirm the capability response includes event count > 0. If zero events in window: record `no_coverage` and stop.
4. If the probe returns `not_ready`: stop, report `UNKNOWN`.
5. Summarise into the logs card.

## Anti-patterns

- **Running raw `splunk search` or hitting `/services/search` directly** — blocked. `lets inspect surface logs` is the seam.
- **Pasting raw log lines containing PII or credentials into the output** — blocked. Do not exfiltrate PII. Hash or redact correlation ids; never surface secrets.
- **Concluding "no errors" when index coverage is zero** — blocked. Do not claim no errors without index coverage. No coverage is UNKNOWN, not silence.

## Outputs

- Output: **Matching events** — top N matches with timestamp, sourcetype, redacted message.
- Output: **Histogram** — event count per bucket across the window.
- Output: **Index coverage** — confirmed / no_coverage / not_ready.
- Output: **Probe status** — `ok` | `no_coverage` | `not_ready` | `error`.

Done when: the logs card is produced, or UNKNOWN is recorded with probe/coverage detail.
