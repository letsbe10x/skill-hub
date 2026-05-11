# Verification Protocol — lets-bootstrap-agents-md

Run in Phase 7 after all AGENTS.md files are written to disk. Four gates, sequential. A file must pass all gates to be considered complete.

## Execution contract

- **Max fix cycles:** 2 per gate. If a gate still fails after 2 cycles, surface to user with specific remediation.
- **Scope:** All generated AGENTS.md files (root + module tiers 1 and 2).
- **Inputs:** `evidence-index.json`, `command-catalog.json`, `modules.json`, `directory-tree.json` from `/tmp/<repo-name>/.agents-bootstrap/`.

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

## Gate 3 — Actionability

Generated docs must enable agents to act, not just read.

| Check | Rule | Fix action |
|---|---|---|
| Extension recipes | Every Tier 1 module has "Adding a New X" with ≥ 1 registration point and verify step | Add recipe from evidence-index patterns |
| Extension recipes | Every Tier 2 module has at least a Patterns section with one recipe | Add minimal pattern |
| Verify commands | At least one VERIFIED command referenced per Tier 1/2 module | Pull from command-catalog.json |
| Path existence | Every path referenced in any AGENTS.md exists on disk | Remove dead path references |
| Boundary actionability | "Boundaries and Safety Gates" has at least one item per column (Allowed/Ask-first/Never-do) | Fill from evidence or mark `(none identified)` |

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
- <file>: <specific issue and remediation instruction>
```

Overall status: PASS only if all applicable gates show 0 remaining issues.
