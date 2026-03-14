# Cleanup Worktrees

Audit git worktrees and identify stale ones for removal.

## Important

Run ALL commands from the current working directory. Do NOT `cd` to the main repo.

## Steps

### 1. Gather data

```bash
# List all worktrees (exclude the main worktree)
git worktree list

# Sync remote tracking info
git fetch --prune

# Get all remote branch names
git branch -r --list 'origin/*' | sed 's/^ *origin\///'

# Get all PRs in one batch call
gh pr list --state all --json number,title,state,headRefName --limit 500
```

### 2. Categorize each worktree

For each non-main worktree, cross-reference the branch name against the remote branch list and the PR list. Exclude the current worktree from results.

Assign each to exactly one status:

1. **Stale**: Branch has a PR with state `MERGED`. Safe to remove.
2. **Active**: Branch has a PR with state `OPEN`. In-progress work.
3. **No PR**: No merged or open PR exists. Do NOT offer to remove these.

### 3. Present results

Display a table sorted by status: stale first, then active, then no PR.

| # | Worktree | Branch | Status | Linked PR |
|---|----------|--------|--------|-----------|
| 1 | fix-ci | ci-build | 🔴 Stale | #108 — ci: add build step |
| 2 | auto-resume | ci-naming | 🟢 Active | #134 — Rename CI job |
| 3 | browser-test | worktree-browser | ⚪ No PR | — |

**Summary: N stale, N active, N no-pr**

### 4. Offer cleanup

If no stale worktrees, say so and end.

If stale worktrees exist, use `AskUserQuestion` with one option:
- **"All N stale worktrees"**

The user can pick that or choose "Other" to type specific row numbers.

### 5. Remove selected worktrees

For each:
1. `git worktree remove <path>` (offer `--force` if it fails)
2. `git branch -D <branch>`
3. Report success/failure

After local removals, batch-delete remote branches:

```bash
git push origin --delete <branch1> <branch2> ...
```

Then `git worktree prune`. Print final summary.
