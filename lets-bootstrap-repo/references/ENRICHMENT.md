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

Four extraction modes, use whichever sources are available:

#### Mode 1 — From existing standards docs (highest priority)

Scan for:
```
CONTRIBUTING.md, docs/coding-rules.md, docs/style-guide.md,
.editorconfig, .eslintrc*, .prettierrc*, ruff.toml, pyproject.toml [tool.ruff]
```

Parse into importance tiers: non-negotiable, convention, preference.

#### Mode 2 — From linter/formatter configs (VERIFIED conventions)

Mine enforced rules from tooling configuration. These are the strongest evidence — the tool rejects code that violates them.

```bash
# Python: extract ruff rules
grep -A 50 '\[tool.ruff' pyproject.toml | grep "select\|ignore"
# JS/TS: extract eslint rules
cat .eslintrc* | jq '.rules'
```

#### Mode 3 — From PR review comments (optional, requires `gh` CLI)

Extract recurring reviewer feedback — patterns mentioned ≥ 3 times across PRs:

```bash
# Fetch recent merged PR comments
gh pr list --state merged --limit 20 --json number | \
  jq -r '.[].number' | while read pr; do
    gh api repos/{owner}/{repo}/pulls/$pr/comments --jq '.[].body'
  done
```

**Distillation rules:**
- Include all prescriptive comments ≥15 chars (imperative tone: "use X", "don't Y", "avoid W")
- Strip noise: "LGTM", emoji-only, bare links without context
- Deduplicate near-identical comments; keep most specific phrasing
- Mark frequency: how many PRs mentioned this (signals importance)
- Tag signal words: "must", "never", "always" → non-negotiable tier

#### Mode 4 — From codebase pattern analysis

Sample 8-10 files across ≥3 different modules. Extract patterns with ≥3 file occurrences:

```bash
# Error handling patterns
grep -r "raise\|except\|try:" --include="*.py" -l | head -10

# Import ordering
head -20 src/**/*.py | grep "^import\|^from"

# Test fixture patterns
grep -r "fixture\|setUp\|@pytest" --include="*.py" tests/ | head -10
```

Look for:
- Error handling conventions (custom exceptions, Result types, retry patterns)
- Logging patterns (structured logging, correlation IDs, log levels)
- Config access patterns (env vars, settings objects, dependency injection)
- Naming conventions (files, functions, classes, test methods)
- Import ordering conventions

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
