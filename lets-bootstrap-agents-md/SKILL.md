---
name: lets-bootstrap-agents-md
description: "Generate evidence-backed AGENTS.md files for a repo module hierarchy. Runs bottom-up discovery, tiers modules, generates per-module docs with verified commands and evidence citations, then synthesizes the root last. Includes correctness/completeness/actionability verification gates."
metadata:
  author: cogsmith-ai
  version: "2.0.0"
  tags: [agents, documentation, context, bootstrap]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-bootstrap-agents-md/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
triggers:
  - generate AGENTS.md
  - bootstrap AGENTS.md
  - create agent documentation
  - update AGENTS.md
  - refresh AGENTS.md
outcome_runtime:
  open_agency_zones:
    - repo_structure_synthesis
    - architecture_invariant_discovery
    - agent_guidance_design
    - module_tiering_decision
    - coding_standards_extraction
  governed_action_zones:
    - agents_md_mutation
    - architecture_truth_claims
  allowed_moves:
    - request_missing_repo_context
    - mark_guidance_as_inferred
    - recommend_module_boundaries
    - challenge_tiering_decision
    - flag_low_confidence_claim
  hard_limits:
    - do_not_invent_architecture_invariants
    - do_not_overwrite_maintainer_guidance_without_evidence
    - do_not_generate_root_before_modules
    - do_not_surface_blocked_commands
    - do_not_include_claims_without_file_evidence
    - do_not_use_line_numbers_as_anchors
  required_decision_frames:
    - agents_md_hierarchy_strategy
    - module_tiering_decision
  validation_gates:
    - evidence_index_gate
    - command_verification_gate
    - correctness_gate
    - completeness_gate
    - actionability_gate
    - freshness_gate
  mutation_policy: additive_only
  human_checkpoint_triggers:
    - missing_truth
    - strategic_pivot
    - low_confidence_section
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

# lets-bootstrap-agents-md

Generate evidence-backed AGENTS.md files for a repo's module hierarchy. Bottom-up: deepest modules first, root synthesized last from verified outputs on disk. Every claim requires file-backed evidence. Operational detail in phase-specific references — this file is the contract.

---

## Pipeline

```
Phase 1: Readiness     → Detect mode (fresh/update), check existing files
Phase 2: Discovery     → Scan repo, build evidence index + directory tree
Phase 3: Tiering       → Classify modules (Tier 1/2/3), determine generation order
Phase 4: Commands      → Extract + classify commands (VERIFIED/PLAUSIBLE/BLOCKED)
Phase 5: Module loop   → Generate AGENTS.md bottom-up, one at a time, write immediately
Phase 6: Root          → Synthesize root AGENTS.md from module files on disk
Phase 7: Verification  → 4-gate verification (correctness, completeness, actionability, freshness)
```

---

## When to Use

- After `lets-bootstrap-repo` completes and user says yes to enrichment
- User asks "generate AGENTS.md" or "create agent documentation"
- Update mode: AGENTS.md files exist but are stale or non-conforming

## When Not to Use

- Repo already has well-maintained AGENTS.md files and user didn't ask to update
- You only need a repo readiness check (use `lets-bootstrap-repo`)
- You only need to review existing AGENTS.md quality (read and assess directly)

---

## Operating Principles

1. **Evidence first** — no claim without file-backed reference
2. **Bottom-up, root last** — deepest modules written first; root synthesized only from verified module outputs on disk
3. **One module at a time** — write to disk immediately, then clear context
4. **Command discipline** — only VERIFIED/PLAUSIBLE from catalog appear in output; BLOCKED commands never surface
5. **Stable anchors** — reference by path and symbol name, never by line number
6. **Claude parity** — every generated AGENTS.md gets a sibling `CLAUDE.md` bridge (`@AGENTS.md`)
7. **Line budgets** — root ≤200 lines, module ≤150 lines; every line must be actionable
8. **Content budget test** — "Would removing this line cause an agent to make a mistake?" If no → cut it.

---

## Mode Detection

Working artifacts are stored in a temporary directory outside the repo:

```
/tmp/{repo-name}/.agents-bootstrap/
```

- **Fresh mode:** No existing AGENTS.md → run all phases sequentially
- **Update mode:** AGENTS.md exists → run discovery + tiering fresh, build staleness report, rewrite changed/stale/non-conforming modules, regenerate root, verify

---

## Phase Contracts (Summary)

### Phase 1 — Readiness Check

Check for existing AGENTS.md files. If present and user didn't ask to update:
> "AGENTS.md files are already present. Run in update mode to refresh? (yes / exit)"

### Phase 2 — Discovery & Evidence Harvest

Scan repo structure and build two working artifacts in the bootstrap directory:
- `directory-tree.json` — module hierarchy with depth, file count, indicators
- `evidence-index.json` — file-backed claims per module with confidence scores

Sources: `__init__.py`, existing AGENTS.md/CLAUDE.md, README.md, ARCHITECTURE.md, pyproject.toml, Makefile, CI workflows.

**Rule:** Every claim must map to at least one source file. Claims without evidence are excluded.

See [references/ARTIFACT-SCHEMAS.md](references/ARTIFACT-SCHEMAS.md) for all artifact formats.

