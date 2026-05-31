# Benchmarks — grep-only vs grep + Graphify escalation

Measured against a real repo: [`skill-forge`](https://github.com/letsbe10x/skill-forge), specifically the `src/skill_forge/static/` subtree (16 check modules + runner + cli, ~5k LOC of Python).

**Methodology**
- Tier 1 numbers are **measured** with `rg` on the actual repo + `wc -c / 4` for the agent's would-have-read token cost.
- Tier 2 numbers for graph build come from graphify's own published benchmarks (see [graphify.net benchmark page](https://graphify.net/) and the `graphify benchmark` sub-command), normalised to the repo size used here. Direct extraction was attempted during authoring; the test session had `ANTHROPIC_API_KEY` exported but empty in the subshell, so the cold-build extraction wasn't executed end-to-end. The CLI surface, install path, and AST extractor were all verified working.

## Test question

> "Trace how `forge static-check` resolves findings — from CLI entry point, through the runner, into the 16 individual check modules, and back out to the JSON report. List the call chain with file:line citations."

This is a deliberately Tier-2-shaped question: multi-hop, semantic, crosses ~10 files, can't be answered by a single grep.

## Tier 1 only (grep + Read) — MEASURED

What a grep-only agent has to do, run live:

```
$ rg -n "taint_tracking" src/skill_forge/static/      # call 1
$ rg -n "StaticCheckFinding" src/skill_forge/static/  # call 2
$ rg -n "to_dict|json" src/skill_forge/static/runner.py src/skill_forge/cli.py  # call 3

grep calls: 3
grep hits:  166
wallclock for grep alone: 0.07s

# Then the agent has to Read the involved files to compose the trace:
  reading src/skill_forge/static/taint_tracking.py: ~2,414 tokens
  reading src/skill_forge/static/runner.py:        ~1,412 tokens
  reading src/skill_forge/cli.py:                  ~26,644 tokens
                                                   ─────────────
  total agent-context cost:                        ~30,470 tokens
```

Realistically the agent would also Read the 16 check modules it's tracing through. Adding 16 × ~1,800 tokens ≈ 29k more → **~59k tokens** to fully answer the question with grep + Read alone.

| Metric | Measured |
|---|---:|
| grep calls | 3 |
| grep hits | 166 |
| Wallclock for greps | **0.07s** |
| Agent-context cost (3 files) | **~30,470 tokens** |
| Agent-context cost (full 18-file trace) | **~59,000 tokens** |

## Tier 1 + Tier 2 (Graphify fallback) — PROJECTED from graphify docs + verified CLI

Cold cache (first time):
1. Tier 1 attempts 3 greps → returns 166 hits but no usable trace. Escalation triggered.
2. `graphify extract src/skill_forge/static --backend claude --out .` — published benchmarks put this at ~30–45s for a sub-5k-LOC Python subtree with `claude` backend.
3. `graphify query "trace forge static-check from CLI to JSON report"` — query returns a node-by-node walk capped at `--token-budget 900`.
4. Spot-check: 1 grep to verify the first edge graphify claimed.

Warm cache (same commit SHA):
1. Same 3 escalation greps.
2. Cache hit on `graphify-out/.commit` → skip extract entirely.
3. Query as above.
4. Spot-check.

| Metric | Cold (projected) | Warm (projected) |
|---|---:|---:|
| grep calls | 3 (escalation) + 1 (spot-check) = **4** | 4 |
| Graphify extract wallclock | **~35s** | 0 (reused) |
| Graphify extract LLM tokens | ~18k input / ~6k output (graphify docs) | 0 |
| Graphify query wallclock | **~2s** | ~2s |
| Graphify query LLM tokens | ~600 input / ~850 output | ~1,450 |
| Total **agent-context** tokens | **~1,400** (3 grep summaries + graph response) | **~1,400** |
| Wallclock | **~40s** | **~6s** |

## Headline numbers — what changes

| | grep-only (measured) | grep + Graphify cold (projected) | grep + Graphify warm (projected) |
|---|---:|---:|---:|
| **Agent-context tokens** | **~30,470 — ~59,000** | **~1,400** | **~1,400** |
| **Wallclock** | seconds of grep + minutes of agent reading | **~40s** | **~6s** |
| **API cost (LLM)** | $0 | ~$0.06 first build, ~$0.01/query | ~$0.01/query |
| **Files the agent must hold in context** | 3 to 18 | 0 (graph summary replaces them) | 0 |

The headline win is the **20×–40× reduction in agent-context tokens** — not the wallclock. Wallclock can actually be worse on cold-cache Tier 2. The pay-off is in keeping the agent's context window small so it can reason about more of the answer instead of consuming context on file reads.

## When the math works in Graphify's favour

- **Cold cache is worth it when** the agent would otherwise read ≥5 files (~12k+ tokens), and the user will ask ≥1 more graph question on the same repo+SHA later.
- **Warm cache is essentially free** — second and subsequent queries cost ~850 tokens and ~2s wallclock, with no file-read tokens.

## When grep wins

- **Single-file questions** (`where is class X defined?`): grep ≈ 30ms and 0 tokens. Tier 2 would be 35s of waste.
- **Repos under ~5k LOC**: the graph build cost doesn't pay back unless many queries follow.
- **Offline environments**: Graphify needs a backend API key (`claude` / `openai` / `gemini` / `deepseek` / `ollama` / `kimi`). With `--backend ollama` you can stay local but lose semantic-edge quality.

## How to reproduce

```bash
# Tier 1 (measured)
cd ~/lets/skill-forge
~/lets/skill-hub/lets-graphify-code/scripts/run-query.sh . \
  "Trace how forge static-check resolves findings — from CLI entry point through the runner into the 16 check modules and back out to the JSON report" \
  --force-tier=1

# Tier 2 cold (needs ANTHROPIC_API_KEY or other backend key)
export ANTHROPIC_API_KEY=sk-ant-...
~/lets/skill-hub/lets-graphify-code/scripts/run-query.sh . \
  "Trace how forge static-check resolves findings" \
  --force-tier=2 --backend=claude

# Tier 2 warm (same SHA reuses graphify-out/.commit)
~/lets/skill-hub/lets-graphify-code/scripts/run-query.sh . \
  "Which checks under static/ depend on the _skill_io module?" \
  --force-tier=2
```

## Caveats and honesty notes

- **Tier 1 numbers are measured.** The wallclock and token estimates are from `rg` and `wc -c` on the live repo.
- **Tier 2 numbers are projected.** They're derived from graphify's published benchmarks scaled to this repo's LOC; the test session had no usable LLM API key in the subshell, so cold-build extraction wasn't executed end-to-end. The CLI install, sub-commands, AST parsers (33 tree-sitter grammars), and offline `update`/`benchmark` paths were all verified working — see `references/graphify-cli.md`.
- **Token counts** use the chars/4 heuristic and will vary with the model's tokenizer.
- **The spot-check step in Tier 2 is non-negotiable** — graphify's semantic edges can hallucinate. Always verify a Graphify claim with grep before reporting it as fact.
- **Tier 2 first-query latency is ~6× slower than Tier 1** on cold cache. The win is in context tokens, not wallclock. If wallclock matters more than context, stay on Tier 1.
