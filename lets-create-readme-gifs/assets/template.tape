# <project-name> README demo — VHS tape
# ---------------------------------------------------------------------------
# Renders assets/demo.gif used at the top of README.md.
#
# Regenerate:
#   brew install vhs ttyd ffmpeg
#   vhs assets/demo.tape
#
# Adapt to your project:
#   1. Replace the hidden shim with your project's mocked command output.
#   2. Replace the visible Type lines with your project's killer-demo flow.
#   3. Tune Sleep durations after the first render (see frame extraction
#      in scripts/verify-demo.sh).
#   4. Run scripts/verify-demo.sh to confirm size/duration/dimension budgets.
#
# Why each `Set` value:
#   - Shell bash: '#' is a real comment, no zsh "command not found" errors.
#   - Theme Dracula: readable on GitHub light AND dark themes.
#   - FontFamily Menlo: universal on macOS, sensible fallback elsewhere.
#     DO NOT use JetBrains Mono unless you've verified it's installed on
#     every render host — falls back silently to a wrong font otherwise.
#   - Width 1000 / Height 420: see references/sizing-placement.md
#   - TypingSpeed 50ms: feels natural; <40ms looks robotic.
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

# ── Hidden setup: shim the command so output is path-stable ──────────────
# Multi-line function definition — VHS treats `;` outside strings as a tape
# directive separator, so we use newlines + PS2 continuation. Single-quoted
# Type strings avoid double-quote escaping; $ vars defer to the spawned bash.
Hide
Type '<your-command>() {'
Enter
Type '  echo "your mocked output line 1"'
Enter
Type '  echo "your mocked output line 2"'
Enter
Type '}'
Enter
Sleep 200ms
Type 'clear'
Enter
Sleep 200ms
Show

# ── Visible demo ─────────────────────────────────────────────────────────
# Opening tagline (bash comment — does not execute)
Type "# <One-line tagline that telegraphs what the project does>"
Sleep 700ms
Enter
Sleep 300ms

# The killer demo: ONE command, ONE outcome. Not a feature tour.
Type "<your-command> <args>"
Sleep 400ms
Enter

# Sleep covers shim output. Tune after first render.
Sleep 1800ms

# Final caption — value-prop close. Tells the reader what to do next.
Type "# Now <next action a reader should take after seeing this>"
Sleep 2200ms

# Breathing room before loop
Sleep 600ms
