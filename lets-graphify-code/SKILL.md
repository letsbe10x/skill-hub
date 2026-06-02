---
name: lets-graphify-code
description: "Use when the agent needs to understand cross-file relationships in an unfamiliar codebase — 'what calls X', 'how does auth reach the DB', 'what's the blast radius if I change Y' — and grep / Read alone would force reading 20+ files. Tries grep / Read / glob first (cheap, deterministic, no extra tooling). Falls back to Graphify (tree-sitter + LLM knowledge graph by safishamsi/graphify) when the answer needs multi-hop reasoning across files. Reports which tier resolved the query, so reviewers see why the more expensive tool was needed."
metadata:
  author: letsbe10x
  version: "0.1.0"
  tags: [code-navigation, knowledge-graph, graphify, grep, tree-sitter, code-search, onboarding, blast-radius]
lifecycle: published
source: https://github.com/letsbe10x/skill-hub/blob/main/lets-graphify-code/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
  requirements:
    - "ripgrep (rg) on PATH — used by the grep tier; almost always present."
    - "Python 3.11+ on PATH — only required if the grep tier escalates to Graphify."
    - "uv on PATH — used to install Graphify on demand (uv tool install graphifyy)."
    - "Network access — only required the first time Graphify is installed."
triggers:
  - "how does auth flow from request to database in this repo"
  - "what are the upstream callers of this function"
  - "what's the blast radius if I change this class"
  - "which modules touch this config key"
  - "explain the call graph from X to Y"
  - "I'm in an unfamiliar repo and need to trace a feature end-to-end"
not-for:
  - "Single-file edits or refactors where the relevant code is already in the prompt"
  - "Simple find-this-string queries — plain rg is faster and free"
  - "Replacing repo onboarding — use lets-onboard-repo first; this skill assumes the repo layout is known"
  - "Production runtime tracing — graphify is a static analyser; for runtime use lets-search-logs or lets-watch-service"
  - "Reading files the user hasn't opened the repo to — respect path containment"
capabilities:
  resources: [shell]
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `lets` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

## Overview

`lets-graphify-code` answers cross-file code-understanding questions using the **cheapest tool that will work**. It is a tiered strategy:

1. **Tier 1 — grep / Read / glob.** Resolves any question that has a single grepable answer. Examples: "where is `UserService` defined?", "find all callers of `create_user`", "what files import `db.session`?". Cost: ~0 tokens beyond the tool calls themselves; runs in tens of milliseconds.
2. **Tier 2 — Graphify knowledge graph.** Only invoked when Tier 1 can't resolve the question because the answer requires **multi-hop reasoning across files** (e.g., "trace auth from HTTP handler to DB write" — 6 files, 4 indirection layers). Builds a tree-sitter + LLM extracted graph and queries it with natural language. Cost: one-time graph build (~30s–3min depending on repo size), then ~600–900 tokens per query instead of ~5–15k tokens of file reads.

The skill **always tells the user which tier resolved the query** so reviewers and CI logs can see whether Graphify was actually needed. Default posture: **start at Tier 1, only escalate when grep can't answer**.

The skill is **read-only** — it never modifies the target repo. Graphify output is written to `./graphify-out/` inside the target repo by default (gitignored if a `.gitignore` exists).

## Triggers and discovery

Activate this skill when the question shape is "explain how X connects to Y across the codebase" and the agent suspects the answer crosses **3 or more files**. If the agent can see the answer in 1–2 files via grep, skip this skill entirely — `rg` is enough.

Do **not** activate for:
- Edits, fixes, or refactors (use `lets-develop-feature` or `lets-review-code`).
- First-touch repo onboarding (use `lets-onboard-repo`).
- Runtime debugging (use `lets-search-logs` or `lets-triage-incident`).

## Steps

### Step 1 — Classify the question

Categorise the user's question into one of these shapes:

