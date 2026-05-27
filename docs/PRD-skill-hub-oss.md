# PRD — skill-hub as OSS Ground Truth

**Status:** proposal · **Owner:** letsbe10x · **Last updated:** 2026-05-27

This document is the single alignment artifact for the next ~3 months of
work on `letsbe10x/skill-hub`. It establishes ground-truth decisions on
architecture, distribution, brand, and the work backlog. It does not by
itself ship code — follow-up PRs implement each section.

---

## 1. TL;DR

We are turning `letsbe10x/skill-hub` into the canonical OSS home for the
letsbe10x agent-skills ecosystem. This PR captures the decisions to:

1. **Move adapters and sandboxes into `skill-hub`** as top-level dirs,
   making this repo the single source of truth for skills, adapters, and
   local stacks to test them against.
2. **Ship skills that work on day one with zero letsbe10x CLI installed**.
   The skill itself contains everything required to invoke the backend
   directly. No `lets` binary on the user's PATH.
3. **Introduce a top-level `adapters/` folder** where each backend
   (Splunk, Loki, Kibana, Prometheus, Jaeger, Grafana, etc.) lives as a
   self-contained directory. Skills reference these adapters via a small
   `backends.json` manifest, resolved at install time into a per-machine
   `skill.lock` file.
4. **Position `skill-hub` as the first OSS skill hub with first-class
   multi-backend support** for observability, ticketing, and the rest of
   the SDLC tool surface.

Net effect: one repo, one install command (`npx ... install`), one shared
adapter cache per machine, and a brand-defensible "bring your own stack"
story that nobody else in the field currently has.

---

## 2. Why move adapters and sandboxes into `skill-hub`

### 2.1 Today

| Repo | Visibility | Contents |
|---|---|---|
| `letsbe10x/skill-hub` | public | Skills only (workflow markdown) |
| `letsbe10x/adapters` | private (planned public) | CLIs/integration code (Splunk, Prometheus, Jaeger, Grafana), `capability_adapters`, `resource_adapters`, `browser_auth` |
| `letsbe10x/examples` | public | Sandbox Docker Compose stacks for local testing of observability tools |
| Internal repos | private | Core, governance, groundtruth (stay private) |

Skills, adapters, and sandboxes evolve together but live in three repos.
Coordinating a change that touches all three (e.g. shipping a new skill +
its adapter + its sandbox) requires three PRs in three places. Users
trying to find "the OSS thing" hit three different repos.

### 2.2 Tomorrow

```
letsbe10x/skill-hub (single public repo, ground truth)
├── adapters/                ← moved in from letsbe10x/adapters (public subset only)
├── sandboxes/               ← moved in from letsbe10x/examples
├── lets-*/                  ← existing and new skills
├── bin/skill-hub.js         ← installer
├── docs/                    ← PRDs, ADRs, contributor guides
└── pack.toml / package.json

letsbe10x/adapters (stays private)
└── (capability_adapters, resource_adapters, browser_auth — bound to private core)

letsbe10x/skill-lab (optional, private)
└── pre-`dev` experimentation that we don't want publicly visible yet
```

### 2.3 The reasons (in priority order)

1. **One install motion**. `npx github:letsbe10x/skill-hub install …`
   becomes the one command that fetches skills, adapters, and sandbox
   pointers. No PyPI, no second `pip install`, no cross-repo dance.
2. **Atomic changes**. A new skill that depends on a new adapter and a
   new sandbox lands in one PR with one review. Today that's three PRs
   plus a coordination Slack thread.
3. **No external network calls at install time**. Everything the
   installer needs is already in the cloned repo. Faster, simpler, more
   reliable in air-gapped or restricted-network environments.
4. **Single trust signal**. Users see one public repo. They can audit
   the entire stack (skills + adapters + sandboxes) in one place. This
   matters for enterprise/security-conscious adopters.
5. **Better discoverability**. Searching "skill hub splunk" should land
   on one repo, not split traffic between `skill-hub` and `adapters`.
6. **Lower contribution friction**. A community contributor adding a
   new backend writes one PR to one repo. Today they'd have to PR
   `adapters`, then PR `skill-hub`, then make sure they're consistent.

### 2.4 Why the move is safe

