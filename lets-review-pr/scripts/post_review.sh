#!/usr/bin/env bash
# post_review.sh — Post a review to GitHub with proper verdict
# Usage: ./post_review.sh <PR_ID> <verdict> <body_file>
# verdict: APPROVE | REQUEST_CHANGES | COMMENT

set -euo pipefail

PR_ID="${1:?Usage: post_review.sh <PR_ID> <verdict> <body_file>}"
VERDICT="${2:?Usage: post_review.sh <PR_ID> <verdict> <body_file>}"
BODY_FILE="${3:?Usage: post_review.sh <PR_ID> <verdict> <body_file>}"

if [ ! -f "$BODY_FILE" ]; then
  echo "ERROR: Body file not found: $BODY_FILE" >&2
  exit 1
fi

# Validate verdict
case "$VERDICT" in
  APPROVE|REQUEST_CHANGES|COMMENT)
    ;;
  *)
    echo "ERROR: Invalid verdict '$VERDICT'. Must be APPROVE, REQUEST_CHANGES, or COMMENT." >&2
    exit 1
    ;;
esac

# Map verdict to gh flag
case "$VERDICT" in
  APPROVE)
    GH_FLAG="--approve"
    ;;
  REQUEST_CHANGES)
    GH_FLAG="--request-changes"
    ;;
  COMMENT)
    GH_FLAG="--comment"
    ;;
esac

BODY=$(cat "$BODY_FILE")

echo "=== Posting Review ==="
echo "PR: $PR_ID"
echo "Verdict: $VERDICT"
echo "Body length: ${#BODY} chars"
echo ""

# Dry run check
if [ "${DRY_RUN:-}" = "true" ]; then
  echo "[DRY RUN] Would post review with:"
  echo "  gh pr review $PR_ID $GH_FLAG --body <body>"
  echo ""
  echo "--- Body preview (first 500 chars) ---"
  echo "$BODY" | head -c 500
  echo ""
  echo "--- End preview ---"
  exit 0
fi

# Post the review
gh pr review "$PR_ID" $GH_FLAG --body "$BODY"

if [ $? -eq 0 ]; then
  echo "SUCCESS: Review posted as $VERDICT"
else
  echo "ERROR: Failed to post review. Check gh auth status." >&2
  echo "Manual command:"
  echo "  gh pr review $PR_ID $GH_FLAG --body-file $BODY_FILE"
  exit 1
fi
