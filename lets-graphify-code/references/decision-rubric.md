# Tier 1 vs Tier 2 — Decision Rubric

Used by `lets-graphify-code` step 1 to pick the cheapest tool that will answer the user's question.

## The rule of thumb

**Tier 1 if the answer fits in N file:line pairs that grep can find by string match.**
**Tier 2 if the answer requires reasoning across edges between files.**

If you find yourself opening more than 3 files to follow a chain of calls, you've already paid the Tier-2 build cost in tokens — escalate.

## Question taxonomy with worked examples

### Tier 1 — grep / Read

| Question | Why Tier 1 | Resolving command |
|---|---|---|
| Where is `UserService` defined? | Single definition | `rg -n "class UserService\|def UserService" --type py` |
| All callers of `create_user`? | Symbol match across files; grep handles it | `rg -n "create_user\(" --type py` |
| Which files import `db.session`? | Import match; grep handles it | `rg -n "from .* import .*session\|import db" --type py` |
| What does `auth/handlers.py` do? | Single-file summary | Read the file |
| List all REST endpoints | Regex over decorators | `rg -n "@(app\|router)\.(get\|post\|put\|delete)" --type py` |
| Find all `TODO` / `FIXME` | String match | `rg -n "TODO\|FIXME"` |
| What does `process_payment` return? | Single-function inspection | Read the function |
| Are there any uses of `eval()`? | Security scan, grepable | `rg -n "\\beval\\(" --type py` |

### Tier 2 — Graphify

| Question | Why Tier 2 | Resolving command |
|---|---|---|
| Trace a `POST /login` request to the DB write | Crosses handler → service → repo → DB; grep can't follow the chain | `graphify query "trace POST /login from handler to DB write"` |
| What's the blast radius if I change `UserService.verify`? | Needs reverse-edge traversal across the entire callgraph | `graphify query "what depends on UserService.verify and could break if its signature changes"` |
| Why is the `billing` module connected to `auth`? | Path-finding between two distant modules | `graphify path "billing" "auth"` |
| Summarise the call graph from `cli.main` | Subgraph extraction with semantic labels | `graphify query "summarise the call graph rooted at cli.main, depth 3"` |
| Which components share state via the global cache? | Edge-pattern query, not string match | `graphify query "which components write to and read from the global cache"` |
| What's the data-flow path from request body to DB column? | Multi-hop dataflow, not call-graph alone | `graphify query "trace user input from POST /users body to the users table columns"` |

## The "have I tried grep?" checklist

Before escalating to Tier 2, the agent must have run at least **three** grep variants and concluded the question can't be answered by string matches alone. Examples of three variants:

1. The literal symbol the user named: `rg -n "<symbol>"`
2. The symbol plus its likely call syntax: `rg -n "<symbol>\\("` or `rg -n "\\.<symbol>\\b"`
3. The symbol's neighbours from the first two greps, traced one hop: pick a hit, `rg -n "<caller>"`

If after these three the picture is still "a graph of 6+ files I'd have to Read in order", escalate.

## When NOT to escalate

- The user asked a single-symbol question. Grep is faster and free.
- The agent has already Read the answer file in this session — re-quoting is free.
- The repo has fewer than ~20 files of source code. Tier 2's graph build won't pay back.
- The user only needs a yes/no ("does this codebase use Redis?") — `rg -n "redis\\."` is enough.

## When to escalate aggressively

- The user explicitly asks for a "trace", "path", "flow", "blast radius", or "what depends on X".
- The repo is large (>50k LOC) and unfamiliar to the agent.
- A previous Tier 1 attempt returned 100+ grep hits and the answer is "find the meaningful subset".

## Failure modes to watch for

| Symptom | Likely cause | Fix |
|---|---|---|
| Tier 1 returns 0 hits | Symbol renamed, or wrong language extension assumed | Drop the `--type` flag; try case-insensitive `rg -i` |
| Tier 1 returns 200+ hits | Symbol is too common (e.g., `init`) | Narrow with module path: `rg -n "auth.*\\.init\\("` |
| Tier 2 graph build > 5 min | Repo too large, or vendored code being indexed | `--ignore vendor/ node_modules/ dist/ .venv/` |
| Tier 2 answer cites files that don't exist | Semantic LLM hallucinated | Spot-check with grep before reporting; downgrade if mismatch |
| Tier 2 backend errors out | Wrong `--backend` for the user's available API keys | Try `--backend gemini` or `--backend openai` per env vars |
