# Artifact Schemas — lets-bootstrap-agents-md

All intermediate artifacts are written to the working directory. They are disposable after the skill completes — never committed to the repo.

## Working directory contract

```
/tmp/<repo-name>/.agents-bootstrap/
  directory-tree.json      # Phase 2
  evidence-index.json      # Phase 2 (updated Phase 6)
  modules.json             # Phase 3
  command-catalog.json     # Phase 4
  staleness-report.json    # Phase 2 (update mode only)
  section-scorecard.json   # Phase 6
  enrichment.json          # Phase 8 (see enrichment-schema.md)
```

`<repo-name>` is the basename of the repo root directory (e.g. `core`, `adapters`).

---

## directory-tree.json (Phase 2)

Module hierarchy with discovery indicators.

```json
{
  "<relative-path>/": {
    "depth": 2,
    "file_count": 7,
    "has_init": true,
    "has_tests": false,
    "has_agents_md": false,
    "subdirs": ["goals/", "runs/", "context/"]
  }
}
```

| Field | Type | Description |
|---|---|---|
| `depth` | int | Directory depth from repo root (root = 0) |
| `file_count` | int | Immediate file count (not recursive) |
| `has_init` | bool | Contains `__init__.py` (Python package indicator) |
| `has_tests` | bool | Contains test files or a `tests/` subdir |
| `has_agents_md` | bool | Existing AGENTS.md present on disk |
| `subdirs` | string[] | Immediate subdirectory names (trailing `/`) |

---

## evidence-index.json (Phase 2, updated Phase 6)

File-backed claims per module. Every claim must trace to at least one source file.

```json
{
  "<relative-path>/": {
    "source_refs": ["file1.py", "subdir/"],
    "key_files": ["registry.py", "base.py"],
    "doc_refs": ["AGENTS.md", "README.md"],
    "invariants": ["engine has no imports from platform"],
    "patterns": [
      {
        "name": "registry pattern",
        "files": ["goals/registry.py", "events/registry.py", "hooks/registry.py"],
        "confidence": 0.9
      }
    ],
    "gotchas": ["# HACK: order matters here due to circular import"]
  }
}
```

| Field | Type | Description |
|---|---|---|
| `source_refs` | string[] | Files/dirs that provide evidence for this module's claims |
| `key_files` | string[] | Most important files (by import count or entry-point status) |
| `doc_refs` | string[] | Existing documentation files found in this module |
| `invariants` | string[] | Architecture rules with file-backed evidence |
| `patterns` | object[] | Recurring patterns detected across ≥ 3 files |
| `patterns[].confidence` | float | 0.0-1.0 confidence score (see scoring rules below) |
| `gotchas` | string[] | HACK/FIXME/WARNING comments verbatim |

---

## modules.json (Phase 3)

Tiering decisions with rationale.

```json
{
  "modules": [
    {
      "path": "src/engine/goals/",
      "tier": 1,
      "reason": "top-level package with > 3 subdirectories",
      "sections": ["scope", "architecture", "patterns", "testing", "boundaries", "related", "conventions"],
      "depends_on": ["src/engine/runs/", "src/engine/context/"],
      "consumed_by": ["src/platform/hooks/"]
    },
    {
      "path": "src/engine/context/discovery/",
      "tier": 2,
      "reason": "has > 2 files with distinct responsibilities",
      "sections": ["scope", "patterns", "related"],
      "depends_on": ["src/engine/context/"],
      "consumed_by": []
    }
  ],
  "tier_3_coverage": {
    "src/engine/events.py": "covered by src/engine/ module map"
  }
}
```

| Field | Type | Description |
|---|---|---|
| `modules[].path` | string | Relative path from repo root (trailing `/`) |
| `modules[].tier` | int | 1 or 2 |
| `modules[].reason` | string | Which tiering criterion was met |
| `modules[].sections` | string[] | Sections to generate (from tier template) |
| `modules[].depends_on` | string[] | Modules this one imports from |
| `modules[].consumed_by` | string[] | Modules that import from this one |
| `tier_3_coverage` | object | Tier 3 dirs mapped to the parent that documents them |

---

## command-catalog.json (Phase 4)

All discovered commands with classification.

