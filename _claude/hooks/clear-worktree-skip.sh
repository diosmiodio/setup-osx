#!/usr/bin/env bash
# clear-worktree-skip.sh — SessionStart hook
# Clears the .worktree-skip marker so the worktree suggestion
# appears fresh each session.

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [[ -n "$REPO_ROOT" ]]; then
  rm -f "$REPO_ROOT/.worktree-skip"
fi