- Only the **public subset** of `letsbe10x/adapters` moves — the 4
  observability CLIs (Splunk, Prometheus, Jaeger, Grafana) plus shared
  HTTP utilities.
- `capability_adapters`, `resource_adapters`, and `browser_auth` stay in
  the private `adapters` repo because they implement private contracts
  from `letsbe10x/core` and aren't ready for public use.
- The 4 CLIs in `letsbe10x/adapters/clis/observability/*` get rewritten
  as stdlib-only "shims" during the move (see §4) — same logic, no
  third-party dependencies, vendor-able into the skill bundle.

---

## 3. Day-one constraint — skills work without any letsbe10x CLI

### 3.1 The constraint

On day one, a user who runs `npx … install` has **nothing from us
installed beyond the skill files we copy onto their disk**. There is no
`lets` binary, no `letsbe10x` Python package, no global CLI. The skill
must be self-sufficient against the user's existing tools (curl, python3,
the agent's own shell).

### 3.2 What that means architecturally

- Adapter shims must run **without third-party dependencies**. Stdlib
  Python only — `urllib.request`, `argparse`, `json`. No `httpx`, no
  `typer`, no `requests`. The user's system Python 3 runs them directly.
- The skill must locate the shim on disk **without a discovery service**.
  We achieve this via `skill.lock`, written by the installer at install
  time, holding absolute paths to each adapter on this machine.
- The skill must know the calling contract for the shim **without
  introspection**. Each adapter ships a `reference.md` that documents
  the exact command shape, response schema, and worked examples. The
  agent reads it before invoking.
- Credentials come from **env vars the user already manages** (e.g.
  `SPLUNK_URL`, `SPLUNK_TOKEN`). No keyring, no YAML config, no first-run
  wizard required.

### 3.3 The runtime flow

```
1. Agent reads SKILL.md from ~/.<agent>/skills/<skill>/
2. Agent reads skill.lock next to SKILL.md → absolute paths to adapters
3. Agent reads adapter's reference.md → calling contract
4. Agent executes the shim: <absolute-path>/lets-<backend> search --normalized "…" --json
5. Shim makes HTTPS call to the user's backend using env-var creds
6. Shim returns normalized JSON
7. Agent continues the workflow with parsed output
```

No CLI install. No daemon. No middleware. Just files on disk and HTTPS.

---

## 4. The `adapters/` folder and `skill.lock` mechanism

### 4.1 In-repo layout

```
skill-hub/
├── adapters/                              ← shared by all skills
│   ├── splunk/
│   │   ├── lets-splunk                    ← stdlib Python shim (~200 lines, +x)
│   │   ├── reference.md                   ← adapter guide for the LLM
│   │   ├── manifest.json                  ← {version, env_vars, supported_ops}
│   │   └── tests/test_shim.py
│   ├── loki/...
│   ├── kibana/...
│   ├── prometheus/...
│   ├── jaeger/...
│   └── grafana/...
└── lets-investigate-logs/
    ├── SKILL.md                           ← vendor-neutral workflow
    └── backends.json                      ← {splunk: "adapters/splunk", loki: "adapters/loki", …}
```

### 4.2 Per-adapter contract

Every adapter under `adapters/<backend>/` must contain:

| File | Purpose |
|---|---|
| `lets-<backend>` | Executable stdlib-only Python shim. Implements `search`, `health`, optionally `count` / `context`. Returns JSON to stdout, structured errors to stderr. |
| `reference.md` | Markdown the agent reads before invoking the shim. Documents env vars, command shape, DSL fields, response schema, worked examples, error envelope. |
| `manifest.json` | Machine-readable metadata: `version` (semver), `env_vars` (required + optional), `supported_ops` (subset of search/count/context/health). |
| `tests/test_shim.py` | Stdlib-only tests that exercise DSL → backend-syntax translation and response normalization. Run in CI. |

Hard rule enforced by CI: **the shim file must not import any
third-party package**. Lint check fails the build if it does.

### 4.3 The `backends.json` per skill

For a skill that supports multiple backends:

```json
{
  "splunk":     "adapters/splunk",
  "kibana":     "adapters/kibana",
  "loki":       "adapters/loki",
  "datadog":    "adapters/datadog",
  "elasticsearch": "adapters/elasticsearch"
}
```

