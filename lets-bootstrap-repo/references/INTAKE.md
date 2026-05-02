# Intake Guide — lets-bootstrap-repo

How to present the Phase 2 intake questions and validate responses.

## Question 1: Approver identity

Ask: "Who is approving this bootstrap? Provide your email address or GitHub handle."

Validation: non-empty string, no spaces. Example: `cogsmith-ai` or `rahul@example.com`.

Passed to: `--approved-by <value>`

## Question 2: One-sentence repo description

Ask: "In one sentence, what does this repo do?"

This is NOT passed to a CLI flag — it seeds a retained decision titled "Service purpose" after Phase 3 completes. Record it and use it in the Phase 5 readiness summary.

Validation: non-empty, ≤ 200 characters.

## Question 3: Non-negotiables

Ask: "What are 2–5 invariants that must never regress? Examples: 'No authenticated session tokens stored in plaintext', 'Public API contract stays backward-compatible'."

Validation: 2–7 items. One per line from user; translate each to a `--non-negotiable` flag.

If the user gives fewer than 2: prompt once more — "Can you add at least one more? Non-negotiables are used to gate AI mutations."

## Question 4: Critical flows

Ask: "What are the 2–5 critical user or system flows? Examples: 'End-to-end onboarding', 'Deployment to production', 'CI green gate'."

Note: `l10x` already detects candidate critical paths from the repo shape (directories named `auth/`, `payments/`, `billing/` etc.). You do not have access to these candidates before bootstrap runs — ask from scratch and bootstrap will merge detected + user-provided.

Validation: 2–7 items.

## Question 5: Governance posture

Ask: "Which governance posture fits this repo best?"

Present choices:
- `guarded` — every AI mutation requires human review; strictest
- `balanced` — AI-assisted edits with owner review *(recommended for most repos)*
- `adaptive` — AI can make most changes; spot review
- `experimental` — minimal gates; prototyping/research repos

Map to `--profile <choice>`.

## Question 6: Operational posture

Ask: "Which operational posture fits?"

Present choices:
- `intensive` — 24×7 availability; strict rollback; prod-critical
- `managed` — business-hours availability; standard rollback *(recommended)*
- `moderate` — best-effort; relaxed recovery
- `lightweight` — dev/internal tooling; minimal gates

Map to `--operational-posture <choice>`. This is a required flag alongside `--profile`.
