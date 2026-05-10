# Evaluation Gate

Keep evaluation layers separate. Do not collapse them into a single vague "eval" bucket.

1. deterministic packaging and forge gate checks
2. deterministic boundary-dataset integrity checks when routing matters
3. optional live model scoring on a held-out split

## Gate 1: Packaging (Always Required)

Run forge's structural gate for any new or materially changed skill. This is the minimum merge bar.

```bash
forge check lets-{name}/SKILL.md --baselines-dir .forge/baselines
```

What forge checks:
- frontmatter completeness (name, description, version on published skills)
- required section presence
- no placeholder tokens left in the body
- structural score does not regress below the stored baseline

This gate requires no LLM and runs in milliseconds. Every PR must pass it.

## Gate 2: Boundary Dataset (When Routing Changes)

Add a versioned boundary dataset under `evals/datasets/` when:

- a new skill competes with an existing one for similar trigger prompts
- a skill's description or positioning changes in a way that likely affects routing
- a maintainer reports repeated routing confusion between adjacent skills

Use a boundary dataset when you need a concrete source-of-truth pattern:

```bash
# run the bundle's boundary-eval suite
forge bench lets-{name} --suite capability

# score predictions against the dataset
forge result analyze .forge/benchmarks/lets-{name}.json
```

Accept a run only after reviewing the analysis — record a reason:

```bash
forge bundle accept-run lets-{name} .forge/benchmarks/lets-{name}.json \
  --reason "accepted curated capability baseline"
```

## Gate 3: Live Scoring (Optional)

Treat live model scoring as a quality signal, not a packaging gate.

Typical pattern:
- tune on `train` split
- score on `validation` split
- update the dataset only when the product boundary truly changed

If the repo does not have a routing-eval harness, stop at Gate 2 instead of inventing a fake eval layer.

## Dataset Design Rules

- keep IDs stable — add cases instead of silently reinterpreting old ones
- keep `train` and `validation` both non-empty
- use natural prompts, not slot-filled templates
- make negatives near-misses, not unrelated noise

Trigger fixtures and boundary datasets solve different problems:
- trigger fixtures protect packaging and basic discovery hygiene
- boundary datasets protect high-value routing boundaries over time

## When to Stop

- Gate 1 is enough for a new skill with a clear, non-overlapping boundary
- Add Gate 2 when the skill competes with a neighbor or a maintainer flags routing confusion
- Add Gate 3 only when live scoring is the only way to verify a quality property that matters
