# skill-hub README demo — VHS tape
# ---------------------------------------------------------------------------
# Renders assets/demo.gif used at the top of README.md.
#
# Regenerate:
#   brew install vhs ttyd ffmpeg
#   vhs assets/demo.tape
#
# Design notes:
#   - 1000x420 source, displayed at width="900" in the README.
#   - bash shell so '#' lines are real shell comments (no errors).
#   - Menlo font — universally present on macOS; falls back to system mono
#     elsewhere (Cascadia / DejaVu) without obvious artifacts.
#   - Hidden setup defines an `npx` shell function that prints the same
#     output format as bin/skill-hub.js, but rooted at /Users/lets so the
#     demo never leaks the operator's actual home directory. Output format
#     matches the real installer line-for-line ("installed X -> PATH").
#     If you change the real installer's print format, update the function.
# ---------------------------------------------------------------------------

Output assets/demo.gif

Set Shell "bash"
Set Theme "Dracula"
Set FontFamily "Menlo"
Set FontSize 18
Set Width 1000
Set Height 420
Set Padding 20
Set TypingSpeed 50ms
Set PlaybackSpeed 1.0
Set LoopOffset 5%

# ── Hidden setup: shim `npx` so the recorded output is path-stable ───────
# Multi-line function definition — VHS treats `;` outside strings as a tape
# directive separator, so we use newlines + PS2 continuation instead.
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

# ── Visible demo ─────────────────────────────────────────────────────────
# Tagline (bash comment — does not execute)
Type "# Evidence-gated workflow skills for Claude Code, Cursor, Codex, Copilot"
Sleep 700ms
Enter
Sleep 300ms

# The install command — the one thing a reader must remember
Type "npx -y github:letsbe10x/skill-hub install engineering --agent cursor"
Sleep 400ms
Enter

# Shim prints the install output instantly
Sleep 1800ms

# Final caption — value-prop close
Type "# Now say 'review my PR' or 'I want to add a feature' in Cursor."
Sleep 2200ms

# Breathing room before loop
Sleep 600ms
