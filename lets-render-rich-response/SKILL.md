---
name: lets-render-rich-response
description: "Use when an AI run should emit a rich rail tile (diff-view, simple-form, structured renderer, or sandboxed generated JSX) as a RailMessageV2 artifact. Orchestrates classification, envelope layout, codegen, validation, and publish — canonical types and renderers live in ux-engine."
metadata:
  author: letsbe10x
  version: "0.3.1"
  tags: [generative-ui, tile, rail, track-2, jsx, sandbox, rich-response, ux-engine]
lifecycle: published
source: https://github.com/letsbe10x/skill-hub/blob/main/lets-render-rich-response/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - render a tile
  - emit a rich response
  - generate a UI component in the rail
  - show a diff view in conversation
  - show a form in conversation
  - render JSX tile
  - emit structured rail content
  - create a comparison tile
goals:
  - render
outcome_runtime:
  open_agency_zones:
    - tile_kind_classification
    - jsx_generation
    - layout_selection
  governed_action_zones:
    - jsx_validation
    - publish_to_run_artifact
    - audit_record_emission
  allowed_moves:
    - classify_tile_kind
    - select_fast_path_renderer
    - emit_generated_tile_spec
    - fallback_to_prose
  hard_limits:
    - do_not_emit_generated_tile_without_validation
    - do_not_embed_credentials_in_tile_jsx  # noqa-capability: resources.secrets - explicit deny; tiles must not carry credentials
    - do_not_skip_fast_path_when_applicable
    - do_not_duplicate_ux_engine_contracts_in_skill_output
  validation_gates:
    - classification_gate
    - validation_gate
    - publish_gate
  mutation_policy: read_write
capabilities:
  surfaces: [ide, cli]
  resources: [file_system]
  handoffs:
    subagent: false  # noqa-capability: handoffs.subagent - orchestration only; no subagent delegation
    sub_runs: false
capabilities_evidence:
  - capability: "surfaces.ide"
    citation: "SKILL.md: When to Use"
  - capability: "surfaces.cli"
    citation: "SKILL.md: Example — assemble and validate scripts"
---

# lets-render-rich-response

## Overview

Agent-facing workflow for **Track 2 — Agentic Conversation Surfaces** (PRD-163, decision-037). This skill tells the agent **which bundled file to load at each step**; ux-engine owns renderers and contracts.

Progressive disclosure (agentskills.io): keep this file as the router. Load `assets/` for machine-readable catalogs, `references/` for procedure detail, `scripts/` for deterministic gates.

## Skill file map

### `assets/` — load on demand (data + templates)

| File | Load when | Use for |
|------|-----------|---------|
| [`assets/component-catalog.yml`](assets/component-catalog.yml) | Step 1 (catalog) | Authoritative map: `catalog_id` → `kind`, `schemaId`, renderer, `when` / `not_when`, template paths |
| [`assets/tile-kind-decision.yml`](assets/tile-kind-decision.yml) | Step 2 (classify) | Decision tree nodes → outcome `catalog_id` |
| [`assets/schemas/diff-view-payload.schema.json`](assets/schemas/diff-view-payload.schema.json) | Step 4, `catalog_id: diff-view` | Payload shape for `DiffViewRenderer` |
| [`assets/schemas/simple-form-payload.schema.json`](assets/schemas/simple-form-payload.schema.json) | Step 4, `catalog_id: simple-form` | Payload shape for `SimpleFormRenderer` |
| [`assets/templates/structured-diff-view.message.json`](assets/templates/structured-diff-view.message.json) | Step 3, manual assemble, diff-view | Envelope + placeholder fields for `kind: structured` diff |
| [`assets/templates/structured-simple-form.message.json`](assets/templates/structured-simple-form.message.json) | Step 3, manual assemble, simple-form | Envelope stub; fill `payload.fields` |
| [`assets/templates/generated-tile.message.json`](assets/templates/generated-tile.message.json) | Step 3, manual assemble, generated-tile | Envelope stub; fill `tile.jsx` after codegen |
| [`assets/templates/generated-metrics-card.jsx.txt`](assets/templates/generated-metrics-card.jsx.txt) | Step 3–4, generated-tile | Starter `React.createElement` tree (showcase metrics card; replace `{{placeholders}}`) |

### `references/` — load for the active step (procedures)

| File | Step | Use for |
|------|------|---------|
| [`references/canonical-sources.md`](references/canonical-sources.md) | Before Step 1 | External repos (ux-engine, ground-truth); do not re-type contracts |
| [`references/component-inventory.md`](references/component-inventory.md) | Step 1 | Human-readable index of catalog rows |
| [`references/assembly-from-ux-engine.md`](references/assembly-from-ux-engine.md) | Step 3 | How host collates: registry → `RailMessageRenderer` → renderer path |
| [`references/classify-tile-kind.md`](references/classify-tile-kind.md) | Step 2 | Kind definitions + output JSON; pairs with `tile-kind-decision.yml` |
| [`references/layout-envelope.md`](references/layout-envelope.md) | Step 3 | Required `RailMessageV2` fields per `kind` |
| [`references/generated-tile-code.md`](references/generated-tile-code.md) | Step 3–4, `generated-tile` only | `React.createElement` rules, bridge API, `GeneratedTileSpec` fields |
| [`references/validate-tile-jsx.md`](references/validate-tile-jsx.md) | Step 4, `generated-tile` | Ban list + when to run `validate-tile-jsx.py` |
| [`references/publish-artifact.md`](references/publish-artifact.md) | Step 5 | Host publish + `AuditAdapter` record shapes |
| [`references/bench-cases.md`](references/bench-cases.md) | Step 6 (optional) | Forge bench prompts; wire to scripts as `program` verifiers |

