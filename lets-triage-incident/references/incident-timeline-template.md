# Incident Timeline Template

Output template for the `lets-triage-incident` skill step 5.

---

## Incident Timeline

**Incident ID**: INC-<timestamp>
**Reported by**: <on-call engineer or alert name>
**Triage started**: <ISO-8601>

---

### T-0: Detection

| Field | Value |
|-------|-------|
| Timestamp | <ISO-8601> |
| Symptom | <one-sentence description> |
| Source | alert / user report / monitoring |
| Severity | P0 / P1 / P2 |

---

### Contributing Changes

List changes in the incident window (T-0 minus 2 hours to T-0):

| Timestamp | Type | Description | Author |
|-----------|------|-------------|--------|
| <ISO-8601> | commit / deploy / config | <description> | <author> |

---

### Root Cause Hypothesis

**Hypothesis**: <one sentence>
**Confidence**: high / medium / low
**Supporting evidence**:
- <evidence item 1>
- <evidence item 2>

---

### Recommended Mitigation

**Immediate action**: <what to do right now to stop the bleeding>
**Owner**: <who should execute this>
**Estimated time to mitigate**: <e.g. 5 minutes, 30 minutes>

**Long-term fix**: <link to follow-up ticket or description of root fix>
