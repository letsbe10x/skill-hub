# Webwright workspace contract (letsbe10x)

Applies when using [Microsoft Webwright](https://github.com/microsoft/Webwright) in **workspace mode** (agent follows the upstream skill contract) or when reviewing plugin output.

## Layout

- Pick `WORKSPACE_DIR` (under the repo `outputs/` tree or another user-approved run directory) and keep all artifacts inside it.
- Required deliverable: `final_script.py` (one-shot or crafted CLI).
- Each clean run: `final_runs/run_N/` where N is the next integer.
- Per run folder:
  - `final_script.py` (copy or entry for that run)
  - `screenshots/final_execution_STEP_ACTION.png`
  - `final_script_log.txt` — one line per constraint-relevant step; success datum at end
- Root of workspace: `plan.md` with critical points (CP1, CP2, …) checked off when verified.

## Playwright defaults

- Viewport: width 1280, height 1800 unless the brief lists other widths (UI audits use 375, 768, 1024, 1440).
- Do not use `page.screenshot(full_page=True)` (upstream Webwright guidance).
- Local browsers: fresh session per script run; no persistent browser-as-state.
- Plugin mode on Claude Code often uses Firefox for final runs; match the generated script.

## Record in brief

Copy paths into [`browser_evidence_brief.yml`](browser_evidence_brief.yml) when the run completes.