Each key is a backend name (what the user types after `--backend`). Each
value is the relative path to the adapter folder in this repo. The
installer uses this map to know which adapter folders to copy when the
user requests specific backends.

### 4.4 What the installer does

```bash
npx github:letsbe10x/skill-hub install observability --backend splunk loki --agent cursor
```

1. **npx fetches the skill-hub repo** (one HTTP call to GitHub).
2. **For each skill in the requested bundle** (e.g. `observability`):
   - Copy `SKILL.md` to `~/.cursor/skills/<skill>/`.
   - Copy `backends.json` to `~/.cursor/skills/<skill>/`.
3. **For each `--backend` requested**:
   - Look up the adapter folder via `backends.json`.
   - If `~/.letsbe10x/adapters/<backend>/` does not exist, copy the
     adapter folder to it. (Dedup — if already installed for another
     skill or IDE, skip.)
   - `chmod 755` the shim file.
4. **Write `skill.lock`** to each installed skill's directory, holding
   absolute paths to the adapters on this machine.

### 4.5 The `skill.lock` file

Per installed skill. Written by the installer. Per-machine state.

```json
{
  "schema_version": 1,
  "installed_at": "2026-05-27T14:30:00Z",
  "skill_version": "0.1.0",
  "adapters": {
    "splunk": {
      "shim": "/Users/<user>/.letsbe10x/adapters/splunk/lets-splunk",
      "reference": "/Users/<user>/.letsbe10x/adapters/splunk/reference.md",
      "version": "0.1.0"
    },
    "loki": {
      "shim": "/Users/<user>/.letsbe10x/adapters/loki/lets-loki",
      "reference": "/Users/<user>/.letsbe10x/adapters/loki/reference.md",
      "version": "0.1.0"
    }
  }
}
```

Field semantics:

| Field | Holds | Set by |
|---|---|---|
| `schema_version` | Lock-file format version, for future migrations | installer |
| `installed_at` | ISO timestamp of install | installer |
| `skill_version` | Version of the skill at install time | installer (reads from SKILL.md frontmatter) |
| `adapters.<name>.shim` | Absolute path to shim binary on this machine | installer |
| `adapters.<name>.reference` | Absolute path to adapter guide markdown | installer |
| `adapters.<name>.version` | Version of the adapter at install time | installer (reads from `manifest.json`) |

The skill reads `skill.lock` at runtime to find each adapter. The SKILL.md
never contains an absolute path — those are machine-specific and live in
the lock file.

### 4.6 On-disk layout after install

```
~/.cursor/skills/                          ← Cursor's skills dir (IDE-owned)
└── lets-investigate-logs/
    ├── SKILL.md
    ├── backends.json
    └── skill.lock

~/.letsbe10x/                              ← shared across IDEs, IDE-agnostic
└── adapters/
    ├── splunk/
    │   ├── lets-splunk
    │   ├── reference.md
    │   └── manifest.json
    └── loki/
        ├── lets-loki
        ├── reference.md
        └── manifest.json
```

Multi-IDE deduplication: if the user later installs the same skill for
Claude Code (`--agent claude-code`), the SKILL.md copies to
`~/.claude/skills/lets-investigate-logs/` with its own `skill.lock`,
but the adapters at `~/.letsbe10x/adapters/` are reused. **Adapters are
installed once per machine, regardless of how many IDEs use them.**

---

## 5. Sandbox migration

### 5.1 Move

`letsbe10x/examples/sandboxes/observability/{logging,monitoring,tracing,dashboarding}/`
moves to `skill-hub/sandboxes/observability/…` at the same path depth.

### 5.2 Why

- Sandboxes exist **to validate skills + adapters against real-ish
  backends without needing a customer's prod**. They are tightly coupled
  to the skills and adapters they enable.
- Today they live in a separate `examples` repo. Pairing a skill change
  with its sandbox change requires two PRs.
- Once moved, a contributor adding a new backend can ship the adapter,
  the skill changes that use it, and a Docker Compose sandbox to test
  it against — all in one PR.

### 5.3 What changes for users

Today:
```bash
git clone letsbe10x/examples
cd examples/sandboxes/observability/logging/splunk
docker compose up
```

Tomorrow:
```bash
git clone letsbe10x/skill-hub  # or npx fetches it
cd skill-hub/sandboxes/observability/logging/splunk
docker compose up
```

