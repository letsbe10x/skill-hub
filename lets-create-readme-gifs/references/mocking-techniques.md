# Mocking Techniques

The recording captures whatever the terminal renders. If your real workflow
leaks operator state, drifts over time, or exposes secrets, the recording
inherits those problems forever. Three patterns cover ~95% of cases.

## Pattern 1 — Hide/Show shell-function shim

The most powerful technique. Define a function in a `Hide`d block so it never
appears in the recording, then call it in the visible part of the demo. The
function prints whatever you want — including paths rooted at fake home
directories, fake counts, fake hostnames.

### When to use

- The real command leaks the operator's home directory (e.g. `npx install`
  printing `/Users/anugeet/.cursor/skills/X`)
- The real command takes too long or has network dependencies that make the
  recording flaky
- You want path-stable output across machines and CI

### Example (from `skill-hub`'s own demo.tape)

```
# ── Hidden setup: shim `npx` so the recorded output is path-stable ───────
Hide
Type 'npx() {'
Enter
Type '  for s in lets-start-here lets-bootstrap-agents-md lets-bootstrap-repo lets-develop-feature lets-review-code lets-review-pr lets-verify-change lets-verify-ready lets-spec-to-pr lets-create-plan lets-brainstorm lets-onboard-repo'
Enter
Type '  do echo "installed $s -> /Users/lets/.cursor/skills/$s"'
Enter
Type '  done'
Enter
Type '}'
Enter
Sleep 200ms
Type 'clear'
Enter
Sleep 200ms
Show

# ── Visible demo (npx now calls the shim) ──────────────────────────────
Type 'npx -y github:letsbe10x/skill-hub install engineering --agent cursor'
Enter
Sleep 1800ms
```

The viewer sees `npx ...` typed, then real-looking install output rooted at
`/Users/lets/`. The shim is invisible.

### Gotchas

- VHS treats `;` outside strings as a tape-directive separator. Use
  newlines + PS2 continuation, not single-line `for ... ; do ... ; done`.
- Use **single-quoted** `Type` strings. Inner double quotes don't need
  escaping, and `$` variables pass through to the spawned shell verbatim.
- See [`vhs-gotchas.md`](vhs-gotchas.md) for the full failure-mode list.

## Pattern 2 — Mocked environment variables

Use VHS's `Env` directive to set env vars for the spawned shell.

### When to use

- The recorded command reads from `HOME`, `USER`, `HOSTNAME`, or similar
- You want to redirect file writes to a temp location
- A tool prints `$USER@$HOSTNAME` in a prompt and you want both to be neutral

### Example

```
Env HOME /Users/demo
Env USER demo
Env HOSTNAME workstation
```

### Gotchas

- Setting `HOME=/Users/demo` will make the real command try to write to
  `/Users/demo/.cursor/skills/`, which doesn't exist on the rendering
  machine and may fail with permission errors (on macOS, `/Users/X` needs
  root to create). Combine with **Pattern 1** (a shim that doesn't
  actually write) when this matters.
- Some tools read env vars *at first invocation* and cache them. Restart
  the shell or use a fresh subprocess.

## Pattern 3 — Redacted-by-default output

Some tools accept a `--redact` or `--no-color` or `--quiet` flag that
strips sensitive info. Use these when they exist instead of writing a shim.

### When to use

- The real command already supports verbosity control
- The redaction is structural (token field, URL params) rather than
  per-operator (home dir)

### Example

```
# Real CLI: pretty-printed JSON includes a `token` field
Type 'mytool list --format json'

# Better: use the tool's own redaction
Type 'mytool list --format json --redact-secrets'
```

### Anti-pattern

Don't pipe through `sed` to redact — it pollutes the displayed command and
makes the demo look like the user has to do work to make output safe. Either
shim, or use the tool's built-in flag, or change the demo.

## What to mock — comprehensive checklist

Walk the planned recording line by line. For each visible line, ask:

| Category | Examples | Mock how |
|---|---|---|
| Home directory | `/Users/anugeet/`, `/home/dave/` | Hide/Show shim with fake path |
| Hostname | `dave-mbp.local`, `prod-db-3.internal.corp` | `Env HOSTNAME` + shim if needed |
| Username | `anugeet@`, `$ USER=alice` in prompt | `Env USER`, restart shell |
| Real org names | `acme-corp/`, `internal-tools/` | Shim or text substitution |
| Tokens / keys | `Bearer abc123...`, `sk-...` | Tool's `--redact` or shim |
| Internal URLs | `https://prod.internal.corp` | Shim, or use a public demo URL |
| Drift-prone counts | "21 skills", "v3.4.7", "47 endpoints" | Drop entirely from typed lines |
| Drift-prone dates | "as of Nov 2024" | Drop or use "today" |
| File counts in `ls` output | "1,247 files" | Shim `ls` if it must appear |

## When mocking is the wrong answer

Sometimes the right answer is **don't put it in the demo**. If a value
fundamentally has to be present and is hard to mock cleanly (e.g. a real
output that includes generated UUIDs at multiple positions), consider:

- Cropping the demo to skip that section
- Using a different demo flow
- Switching to a static screenshot of a carefully-chosen frame

Don't fight the recording.
