# Verification Protocol — lets-bootstrap-agents-md

Run in Phase 7 after all AGENTS.md files are written to disk. Four gates, sequential. A file must pass all gates to be considered complete.

## Execution contract

- **Max fix cycles:** 2 per gate. If a gate still fails after 2 cycles, surface to user with specific remediation.
- **Scope:** All generated AGENTS.md files (root + module tiers 1 and 2).
- **Inputs:** `evidence-index.json`, `command-catalog.json`, `modules.json`, `directory-tree.json` from the bootstrap working directory.

## Gate 1 — Correctness

Every claim in every AGENTS.md must be traceable to evidence.

| Check | Rule | Fix action |
|---|---|---|
| Evidence accuracy | Non-negotiable claims (invariants, boundaries) have ≥ 1 citation in `evidence-index.json` | Remove claim or downgrade to "inferred" |
| Evidence accuracy | Convention claims have ≥ 3 file references in evidence-index | Remove if < 3 refs |
| Command validity | Every command appears verbatim in a build surface (`Makefile`, `pyproject.toml`, CI workflow) | Replace with nearest VERIFIED command or remove |
| Specificity | No vague statements like "we use X for Y" without a `file:role` reference | Add file reference or remove statement |
| De-duplication | No rule appears in both root and module AGENTS.md | Remove from module (root wins) |
| De-duplication | No rule appears in two sibling module AGENTS.md files | Move to parent, remove from both siblings |

### Correctness verification protocol

For each claim in a generated AGENTS.md:

1. **Non-Negotiable claims** — verify ≥1 file where the pattern is enforced:
   ```bash
   # Example: verify auth pattern exists
   grep -r "auth\|permission\|session" --include="*.py" -l
   ```

2. **Convention claims** — verify ≥3 file occurrences across ≥2 directories:
   ```bash
   # Example: verify error handling pattern
   grep -r "raise CustomException" --include="*.py" -l | wc -l
   ```

3. **Tech stack claims** — verify (a) manifest reference AND (b) ≥1 import in application code:
   ```bash
   # Check manifest
   grep "redis" pyproject.toml requirements.txt package.json 2>/dev/null
   # Check usage
   grep -r "import redis\|from redis" --include="*.py" -l
   ```

4. **Command claims** — verify verbatim in build surface:
   ```bash
   grep -F "make test" Makefile
   grep "scripts" package.json | grep "test"
   ```

### Specificity standard

Bad (vague):
- "We use Redis for caching"
- "Kafka is the async pattern"

Good (specific):
- "Redis for session storage in `permissions/session_store.py`"
- "Kafka (via Confluent) handles job intake; Procrastinate manages worker queuing (see `workers/queue.py`)"

## Gate 2 — Completeness

No significant patterns or signals left undocumented.

| Check | Rule | Fix action |
|---|---|---|
| Tier coverage | Every Tier 1/2 module in `modules.json` has AGENTS.md + CLAUDE.md bridge on disk | Generate missing file |
| Template conformance | Each file has all required sections for its tier (per MODULE-AGENTS-TEMPLATE.md) | Add missing section header + content from evidence-index |
| Security patterns | If evidence-index contains auth/authz/crypto/secret patterns → non-negotiable boundary must exist | Add boundary to nearest ancestor AGENTS.md |
| Cross-file patterns | Any pattern occurring in ≥ 3 files within a module and not documented | Add to "Known patterns" or "Conventions" |
| Undocumented gotchas | HACK/FIXME/WARNING/XXX comments in module source → tribal knowledge section | Add to Anti-Patterns (root) or Boundaries (module) |
| Orphaned tech | Manifest dependencies with ≥ 3 imports not mentioned in Technology Stack | Add to tech stack or note in Related |
| Root synthesis | Root AGENTS.md references every Tier 1 module in its module map | Add missing module row |

### Completeness scanning protocol

1. **Missing tier coverage** — check if any tiers are empty when code suggests otherwise:
   - If codebase has ≥3 security-related patterns, "Non-Negotiables" should exist
   - If codebase has ≥5 repeated architectural patterns, "Strong Conventions" should exist
   - If README/comments mention gotchas, anti-patterns section should exist