Each sandbox README links to the skills that work against it.

---

## 6. The wedge — first OSS skill hub with multi-backend support

### 6.1 Evidence (from competitive research)

Surveyed the full Agent Skills landscape:

| Source | Skills | Multi-backend? |
|---|---|---|
| `anthropic/skills` | 10 official | All single-vendor (docx, pdf, etc.) |
| `mattpocock/skills` (108k★) | 21 | None — Pocock avoids infra |
| `garrytan/gstack` (104k★) | 23 | No backend abstraction |
| `gsd-build` (63.7k★) | 6 | GitHub-Actions-shaped, no abstraction |
| `datadog-labs/agent-skills` | 9 | Datadog-only |
| `honeycombio/agent-skill` | 8 | Honeycomb-only |
| `kodustech/awesome-agent-skills` + `VoltAgent` | ~1000 | Zero vendor-neutral observability |
| MCP servers (Splunk, Datadog, etc.) | many | Each is single-vendor |
| `mcp-grafana` (closest analog) | n/a | Spans Loki/Prom/ES — but only what Grafana proxies |

**Nobody in the field has shipped a vendor-neutral, multi-backend Agent
Skill.** This PR puts us in position to be the first.

### 6.2 The headline

README hero line:

> **The first skill hub with first-class support for multiple backends.**
>
> Bring your own stack. Splunk, Loki, Kibana, Datadog, Honeycomb,
> Grafana, Jaeger — one workflow, your tools, your credentials.

### 6.3 What this gives different audiences

**Agent users:**
- Pre-built workflows that work across Claude Code, Cursor, Codex, Copilot
- One install motion regardless of how many backends they have
- Real workflows (review-pr, investigate-logs, incident-rca), not toy demos

**Platform engineers / SREs:**
- Adapters run locally with the team's own credentials
- No data leaves their network
- BYO backend — write a 200-line shim for an internal tool, drop it under
  `adapters/<name>/`, ship in their own dotfiles

**OSS contributors:**
- Adding a backend = one folder under `adapters/` + one entry in a skill's
  `backends.json` + tests. Anyone can do it in a couple hours.
- Adding a skill = markdown only. No code, no build, no PyPI.
- Methodology-driven — backed by skill-forge's static rubric.

---

## 7. README updates

Per the recent UX audit (35% adoption probability after 15 min for a
skeptical Cursor user), the README needs work. Tasks split into must-fix
and should-fix.

### 7.1 Must-fix (highest leverage, ship Week 1)

1. **Add an "Invoking a Skill" section.** The single biggest gap from the
   audit. The current README lists install paths but never explains how
   the agent picks up the skill once installed. Add 6 lines explaining
   the per-agent invocation (`@`-mention in Cursor, slash command in
   Claude Code, etc.).
2. **Add `--force` flag to the installer.** `bin/skill-hub.js` L215 does
   `fs.rmSync(destination, …)` unconditionally before every copy. This
   silently nukes any local edits the user made. Make the default
   non-destructive; require `--force` to overwrite.
3. **Re-record the demo GIF to show a skill in action, not the
   installer.** The current GIF is the `npx install` flow. Ironic given
   the new `lets-create-readme-gifs` skill literally says "show the
   outcome, not the chrome." Use the new skill to re-record showing
   `lets-investigate-logs` running.
4. **Move "Why This Exists" above the install section.** The strongest
   paragraph in the doc is buried at line 29. Lead with pain, then sell
   the cure.
5. **Promote the `starter` bundle.** The 4-skill `starter` bundle exists
   in `bin/skill-hub.js` but is not mentioned in the README. The
   recommended bundle is currently `engineering` (12 skills). Switch the
   "start here" recommendation to `starter`; promote `engineering` once
   the user knows what they want.

### 7.2 Should-fix (Week 2)

6. **First-class multi-backend section.** Headline the multi-backend
   differentiator. Show: one skill, multiple backends, your stack.
7. **Add an architecture diagram.** Show: SKILL.md → backends.json →
   shim → reference.md → user's backend. One image worth 500 words.
8. **Comparison table vs Pocock, gstack, GSD, Datadog-skills,
   Honeycomb-skills.** On axes: lifecycle coverage, multi-backend,
   evidence-gating, OSS license, methodology rigor. We win on multiple.
