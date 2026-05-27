# Protocol — Producing a README Demo GIF

The full 8-step methodology. Read end-to-end before invoking. Skipping a step
requires a one-line note in the PR explaining why.

## Operating Contract

The demo's job is to make a reader say "I want this" in under five seconds.
Everything below is in service of that.

### Step 1 — Confirm the format

Pick exactly one. See [`format-decision.md`](format-decision.md) for the
decision tree. Quick version:

| Format | When |
|---|---|
| **VHS GIF** | Default for terminal-based projects. Deterministic, scriptable, ~150–500KB for 10–15s loops. |
| **Animated SVG** | Terminal demos where text crispness matters more than file size. ~5–10× smaller than equivalent GIF, sharper at any zoom. |
| **Hosted MP4** | Product-UI demos that need motion + audio + >20s runtime. Host on the project's CDN; embed via `<video>` or YouTube/Vimeo. |
| **Static screenshot (PNG)** | Backend libraries with no terminal-visible action, or projects where animation distracts. Use sparingly — animation wins above the fold. |

### Step 2 — Identify the killer demo

One concrete user flow. Not a feature tour.

The format: *one* command the user types, *one* outcome they care about,
chained automatically if there are intermediate steps. Examples that work:

- **lazygit**: stage → commit → push, three keystrokes
- **mods**: shell-pipe output into an LLM
- **tRPC**: define a server type, watch the client autocomplete change
- **skill-hub**: `npx install engineering --agent cursor`, 12 skills land

The wrong demo: a 30-second tour of "look at all our commands." The viewer
retains nothing.

### Step 3 — Audit for leaks

Walk through what the recording will contain. Mock anything that:

1. **Embeds operator state**: `/Users/<name>/`, hostname, env vars, kerberos
   principal, git-config user, IP address.
2. **Drifts over time**: hardcoded counts ("21 skills"), version numbers,
   timestamps, dates, build IDs.
3. **Exposes secrets**: tokens, API keys, internal URLs, customer names,
   bearer credentials, hostnames of internal services.

For each, plan a mock per [`mocking-techniques.md`](mocking-techniques.md):
Hide/Show shims, fake env vars, redacted strings, computed-not-hardcoded text.

### Step 4 — Write the source script

Use [`../assets/template.tape`](../assets/template.tape) as the starting
point. Adjust:

- **Output path**: `<repo>/assets/demo.gif` (or `.svg`, `.mp4`)
- **Shell**: bash (so `#` lines are real comments, not zsh errors)
- **Theme**: Dracula is safe for both light and dark GitHub themes
- **Font**: Menlo — universal on macOS, sensible fallback elsewhere. Do not
  use JetBrains Mono unless you've verified it's installed on every render
  host.
- **Dimensions**: 1000×420 for terminal demos. See
  [`sizing-placement.md`](sizing-placement.md).
- **Typing speed**: 50–60ms per character feels natural. <40ms looks robotic.

### Step 5 — Render

```bash
vhs assets/demo.tape
```

If render fails with `Invalid command:` errors, the issue is almost always
in [`vhs-gotchas.md`](vhs-gotchas.md). The three usual culprits:

1. Semicolons inside `Type "..."` strings — VHS parses `;` as a tape
   directive separator. Use multi-line bash function definitions instead.
2. Escaped double quotes (`\"`) inside `Type "..."` — switch the outer to
   single quotes and the inner double quotes need no escape.
3. Multi-line bash inside `Hide` block — bash shows PS2 (`>`) continuation
   prompts. They're not in the recording (Hide block), but VHS still needs
   each line `Enter`-terminated cleanly.

### Step 6 — Verify

Run the verification script:

```bash
bash scripts/verify-demo.sh assets/demo.gif
```

It asserts:
- Duration ≤ 20s (longer = belongs on YouTube)
- Size ≤ 1MB (in-repo) or ≤ 5MB (CDN-hosted)
- Dimensions match expected (e.g. 1000×420)

Then frame-extract for visual review:

```bash
mkdir -p /tmp/demo-frames
ffmpeg -y -i assets/demo.gif -vf "fps=1" /tmp/demo-frames/frame_%02d.png
```

Open three frames: one near the start, one in the middle, one near the end.
Confirm:
- No leaked paths/counts/secrets visible
- The killer-demo command and outcome both appear
- Text is sharp (not fuzzy or pixelated)

### Step 7 — Wire into README

Insert the block from
[`../assets/header-template.md`](../assets/header-template.md) at the top of
the target repo's `README.md`, *before* any existing content. The block has
five elements in fixed order:

1. `<h1 align="center">project-name</h1>`
2. `<p align="center"><em>One-line tagline.</em></p>`
3. `<p align="center"><img src="assets/demo.gif" width="900" alt="..."></p>`
4. 4 badges (license, stars, PRs welcome, "works with X")
5. Nav row pointing at existing README sections

Verify nav anchors resolve to real headings. If a heading doesn't exist,
either add it or drop the nav entry.

### Step 8 — Document regeneration

The first ~15 lines of `assets/demo.tape` are comments explaining how to
regenerate. The next person updating the demo (or you, six months later)
should not have to reverse-engineer:

- Which tool produced this (`vhs`)
- How to install it (`brew install vhs ttyd ffmpeg`)
- How to re-render (`vhs assets/demo.tape`)
- Why anything in the tape is mocked vs real
- What budgets the rendered output is held to

If the demo is fragile (cold-cache npm fetch, network-dependent), say so.

## Non-Negotiables

1. **Source script always ships with the artifact.** No GIF without a tape.
2. **No operator-specific state in the recording.** Mock or redact.
3. **No hardcoded drift-prone counts.** No "N skills", "M endpoints" baked into typed lines.
4. **One flow.** Not a feature tour.
5. **Width 600–900px.** Not full-bleed.
6. **Duration ≤ 20s** for the in-README artifact.
7. **CDN-host anything >2MB** — don't bloat `git clone`.
8. **Verification script lives in the repo.** `scripts/verify-demo.sh` is checked in alongside the artifact.