### `scripts/` — run at gates (deterministic; stdout JSON, exit code)

| Script | Step | Run when | Arguments |
|--------|------|----------|-----------|
| [`scripts/assemble-rail-message.py`](scripts/assemble-rail-message.py) | 3 | After `catalog_id` known | `--catalog-id`, `--envelope`, `--payload`; optional `--jsx-file` for generated |
| [`scripts/validate-structured-payload.py`](scripts/validate-structured-payload.py) | 4 | `catalog_id` is `diff-view` or `simple-form` | `--schema diff-view\|simple-form`, `--payload-file` |
| [`scripts/validate-tile-jsx.py`](scripts/validate-tile-jsx.py) | 4 | `catalog_id` is `generated-tile` | `--jsx-file`, `--spec-file` (tile spec JSON) |

### Step → file quick reference

| Step | Read (`assets/` + `references/`) | Run (`scripts/`) |
|------|----------------------------------|------------------|
| 1 Catalog | `component-catalog.yml`, `component-inventory.md`, `canonical-sources.md` | — |
| 2 Classify | `tile-kind-decision.yml`, `classify-tile-kind.md` | — |
| 3 Assemble | `assembly-from-ux-engine.md`, `layout-envelope.md`; path-specific template + `generated-tile-code.md` if generated | `assemble-rail-message.py` **or** hand-fill template from catalog row |
| 4 Validate | `validate-tile-jsx.md` if generated | `validate-structured-payload.py` **or** `validate-tile-jsx.py` |
| 5 Publish | `publish-artifact.md` | — |
| 6 Verify (optional) | `bench-cases.md` | `forge check` (skill-forge) |

## When to Use

- A run should show a before/after diff, inline form, custom metrics tile, or registry structured message in the rail.
- You need to **collate** a `RailMessageV2` the host can route without importing React in the agent runtime.

## When NOT to Use

