# Browser evidence (delegated)

UI workflows no longer define browser setup here. Use the shared skill:

- **Skill:** [`lets-browser-evidence`](../../lets-browser-evidence/SKILL.md)
- **UI prompts:** [`lets-browser-evidence/references/domain-prompts.md`](../../lets-browser-evidence/references/domain-prompts.md) (UI audit, journey smoke, regression sections)
- **Brief fields:** align `evidence.browser_automation` in [`ui_ux_brief.yml`](ui_ux_brief.yml) with [`browser_evidence_brief.yml`](../../lets-browser-evidence/references/browser_evidence_brief.yml)

Install (includes Webwright engine): `make lets-browser-evidence` or `make lets-build-ui`.