```json
{
  "commands": [
    {
      "command": "uv run pytest tests/ -v",
      "source": "Makefile:test",
      "status": "VERIFIED",
      "scope": "repo-wide",
      "modules": ["src/engine/", "src/platform/"]
    },
    {
      "command": "npm run build",
      "source": "README.md",
      "status": "PLAUSIBLE",
      "scope": "repo-wide",
      "modules": []
    },
    {
      "command": "docker compose down -v --remove-orphans",
      "source": "Makefile:nuke",
      "status": "BLOCKED",
      "scope": "repo-wide",
      "modules": [],
      "block_reason": "destructive operation"
    }
  ]
}
```

### Command taxonomy

| Status | Rule | Appears in AGENTS.md? |
|---|---|---|
| VERIFIED | Command exists verbatim as a Makefile target, `pyproject.toml` script, or CI step | Yes — use freely in Commands and verify steps |
| PLAUSIBLE | Mentioned in docs (README, CONTRIBUTING) but not in a build surface | Yes — only in Decision-Making Guidance, marked `(unverified)` |
| BLOCKED | Destructive, secret-revealing, or infrastructure-mutating | Never — excluded from all output |

**BLOCKED classification triggers:**
- Contains `--force`, `--hard`, `rm -rf`, `drop`, `delete`, `destroy`, `nuke`
- References secrets, tokens, or credentials
- Targets production infrastructure (deploy, publish, release) without a safety wrapper
- Marked dangerous in source comments

---

## staleness-report.json (Phase 2, update mode only)

Identifies what changed since the last AGENTS.md compilation.

```json
{
  "generated_at": "2026-05-11T00:00:00Z",
  "stale_modules": [
    {
      "path": "src/engine/goals/",
      "reasons": [
        "references deleted file: src/engine/goals/legacy.py",
        "missing required section: conventions",
        "last_compiled_date > 90 days and module changed"
      ]
    }
  ],
  "new_modules": [
    {
      "path": "src/engine/streaming/",
      "reason": "new directory with __init__.py, not in any existing AGENTS.md"
    }
  ],
  "deleted_modules": [
    {
      "path": "src/engine/legacy/",
      "reason": "directory no longer exists on disk"
    }
  ]
}
```

| Field | Type | Description |
|---|---|---|
| `stale_modules[].reasons` | string[] | All staleness signals (from tiering.md freshness rules) |
| `new_modules` | object[] | Directories that qualify for Tier 1/2 but have no AGENTS.md |
| `deleted_modules` | object[] | Modules referenced in existing AGENTS.md that no longer exist |

---

## section-scorecard.json (Phase 6)

Quality scores for the root AGENTS.md, used to decide if a section needs user review.

```json
{
  "file": "AGENTS.md",
  "sections": [
    {
      "name": "Project Overview",
      "line_count": 12,
      "evidence_refs": 4,
      "confidence": 0.95,
      "flags": []
    },
    {
      "name": "Critical Coding Rules",
      "line_count": 8,
      "evidence_refs": 6,
      "confidence": 0.72,
      "flags": ["one rule has only 2 file refs (below 3 threshold)"]
    },
    {
      "name": "Anti-Patterns and Tribal Knowledge",
      "line_count": 5,
      "evidence_refs": 2,
      "confidence": 0.55,
      "flags": ["below confidence threshold — flag for user review"]
    }
  ]
}
```

---

## Confidence scoring rules

Confidence is a float from 0.0 to 1.0 assigned to patterns, invariants, and sections.

| Score range | Meaning | Action |
|---|---|---|
| 0.9 - 1.0 | High confidence — multiple corroborating sources | Include without flag |
| 0.6 - 0.89 | Moderate confidence — evidence exists but limited | Include, note source count |
| < 0.6 | Low confidence — insufficient evidence | Flag for user review, do not include without confirmation |

**Scoring inputs:**

| Factor | Weight |
|---|---|
| File count supporting the claim | +0.2 per file (max +0.6) |
| Claim appears in existing AGENTS.md or README | +0.2 |
| Claim appears in CI enforcement (test, lint rule) | +0.2 |
| Claim contradicted by any source file | -0.5 |
| Claim is inferred (no direct statement, only pattern) | -0.2 |

Minimum score for inclusion without user confirmation: **0.6**.
