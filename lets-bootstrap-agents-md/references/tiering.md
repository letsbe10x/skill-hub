# Module Tiering Criteria — lets-bootstrap-agents-md

## Decision tree

For each directory, apply in order:

### Tier 1 — Full AGENTS.md (8 sections)

Assign Tier 1 if ANY of:
- It is a top-level package directory (depth ≤ 2 from repo root, has `__init__.py`)
- It has > 3 immediate subdirectories
- It is named in a critical boundary in `service.yaml`
- It already has an `AGENTS.md` with ≥ 5 sections

**8 required sections for Tier 1:**
1. Overview — what this module owns (one sentence)
2. Module map — table of subdirectories and what each owns
3. Hard distinctions — the 2–4 boundaries most likely to be violated
4. Invariants — rules that must not drift
5. Commands — VERIFIED/PLAUSIBLE commands for working in this module
6. Adding a new X — step-by-step pattern for the most common extension
7. Known patterns — recurring implementation patterns with file references
8. Cross-module contracts — what this module exposes to others

### Tier 2 — Lightweight AGENTS.md (4 sections)

Assign Tier 2 if ANY of (and not already Tier 1):
- It has > 2 files with clearly distinct responsibilities
- It is explicitly mentioned in a parent module's invariants section
- It has an existing AGENTS.md with 2–4 sections

**4 required sections for Tier 2:**
1. Overview — what this module owns
2. Key files — table of the 3–6 most important files and what each does
3. Commands — VERIFIED/PLAUSIBLE commands relevant to this module
4. Known patterns — recurring patterns with file references

### Tier 3 — No AGENTS.md

All remaining directories. Reference them from the parent's module map.

## CLAUDE.md bridge rule

Every generated AGENTS.md (Tier 1 or 2, root or module) gets a sibling `CLAUDE.md` with exactly:

```
<!-- bridge -->
@AGENTS.md
```

This ensures Claude Code loads the same hierarchy as the `lets` CLI.

## Freshness (update mode)

A module's AGENTS.md is **stale** if:
- It references a file path that no longer exists
- It references a command that is now BLOCKED in the command catalog
- It is missing a required section for its tier
- Its `last_compiled_date` frontmatter is > 90 days old AND the module has changed since

Stale modules must be rewritten in update mode. Non-conforming files (wrong tier template, missing sections) are treated as stale.
