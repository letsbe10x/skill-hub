# Browser evidence — security

- **Local/staging by default.** Production URLs require explicit user approval in the brief.
- **No credentials in artifacts** — scripts, logs, screenshots, and commits must not contain passwords, tokens, or API keys; use test accounts and environment variables.
- **Read-only discovery** unless `browser_evidence_brief.yml` lists approved mutations.
- **No** real purchases, email sends, or production data entry during walkthroughs.
- **Fail closed:** missing VPN, auth, or test credentials → stop and request access; do not bypass gates.
- **Redact** accidental PII from captures; restart from a clean workspace if sensitive data appeared.
