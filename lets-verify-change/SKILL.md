---
name: lets-verify-change
description: "Completeness gate: runs mechanical verification scripts (scenario coverage, stitch checks, spec alignment) + test suite, produces gap ledger on failure, and enables loop-back to lets-develop-feature for scoped fixes. Do not invoke without implementation being complete."
metadata:
  author: cogsmith-ai
  version: "2.0.0"
  tags: [testing, verification, delivery, completeness, enforcement]
lifecycle: published
source: https://github.com/letsbe10x/skills/blob/main/lets-verify-change/SKILL.md
compatibility:
  agents: [claude-code, cursor, codex, copilot]
handoffs:
  - trigger: gap_found_structural
    delegate_to: lets-develop-feature
    artifact_expected: gap-ledger.json
    resume_at: stage_6_implement
    required: true
    context_pass: [gap_ledger, carry_forward]
outcome_runtime:
  open_agency_zones:
    - verification_strategy
    - risk_based_test_selection
    - semantic_check_depth
  governed_action_zones:
    - verification_claim
    - gap_deferral
  allowed_moves:
    - request_missing_test_surface
    - narrow_verification_to_risk
    - defer_gap_with_user_confirmation
    - loop_back_to_implement
  hard_limits:
    - do_not_claim_success_without_command_output
    - do_not_ignore_failing_checks
    - do_not_skip_gate_scripts
    - do_not_defer_without_user_confirmation
    - do_not_exceed_max_iterations
    - do_not_pass_gate_with_open_structural_gaps
  required_decision_frames:
    - verification_scope
    - gap_severity_assessment
  validation_gates:
    - verification_evidence_gate
    - script_execution_gate
    - gap_resolution_gate
  mutation_policy: additive_only
  human_checkpoint_triggers:
    - missing_truth
    - unresolved_disagreement
    - max_iterations_exceeded
    - structural_gap_discovered
---

