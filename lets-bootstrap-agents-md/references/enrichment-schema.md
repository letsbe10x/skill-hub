# Enrichment JSON Schema — lets-bootstrap-agents-md

The enrichment file is written to `/tmp/<repo-name>/.agents-bootstrap/enrichment.json` in Phase 8 and passed to `lets context enrich`. It carries the three fields that populate the engineering context pack: `repo_summary`, `key_flows`, and `architecture_invariants`.

## Schema

```json
{
  "pack_id": "engineering",
  "repo_summary": "<string: ≤ 3 sentences, evidence-derived>",
  "key_flows": [
    "<string: one sentence per flow, 3–7 items>"
  ],
  "architecture_invariants": [
    "<string: one invariant per item, 3–10 items>"
  ]
}
```

## Field constraints

### pack_id

Must be exactly `"engineering"`. No other value is accepted by `lets context enrich`.

### repo_summary

- Required. Must be present and non-empty.
- Maximum 3 sentences, maximum 300 characters.
- Must be evidence-derived — synthesized from `README.md`, the root `AGENTS.md`, and the module map produced in Phase 5. Do not invent.
- Example:
  > "letsbe10x/core is a multi-layer Python runtime for AI-assisted software delivery, providing goal execution, context management, and platform integrations. It is organized into five layers — packs, governance, platform, sdlc, and engine — with strict one-directional dependencies. The engine layer has no imports from sdlc or platform."

### key_flows

- 3–7 items. Required.
- Each item is one sentence describing a cross-module execution path.
- Derived from goal IDs (e.g. `change_code`, `verify_change`, `deploy_service`), the module map, and critical path context in `service.yaml`.
- Example items:
  - `"change_code goal: engine/goals triggers engine/runs lifecycle, which writes artifacts via engine/artifacts"`
  - `"verify_change goal: engine/goals invokes sdlc/delivery stage contracts and emits events via engine/events"`
  - `"onboard_repo goal: platform/repo bootstrap runs, then platform/runtime doctor validates the environment"`
  - `"pack install flow: packs/lifecycle discovers overlays and applies them without touching engine or platform"`

### architecture_invariants

- 3–10 items. Required.
- Each item must appear verbatim or in substance in a generated AGENTS.md invariants section — do not add invariants here that are not reflected in the module files.
- Derived from AGENTS.md invariants sections produced in Phase 5 and Phase 6.
- Example items (drawn from this repo's CLAUDE.md):
  - `"engine/ has no top-level imports from sdlc/ or platform/"`
  - `"packs/ has no internal dependencies"`
  - `"events are append-only — never mutate a written event"`
  - `"memory writes are atomic via exclusive-create + os.replace"`

## Validation before running lets context enrich

Before invoking `lets context enrich`, verify:

1. `pack_id` is exactly `"engineering"`.
2. `repo_summary` is non-empty and ≤ 300 characters.
3. `key_flows` has between 3 and 7 items, each non-empty.
4. `architecture_invariants` has between 3 and 10 items, each non-empty.
5. Every invariant in `architecture_invariants` appears in at least one AGENTS.md file written in Phase 5 or Phase 6.

If any check fails, fix the enrichment file before running the command. Do not pass a malformed enrichment file to `lets context enrich`.
