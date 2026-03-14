# Code Review Loop

Thorough review workflow. Can be invoked standalone or from `/auto` and `/submit`.

## Step 1: Determine Design Intent

The reviewer needs to understand WHAT the code should accomplish — but NOT how it was planned or implemented.

**If called from `/auto`:** Use the design intent doc from brainstorming (in `docs/plans/`). Skip the prompt below.

**If called from `/submit`:** Check for a design doc in `docs/plans/` from the current branch. If one exists, use it. If not, infer intent from the git history (`git log origin/main..HEAD`).

**If called standalone or no design doc exists:** Present the user with these options:

```
I need to understand the design intent before reviewing. How would you like to provide it?

1. I'll describe it — [text input]
2. Infer from git history — I'll analyze commits and diffs to determine intent
3. Infer from git history + my input — I'll analyze commits, then you refine

Select one or more (e.g. "2" or "2,3"):
```

Wait for the user's selection before proceeding.

## Step 2: Verify

Invoke `superpowers:verification-before-completion`. Detect verification commands from:
- Project CLAUDE.md
- `package.json` scripts → `npm run typecheck && npm run test`
- `Makefile` → `make check` or `make test`
- `pyproject.toml` → `pytest` or `uv run pytest`
- `Cargo.toml` → `cargo test`

If verification fails, fix the issues before proceeding to review.

## Step 3: Request Review

**Setup:** Create `tmp/review-log.md` with a header (or append to existing if re-entering):

```markdown
# Code Review Log — [feature/change name]
```

Dispatch a fresh code-reviewer subagent via `superpowers:requesting-code-review`.

**Include in reviewer context:**
- The design intent (from Step 1)
- The path to `tmp/review-log.md` so it knows what prior rounds addressed

**Do NOT include:**
- Implementation plans or step-by-step details

## Step 4: Receive Findings

Process findings using `superpowers:receiving-code-review` principles:
- Verify each finding against the code
- Push back if feedback is wrong (with reasoning)
- Fix Critical and Important issues
- Act on valid Suggestions

## Step 5: Log the Round

Append a summary to `tmp/review-log.md`:

```
## Round N
### Findings
- [severity] what was flagged and where
### Actions
- what was fixed, with file:line references
### Deferred
- anything intentionally skipped, with reasoning
```

## Step 6: Commit Fixes

Stage and commit any changes made this round.

## Step 7: Loop or Exit

If you made ANY code changes this round, go back to Step 2.

The loop is only done when a review round completes with **zero code changes** made.