9. **First testimonials / case study once early users land.** Reserve
   the slot; fill it as soon as the first credible engineer ships
   something with skill-hub.
10. **"Bring your own backend" section** with a worked example of
    writing a custom adapter shim in ~200 lines. The long-tail story.

---

## 8. Skill-hub management — going forward

### 8.1 Branch strategy

Single public repo with branch protection:

- `main` — stable. What `npx` defaults to. Every commit reviewed.
- `dev` — integration / WIP. Where in-flight work lives. Users opt in
  via `npx github:letsbe10x/skill-hub#dev install …`.
- `feature/*` — per skill or per adapter, merged into `dev`, then
  graduated to `main` after testing.

Optional `letsbe10x/skill-lab` (private) for exploratory work that
shouldn't be publicly visible. Graduates to `dev` via PR.

### 8.2 Quality bar

- Every adapter has unit tests (DSL → backend translation + response
  normalization) and a sandbox-based integration test.
- Every multi-backend skill has at least one worked example per
  backend in its `references/` or as a fixture.
- CI hard gate: shim files cannot import third-party packages.
- CI hard gate: `backends.json` entries must point at existing adapter
  directories with valid `manifest.json`.
- Skill-forge rubric (HG1, HG2, HG3, S1-S9) runs on every SKILL.md
  change. Scored skills must pass `forge check` to merge.

### 8.3 Versioning

- Each adapter has its own semver in `manifest.json`. Bumped when its
  shim, reference, or contract changes.
- `skill.lock` records adapter versions installed on the user's machine.
- Skill versions are tracked in SKILL.md frontmatter.
- No global "skill-hub version" — independent versioning per artifact.

### 8.4 Catalog growth

- **Mainline**: we ship the common backends (logs: Splunk / Loki /
  Kibana / Datadog / Honeycomb; metrics: Prometheus / Datadog;
  tracing: Jaeger / Tempo; dashboards: Grafana). Goal: 10–15 stable
  adapters by month 6.
- **Long-tail**: third parties ship their adapters as separate repos.
  Users install via `npx … install --backend acme --source github:acme/lets-acme`.
- **Internal / proprietary tools**: customers write a 200-line shim
  using the documented contract, drop it in their own dotfiles, never
  upstream it.

### 8.5 Contribution flow

| Contribution | Steps |
|---|---|
| New skill (no adapters) | One PR adding `<skill>/SKILL.md` + optionally `references/`. Review against skill-forge rubric. |
| New adapter | One PR adding `adapters/<backend>/{shim, reference.md, manifest.json, tests/}` to a feature branch. CI runs lint + tests. Merge to `dev` after review. |
| New multi-backend skill | One PR with SKILL.md + `backends.json` + worked examples. May depend on existing adapters or include new ones in the same PR. |
| Bug fix | Branch from `main`, fix, PR back to `main` with regression test. |

---

## 9. Tasks backlog

This PRD is the planning artifact. The actual work splits into the PRs
below. Total estimated effort: ~95 focused hours.

### 9.1 Adapter migration (~24h)

- [ ] Rewrite `lets-splunk` as stdlib-only shim, copy into
  `skill-hub/adapters/splunk/`, add `reference.md` + `manifest.json` + tests (~4h)
- [ ] Same for `lets-prometheus` → `adapters/prometheus/` (~4h)
- [ ] Same for `lets-jaeger` → `adapters/jaeger/` (~4h)
- [ ] Same for `lets-grafana` → `adapters/grafana/` (~4h)
- [ ] CI: shim lint rule (no third-party imports) (~2h)
- [ ] CI: backends.json schema validation (~2h)
- [ ] CI: cross-adapter response shape consistency (~4h)

### 9.2 New adapters (~24h)

- [ ] `adapters/kibana/` (~6h)
- [ ] `adapters/loki/` (~6h)
- [ ] `adapters/datadog/` (~6h)
- [ ] `adapters/elasticsearch/` (~6h)

### 9.3 Skills (~14h)

- [ ] `lets-investigate-logs` skill (~4h)
- [ ] `lets-investigate-metrics` skill (~3h)
- [ ] `lets-trace-request` skill (~3h)
- [ ] `lets-investigate-incident` cross-cutting skill (~4h)

### 9.4 Sandbox migration (~5h)

