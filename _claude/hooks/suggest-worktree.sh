#!/usr/bin/env bash
# suggest-worktree.sh — PreToolUse hook for Edit/Write
# Suggests worktree isolation on first edit outside a worktree.
# One-time prompt per session: after the user decides, a .worktree-skip
# marker prevents re-prompting. Cleared on next session start.

set -euo pipefail

INPUT=$(cat)

if ! command -v jq &>/dev/null; then
  exit 0
fi

# Not in a git repo — allow
if ! git rev-parse --show-toplevel &>/dev/null; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

extract_worktree_root() {
  local path="$1"
  if [[ "$path" =~ (.*/.claude/worktrees/[^/]+) ]]; then
    echo "${BASH_REMATCH[1]}"
  fi
}

IN_WORKTREE=""
if [[ -n "$FILE_PATH" ]]; then
  IN_WORKTREE=$(extract_worktree_root "$FILE_PATH")
fi
if [[ -z "$IN_WORKTREE" ]]; then
  IN_WORKTREE=$(extract_worktree_root "$PWD")
fi

# Already in a worktree — allow
if [[ -n "$IN_WORKTREE" ]]; then
  exit 0
fi

# Check for skip marker at repo root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [[ -n "$REPO_ROOT" && -f "$REPO_ROOT/.worktree-skip" ]]; then
  exit 0
fi

# First edit outside a worktree — suggest isolation
cat >&2 <<'MSG'
WORKTREE_SUGGESTION: You're about to edit outside a worktree. Before proceeding, use AskUserQuestion to ask the user:

Question: "You're editing on the main branch. Would you like worktree isolation?"
Options:
  1. "Enter a worktree (Recommended)" — description: "Creates an isolated copy so concurrent sessions can't collide."
  2. "Continue on main branch" — description: "Edit directly. Fine for solo work or quick changes."

If the user picks worktree: invoke /setup-worktree to create and initialize the worktree, then retry the edit.
If the user picks continue: create a .worktree-skip marker at the repo root, then retry the edit:
  echo "skip" > "$(git rev-parse --show-toplevel)/.worktree-skip"
MSG
exit 2