- Plain prose only → `kind: "text"` without this skill.
- Implementing renderers or harness → ux-engine + [`lets-build-ui`](https://github.com/letsbe10x/skills/blob/main/lets-build-ui/references/ux-engine-stack.md).
- Server-only live data in iframe with no embedded payload → redesign the turn.

## Inputs and Outputs

**Inputs:** `runId`, `episodeId`, intent, optional `layoutHint`, payload blobs or metrics for templates.

**Outputs:** `RailMessageV2` on the run stream; audit via host `AuditAdapter`.

## Example

Paths below are relative to this skill directory (the folder containing `SKILL.md`).

```bash
ROOT=.

# Step 2 — classify (read assets/tile-kind-decision.yml → catalog_id: diff-view)

# Step 3 — assemble (script reads assets/component-catalog.yml internally)
python3 $ROOT/scripts/assemble-rail-message.py \
  --catalog-id diff-view \
  --envelope '{"runId":"run-abc","messageId":"msg-1","label":"Config diff","summary":"Config before/after"}' \
  --payload '{"left":"a: 1","right":"a: 2","title":"Config"}' \
  --out /tmp/rail-message.json

# Step 4 — validate structured payload
python3 $ROOT/scripts/validate-structured-payload.py \
  --schema diff-view \
  --payload '{"left":"a: 1","right":"a: 2","title":"Config"}'

# Generated path (catalog_id: generated-tile):
#   - codegen from assets/templates/generated-metrics-card.jsx.txt
#   - then:
python3 $ROOT/scripts/validate-tile-jsx.py \
  --jsx-file /tmp/tile.jsx \
  --spec-file /tmp/tile-spec.json

# Step 5 — publish per references/publish-artifact.md (host integration)
```

## Steps

1. **Catalog** (input: run intent, host `registeredSchemas`) → output: shortlist of `catalog_id` values.
   - **Load:** [`assets/component-catalog.yml`](assets/component-catalog.yml), [`references/component-inventory.md`](references/component-inventory.md), [`references/canonical-sources.md`](references/canonical-sources.md).

2. **Classify** (input: intent) → output: single `catalog_id`; **checkpoint classification_gate:** confirm `catalog_id` with the operator before assemble if ambiguous.
   - **Load:** [`assets/tile-kind-decision.yml`](assets/tile-kind-decision.yml), [`references/classify-tile-kind.md`](references/classify-tile-kind.md).
   - **Cross-check:** chosen row in `component-catalog.yml` (`when` / `not_when`).

3. **Assemble** (input: `catalog_id`, envelope, payload) → output: `RailMessageV2` JSON.
   - **Load:** [`references/assembly-from-ux-engine.md`](references/assembly-from-ux-engine.md), [`references/layout-envelope.md`](references/layout-envelope.md).
   - **Per `catalog_id` (from catalog row `template` / `schema`):**
     - `diff-view` → template [`assets/templates/structured-diff-view.message.json`](assets/templates/structured-diff-view.message.json); schema [`assets/schemas/diff-view-payload.schema.json`](assets/schemas/diff-view-payload.schema.json).
     - `simple-form` → template [`assets/templates/structured-simple-form.message.json`](assets/templates/structured-simple-form.message.json); schema [`assets/schemas/simple-form-payload.schema.json`](assets/schemas/simple-form-payload.schema.json).
     - `generated-tile` → template [`assets/templates/generated-tile.message.json`](assets/templates/generated-tile.message.json); JSX starter [`assets/templates/generated-metrics-card.jsx.txt`](assets/templates/generated-metrics-card.jsx.txt); procedure [`references/generated-tile-code.md`](references/generated-tile-code.md).
   - **Run (preferred):** [`scripts/assemble-rail-message.py`](scripts/assemble-rail-message.py) with `--catalog-id` matching the classified row.

4. **Validate** (input: assembled message) → output: pass before **validation_gate** clears; do not proceed to publish until the Step 4 script exits 0.
   - **If `diff-view` or `simple-form`:** **Run** [`scripts/validate-structured-payload.py`](scripts/validate-structured-payload.py) with `--schema` matching `schemaId`.
   - **If `generated-tile`:** **Load** [`references/validate-tile-jsx.md`](references/validate-tile-jsx.md); **Run** [`scripts/validate-tile-jsx.py`](scripts/validate-tile-jsx.py).
   - **If validation fails:** do not publish; go to Fallback.

5. **Publish** (input: validated `RailMessageV2`) → output: message on run stream + audit records; **checkpoint publish_gate:** attach only after validation_gate passed.
   - **Load:** [`references/publish-artifact.md`](references/publish-artifact.md).

6. **Verify** (optional; skill maintenance) → output: forge/bench evidence.
   - **Load:** [`references/bench-cases.md`](references/bench-cases.md).

## Governance invariants

- **Collate, don't re-render:** Emit `RailMessageV2`; host runs `RailMessageRenderer` ([`references/assembly-from-ux-engine.md`](references/assembly-from-ux-engine.md)).
- **Fast-path first:** Prefer catalog rows `diff-view` and `simple-form` over `generated-tile` ([`assets/component-catalog.yml`](assets/component-catalog.yml)).
- **Token-safe generated JSX:** Use [`assets/templates/generated-metrics-card.jsx.txt`](assets/templates/generated-metrics-card.jsx.txt) patterns (`var(--ux-*)`).
- **Fail closed:** Scripts exit non-zero → prose fallback ([`references/publish-artifact.md`](references/publish-artifact.md)).

## Outputs

| Artifact | Produced by |
|----------|-------------|
| `RailMessageV2` | Step 3 template or [`scripts/assemble-rail-message.py`](scripts/assemble-rail-message.py) |
| Validated payload / JSX | Step 4 scripts under [`scripts/`](scripts/) |
| Audit records | Step 5 host [`references/publish-artifact.md`](references/publish-artifact.md) |

**Done when:** `catalog_id` recorded, the Step 4 script for that path exits 0, and publish gate satisfied (or prose fallback emitted).

## Anti-patterns

- **Skipping the file map** — Do not improvise paths; each step lists required `assets/`, `references/`, and `scripts/` entries.
- **Loading all references upfront** — Load only files for the current step and `catalog_id`.
- **Hand-editing without catalog row** — `component-catalog.yml` is the source of `schemaId`, templates, and renderer path.
- **Custom diff/form JSX** — Use structured templates, not `generated-tile`.
- **Publishing without Step 4 script** — Validators in [`scripts/`](scripts/) are mandatory for their paths.
- **Credentials in tile JSX** — Host bridge attaches auth.  # noqa-capability: resources.secrets - explicit deny; tiles must not carry credentials

## Error handling

| Failure | Action | Recovery |
|---------|--------|----------|
| If classification is ambiguous | Stop at classification_gate; re-read [`assets/tile-kind-decision.yml`](assets/tile-kind-decision.yml) | Instead emit `kind: "text"` |
| If [`scripts/validate-structured-payload.py`](scripts/validate-structured-payload.py) fails | Fix payload against [`assets/schemas/`](assets/schemas/) | Retry validate |
| If [`scripts/validate-tile-jsx.py`](scripts/validate-tile-jsx.py) fails | See [`references/validate-tile-jsx.md`](references/validate-tile-jsx.md) | Prose fallback + `validation_failure` |
| If host registry misses `schemaId` | See [`references/assembly-from-ux-engine.md`](references/assembly-from-ux-engine.md) | Reclassify or register schema |
| If publish sink unavailable | See [`references/publish-artifact.md`](references/publish-artifact.md) | Instead emit text |

## Fallback

If validation fails or publish is unavailable: `kind: "text"` with complete `summary`. Never ship partial `GeneratedTileSpec`.