| Shape | Tier | Reason |
|---|---|---|
| "where is `<symbol>` defined?" | Tier 1 (`rg`) | Single-file answer |
| "find all callers of `<fn>`" | Tier 1 (`rg`) | Grep handles it |
| "which files import `<module>`?" | Tier 1 (`rg`) | Grep handles it |
| "what does `<file>` do?" | Tier 1 (Read) | Single-file summary |
| "trace `<feature>` from `<entry>` to `<sink>`" | Tier 2 (Graphify) | Multi-hop, semantic |
| "what's the blast radius if I change `<class>`?" | Tier 2 (Graphify) | Needs reverse-edge traversal |
| "why is `<A>` connected to `<B>`?" | Tier 2 (Graphify) | Needs path-finding |
| "summarise the call graph from `<entry-point>`" | Tier 2 (Graphify) | Needs subgraph extraction |

If a question is ambiguous, **try Tier 1 first** and escalate only if the answer is incomplete after 3 grep attempts.

### Step 2 — Tier 1: grep / Read / glob

Run the queries that match the question shape. Examples:

```bash
# "where is UserService defined?"
rg -n "class UserService|def UserService|UserService =" --type py

# "callers of create_user"
rg -n "create_user\\(" --type py

# "which files import db.session?"
rg -n "from .* import .*session|import db" --type py

# "what does this file do?" — Read tool, not grep
```

**Stop here** if any of these are true:
- The answer is fully in the grep output (file paths + line numbers + matched lines).
- A single Read of one or two files completes the answer.
- The question was about a single symbol's definition or direct usage.

**Escalate to Tier 2** only if:
- 3 grep attempts return either nothing useful or so many hits that the answer requires understanding relationships, not just locations.
- The question explicitly asks for a path, flow, or blast radius across modules.

### Step 3 — Tier 2: Graphify

Use Graphify when Tier 1 cannot resolve the question.

**3a. Verify install (idempotent):**

```bash
if ! command -v graphify >/dev/null 2>&1; then
  uv tool install graphifyy
fi
```

**3b. Build the graph (once per repo + commit):**

```bash
cd <repo-root>
# Reuse existing graph if commit hash matches
GRAPH_DIR="graphify-out"
CURRENT_SHA=$(git rev-parse HEAD 2>/dev/null || echo "no-git")
if [ -f "$GRAPH_DIR/.commit" ] && [ "$(cat $GRAPH_DIR/.commit)" = "$CURRENT_SHA" ]; then
  echo "Reusing existing graph for $CURRENT_SHA"
else
  graphify extract . --backend "${GRAPHIFY_BACKEND:-claude}" --out .
  echo "$CURRENT_SHA" > "$GRAPH_DIR/.commit"
fi
```

The `--backend` flag selects the LLM that does semantic extraction. Valid values per `graphify --help`: `gemini|kimi|claude|openai|deepseek|ollama` (default: whichever API key is set in env). Respect `GRAPHIFY_BACKEND` if the user sets it. The graph is cached per commit so re-running the skill on the same checkout is free. Subsequent incremental updates use `graphify update <path>` which is AST-only and needs no LLM.

**3c. Query the graph:**

```bash
graphify query "trace how a POST /login request reaches the users table"
# Or, for explicit path-finding between two known symbols:
graphify path "LoginHandler" "UsersRepository"
```

Use the natural-language `query` form when the user phrases the question in prose. Use the explicit `path` form when both endpoints are known symbols.

**3d. Report which tier resolved the query.** Always tell the user (and write to the run log) one of:

- `tier=1 grep` — answered with N grep calls, ~T tokens of file reads.
- `tier=2 graphify` — escalated after grep returned ambiguous results; graph build took Ts, query took Tq, ~T tokens consumed.

### Step 4 — Validate the answer against the source

Graphify can hallucinate edges in its semantic extraction layer (the AST layer is deterministic; the semantic LLM pass is not). For any Tier 2 answer that the user will act on, **spot-check one claim** with grep before reporting it as fact:

```bash
# Graphify says LoginHandler calls AuthService.verify_password — verify:
rg -n "verify_password" --type py | head -5
```

If the spot-check fails, downgrade the answer to "Graphify suggested this path; could not verify with grep — recommend manual confirmation" and flag the specific edge.

### Step 5 — Tell the user what to do next

Three outcomes:

- **Question answered, Tier 1.** Report the answer and tier. No artifacts created. Recommend `lets-develop-feature` or `lets-review-code` if the user is about to edit.
- **Question answered, Tier 2.** Report the answer, tier, and graph location (`./graphify-out/`). Suggest the user add `graphify-out/` to `.gitignore` if they don't want it tracked. Recommend `lets-develop-feature` next.
- **Question not answered.** Be honest. Report the grep attempts that failed and (if Tier 2 ran) the graph queries that returned low confidence. Recommend the user provide a specific entry point or symbol name to narrow the search.