> **Note:** This is the standalone version. For letsbe10x runtime augmentation (context pre-flight, governance, pack enrichment), use the `l10x` profile from [skill-overlay](https://github.com/letsbe10x/skill-overlay).

# lets-verify-change

The completeness gate for feature delivery. Runs mechanical scripts + test suite + semantic
checks to verify that the implementation is complete, correctly wired, and aligned to the spec.
Produces a structured gap ledger when gaps exist, enabling scoped loop-back to implementation.

**This skill is NOT "run tests again." It answers:**
1. Are all scenarios from the matrix covered by tests?
2. Are all components wired together (registered, imported, connected)?
3. Are all spec requirements implemented with evidence?
4. Does the test suite pass?
5. Do semantic spot-checks confirm the tests verify actual intent?

---

## Verification Law

**NO COMPLETION CLAIM WITHOUT FRESH VERIFICATION RUN.**

If you have not run the verification scripts AND the test suite in this response, you
cannot report the change as verified. "Should pass", "likely passes", "passed last time"
are not verification evidence.

**NO GATE BYPASS WITHOUT USER CONFIRMATION.**

If a gate script reports gaps, you cannot proceed to review. You either fix the gaps
(loop back) or the user explicitly defers them.

---

## When to Use

- After `lets-develop-feature` has completed implementation (Stage 6-7 done)
- Before `lets-review-code` — review ONLY fires after this gate passes
- Part of the delivery chain: lets-develop-feature → **lets-verify-change** → lets-review-code
- On loop-back: after scoped fixes from develop-feature, re-verify incrementally

## When Not to Use

- Implementation is not complete → invoke `lets-develop-feature` first
- You only need to run the test suite without completeness checks → use the test runner directly
- You want a code quality review → that's `lets-review-code` (after this passes)

---

## Two Operating Modes

### Mode A: Core Runtime Present

When `lets` CLI is available, the core runtime invokes gate scripts automatically via
`VerificationGate` and manages the loop. The skill protocol guides the agent through
interpreting results and deciding on fixes vs deferrals.

### Mode B: Agent-Directed (Standalone)

When core is not available, the agent runs gate scripts directly, reads their JSON output,
and follows the loop protocol manually. Same scripts, same artifacts, same enforcement —
different orchestrator.

**Detection:** Try `lets --version`. If available, use Mode A. If not, use Mode B.

---

## Inputs

| Input | Source | Required |
|-------|--------|----------|
| Run directory | `lets run list` or `.lets/runs/lets-develop-feature/latest` | Yes |
| `scenario-matrix.json` | Produced by develop-feature Stage 3 | For STANDARD+ |
| `execution-packet.json` | Produced by develop-feature Stage 3 | For STANDARD+ |
| `spec-requirements.json` | Produced by develop-feature Stage 3 | For ELEVATED+ |
| Rigor level | From run-state.json or classification | Yes |
| Repo root | Working directory | Yes |
| Previous gap ledger (on loop-back) | From prior verification iteration | On re-entry |

---

## Phase 0 — Load Context

### Mode A (core present):

```bash
lets run list --format json | jq '.[0].run_dir // empty'
```

Read from run directory:
- `workflow_context.json` → extract `must_preserve`
- `classification.json` → extract `governance_verdict`, `rigor_level`
- `run-state.json` → extract current stage, iteration count
- `gap-ledger.json` (if exists) → this is a loop-back re-entry

### Mode B (standalone):

Read from the run directory (`.lets/runs/lets-develop-feature/latest/`):
- `run-state.json` → rigor level, current iteration
- `scenario-matrix.json`, `execution-packet.json`, `spec-requirements.json`
- `gap-ledger.json` (if exists) → loop-back re-entry

If governance verdict is BLOCK: stop, print reason, do not proceed.

---

## Phase 1 — Prerequisites Check

Before running verification:

1. Implementation work packages from the execution packet are marked complete
2. Test stage (Stage 7) has been executed — tests exist
3. Structured artifacts exist per rigor level:
   - STANDARD+: `scenario-matrix.json` and `execution-packet.json`
   - ELEVATED+: also `spec-requirements.json`
4. If this is a loop-back: `gap-ledger.json` exists with open gaps

If artifacts are missing: surface which ones and ask the user whether to proceed
with reduced verification or go back to produce them.

---

## Phase 2 — Run Gate Scripts (Mechanical Verification)

### Intensity filtering

Only run scripts appropriate for the current rigor level:

| Script | MINIMAL | STANDARD | ELEVATED | FULL |
|--------|---------|----------|----------|------|
| `verify_scenarios.py` | — | ✓ | ✓ | ✓ |
| `verify_stitch.py` | — | ✓ | ✓ | ✓ |
| `verify_spec_coverage.py` | — | — | ✓ | ✓ |

### Mode A (core present):

```bash
lets run exec verify-change \
  --repo-root $REPO_ROOT \
  --state-root $STATE_ROOT \
  --format json
```

Core's `VerificationGate` runs the scripts and returns the aggregated result.

### Mode B (standalone):

Run each applicable script directly:

```bash
python /path/to/skill/scripts/verify_scenarios.py \
  "$RUN_DIR/scenario-matrix.json" "$REPO_ROOT"

python /path/to/skill/scripts/verify_stitch.py \
  "$RUN_DIR/execution-packet.json" "$REPO_ROOT"

python /path/to/skill/scripts/verify_spec_coverage.py \
  "$RUN_DIR/spec-requirements.json" "$REPO_ROOT"
```

Each script outputs JSON to stdout. Capture and parse it.

### Incremental mode (loop-back)

When re-verifying after a fix loop, pass the carry-forward list:
- Only re-check scenarios/requirements that were in the gap ledger's `re_verify_scope`
- All previously-passed IDs carry forward without re-checking

For Mode B: filter the input JSON to only include the IDs in `re_verify_scope` before
passing to scripts, OR run the full script and ignore results for IDs in `carry_forward.passed_ids`.

---

## Phase 3 — Run Test Suite

Regardless of gate script results, run the project's test suite:

```bash
# Detect and run
uv run pytest tests/ -v          # Python
npm test                          # JavaScript/TypeScript
cargo test                        # Rust
go test ./...                     # Go
```

Capture full output. Do not skim or scroll past failures.

| `test_status` | Meaning | Action |
|---------------|---------|--------|
| `passed` | All tests pass | Continue to Phase 4 |
| `failed` | Tests failing | Fix immediately (not via loop-back — these are code bugs) |
| `skipped` | No test runner | Note in output, continue to Phase 4 |

**Test failures are fixed in-place** (not via the loop protocol). The loop is for
completeness gaps, not broken code.

---

## Phase 4 — Semantic Verification (Agent-Driven)

For STANDARD+ rigor, perform semantic spot-checks on the highest-risk scenarios:

### What to check

For the top N scenarios (N depends on rigor):
- STANDARD: top 3 risk scenarios
- ELEVATED: all scenarios
- FULL: all scenarios + integration flow trace

### Per scenario

1. Read the test that covers this scenario
2. Assess: does the test actually verify the scenario's expected behavior?
   - Does it assert the right output (not just "no crash")?
   - Does it test the specific input described in the scenario?
   - Does it cover the error handling path (if failure scenario)?
3. Record verdict:

```json
{
  "check_id": "SEM-001",
  "scenario_id": "S004",
  "verdict": "adequate | weak | missing_intent",
  "confidence": 0.8,
  "reasoning": "Test asserts 429 status but never validates rate counter was exceeded."
}
```

### Semantic check thresholds

| Rigor | Block on |
|-------|----------|
| STANDARD | Any `missing_intent` in top-3 |
| ELEVATED | Any `missing_intent` anywhere |
| FULL | Any `missing_intent` OR >2 `weak` |

---

## Phase 5 — Aggregate Results & Decide

Aggregate all verification evidence:

| Source | Status field |
|--------|-------------|
| Gate scripts | `script_status`: passed / gap_found / error |
| Test suite | `test_status`: passed / failed / skipped |
| Semantic checks | `semantic_status`: passed / weak / gaps_found |

### Decision matrix

| script_status | test_status | semantic_status | Overall verdict |
|---------------|-------------|-----------------|----------------|
| passed | passed | passed | **PASS** → proceed to review |
| passed | passed | weak | **PASS with warning** → proceed, note in handoff |
| gap_found | passed | * | **GAPS** → produce gap ledger, loop or defer |
| * | failed | * | **BLOCKED** → fix tests first (in-place, no loop) |
| passed | passed | gaps_found | **GAPS** → semantic gaps added to gap ledger |
| error | * | * | **ERROR** → investigate script failure |

---

## Phase 6 — Gap Resolution Protocol

When verdict is **GAPS**:

### Step 1: Produce the gap ledger

Aggregate all gaps from script results + semantic checks into a single `gap-ledger.json`:

```json
{
  "schema_version": "1",
  "run_id": "<current-run-id>",
  "iteration": 1,
  "max_iterations": 2,
  "carry_forward": {
    "passed_ids": ["S001", "S002", "S003", "R001", "R002"],
    "passed_at": "2026-05-16T10:30:00Z"
  },
  "gaps": [...],
  "re_verify_scope": ["S004", "R007", "ST002"],
  "status": "open"
}
```

Write to `$RUN_DIR/gap-ledger.json`.

### Step 2: Present gaps to user

```
Verification found N gaps:

| # | Type | Severity | Reference | Description |
|---|------|----------|-----------|-------------|
| G001 | scenario_uncovered | minor | S004 | No test for rate limit scenario |
| G002 | stitch_missing | minor | ST002 | BillingHandler not registered |
| G003 | spec_unimplemented | structural | R007 | Audit log requirement not implemented |

Options:
1. Fix all gaps (loop back to implement)
2. Defer minor gaps, fix structural (loop back with reduced scope)
3. Defer all (requires justification per gap)
```

### Step 3: Handle user decision

**If fixing (loop back):**
- Check iteration count: if `iteration >= max_iterations` → escalate (can't loop more)
- Increment iteration in gap ledger
- Hand off to `lets-develop-feature` with the gap ledger as the scoped packet
- Develop-feature reads ONLY the gap ledger (no re-grounding, no re-planning)
- After fix: re-enter this skill at Phase 2 (incremental mode)

**If deferring:**
- Require user to confirm each deferral with a reason
- Validate against deferral policy (rigor-based caps):
  - STANDARD: max 3 deferred, minor severity only
  - ELEVATED: max 1 deferred, minor only
  - FULL: no deferrals allowed
- Update gap status to "deferred" in ledger
- If all remaining gaps are deferred: verdict becomes PASS (with deferrals noted in handoff)

**If max iterations exceeded:**
- Present full gap report
- Escalate to user: "Gaps persist after N fix loops. Options: defer, manual fix, or block."

---

## Phase 7 — Produce Verification Record

When the gate passes (all gaps resolved/deferred, tests pass):

Write `verification-result.json` to the run directory:

```json
{
  "schema_version": "1",
  "status": "passed",
  "timestamp": "2026-05-16T10:45:00Z",
  "iterations": 1,
  "test_status": "passed",
  "test_counts": { "passed": 42, "failed": 0, "errors": 0 },
  "script_results": {
    "verify_scenarios": { "status": "passed", "checks": 8, "passed": 8 },
    "verify_stitch": { "status": "passed", "checks": 3, "passed": 3 },
    "verify_spec_coverage": { "status": "passed", "checks": 5, "passed": 5 }
  },
  "semantic_checks": {
    "total": 3,
    "adequate": 3,
    "weak": 0,
    "missing_intent": 0
  },
  "deferred_gaps": [],
  "carry_forward_count": 0,
  "rigor_level": "STANDARD"
}
```

---

## Phase 8 — Handoff to Review

When verification passes, proceed to `lets-review-code`.

### Mode A:
```bash
lets run exec review-change \
  --repo-root $REPO_ROOT \
  --state-root $STATE_ROOT
```

### Mode B:
Invoke `lets-review-code` skill directly. Pass the verification result as context.

---

## Loop Protocol Summary

```
lets-develop-feature (Stages 1-7 complete)
    │
    ▼
lets-verify-change
    │
    ├── Phase 2-4: Run scripts + tests + semantic checks
    │
    ├── ALL PASS ────────────────────────────► Phase 7-8 (record + handoff to review)
    │
    ├── TEST FAILURES ───────────────────────► Fix in-place, re-run Phase 3
    │
    └── COMPLETENESS GAPS ───────────────────► Phase 6 (gap protocol)
            │
            ├── User: "fix" ─────────────────► Gap ledger → develop-feature (scoped)
            │                                      │
            │                                      └── Re-enter Phase 2 (incremental)
            │
            ├── User: "defer" ───────────────► Validate policy → PASS (with deferrals)
            │
            └── Max iterations hit ──────────► Escalate to user
```

---

## Negative Guardrails

| # | Guardrail |
|---|-----------|
| 1 | I will NOT claim verification passed without running gate scripts |
| 2 | I will NOT skip a gate script because "it probably passes" |
| 3 | I will NOT defer gaps without explicit user confirmation |
| 4 | I will NOT exceed deferral policy limits for the rigor level |
| 5 | I will NOT loop back more than max_iterations times |
| 6 | I will NOT proceed to review with open structural gaps |
| 7 | I will NOT fabricate script results or test output |
| 8 | I will NOT re-run the full verification when incremental mode applies |
| 9 | I will NOT treat semantic "weak" as "missing_intent" (different thresholds) |
| 10 | I will NOT fix completeness gaps in-place (that's develop-feature's job via loop-back) |

---

## Anti-patterns

- **Running tests without gate scripts** — tests prove code correctness, not completeness
- **Skipping semantic checks at ELEVATED+ rigor** — a test that asserts nothing is worse than no test
- **Deferring structural gaps** — structural gaps (requirement not implemented) should loop back, not defer
- **Re-running full verification on loop-back** — incremental mode checks only the gap scope
- **Fixing gaps inside verify-change** — verify is read-only for completeness gaps. It hands back to implement.
- **Treating the gap ledger as optional** — without it, the fix pass has no scope and burns tokens re-discovering

---

## Error Handling

| Condition | Action |
|-----------|--------|
| Script not found | Report error, ask user to check skill installation |
| Script timeout (>60s) | Report timeout, retry once, then error |
| Script outputs invalid JSON | Report parse error, mark as error status |
| No structured artifacts exist | Reduce to test-suite-only verification, note in handoff |
| Iteration >= max_iterations | Block with full gap report, escalate to user |
| User rejects all gaps for deferral | Loop back to implement |
| User wants to proceed despite gaps | Only possible if gaps are within deferral policy |

---

## Graceful Degradation

| Condition | Behavior |
|-----------|----------|
| Core not available | Agent runs scripts directly (Mode B) |
| Structured artifacts missing | Run test suite only, note reduced verification |
| MINIMAL rigor | Skip all gate scripts, run tests only |
| Scripts fail to execute | Fall back to test-suite-only + semantic checks |
| No test runner detected | Report skipped, proceed with script verification only |

---

## Done when

All of the following are true:
- Gate scripts pass (or no applicable scripts at this rigor level)
- Test suite passes (or documented skip)
- Semantic checks pass threshold (or rigor doesn't require them)
- No open structural gaps remain
- All deferred gaps are within policy
- `verification-result.json` written to run directory
- Handoff to `lets-review-code` invoked
