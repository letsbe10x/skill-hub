---
name: lets-bootstrap-agents-md
description: "Use when generating or updating AGENTS.md files for a repo. Runs bottom-up discovery through all modules before writing the root AGENTS.md. Do not invoke before Phase 2 evidence harvest is complete."
metadata:
  author: cogsmith-ai
  version: "1.0.0"
  tags: [agents, documentation, context]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-bootstrap-agents-md/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
outcome_runtime:
  open_agency_zones:
    - repo_structure_synthesis
    - architecture_invariant_discovery
    - agent_guidance_design
  governed_action_zones:
    - agents_md_mutation
    - architecture_truth_claims
  allowed_moves:
    - request_missing_repo_context
    - mark_guidance_as_inferred
    - recommend_module_boundaries
  hard_limits:
    - do_not_invent_architecture_invariants
    - do_not_overwrite_maintainer_guidance_without_evidence
  required_decision_frames:
    - agents_md_hierarchy_strategy
  validation_gates:
    - evidence_index_gate
    - command_verification_gate
  mutation_policy: additive_only
  human_checkpoint_triggers:
    - missing_truth
    - strategic_pivot
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

# lets-bootstrap-agents-md

Generate evidence-backed AGENTS.md files for the repo module hierarchy.

## When to use

- After `lets-bootstrap-repo` completes and user says yes to enrichment
- User asks "generate AGENTS.md" or "create agent documentation for this repo"
- Update mode: AGENTS.md files exist but are stale

## Inputs

- Input: Repo root path (working directory or explicit `--repo-root`)
- Input: Mode — fresh bootstrap or update (default: fresh)
- Input: Optional existing AGENTS.md files to preserve/merge

## Outputs

- Output: AGENTS.md + CLAUDE.md bridge for each Tier 1/2 module
- Output: Root AGENTS.md synthesized from module files

---

## Phase 1 — Readiness check

Check whether existing AGENTS.md files are present. If they exist and the user did not ask to update:
> "AGENTS.md files are already present. Run in update mode to refresh? (yes / exit)"

If exit: stop.
If yes or no existing files: proceed to Phase 2.

---

## Phase 2 — Discovery and evidence harvest

Scan the repo. Produce two working files in `/tmp/$REPO_NAME/.agents-bootstrap/`:

**`directory-tree.json`** — module hierarchy with indicators:

```json
{
  "src/engine/": {
    "depth": 3,
    "file_count": 4,
    "has_init": true,
    "has_tests": false,
    "has_agents_md": true,
    "subdirs": ["context/", "goals/", "memory.py", "events.py"]
  }
}
```

**`evidence-index.json`** — file-backed claims per module:

```json
{
  "src/engine/runs/": {
    "source_refs": ["lifecycle/", "pipeline/", "coordination/"],
    "key_files": ["__init__.py", "store.py", "digest.py"],
    "doc_refs": ["AGENTS.md"],
    "invariants": ["pipeline is intra-run; coordination is inter-run"]
  }
}
```

Sources to scan: all `__init__.py` files, existing `AGENTS.md`/`CLAUDE.md`, `README.md`, `ARCHITECTURE.md`, `CONTRIBUTING.md`, `pyproject.toml`, CI workflow files (under `.github`, in `workflows`), `Makefile`.

**Rule:** Every claim in the evidence index must map to at least one source file. Claims without file evidence are excluded.

---

## Phase 3 — Module tiering

Apply the tiering decision tree (see `references/tiering.md`) to each directory discovered in Phase 2.

Present the tiering plan as a module list with tier assignments. Example:

```
Tier 1 (full AGENTS.md):
  src/engine/
  src/engine/runs/
  src/engine/context/
  src/platform/

Tier 2 (lightweight AGENTS.md):
  src/engine/context/discovery/
  src/engine/context/verification/

Tier 3 (covered by parent — no AGENTS.md):
  src/engine/context/registry/
  src/engine/events.py
```

