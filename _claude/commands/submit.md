# Submit PR

Integration and submission workflow. Prompts for review, syncs with main, then creates or updates the PR.

## Step 0: Review Check

Before doing anything else, use `AskUserQuestion` to prompt the user:

**Question:** "Would you like to run a code review before submitting?"
**Options:**
1. **Run /review first (Recommended)** — "Invokes the full review loop to catch issues before the PR goes up."
2. **Skip review and submit** — "Submit directly without running /review."

If the user selects "Run /review first", invoke `/review` and wait for it to complete before continuing to Step 1.

## Step 1: Sync with Main

Sync again before submitting — new commits may have landed on main during the workflow.

```bash
git fetch origin main
git rebase origin/main
```

**Check for conflicts.** The rebase result determines which path to take:

- **No conflicts → Fast path** (skip to Step 3)
- **Conflicts → Full path** (continue to Step 2)

If there were conflicts, resolve them. Document what conflicted and how it was resolved — this goes into the PR description.

## Step 2: Post-Merge Review (Full Path Only)

**Skip this step if the rebase in Step 1 had no conflicts.**

Invoke `/review` to run the full review loop post-merge. This catches:
- Bugs introduced by conflict resolution
- Regressions from upstream changes in main
- Any issues that slipped through earlier reviews

## Step 3: Final Verification

Run the project's verification commands (typecheck + tests). Detect them from:
- Project CLAUDE.md
- `package.json` scripts → `npm run typecheck && npm run test`
- `Makefile` → `make check` or `make test`
- `pyproject.toml` → `pytest` or `uv run pytest`
- `Cargo.toml` → `cargo test`

Both must pass. If verification fails repeatedly (3+ attempts), stop and ask the user for guidance.

## Step 4: Build PR Description

Since all commits will be squash-merged, the PR description is the only record of what happened. Build it from:

```bash
git log origin/main..HEAD --oneline
git diff --stat origin/main | tail -1
```

The description must include:

1. **Summary** — What was built/fixed and why (1-3 sentences)
2. **What changed** — Walk through the key changes, organized by area. Explain the approach, not just list files.
3. **Key files** — When the diff touches more than ~5 files, list the 3-5 most important files a reviewer should start with, each with a one-line explanation.
4. **Conflicts resolved** — If Step 1 had conflicts, document what conflicted and how it was resolved
5. **Review notes** — Any notable decisions from the review loop (deferred items, pushbacks, trade-offs)
6. **Test plan** — How to verify the changes work

## Step 5: Submit

1. Stage and commit all remaining changes
2. Push the branch: `git push -u origin <branch>`
3. Check if a PR already exists:
   ```bash
   BRANCH=$(git branch --show-current)
   gh pr list --head "$BRANCH" --json number --jq '.[0].number'
   ```
   - **If a PR exists:** update it with `gh pr edit <number>`
   - **If no PR exists:** create one via `gh pr create --draft`
