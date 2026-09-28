#!/bin/bash

set -euo pipefail

COMMIT="${BUILDKITE_COMMIT:-}"
BASE_BRANCH="${BUILDKITE_PULL_REQUEST_BASE_BRANCH:-main}"

if [[ -z "$COMMIT" ]]; then
  echo "❌ Missing BUILDKITE_COMMIT env var"
  exit 1
fi

BRANCH_POINT_COMMIT=$(git merge-base "$BASE_BRANCH" "$COMMIT")

>&2 echo "⚙️ Diff between $COMMIT and $BRANCH_POINT_COMMIT"

CHANGED_FILES=$(git --no-pager diff --name-only "$BRANCH_POINT_COMMIT".."$COMMIT" | \
  grep -Ev '^\.buildkite/|\.md$|^README\.md$|^LICENSE$' || true)

if [[ -z "$CHANGED_FILES" ]]; then
  >&2 echo ""
  >&2 echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  >&2 echo "✅ No changes detected!"
  >&2 echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  >&2 echo "No triggering of pipelines was necessary."
  >&2 echo ""
  buildkite-agent annotate "✅ No changes detected - no pipelines triggered." --style "info"
  exit 0
fi

>&2 echo ""
>&2 echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
>&2 echo "🚀 Changes detected in:"
>&2 echo "$CHANGED_FILES"
>&2 echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
>&2 echo ""

echo "$CHANGED_FILES"
