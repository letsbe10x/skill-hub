# Intake Guide — lets-bootstrap-repo

How to present Phase 2 intake questions: choice menus with recommended defaults, validation rules, and staleness handling.

## Intake Card (present first)

Before asking questions, present the current state:

```
Repo: <basename of repo root>
Artifact          Present   Verified   Stale
service.yaml        ✓/✗       ✓/✗       ✓/✗
engineering.yaml    ✓/✗       ✓/✗       ✓/✗
AGENTS.md           ✓/✗       —         —
CLAUDE.md           ✓/✗       —         —
CI config           ✓/✗       —         —
```

Then ask: which bootstrap depth?

| Depth | What you get |
|-------|-------------|
| **Baseline** (Recommended) | Capture service truth + readiness report |
| **Operational** | + auto-discover engineering + delivery facts |
| **Full** | + discover observability + offer enrichment |

---

## Question Set (ask one at a time)

### Question 1 — Approver identity

**Ask:** "Who is approving this bootstrap? Provide your email or handle."

**Validation:** Non-empty string, no spaces. Example: `cogsmith-ai` or `rahul@example.com`.

**Maps to:** `service.approved_by`

---

### Question 2 — Repo description

**Ask:** "In one sentence, what does this repo do?"

**Validation:** Non-empty, ≤ 200 characters.

**Maps to:** `service.purpose`

---

### Question 3 — Non-negotiables

**Ask:** "What are 2–5 invariants that must never regress?"

**Examples to show:**
- "No authenticated session tokens stored in plaintext"
- "Public API contract stays backward-compatible"
- "All database migrations must be reversible"

**Validation:** 2–7 items. If fewer than 2: prompt once more — "Can you add at least one more? Non-negotiables gate AI mutations."

**Maps to:** `service.non_negotiables[]`

---

### Question 4 — Critical flows

**Ask:** "What are the 2–5 critical user or system flows?"

**Examples to show:**
- "End-to-end user onboarding"
- "Payment processing pipeline"
- "CI green gate → deploy"

**Validation:** 2–7 items.

**Maps to:** `service.critical_paths[]`

---

### Question 5 — Repo type (choice menu)

**Ask:** "What type of repo is this?"

| Choice | Description |
|--------|-------------|
| `service-or-application` (Recommended) | Web service, API, or user-facing application |
| `library-or-package` | Shared library or published package |
| `workflow-or-tooling-platform` | Developer tools, CI/CD tooling, internal platform |
| `monorepo-or-multi-service` | Multiple services or packages in one repo |

**Default:** Infer from repo shape. If `src/` + `Dockerfile` → `service-or-application`. If `setup.py`/`pyproject.toml` with `[project]` → `library-or-package`. If multiple top-level services → `monorepo-or-multi-service`.

**Maps to:** `service.type`

---

### Question 6 — Governance posture (choice menu)

**Ask:** "Which governance posture fits this repo best?"

| Choice | Description |
|--------|-------------|
| `guarded` | Every AI mutation requires human review; strictest |
| `balanced` (Recommended) | AI-assisted edits with owner review |
| `adaptive` | AI can make most changes; spot review |
| `experimental` | Minimal gates; prototyping/research repos |

**Maps to:** `service.governance_profile`

---

### Question 7 — Operational posture (choice menu)

**Ask:** "Which operational posture fits?"

| Choice | Description |
|--------|-------------|
| `intensive` | 24×7 availability; strict rollback; prod-critical |
| `managed` (Recommended) | Business-hours availability; standard rollback |
| `moderate` | Best-effort; relaxed recovery |
| `lightweight` | Dev/internal tooling; minimal gates |

**Maps to:** `service.operational_posture`

---

## Staleness Handling

When artifacts exist but may be stale, present:

```
service.yaml was last modified <N days ago>.
```

Then ask:

| Choice | Action |
|--------|--------|
| **Re-verify** (Recommended) | Keep existing content, refresh verification timestamp |
| **Re-bootstrap** | Discard and recapture from scratch (requires `--force`) |
| **Skip** | Leave as-is, proceed to next phase |

**Staleness signals:**
- `last_compiled_date` > 90 days old
- Referenced files no longer exist on disk
- Referenced commands no longer in Makefile/pyproject.toml
- Module structure has changed significantly (new top-level dirs)

---

## Validation Summary

| Field | Rule |
|-------|------|
| `approved_by` | Non-empty, no spaces |
| `purpose` | Non-empty, ≤ 200 chars |
| `non_negotiables` | 2–7 items |
| `critical_paths` | 2–7 items |
| `type` | One of: service-or-application, library-or-package, workflow-or-tooling-platform, monorepo-or-multi-service |
| `governance_profile` | One of: guarded, balanced, adaptive, experimental |
| `operational_posture` | One of: intensive, managed, moderate, lightweight |
