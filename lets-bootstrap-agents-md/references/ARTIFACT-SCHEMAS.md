# Artifact Schemas — lets-bootstrap-agents-md

All intermediate artifacts are written to the working directory. They are disposable after the skill completes — never committed to the repo.

## Working directory contract

```
/tmp/{repo-name}/.agents-bootstrap/
  directory-tree.json      # Phase 2
  evidence-index.json      # Phase 2 (updated Phase 6)
  modules.json             # Phase 3
  command-catalog.json     # Phase 4
  staleness-report.json    # Phase 2 (update mode only)
  section-scorecard.json   # Phase 6
```

`{repo-name}` is the basename of the repo root directory (e.g. `core`, `adapters`).

---

## Schemas

Each artifact has a JSON Schema in `assets/templates/`. Read the schema when generating or validating the artifact.

| Artifact | Schema | Phase |
|----------|--------|-------|
| `directory-tree.json` | [directory-tree.schema.json](../assets/templates/directory-tree.schema.json) | Phase 2 |
| `evidence-index.json` | [evidence-index.schema.json](../assets/templates/evidence-index.schema.json) | Phase 2, updated Phase 6 |
| `modules.json` | [modules.schema.json](../assets/templates/modules.schema.json) | Phase 3 |
| `command-catalog.json` | [command-catalog.schema.json](../assets/templates/command-catalog.schema.json) | Phase 4 |
| `staleness-report.json` | [staleness-report.schema.json](../assets/templates/staleness-report.schema.json) | Phase 2 (update mode) |
| `section-scorecard.json` | [section-scorecard.schema.json](../assets/templates/section-scorecard.schema.json) | Phase 6 |

---

## Quick reference (key fields)

### directory-tree.json

Module hierarchy with discovery indicators. Keyed by relative path.

Key fields: `depth`, `file_count`, `has_init`, `has_tests`, `has_agents_md`, `subdirs`

### evidence-index.json

File-backed claims per module. Every claim must trace to ≥1 source file.

Key fields: `source_refs`, `key_files`, `doc_refs`, `invariants`, `patterns[]` (with `confidence` score), `gotchas`

### modules.json

Tiering decisions with dependency mapping.

Key fields: `modules[].path`, `modules[].tier` (1 or 2), `modules[].reason`, `modules[].sections`, `modules[].depends_on`, `modules[].consumed_by`, `tier_3_coverage`

### command-catalog.json

All discovered commands with classification.

Key fields: `commands[].command`, `commands[].source`, `commands[].status` (VERIFIED/PLAUSIBLE/BLOCKED), `commands[].scope`, `commands[].block_reason`

### staleness-report.json (update mode only)

What changed since last AGENTS.md compilation.

Key fields: `stale_modules[].reasons`, `new_modules[]`, `deleted_modules[]`

### section-scorecard.json

Per-section quality scores for generated files.

Key fields: `sections[].confidence` (0.0-1.0), `sections[].evidence_refs`, `sections[].flags`

---

## Command taxonomy

| Status | Rule | Appears in AGENTS.md? |
|---|---|---|
| VERIFIED | Exists verbatim in Makefile target, `pyproject.toml` script, or CI step | Yes — use in Commands and verify steps |
| PLAUSIBLE | Mentioned in docs but not in a build surface | Yes — only in Decision-Making, marked `(unverified)` |
| BLOCKED | Destructive, secret-revealing, or infrastructure-mutating | Never — excluded from all output |

**BLOCKED triggers:** `--force`, `--hard`, `rm -rf`, `drop`, `delete`, `destroy`, `nuke`, secrets/tokens, production infra without safety wrapper.

---

## Confidence scoring rules

| Score | Meaning | Action |
|---|---|---|
| 0.9 - 1.0 | High — multiple corroborating sources | Include without flag |
| 0.6 - 0.89 | Moderate — evidence exists but limited | Include, note source count |
| < 0.6 | Low — insufficient evidence | Flag for user review |

**Scoring inputs:**

| Factor | Weight |
|---|---|
| File count supporting the claim | +0.2 per file (max +0.6) |
| Claim in existing AGENTS.md or README | +0.2 |
| Claim in CI enforcement (test, lint rule) | +0.2 |
| Claim contradicted by a source file | -0.5 |
| Claim is inferred only (no direct statement) | -0.2 |

Minimum score for inclusion without user confirmation: **0.6**.