**User must confirm before Phase 5 begins.** Ask: "Does this tiering look right? (confirm / adjust)"

Write `modules.json` to `/tmp/$REPO_NAME/.agents-bootstrap/`.

---

## Phase 4 — Command catalog

Extract all runnable commands from: `Makefile`, `pyproject.toml [project.scripts]`, GitHub Actions workflows under .github/workflows, and `README.md` code blocks.

Classify each command:
- **VERIFIED** — present in Makefile targets or `pyproject.toml [project.scripts]`
- **PLAUSIBLE** — mentioned in docs but not in a build surface
- **BLOCKED** — do not surface in any AGENTS.md output (e.g. destructive commands, secrets)

Write `command-catalog.json` to `/tmp/$REPO_NAME/.agents-bootstrap/`.

Only VERIFIED and PLAUSIBLE commands may appear in generated AGENTS.md files.

---

## Phase 5 — Module loop (bottom-up)

Process modules **deepest first** — leaves before parents, root last.

For each Tier 1/2 module:

1. Read the module's source files (key files from evidence-index) and any existing AGENTS.md.
2. Generate AGENTS.md using the tier template from `references/tiering.md`.
3. **Evidence check:** every command claim must be VERIFIED or PLAUSIBLE in the catalog; every path must exist on disk. Remove any claim that fails this check.
4. Write the file to disk immediately. Do not batch.
5. Write a sibling `CLAUDE.md` bridge:
   ```
   <!-- bridge -->
   @AGENTS.md
   ```
6. **Checkpoint every 3–4 modules:** show what was written, ask: "Continue? (yes / adjust)"

---

## Phase 6 — Root AGENTS.md

Synthesize the root `AGENTS.md` **only after all module files are on disk**. Never generate it from scratch — read the verified module outputs and synthesize from them.

Root AGENTS.md target: ≤200 lines.

Required sections:
1. The one rule (what every module in this repo does)
2. Module map (from Tier 1 AGENTS.md module maps)
3. Hard distinctions (key boundaries, from module invariants)
4. Invariants (top-level, from module cross-module contracts)
5. Ecosystem boundary

Write a sibling root `CLAUDE.md` bridge:
```
<!-- bridge -->
@AGENTS.md
```

---

## Phase 7 — Verification pass

Run two gates, max one fix cycle each:

**Gate 1 — Correctness:**
- Every command in every AGENTS.md is VERIFIED or PLAUSIBLE in `command-catalog.json`
- Every file path referenced exists on disk
- No invented claims (claims not in `evidence-index.json`)

**Gate 2 — Completeness:**
- Every Tier 1/2 module has `AGENTS.md` + `CLAUDE.md` bridge
- Root `AGENTS.md` exists
- Every Tier 1 AGENTS.md has an "Adding a new X" section

For each failed check: fix inline (one pass). Surface checks that cannot be auto-fixed to the user with specific remediation instructions.

---

## Anti-patterns

- **Generating AGENTS.md without running evidence harvest** — Phase 2 discovery is required before any authoring.
- **Writing a root-level AGENTS.md before completing all module AGENTS.md files** — bottom-up order is enforced.
- **Skipping the verification pass** — Phase 7 verification checks for stale content and missing commands.

Done when: all AGENTS.md files pass Phase 7 verification, and the root AGENTS.md references all module files.

## Hard rules

- Never commit AGENTS.md files on behalf of the user.
- Never write to `/tmp/$REPO_NAME/.agents-bootstrap/` files in the repo itself — these are working files only.
- Do not surface BLOCKED commands in any output.
- Root AGENTS.md must be synthesized from module files on disk — never written from a blank prompt.
- If Phase 2 evidence harvest returns no source files, fallback to scanning README.md and pyproject.toml directly before declaring harvest complete.
- If a module's AGENTS.md cannot be auto-fixed in one pass, surface it to the user with specific remediation instructions and retry after correction.