## Checkpoints

Before reporting the answer, the agent must confirm all of:

1. **Tier honesty** — the response states `tier=1` or `tier=2` explicitly. No silent escalation.
2. **No file mutations** — the target repo's git status is unchanged (except for the gitignored `graphify-out/` directory if Tier 2 ran).
3. **Spot-check passed (Tier 2 only)** — at least one Graphify claim was verified with grep before being asserted.
4. **Cost reported** — the response includes either grep call count (Tier 1) or graph-build time + query time + token estimate (Tier 2).

## Outputs

**Tier 1 response shape:**
```
tier: 1 (grep)
question: <verbatim user question>
answer: <prose answer with file:line citations>
grep_calls: N
tokens_estimated: T
next_skill: lets-develop-feature | lets-review-code | (none)
```

**Tier 2 response shape:**
```
tier: 2 (graphify)
question: <verbatim user question>
answer: <prose answer with file:line citations>
grep_calls_attempted_first: N
graph_build_s: Ts
query_s: Tq
tokens_estimated: T
spot_check: pass | fail | n/a
graph_path: ./graphify-out/
next_skill: lets-develop-feature | lets-review-code | (none)
```

## Boundary conditions

- **No network → Graphify install blocked.** If `uv tool install` fails, Tier 2 is unavailable. Report `tier=1` outcome plus a note that Tier 2 was needed but unreachable.
- **Repo > 100k LOC.** Warn the user before Tier 2 — graph build can exceed 5 minutes on cold cache. Offer to scope the extraction with `graphify extract <subdir>` instead of the whole repo.
- **Binary files / large vendored trees.** Tell Graphify to skip them: `graphify extract . --ignore vendor/ --ignore node_modules/ --ignore dist/`.
- **Non-code questions ("explain this PDF" / "what's in this image").** Out of scope. Graphify can index PDFs/images but that's a different skill — recommend `lets-research-content-evaluate`.
- **Stale graph after rebase.** The commit-hash check in Step 3b handles this automatically; the graph is rebuilt when the SHA changes.

## Anti-patterns

- ❌ **Always reaching for Graphify.** Most code questions are 1–2 file lookups. Default to grep; escalate only when grep genuinely can't answer.
- ❌ **Reading 20 files in sequence to "trace" a flow.** This is exactly the case Graphify exists for — escalate.
- ❌ **Trusting Graphify's semantic edges without spot-checking.** The AST layer is reliable; the LLM-extracted "this calls that" edges are not. Always verify before asserting.
- ❌ **Building the graph on every run.** Reuse via the `.commit` cache file. Re-running on the same SHA must be near-instant.
- ❌ **Committing `graphify-out/`.** It's derived state — gitignore it.
- ❌ **Recommending the user install Graphify globally up-front.** Lazy install only when Tier 2 actually fires.

## Enforcement law

When this skill produces an answer, the response **must** begin with `tier=1` or `tier=2`. If the agent cannot determine which tier resolved the query, the answer is incomplete and must not be reported.

## References

- [`references/decision-rubric.md`](references/decision-rubric.md) — full Tier 1 vs Tier 2 question taxonomy with worked examples.
- [`references/graphify-cli.md`](references/graphify-cli.md) — cheat sheet for `graphify extract`, `query`, `path`, `export`, with version-pinned flags.
- [`references/benchmarks.md`](references/benchmarks.md) — token + wallclock measurements on a real repo (skill-forge), grep-only vs Tier 2 escalation.
- [`scripts/run-query.sh`](scripts/run-query.sh) — bash harness that runs the tiered logic end-to-end and emits the structured output shape above.

## What good looks like

- The agent answers a simple "where is X defined" in <1 second with 0 token cost beyond the grep call. Tier 1.
- The agent answers a 6-file "trace auth from HTTP to DB" in ~45 seconds (including one-time graph build) with ~800 tokens for the query — vs. ~12k tokens if it had Read'd every file in sequence. Tier 2.
- The user sees `tier=2` in the response and understands *why* the more expensive path was taken.
