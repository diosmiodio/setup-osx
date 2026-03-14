# Autonomous Development Workflow

Structured workflow for development work. Provides worktree isolation, planning, review, and submission. Follow it phase by phase.

**CRITICAL: Execute all phases autonomously.** Do NOT stop between phases to ask the user if they want to continue. Run through every phase in sequence until the PR is created. The only acceptable pause point is design approval during brainstorming in the Full Pipeline — every other phase transition happens automatically.

## Step 0: Worktree Detection

Check if you're already inside a worktree (PWD contains `/.claude/worktrees/`).

- **Already in a worktree** → go to **Resume in Existing Worktree** below.
- **Not in a worktree** → go to **Fresh Start** below.

---

## Resume in Existing Worktree

You're resuming work in an existing worktree. Skip sync and worktree creation.

**1. Survey the existing state.** Run these and summarize what you find:

```bash
git log --oneline main..HEAD
git status --short
```

Tell the user: the worktree name, branch name, how many commits exist, and whether there are uncommitted changes. Then proceed to **Triage**.

---

## Fresh Start

Invoke `/setup-worktree origin/main` to create an isolated worktree based on the latest remote main.

After the worktree is ready, proceed to **Triage**.

---

## Triage

Route based on what the user asks for:

- **Lightweight** — the user explicitly says "small change", "quick fix", "bug fix", "tweak", or otherwise signals the scope is small and well-defined.
- **Full** — everything else. This is the default.

---

## Full Pipeline

### Phase 1: Brainstorm & Design

Invoke `superpowers:brainstorming`. Do not write any code until the design is approved. The brainstorming skill saves a design doc to `docs/plans/` and hands off to planning.

**Important:** The design doc captures the *intent* — what the code should accomplish and why. This doc will be shared with reviewers later. The implementation plan will NOT be shared with reviewers.

### Phase 2: Plan

Invoke `superpowers:writing-plans`. This breaks the design into bite-sized implementation steps with TDD built in. The plan is saved to `docs/plans/`.

### Phase 3: Implement

Create a feature branch if not already on one.

Invoke `superpowers:executing-plans` to work through the plan. Every step follows `superpowers:test-driven-development` — no production code without a failing test first.

Before claiming implementation is complete, invoke `superpowers:verification-before-completion`:
- Look for verification commands in the project's CLAUDE.md, package.json scripts, Makefile, or pyproject.toml
- Common patterns: `npm run typecheck && npm run test`, `make check`, `pytest`, `cargo test`
- Both typecheck and tests must pass

### Phase 4: Retrospective

Step back and ask yourself:

- What architectural decisions would you reconsider?
- What would you name, organize, or abstract differently?
- What edge cases or failure modes did you miss?
- What tests are missing or weak?

Implement the improvements using `superpowers:test-driven-development`.

### Phase 5: Review

Invoke `/review`. Pass the design intent doc from Phase 1 so the reviewer understands WHAT the code should accomplish.

If `/review` produces code changes, it handles its own verification and re-review internally.

### Phase 6: Submit

Invoke `/submit`. It syncs with main, runs verification, builds a PR description, and creates the PR.

---

## Lightweight Pipeline

For small, well-defined changes.

### Step 1: Implement

No brainstorming or planning needed. Implement directly. Still follow `superpowers:test-driven-development`: write a failing test, make it pass.

### Step 2: Retrospective

Same as Phase 4. Make improvements if needed.

### Step 3: Review

Invoke `/review`. Pass the user's original task description as the design intent.

### Step 4: Submit

Invoke `/submit`.
