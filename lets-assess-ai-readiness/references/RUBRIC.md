# Rubric — lets-assess-ai-readiness

Full check catalog. Each check is deterministic (file/config based) or heuristic (pattern-based with confidence). Deterministic checks gate levels; heuristic checks are advisory only.

## Check Schema

Every check has:
- `check_id`: stable identifier (e.g., `feedback.test_runner_discoverable`)
- `pillar`: one of the 8 pillars
- `min_level`: L1-L5 (minimum level this check gates)
- `required`: boolean (gates level achievement)
- `weight`: numeric (contribution to pillar score)
- `detect_type`: `deterministic` or `heuristic`
- `detect_method`: how to verify (see methods below)
- `evidence`: what to record
- `remediation`: concrete fix action
- `scaffold`: whether this can be auto-generated

## Detection Methods

| Method | Type | How |
|--------|------|-----|
| `file_exists` | deterministic | Check if path exists (supports glob) |
| `file_contains` | deterministic | Check if file contains a pattern |
| `config_has_key` | deterministic | Parse JSON/YAML/TOML and check for key |
| `command_discoverable` | deterministic | Check Makefile/scripts/package.json for target |
| `directory_structure` | deterministic | Check directory naming and organization patterns |
| `file_ratio` | heuristic | Ratio of files matching a pattern vs total |
| `convention_consistency` | heuristic | Measure how consistently a pattern is followed |
| `content_quality` | heuristic | Assess whether content is actionable vs placeholder |
| `timing_estimate` | heuristic | Estimate execution time from config/CI logs |

---

## Check Catalog

### Pillar 1: Feedback Velocity

| check_id | min_level | required | weight | detect | remediation |
|-----------|-----------|----------|--------|--------|-------------|
| `feedback.test_runner_discoverable` | L1 | yes | 3 | command_discoverable: test target in Makefile/scripts/pyproject | Add a discoverable test command |
| `feedback.scoped_execution` | L2 | yes | 3 | file_contains: test runner config supports path arguments | Configure test runner for file/directory filtering |
| `feedback.test_convention_consistent` | L3 | yes | 3 | file_ratio: >80% test files follow one naming pattern | Standardize test file naming |
| `feedback.fast_target_exists` | L3 | no | 2 | command_discoverable: "unit"/"fast"/"smoke" target | Add a fast test target (<60s) |
| `feedback.layered_validation` | L4 | no | 2 | command_discoverable: distinct unit/integration/e2e targets | Separate test layers with distinct commands |
| `feedback.incremental_tooling` | L5 | no | 2 | file_exists: watch mode config or incremental build config | Configure incremental/watch tooling |

### Pillar 2: Error Signal Clarity

| check_id | min_level | required | weight | detect | remediation |
|-----------|-----------|----------|--------|--------|-------------|
| `errors.linter_configured` | L1 | yes | 2 | file_exists: linter config file (any ecosystem) | Configure a linter |
| `errors.structured_output_supported` | L3 | no | 2 | config_has_key: linter/test supports --format json or SARIF | Enable structured output format |
| `errors.type_checker_configured` | L2 | no | 2 | file_exists: type checker config (tsconfig, mypy.ini, pyrightconfig) | Configure type checking |
| `errors.assertion_diffs` | L3 | no | 2 | heuristic: test framework configured for diff output | Configure test runner for assertion diffs |
| `errors.ci_failure_parseable` | L4 | no | 2 | heuristic: CI output has file:line references in failures | Configure structured CI output |

### Pillar 3: Determinism

| check_id | min_level | required | weight | detect | remediation |
|-----------|-----------|----------|--------|--------|-------------|
| `determinism.lockfile_present` | L1 | yes | 3 | file_exists: lockfile for ecosystem | Commit a lockfile |
| `determinism.lockfile_committed` | L1 | yes | 2 | file_contains: lockfile NOT in .gitignore | Remove lockfile from .gitignore |
| `determinism.env_documented` | L2 | yes | 2 | file_exists: .env.example or equivalent | Add .env.example with all required vars |
| `determinism.test_isolation` | L3 | no | 3 | heuristic: no shared mutable state patterns in test config | Configure test isolation |
| `determinism.ci_matches_local` | L3 | no | 2 | heuristic: CI commands match documented local commands | Align CI and local test commands |
| `determinism.no_network_in_tests` | L4 | no | 3 | heuristic: test files don't make unmocked network calls | Mock external network calls in tests |

### Pillar 4: Change Safety

| check_id | min_level | required | weight | detect | remediation |
|-----------|-----------|----------|--------|--------|-------------|
| `safety.module_boundaries_exist` | L1 | yes | 3 | directory_structure: >1 top-level source directory | Organize code into modules |
| `safety.boundaries_documented` | L2 | no | 2 | file_exists: module-level docs or AGENTS.md describing boundaries | Document module responsibilities |
| `safety.import_restrictions` | L3 | no | 3 | config_has_key: import linting rules or layer checks | Configure import boundary enforcement |
| `safety.circular_deps_checked` | L3 | no | 2 | command_discoverable: dependency graph or circular dep check | Add circular dependency detection |
| `safety.scoped_test_confidence` | L4 | no | 3 | heuristic: module changes only require module tests | Design tests for module isolation |
| `safety.impact_analysis_available` | L5 | no | 2 | command_discoverable: affected-test or impact analysis tool | Add change impact tooling |

