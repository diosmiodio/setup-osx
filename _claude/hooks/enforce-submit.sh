#!/usr/bin/env bash
# enforce-submit.sh — PreToolUse hook for Bash
# Blocks direct PR creation (gh pr create) and requires /submit instead.
# This ensures every PR goes through the review + submit workflow.

set -euo pipefail

INPUT=$(cat)

if ! command -v jq &>/dev/null; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -qE 'gh\s+pr\s+create'; then
  cat >&2 <<'MSG'
BLOCKED: Direct PR creation is not allowed. Use the /submit command instead.

/submit runs code review, syncs with main, verifies tests pass, and creates the PR with a proper description. Run /submit to continue.
MSG
  exit 2
fi

exit 0
