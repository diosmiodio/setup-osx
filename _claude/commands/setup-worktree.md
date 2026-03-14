# Set Up Worktree

Create an isolated worktree for development work.

## Arguments

Accepts an optional argument: the base to branch from.

- `origin/main` — Fetch and branch from the latest remote main. Recommended for new work.
- `HEAD` (or omitted) — Branch from the current position.

If no argument is provided, use `AskUserQuestion` to ask which base to use.

## Step 1: Check Current State

```bash
git branch --show-current
git log --oneline -1
```

Report the current branch and latest commit.

## Step 2: Choose Base (skip if argument provided)

Use `AskUserQuestion`:

**Question:** "What should the worktree be based on?"
**Options:**
1. **"Current HEAD (`<branch-name>`)"** — "Branch from your current position."
2. **"Latest origin/main"** — "Fetch and branch from the latest remote main. Recommended for new work."

## Step 3: Pre-flight Checks

Ensure the working tree is clean:

```bash
git status --porcelain
```

If there are uncommitted changes, ask the user: **Commit them**, **Stash temporarily**, or **Discard changes**. Act on their choice, then re-check.

## Step 4: Enter Worktree

Use `EnterWorktree` to create the worktree.

## Step 5: Rebase (if origin/main was chosen)

```bash
git fetch origin main
git rebase origin/main
```

## Step 6: Initialize

Check if the project has an init script (e.g., `scripts/worktree-init.sh`). If so, run it. Otherwise, check if dependencies need linking:

- Node.js: if `node_modules` doesn't exist or is a broken symlink, note that `npm install` may be needed
- Python: if a virtualenv is expected, note that setup may be needed

Report the worktree name, branch, and base commit. The user is ready to work.
