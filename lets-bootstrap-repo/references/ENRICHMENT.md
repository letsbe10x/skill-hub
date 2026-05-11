# Enrichment Reference — lets-bootstrap-repo

Phase 5 optional enrichment: AGENTS.md generation, coding standards extraction, and architecture scaffolding.

## Enrichment Depth Menu

Present after Phase 4 discovery:

| Depth | What it does | When to recommend |
|-------|-------------|-------------------|
| **Skip** | Proceed to readiness report | User just wants baseline context |
| **AGENTS.md only** (Recommended) | Invoke `lets-bootstrap-agents-md` | Most repos — immediate agent guidance value |
| **Full** | AGENTS.md + coding standards + architecture scaffold | Repos with complex conventions or undocumented architecture |

---

## AGENTS.md Generation

Handoff to `lets-bootstrap-agents-md`:
- Pass discovered `service.type` so tiering can account for repo shape
- Pass `service.non_negotiables` so they surface as boundaries in generated AGENTS.md
- After completion, re-run readiness assessment (AGENTS.md existence improves engineering score)

---

## Coding Standards Extraction

Extract repo-specific coding rules into `docs/coding-rules.md`. This captures conventions that would otherwise be tribal knowledge.

### Source Precedence

1. **Existing maintainer-authored docs** — `CONTRIBUTING.md`, `docs/style-guide.md`, `.editorconfig`, linter configs
2. **AGENTS.md guidance** — if already present, extract rules it references
3. **PR review patterns** — recurring reviewer feedback (requires `gh` CLI access)
4. **Codebase patterns** — conventions with ≥ 3 file occurrences

When sources conflict: prefer explicit docs over inferred patterns. Surface conflicts instead of silently flattening.

### Extraction Protocol

1. **Scan for explicit standards docs:**
   ```
   CONTRIBUTING.md, docs/coding-rules.md, docs/style-guide.md,
   .editorconfig, .eslintrc*, .prettierrc*, ruff.toml, pyproject.toml [tool.ruff]
   ```

2. **Mine linter configs** for enforced rules (these are VERIFIED conventions)

3. **Check for PR review patterns** (optional, requires `gh` CLI):
   - Look for recurring review comments on recent PRs
   - Extract patterns mentioned ≥ 3 times by reviewers

4. **Scan codebase patterns:**
   - Import ordering conventions
   - Error handling patterns (e.g., always wrap in Result, never bare except)
   - Naming conventions (files, functions, classes)
   - Test structure patterns

### Output Structure

```markdown
# Coding Rules — <repo-name>

## Non-negotiables (from service truth)
- <invariants from Phase 2>

## Enforced by tooling
- <rules from linter/formatter configs>

## Conventions (≥ 3 file occurrences)
- <pattern>: <evidence files>

## Reviewer guidance (from PR comments)
- <recurring feedback>

## Unresolved conflicts
- <areas where sources disagree>
```

### Rules

- Never invent generic advice — every rule must cite repo evidence
- Distinguish enforced (tooling) from conventional (pattern) from aspirational (docs say but code doesn't follow)
- Keep output ≤ 100 lines — link to detailed sources rather than reproducing them
- If `docs/coding-rules.md` already exists, prefer update mode over rewrite

---

## Architecture Scaffold (Full mode only)

Generate a lightweight architecture document when the repo lacks one.

### When to scaffold

- No `ARCHITECTURE.md`, `docs/architecture.md`, or equivalent exists
- Repo has ≥ 3 top-level source directories
- User selected "Full" enrichment depth

### What to scaffold

```markdown
# Architecture — <repo-name>

## System context
<one-sentence purpose from service truth>

## Component map
<discovered module roots with one-line descriptions>

## Data flow
<inferred from entrypoints and module dependencies — marked as INFERRED>

## Key decisions
<empty — to be filled by maintainers>
```

### Rules

- Mark all inferred claims explicitly: `(inferred from <source>)`
- Do not generate detailed architecture for undiscoverable patterns — leave sections empty with a note
- This is scaffolding, not verified documentation — it does not count toward readiness score

---

## After Enrichment

Re-assess readiness:
- AGENTS.md present → engineering pillar gains partial credit
- `docs/coding-rules.md` present → engineering pillar gains additional credit (if verified)
- Architecture doc → does NOT count until maintainer verifies

Proceed to Phase 6 (readiness report).
