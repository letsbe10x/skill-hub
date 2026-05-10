# Quality Checklist

Run these checks whenever a skill is added or materially changed.

## Trigger Fixture Requirement

Every skill must have a trigger test fixture:

```
tests/skill-triggers/{skill-name}.json
```

Target:
- at least 10 `should_trigger` queries
- at least 10 `should_not_trigger` queries

Negatives must be near-misses — prompts that share vocabulary with the skill but belong to a neighboring surface. Trivially unrelated prompts do not prove the boundary.

## Minimum Validation Commands

```bash
# structural gate — required before any PR
forge check lets-{name}/SKILL.md --baselines-dir .forge/baselines

# smoke bench — confirms routing and basic behavior
forge bench lets-{name} --suite smoke
```

Run the forge check in strict mode. A missing or under-target trigger fixture fails the gate. Use `--allow-advisory` only when intentionally iterating in a draft loop before filling the trigger corpus.

If install smoke coverage exists for the repo surface, run it too:

```bash
# when the skill has a dedicated make target
forge bench lets-{name} --suite install-smoke
```

## Routing Boundary Check

If the skill introduces or narrows a routing boundary, decide whether trigger fixtures alone are enough or whether a versioned boundary dataset is warranted. See `evaluation-gate.md` for the decision rule.

Typical cases that need a dataset:
- a new skill competes with an existing one for similar trigger prompts
- the skill's description positioning shifts in a way that affects routing
- a maintainer reports repeated routing confusion

## Smoke-Test Rule of Thumb

Add or update install smoke coverage when:
- the skill gets its own `make` target
- the install target installs helper companions alongside the skill
- the install surface is user-facing and should stay stable

## Done Definition

Treat the skill as done only when:

- `forge check` passes in strict mode
- trigger fixture exists with strong near-miss negatives
- Makefile and README surfaces are updated when the repo maintains them
- any chosen bench suites ran and results were reviewed (not blindly accepted)
- remaining skips or advisory-only items are explicitly noted in the PR
