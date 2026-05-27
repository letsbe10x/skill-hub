# VHS Gotchas

Failure modes encountered while producing real `.tape` files. Each entry has
the symptom, the cause, and the fix.

## 1. Semicolons inside `Type "..."` strings

**Symptom:**
```
parser: 10 error(s)
Invalid command: ; done; }
```

**Cause:** VHS's tape parser treats `;` as a directive separator at the top
level. Even though your `;` is inside a quoted string, the parser fails
before the lexer fully resolves quoting.

**Fix:** Replace single-line shell with multi-line. Bash will show PS2 (`>`)
continuation prompts; they're inside a `Hide` block, so the user never sees
them.

```vhs
# WRONG — fails
Type "npx() { for s in lets-X lets-Y; do echo $s; done; }"

# RIGHT
Type 'npx() {'
Enter
Type '  for s in lets-X lets-Y'
Enter
Type '  do echo $s'
Enter
Type '  done'
Enter
Type '}'
Enter
```

## 2. Escaped double quotes (`\"`) inside `Type "..."` strings

**Symptom:**
```
Invalid command:
```

**Cause:** Backslash-escaped quotes inside a double-quoted `Type` string
confuse VHS's lexer. The parser interprets the first `\"` as ending the
string and treats the rest as garbage tokens.

**Fix:** Use **single quotes** for the outer `Type` string. Inner double
quotes pass through unescaped.

```vhs
# WRONG
Type "echo \"installed $s -> $path\""

# RIGHT
Type 'echo "installed $s -> $path"'
```

## 3. `$` interpolation in `Type` strings

**Symptom:** Variables like `$s` print as empty when the recorded command
runs.

**Cause:** Some VHS versions/shells will interpolate `$VAR` *before* sending
to the spawned shell, expanding to whatever the env var is at tape-execution
time.

**Fix:** Single-quote the `Type` string — single quotes prevent the tape
parser from expanding `$VAR`. The spawned bash then sees `$s` literally and
expands it correctly inside the function body.

```vhs
# Use single quotes to defer $ expansion to the spawned shell
Type '  do echo "installed $s -> /Users/lets/.cursor/skills/$s"'
```

## 4. `Set FontFamily "JetBrains Mono"` falling back silently

**Symptom:** The rendered GIF has weirdly-spaced letters or looks like a
proportional font.

**Cause:** VHS can only render with fonts that are *installed on the render
host*. JetBrains Mono is not a system default on macOS. When the font isn't
found, VHS falls back to a generic monospace without warning.

**Fix:** Use **Menlo** on macOS (it's a system font, always present). On
Linux render hosts, use **DejaVu Sans Mono** or **Cascadia Code**.

```vhs
Set FontFamily "Menlo"
```

If you must use JetBrains Mono, bundle the font file with the render setup
or document the install step in the tape's header comments.

## 5. Default shell is sh, not bash — `#` comments fail in zsh

**Symptom:** Lines starting with `#` show `zsh: command not found: #...` in
the recording.

**Cause:** Some shells (notably zsh without `interactive_comments` enabled)
do not treat `#` as a comment in interactive mode.

**Fix:** Explicitly set `Set Shell "bash"` at the top of the tape. Bash
interactive mode honors `#` comments by default.

```vhs
Set Shell "bash"
```

## 6. Cold npm/pip/cargo fetch takes longer than your Sleep

**Symptom:** GIF shows command typed + Enter + blank cursor for 5 seconds,
then output finally streams in (looks broken).

**Cause:** First-run package fetches over the network have latency that
varies by machine and connection. Your hardcoded `Sleep 4500ms` works on a
warm cache but fails on a cold one.

**Fix:** Two options:

1. **Pre-warm the cache** in a `Hide` block before the demo:
   ```vhs
   Hide
   Type 'npx -y github:letsbe10x/skill-hub --version > /dev/null 2>&1'
   Enter
   Sleep 4000ms
   Show
   ```
2. **Shim the command** so it doesn't actually fetch. See
   [`mocking-techniques.md`](mocking-techniques.md) Pattern 1.

The shim approach is more deterministic and works in CI.

## 7. Terminal width too narrow → long lines wrap

**Symptom:** Output that should fit on one line wraps in the middle, looking
visually broken.

**Cause:** `Set Width 800` gives ~78 columns at FontSize 16. Long install
paths (`/Users/lets/.cursor/skills/lets-bootstrap-agents-md`) overflow.

**Fix:** Use `Set Width 1000` for terminal demos that show long paths. See
[`sizing-placement.md`](sizing-placement.md).

## 8. `Output` path is relative to wd, not the tape file

**Symptom:** GIF lands somewhere unexpected when you run `vhs` from a
different directory than the tape file.

**Cause:** `Output assets/demo.gif` is resolved relative to the current
working directory, not the location of the tape.

**Fix:** Run VHS from the repo root: `vhs assets/demo.tape`. Or use an
absolute path in the tape (not recommended for portability).

## 9. Recording starts mid-typing because of `LoopOffset`

**Symptom:** The first frame of the GIF shows the demo already in progress
(e.g., the first 5 characters of the tagline already typed).

**Cause:** `LoopOffset 5%` (or similar) skips the first N% of the recording
to make the loop seam less obvious — but if your demo has a long tail and a
short head, the offset lands mid-action.

**Fix:** Either drop `LoopOffset` entirely (loop seam is barely noticeable
for terminal demos) or add explicit `Sleep` at the very start before any
`Type`:

```vhs
# Give 500ms of clean prompt at the start so LoopOffset doesn't eat it
Sleep 500ms

Type 'first visible command'
```

## 10. `Clear` doesn't always clear what you expect

**Symptom:** After a `Hide` setup block, the prompt is at the bottom of the
screen even after `Type 'clear'`.

**Cause:** The shell's `clear` command writes terminal control codes that
move the cursor to top-left, but VHS's recording surface keeps the
"scrollback" visible until enough new lines push it off-screen.

**Fix:** Use `Ctrl+L` (the VHS-native keystroke) instead of typing `clear`:

```vhs
Ctrl+L
```

Or write enough blank lines to fill the screen:

```vhs
Type 'clear && tput cup 0 0'
Enter
```

## 11. Final frame is the typing-in-progress, not the completed state

**Symptom:** Last frame of the GIF shows the user mid-typing the final
caption.

**Cause:** No `Sleep` after the last `Type 'something'` — VHS ends the
recording as soon as the typing completes, so the final visible state is the
end of that typing animation.

**Fix:** Add a trailing `Sleep` to let the final state breathe:

```vhs
Type "# Now you're ready."
Sleep 2000ms   # ← let the viewer read this
```
