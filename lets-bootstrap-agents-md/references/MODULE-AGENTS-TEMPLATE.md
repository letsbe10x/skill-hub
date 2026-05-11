# Module AGENTS.md Template — lets-bootstrap-agents-md

## Line budget

**Maximum 150 lines.** Same content budget test as root:

> "Would removing this line cause an agent to make a mistake?"

## Tier-based section requirements

| Section | Tier 1 (full) | Tier 2 (lightweight) |
|---------|:---:|:---:|
| Scope | required | required |
| Architecture | required | -- |
| Patterns | required | required |
| Testing | required (if testable) | -- |
| Boundaries | required | -- |
| Related | required | required |
| Conventions | required | -- |

## Section specifications

### 1. Scope

One sentence: what this module owns. Must answer "if I need to change X, is this the right place?"

Format:
```
## Scope

<module-name> owns <responsibility>. It does NOT own <common confusion>.
```

### 2. Architecture (Tier 1 only)

Key files table + optional diagram.

| File/Dir | Role | Entry point? |
|----------|------|:---:|
| `registry.py` | Goal registration and lookup | yes |
| `base.py` | Abstract goal interface | no |
| `builtin/` | Concrete goal implementations | no |

Diagram format selection (same rules as root):

| Module shape | Format |
|---|---|
| ≤ 5 key files, linear flow | Numbered list with arrows |
| Hub-and-spoke (registry + implementations) | Table with entry point column |
| Pipeline (ordered stages) | ASCII pipeline: `A → B → C → D` |
| Complex internal (> 8 files, cyclic refs) | Mermaid subgraph |

### 3. Patterns

At minimum one "Adding a New X" recipe. X = the most common extension point in this module.

Required structure:
```
### Adding a New <X>

1. Create `<path>` following `<existing-example>` as template
2. Register in `<registration-file>::<symbol>`
3. <Any additional wiring steps>
4. Verify: `<command from command-catalog>`
```

Rules:
- Registration points must reference exact file + symbol
- Verify step must use a VERIFIED command from the catalog
- If multiple extension patterns exist, document up to 3 (most frequent first)

### 4. Testing (Tier 1, if module is testable separately)

| Field | Content |
|---|---|
| Test directory | Relative path to tests |
| Run command | VERIFIED command from catalog |
| Mock patterns | How this module's tests mock dependencies (with one example path) |
| Coverage | Expected coverage or "no gate" |

Skip this section entirely if the module has no dedicated tests (document in parent instead).

### 5. Boundaries (Tier 1 only)

Two parts:

**Common mistakes** — things agents get wrong in this module:
```
- Do NOT import from <sibling-module> directly — use <interface>
- Do NOT instantiate <class> outside of <factory>
```

**Integration points** — where this module connects to others:
```
- Consumed by: <list of consumer modules>
- Depends on: <list of dependency modules>
- Contract: <interface file or protocol>
```

### 6. Related

Table linking to dependency/consumer modules with a one-phrase reason:

| Module | Relationship | Why |
|--------|------|-----|
| `../runs/` | depends-on | Executes goals through run lifecycle |
| `../../platform/hooks/` | consumed-by | Hooks invoke goals by ID |

### 7. Conventions (Tier 1 only)

Maximum 3 module-specific rules. Each must be backed by **≥ 2 occurrences** in the module source.

Format:
```
- <Rule statement> — see `<file1>`, `<file2>`
```

Do not repeat rules already in the root AGENTS.md Critical Coding Rules section.

## Per-module correction pass checklist

After writing each module AGENTS.md, verify:

| Check | Action on failure |
|---|---|
| All paths exist on disk | Remove the reference |
| All commands are VERIFIED or PLAUSIBLE | Replace with nearest VERIFIED alternative |
| No claims without evidence-index entry | Remove the claim |
| Line count ≤ 150 | Cut lowest-evidence lines first |
| No duplication with parent AGENTS.md | Remove from child (parent wins) |
| Scope statement answers "is this the right place?" | Rewrite with explicit NOT-own clause |
| "Adding a New X" has verify step | Add from command-catalog or mark `(no verify command)` |

## CLAUDE.md bridge

Every module AGENTS.md gets a sibling `CLAUDE.md`:

```markdown
<!-- bridge -->
@AGENTS.md
```

Write this immediately after writing the AGENTS.md. No exceptions.
