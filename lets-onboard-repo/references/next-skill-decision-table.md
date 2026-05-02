# Next Skill Decision Table

Used by `lets-onboard-repo` step 4 to recommend the appropriate follow-up skill.

## Decision Logic

Evaluate conditions in order. Use the first row that matches.

| Condition | Recommended next skill | Rationale |
|-----------|------------------------|-----------|
| One or more recent runs have `status: failed` | `lets-triage-issue` | Active failures need diagnosis before other work. |
| Governance gaps detected (P0 or P1) | `lets-audit-repo` | Policy violations should be resolved early. |
| Context pack is stale or incomplete | `lets-enrich-context` | Stale context degrades all other skills. |
| Repo has no open PRs and no recent failures | `lets-spec-to-pr` | Good baseline — time to build something. |
| Repo has open PRs awaiting review | `lets-review-pr` | Unreviewed PRs are the highest-leverage next action. |
| None of the above | (no recommendation) | The repo looks healthy — explore the skill library. |

## Notes

- "Recent runs" means within the last 7 days or since the last deploy, whichever is shorter.
- "Stale context" means the context pack TTL has expired per `settings.py` defaults.
- Governance gap priority (P0/P1) is defined in the `lets-audit-repo` skill outputs.