- [ ] Move `examples/sandboxes/observability/*` into `skill-hub/sandboxes/` (~2h)
- [ ] Verify each sandbox still spins up cleanly (~1h)
- [ ] Update sandbox READMEs to link to relevant skills (~2h)

### 9.5 Installer changes (~10h)

- [ ] Add `--backend <name> [<name>…]` flag handling (~2h)
- [ ] Add `--force` flag (default non-destructive) (~1h)
- [ ] Interactive backend picker when `--backend` not passed (~3h)
- [ ] Write `skill.lock` per install (~2h)
- [ ] Adapter dedup via `~/.letsbe10x/adapters/` (~2h)

### 9.6 README polish (~14h)

- [ ] Add "Invoking a Skill" section (~1h)
- [ ] Re-record demo GIF using `lets-create-readme-gifs` (~2h)
- [ ] Move "Why This Exists" above install (~30 min)
- [ ] Promote `starter` bundle (~30 min)
- [ ] Multi-backend headline section (~2h)
- [ ] Architecture diagram (~2h)
- [ ] Comparison table vs competitors (~2h)
- [ ] BYO backend worked example (~4h)

### 9.7 Documentation (~4h)

- [ ] `docs/contributor-guide-adapters.md` — how to add a new adapter (~2h)
- [ ] `docs/contributor-guide-skills.md` — how to add a new skill (~2h)

---

## 10. Open decisions

These are explicitly not locked by this PRD. Decide before the relevant
sprint:

1. **Branch strategy**. Single `skill-hub` with branches (recommended),
   or two-repo private→public with promotion?
2. **License for adapters**. MIT throughout (simplest), or Apache 2.0
   on adapters to preserve future enterprise carve-out flexibility?
3. **CLA**. Adopt a lightweight CLA for adapter contributions (since
   they're closest to the monetization spine), or DCO everywhere?
4. **Launch target**. What's the "wow" demo on launch day? Best
   candidate: cross-stack incident RCA — `lets-investigate-incident`
   pulling logs from Splunk + metrics from Prometheus + traces from
   Jaeger, correlating by trace_id, returning a coherent narrative.
5. **First credibility play**. Public benchmark vs Pocock/gstack on
   PR-review accuracy or RCA quality? Cold pitch to one named platform
   engineer for a testimonial? Both?
6. **Rename `skill-forge`?** Competitive research surfaced two existing
   public `skill-forge` repos. Considered separately — not blocking
   this PRD.

---

## 11. What this PR adds

This PR adds **this document only**, at `docs/PRD-skill-hub-oss.md`. No
code changes, no file moves, no installer changes.

The PRD is the alignment artifact. Each follow-up PR (per §9) implements
one section.

The order of follow-up PRs matters:

1. **PR-1**: Move first adapter (Splunk) into `skill-hub/adapters/splunk/`
   as stdlib shim + reference + manifest + tests. Proves the contract.
2. **PR-2**: Write `lets-investigate-logs` skill using the Splunk
   adapter. End-to-end smoke against sandbox.
3. **PR-3**: Installer changes — `--backend` flag, `skill.lock`
   generation, adapter dedup. Wire the model.
4. **PR-4**: Move the other 3 adapters (Prometheus, Jaeger, Grafana)
   following the same pattern.
5. **PR-5**: Sandbox migration from `letsbe10x/examples`.
6. **PR-6**: README polish (must-fix items).
7. **PR-7**: New adapters (Loki, Kibana, Datadog, Elasticsearch).
8. **PR-8**: Cross-cutting skills (`lets-investigate-incident` etc.).
9. **PR-9**: Contributor docs + comparison table.

Each PR is independently reviewable and shippable. Cumulative effect
matches this PRD.

---

## 12. Why this matters

We are building inside a category that is two months old. The leaders
(Pocock 108k★, Tan 104k★, GSD 63.7k★) won the first-mover dividends on
personality and breadth. The technical winner has not been decided.

If we ship the architecture in this PRD — vendor-neutral skills, shared
adapter cache, BYO-backend contract, zero-install runtime — we become
the first OSS skill hub that is honestly *infrastructure-grade* rather
than a personality-driven collection.

That is a defensible position. Methodology-rigor over personality-reach.
The wedge is real. The work is concrete.

Lock the PRD, then ship the PRs.