### Pillar 5: Context Discoverability

| check_id | min_level | required | weight | detect | remediation |
|-----------|-----------|----------|--------|--------|-------------|
| `context.readme_with_commands` | L1 | yes | 3 | content_quality: README has fenced code blocks with commands | Add runnable commands to README |
| `context.agent_guidance_present` | L2 | yes | 3 | file_exists: AGENTS.md or CLAUDE.md or equivalent | Add agent guidance documentation |
| `context.module_docs_ratio` | L3 | no | 2 | file_ratio: modules with local docs vs total modules >50% | Add per-module documentation |
| `context.coding_rules_present` | L2 | no | 2 | file_exists: docs/coding-rules.md or CONTRIBUTING.md | Document coding conventions |
| `context.docs_freshness` | L4 | no | 2 | heuristic: doc modification date within 3 months of code changes | Update stale documentation |
| `context.context_verified` | L5 | no | 3 | heuristic: doc commands match actual available commands | Validate documentation commands |

### Pillar 6: Pattern Consistency

| check_id | min_level | required | weight | detect | remediation |
|-----------|-----------|----------|--------|--------|-------------|
| `patterns.formatter_configured` | L1 | yes | 2 | file_exists: formatter config (prettier, black, gofmt, rustfmt) | Configure a formatter |
| `patterns.formatter_enforced` | L3 | yes | 2 | file_contains: formatter in CI or pre-commit | Enforce formatting in CI |
| `patterns.linter_enforced_ci` | L3 | no | 2 | file_contains: linter step in CI workflow | Add linter to CI |
| `patterns.single_test_convention` | L2 | no | 2 | convention_consistency: test organization follows one pattern | Standardize test organization |
| `patterns.extension_guide_exists` | L3 | no | 2 | content_quality: "Adding a New X" guide for common contribution | Add extension guide |
| `patterns.generators_available` | L4 | no | 2 | command_discoverable: scaffolding/generator tooling | Add code generation templates |

### Pillar 7: Recovery Cost

| check_id | min_level | required | weight | detect | remediation |
|-----------|-----------|----------|--------|--------|-------------|
| `recovery.ci_blocks_merge` | L2 | yes | 3 | file_contains: required status checks or CI in PR workflow | Make CI required for merge |
| `recovery.review_required` | L2 | no | 2 | file_exists: CODEOWNERS or branch protection config | Require code review |
| `recovery.feature_flags` | L3 | no | 2 | file_exists: feature flag config or framework references | Add feature flag framework |
| `recovery.migrations_reversible` | L3 | no | 2 | heuristic: migration files have corresponding down/rollback | Add reversible migrations |
| `recovery.rollback_documented` | L4 | no | 2 | content_quality: rollback procedure in docs | Document rollback procedure |
| `recovery.progressive_deploy` | L5 | no | 2 | heuristic: canary/blue-green deployment config | Configure progressive rollout |

### Pillar 8: Environment Independence

| check_id | min_level | required | weight | detect | remediation |
|-----------|-----------|----------|--------|--------|-------------|
| `env.setup_command_exists` | L1 | yes | 3 | command_discoverable: setup/install target | Add a setup command |
| `env.env_example_present` | L2 | yes | 2 | file_exists: .env.example or equivalent | Add .env.example |
| `env.container_config_present` | L2 | no | 2 | file_exists: docker-compose, devcontainer, or Dockerfile | Add container configuration |
| `env.tests_run_offline` | L3 | no | 3 | heuristic: test suite passes without external credentials | Make tests work offline |
| `env.single_command_setup` | L4 | no | 2 | content_quality: setup is one documented command | Simplify setup to one command |
| `env.zero_state_bootstrap` | L5 | no | 3 | heuristic: clone + setup + test succeeds with no manual steps | Achieve zero-state bootstrapping |

---

## Scoring Derivation

### Per-pillar score
Sum of (weight * pass_ratio) for all checks in the pillar. Max score = sum of all weights for the pillar.

### Per-pillar level
Highest level L where ALL checks with `required=true` and `min_level <= L` have status `pass`.

### Overall agent level
Minimum of per-pillar levels across all pillars that have required checks at that level.

### Context integration
If `lets-bootstrap-repo` artifacts exist:
- Verified service pack → context level L2
- Verified service + engineering → context level L3
- All packs verified + enriched → context level L4

Overall level = min(agent_level, context_level). If no context artifacts exist, context_level defaults to L1 (does not block below L2).

---

## Confidence Scoring (heuristics only)

| Confidence | Meaning |
|------------|---------|
| 0.9-1.0 | Strong evidence (multiple corroborating signals) |
| 0.7-0.89 | Good evidence (clear signal, minor ambiguity) |
| 0.5-0.69 | Moderate evidence (some signal, notable ambiguity) |
| < 0.5 | Weak evidence (flag as uncertain, exclude from scoring) |

Heuristic checks with confidence < 0.5 appear in advisory only, never in gating.
