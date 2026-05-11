#!/usr/bin/env bash
# verify_findings.sh — Verify that findings cite real code at real locations
# Usage: ./verify_findings.sh <findings_json_file>
# Checks each finding's file:line against the actual repo and reports invalid references

set -euo pipefail

FINDINGS_FILE="${1:?Usage: verify_findings.sh <findings_json_file>}"

if [ ! -f "$FINDINGS_FILE" ]; then
  echo "ERROR: Findings file not found: $FINDINGS_FILE" >&2
  exit 1
fi

echo "=== Finding Verification Report ==="
echo ""

TOTAL=0
VALID=0
INVALID=0
ERRORS=""

# Parse findings and verify each location
while IFS= read -r finding; do
  TOTAL=$((TOTAL + 1))

  FINDING_ID=$(echo "$finding" | python3 -c "import sys,json; print(json.load(sys.stdin).get('finding_id','?'))")
  FILE=$(echo "$finding" | python3 -c "import sys,json; loc=json.load(sys.stdin).get('location',{}); print(loc.get('file',''))")
  LINE=$(echo "$finding" | python3 -c "import sys,json; loc=json.load(sys.stdin).get('location',{}); print(loc.get('line',0))")
  SEVERITY=$(echo "$finding" | python3 -c "import sys,json; print(json.load(sys.stdin).get('severity','?'))")

  if [ -z "$FILE" ] || [ "$FILE" = "None" ]; then
    INVALID=$((INVALID + 1))
    ERRORS="${ERRORS}\n  INVALID: $FINDING_ID — no file specified"
    continue
  fi

  if [ ! -f "$FILE" ]; then
    INVALID=$((INVALID + 1))
    ERRORS="${ERRORS}\n  INVALID: $FINDING_ID ($SEVERITY) — file not found: $FILE"
    continue
  fi

  FILE_LINES=$(wc -l < "$FILE" | tr -d ' ')
  if [ "$LINE" -gt "$FILE_LINES" ] 2>/dev/null; then
    INVALID=$((INVALID + 1))
    ERRORS="${ERRORS}\n  INVALID: $FINDING_ID ($SEVERITY) — line $LINE exceeds file length ($FILE_LINES lines): $FILE"
    continue
  fi

  VALID=$((VALID + 1))

done < <(python3 -c "
import json, sys
with open('$FINDINGS_FILE') as f:
    data = json.load(f)
findings = data if isinstance(data, list) else data.get('findings', [])
for f in findings:
    print(json.dumps(f))
" 2>/dev/null || echo "")

echo "Total findings: $TOTAL"
echo "Valid references: $VALID"
echo "Invalid references: $INVALID"

if [ -n "$ERRORS" ]; then
  echo ""
  echo "Issues found:"
  echo -e "$ERRORS"
  echo ""
  echo "RESULT: FAIL — $INVALID finding(s) have invalid code references"
  exit 1
else
  echo ""
  echo "RESULT: PASS — all findings reference valid code locations"
  exit 0
fi