### Phase 3 — Module Tiering

Apply tiering decision tree to each discovered directory. See [references/tiering.md](references/tiering.md) for criteria.

| Tier | What it gets | Depth |
|------|-------------|-------|
| **Tier 1** | Full AGENTS.md (all sections) | Core modules, high complexity, many files |
| **Tier 2** | Lightweight AGENTS.md (4 sections) | Supporting modules, meaningful but narrow |
| **Tier 3** | No separate file (covered by parent) | Thin directories, few files |

Present tiering plan. **User must confirm before Phase 5.**

### Phase 4 — Command Catalog

Extract commands from Makefile, pyproject.toml, CI workflows, README code blocks. Classify each:

| Status | Rule |
|--------|------|
| **VERIFIED** | Present in Makefile targets or `pyproject.toml [project.scripts]` |
| **PLAUSIBLE** | Mentioned in docs but not in a build surface |
| **BLOCKED** | Never surface in any output (destructive, secrets, inferred) |

### Phase 5 — Module Loop (bottom-up)

Process modules deepest-first. For each Tier 1/2 module:
1. Read source files + evidence index
2. Generate AGENTS.md using the appropriate template
3. Run per-module correction pass (paths exist, commands verified, evidence cited)
4. Write to disk immediately
5. Write sibling `CLAUDE.md` bridge
6. Checkpoint every 3-4 modules

See [references/MODULE-AGENTS-TEMPLATE.md](references/MODULE-AGENTS-TEMPLATE.md) for template and correction checklist.

### Phase 6 — Root AGENTS.md

Synthesize ONLY from verified module files on disk. Never from scratch.

See [references/ROOT-AGENTS-TEMPLATE.md](references/ROOT-AGENTS-TEMPLATE.md) for structure and section budgets.

### Phase 7 — Verification

Run 4 gates sequentially. Max 2 fix cycles per gate. See [references/VERIFICATION.md](references/VERIFICATION.md) for the full protocol.

| Gate | Checks |
|------|--------|
| **Correctness** | Evidence accuracy, command validity, specificity, de-duplication |
| **Completeness** | Tier coverage, template conformance, cross-file patterns, orphaned tech |
| **Actionability** | "Adding a New X" recipes, verify commands, path existence |
| **Freshness** | Staleness resolution (update mode only) |

---

## Error Handling

- If evidence harvest returns no source files: fallback to scanning README.md and pyproject.toml directly
- If a module's AGENTS.md cannot pass correction in one pass: surface to user with specific remediation
- If verification gate fails after 2 fix cycles: mark FAIL with remediation for user, do not force-pass
- If repo has no Makefile/pyproject.toml: command catalog will be sparse — note this in output, rely on README

---

## Anti-patterns

- **Generating AGENTS.md without evidence harvest** — Phase 2 discovery is required before any authoring
- **Writing root before modules** — bottom-up order is strictly enforced
- **Including BLOCKED commands** — only VERIFIED and PLAUSIBLE may appear in output
- **Vague claims** — "We use Redis for caching" is wrong; "Redis for session storage in session_store module" is correct
- **Line number references** — use stable anchors (path + symbol name)
- **Holding multiple modules in context** — process one at a time, write, then move on
- **Skipping verification** — Phase 7 catches correctness and completeness issues before handoff
- **Inventing architecture** — if you can't find evidence for a claim, don't include it

---

## Outputs

- Output: Per-module AGENTS.md + CLAUDE.md bridge for each Tier 1/2 module
- Output: Root AGENTS.md synthesized from module files + root CLAUDE.md bridge
- Output: Verification report (PASS/FAIL per gate with evidence)
- Output: Working artifacts in temporary bootstrap directory (not committed)

Done when: All AGENTS.md files pass Phase 7 verification, root references all modules, and CLAUDE.md bridges exist.

---

## References (Progressive Disclosure)

Read each reference only when its phase activates — not upfront.

| Reference | When to read |
|-----------|-------------|
| [tiering.md](references/tiering.md) | Phase 3 — module tier classification criteria |
| [ROOT-AGENTS-TEMPLATE.md](references/ROOT-AGENTS-TEMPLATE.md) | Phase 6 — root AGENTS.md structure and section budgets |
| [MODULE-AGENTS-TEMPLATE.md](references/MODULE-AGENTS-TEMPLATE.md) | Phase 5 — per-module template, tier depth, correction checklist |
| [VERIFICATION.md](references/VERIFICATION.md) | Phase 7 — 4-gate verification protocol |
| [ARTIFACT-SCHEMAS.md](references/ARTIFACT-SCHEMAS.md) | Phase 2/3/4 — JSON artifact formats and schemas |

## Hard Rules

- Never commit AGENTS.md files on behalf of the user
- Never write working files (`/tmp/...`) into the repo
- Do not surface BLOCKED commands in any output
- Root AGENTS.md must be synthesized from module files on disk — never from blank prompt
- Every generated file must include YAML frontmatter with `last_compiled_date` and `version`
- Use stable anchors (path and symbol name), never hardcoded line numbers
- No implementation code blocks in AGENTS.md — allowed: shell commands, Mermaid diagrams, short pattern signatures (1-2 lines)
