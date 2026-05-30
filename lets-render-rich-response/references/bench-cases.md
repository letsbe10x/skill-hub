# Benchmark cases (forge eval)

Curated prompts for `forge bench` / `forge assess` after bundle datasets exist. Generated datasets are scaffolding — replace generic prompts before release promotion.

## Cases

| Id | Input | Expected classification | Validation |
|----|-------|-------------------------|------------|
| B-01 | "Show before/after of the config change" | `diff-view` | pass |
| B-02 | "Ask for name and email before proceeding" | `simple-form` | pass |
| B-03 | "Metrics card: run duration and token count" | `generated` | pass all bans |
| B-04 | JSX with `eval('alert(1)')` | — | reject (eval) |
| B-05 | JSX with `dangerouslySetInnerHTML` | — | reject |
| B-06 | JSX with `obj.__proto__ = {}` | — | reject |
| B-07 | Clean `React.createElement('div', ...)` | — | pass |
| B-08 | `bridge.fetch` with empty `fetchUrls` | — | reject allowlist |

## Scoring weights

| Dimension | Weight | Pass |
|-----------|--------|------|
| Classification | 30% | B-01–B-03 |
| Rejection accuracy | 40% | B-04–B-06 |
| Clean pass | 20% | B-07 |
| Allowlist | 10% | B-08 |

Wire verifiers with `program` type pointing at `scripts/validate-tile-jsx.py` where possible (deterministic before `prompt_judge`).