2. **Cross-file patterns** — sample 8-10 files across modules, look for:
   - Error handling: Do ≥3 files use the same exception pattern?
   - Logging: Do ≥3 files use the same logger initialization?
   - Config access: Do ≥3 files import config the same way?
   - Testing: Do ≥3 test files use the same fixture pattern?

3. **Undocumented gotchas** — search codebase:
   ```bash
   grep -r "HACK\|FIXME\|XXX\|WARNING\|NOTE:" --include="*.py" --include="*.ts" --include="*.js"
   ```
   Compare findings against generated tribal knowledge / anti-patterns sections.

4. **Orphaned tech** — compare manifest deps against documented tech stack:
   ```bash
   # For Python
   grep -E "^[a-zA-Z]" requirements.txt | cut -d= -f1 | while read dep; do
     count=$(grep -r "import $dep\|from $dep" --include="*.py" -l | wc -l)
     [ "$count" -ge 3 ] && echo "$dep: $count imports"
   done
   ```

## Gate 3 — Actionability

Generated docs must enable agents to act, not just read.

| Check | Rule | Fix action |
|---|---|---|
| Extension recipes | Every Tier 1 module has "Adding a New X" with ≥ 1 registration point and verify step | Add recipe from evidence-index patterns |
| Extension recipes | Every Tier 2 module has at least a Patterns section with one recipe | Add minimal pattern |
| Verify commands | At least one VERIFIED command referenced per Tier 1/2 module | Pull from command-catalog.json |
| Path existence | Every path referenced in any AGENTS.md exists on disk | Remove dead path references |
| Boundary actionability | "Boundaries and Safety Gates" has at least one item per column (Allowed/Ask-first/Never-do) | Fill from evidence or mark `(none identified)` |

### Extension recipe protocol (analogy-driven)

For each Tier 1 module that needs "Adding a New X" recipes:

1. **Find analogous implementations** — search the module for 2-3 existing implementations of the same pattern:
   - Same base class or interface
   - Same decorator or registration mechanism
   - Same file naming convention

2. **Extract the pattern** from those analogies:
   - What base class/interface to extend?
   - What registration step is required?
   - What naming convention to follow?
   - What test pattern to replicate?

3. **Write the recipe** with:
   - Numbered steps
   - At least one registration point (where to register the new thing)
   - At least one verify step (how to confirm it works)

### Boundary protocol (caller-aware)

For each module's boundaries:

1. **Map callers** — who imports from this module?
   ```bash
   grep -r "from {module}" --include="*.py" -l
   grep -r "import {module}" --include="*.py" -l
   ```

2. **Identify contracts** — what does this module expose vs. keep internal?

3. **Classify actions:**
   - **Allowed:** read-only operations, adding new implementations following pattern
   - **Ask-first:** changing public interfaces, modifying shared state
   - **Never-do:** breaking contracts, bypassing safety checks, modifying internals of upstream modules

## Gate 4 — Freshness (update mode only)

Applies only when the skill runs in update mode against existing AGENTS.md files.

| Check | Rule | Fix action |
|---|---|---|
| Staleness resolved | Every entry in `staleness-report.json` has been addressed | Rewrite stale section or remove dead reference |
| Deleted files | No AGENTS.md references files that no longer exist on disk | Remove reference |
| Deleted commands | No AGENTS.md references commands marked BLOCKED in current catalog | Replace or remove |
| Date freshness | `last_compiled_date` in frontmatter updated to today | Update frontmatter |
| Tier drift | Module still qualifies for its assigned tier per current directory state | Re-tier if needed (may require section additions/removals) |

## Report format

After all gates complete, emit a summary:

```
## Verification Report

| Gate | Status | Issues found | Fixed | Remaining |
|------|--------|:---:|:---:|:---:|
| Correctness | PASS/FAIL | N | N | N |
| Completeness | PASS/FAIL | N | N | N |
| Actionability | PASS/FAIL | N | N | N |
| Freshness | PASS/FAIL/SKIP | N | N | N |

### Unresolved (requires user input)
- {file}: {specific issue and remediation instruction}
```

Overall status: PASS only if all applicable gates show 0 remaining issues.
