# Graphify CLI — cheat sheet

Pinned to Graphify ≥ v4. Source: [safishamsi/graphify](https://github.com/safishamsi/graphify).

## Install

```bash
uv tool install graphifyy        # PyPI package name is graphifyy (double y)
graphify --version               # verify
```

The CLI is opt-in and lazy-installed by `lets-graphify-code` only when Tier 2 fires.

## Extract a graph

```bash
graphify extract <path>                    # default backend: anthropic
graphify extract . --backend gemini        # use Gemini for the semantic pass
graphify extract . --output graphify-out   # output dir (default: ./graphify-out)
graphify extract . --ignore vendor/ --ignore node_modules/ --ignore dist/ --ignore .venv/
```

Backends supported: `anthropic`, `openai`, `gemini`, `local` (uses tree-sitter only, no semantic pass — fastest but lower-fidelity).

**Caching:** Graphify itself does not cache across runs. We cache externally by writing the git SHA to `graphify-out/.commit` and skipping re-extraction when the SHA matches.

## Query the graph

```bash
graphify query "<natural language question>"
graphify query "trace the auth flow from HTTP handler to DB write"
graphify query "what depends on UserService.verify and could break if its signature changes" --token-budget 1500
```

The `--token-budget` flag bounds the response size. Default ~900 tokens. Lower it if you only need a summary; raise it for exhaustive traces.

## Path-finding between known symbols

```bash
graphify path "<source-symbol>" "<sink-symbol>"
graphify path "LoginHandler" "UsersRepository"
graphify path "cli.main" "db.execute"          # dotted paths are accepted
```

Returns the shortest path through the graph plus any tied alternates.

## Export views

```bash
graphify export callflow-html              # interactive HTML diagram
graphify export callflow-html --root cli.main --depth 3
graphify export dot                        # graphviz format
graphify export mermaid                    # mermaid format for embedding in markdown
```

Use exports when the user wants a diagram to put in a PR description or design doc.

## MCP server mode

```bash
python -m graphify.serve graphify-out/graph.json
```

Exposes these MCP tools to the agent:
- `query_graph(question)` — natural-language graph query
- `get_node(symbol)` — fetch a single node's metadata
- `get_neighbors(symbol, direction)` — direct callers / callees
- `shortest_path(source, sink)`
- `list_prs()` / `get_pr_impact(pr_number)` / `triage_prs()` — git-aware tools

`lets-graphify-code` does not require MCP mode — the CLI is sufficient. MCP mode is for users who want persistent graph access across many agent sessions.

## CI / team workflows

```bash
graphify hook install              # adds a git hook to rebuild graph on commit
graphify merge-graphs a.json b.json -o merged.json   # combine subgraph outputs
graphify prs --triage              # rank open PRs by graph-impact
```

Out of scope for `lets-graphify-code`. Mentioned here so the agent can recommend follow-up tooling.

## Env vars

| Var | Purpose |
|---|---|
| `GRAPHIFY_BACKEND` | Override the default semantic backend (`anthropic` / `openai` / `gemini` / `local`) |
| `GRAPHIFY_MAX_OUTPUT_TOKENS` | Cap query response size globally |
| `ANTHROPIC_API_KEY` / `OPENAI_API_KEY` / `GEMINI_API_KEY` | Backend credentials — at least one is required unless backend is `local` |

## Cost notes

- **AST extraction** is local-only (tree-sitter). No API calls. Scales with LOC and language count.
- **Semantic pass** calls the chosen backend once per file. Typical cost on a 50k-LOC Python repo: ~20k–50k tokens of LLM API spend on first build, free thereafter (cached by `.commit` file).
- **Query** calls the backend with a graph-trimmed context. Typical cost: 600–900 tokens per question.

`lets-graphify-code` reports these in the Tier 2 output block so the user can see actual cost, not estimated.
