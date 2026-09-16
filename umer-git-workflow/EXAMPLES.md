# EXAMPLES

Concrete before/after examples showing the difference the `git-github-workflow` skill makes in real situations.

---

## Example 1: Commit message hygiene

**User:**

> I refactored the auth module and also fixed a bug where users couldn't log in with their email if it had uppercase letters. Can you commit this?

**Claude (without skill):**

```bash
git add .
git commit -m "refactored auth and fixed login bug"
```

One commit, two unrelated changes, vague past-tense message.

**Claude (with skill):**

```bash
git status
# modified:   src/auth/jwt.ts
# modified:   src/auth/login.ts
# modified:   src/auth/utils.ts
```

> Two logical changes here — a refactor and a fix. They go in separate commits so either can be reverted alone.
>
> Let me inspect each file to decide which hunk belongs where:

```bash
git diff src/auth/login.ts        # email-casing fix
git diff src/auth/utils.ts        # refactor: extract token validation

# First commit: the fix only
git add -p src/auth/login.ts
git commit -m "fix(auth): handle email with uppercase characters in login"

# Second commit: the refactor only
git add src/auth/utils.ts
git commit -m "refactor(auth): extract token validation into shared helper"
```

Two atomic commits. Each is revertible in isolation. The fix lands as the smallest diff that captures the user-visible bug.

---

## Example 2: PR sizing

**User:**

> I added a new dashboard with charts, refactored the data-fetching layer to use a new query client, and fixed the broken dark-mode toggle. The diff is 1800 lines across 47 files. Can you open a PR?

**Claude (without skill):**

Opens one PR titled `feat: dashboard updates` with all three changes mixed together.

**Claude (with skill):**

> Three independent changes can't share a PR — a reviewer can't isolate the refactor from the feature, which is exactly when bugs slip in. I'll split this:
>
> 1. **PR #1** — `refactor(data): migrate fetching layer to new query client`. No behavior change, lands first.
> 2. **PR #2** — `fix(ui): repair dark mode toggle`. Small, independent, lands anytime.
> 3. **PR #3** — `feat(dashboard): add charts using new query client`. Opens against `main` after #1 merges.
>
> Each PR will be under 500 lines and reviewable in under 30 minutes.

Then proceeds to stash the work, branch off `main`, and assemble the three branches one at a time.

---

## Example 3: CI workflow structure

**User:**

> I want a GitHub Action that lints, runs tests, builds the app, and deploys to staging when I push to main. It's a Node project.

**Claude (without skill):**

Writes one `.github/workflows/all.yml` with every job inline, no caching, no concurrency control, third-party actions pinned to `@v4`.

**Claude (with skill):**

Creates three workflow files, one per concern:

```
.github/workflows/
├── ci.yml         # lint, typecheck, test, build — every PR and push to main
├── deploy.yml     # deploys to staging — push to main, needs ci to pass
└── release.yml    # tag-driven production release
```

Each workflow:

- Pins every third-party action to a full commit SHA with a version comment.
- Caches the package manager (`actions/setup-node@SHA` with `cache: 'npm'`).
- Sets `concurrency` to cancel in-progress runs on the same PR ref, but never on `main`.
- Runs `lint` and `typecheck` in parallel, with `build` gated on `needs: [lint, typecheck, test]`.

> One concern per file means a bug in `deploy.yml` can't break CI, and a CI tweak can't accidentally trigger a deploy. Required checks in branch protection point at `ci.yml`'s jobs by name.

---

## Example 4: Force-pushing a shared branch

**User:**

> I rebased my feature branch on top of main, but now `git push` is rejected with "updates were rejected because the tip of your current branch is behind." Should I use `git push --force`?

**Claude (without skill):**

```bash
git push --force
```

Blindly overwrites whatever is on the remote.

**Claude (with skill):**

> Two questions before any force-push:
>
> 1. **Has anyone pulled this branch?** If a teammate has it checked out for review, force-pushing rewrites history under them and they'll have to recover their local state.
> 2. **Are you using `--force` or `--force-with-lease`?** `--force-with-lease` refuses the push if the remote has commits you didn't fetch. It's the safe variant — always prefer it.
>
> If anyone else might have this branch, ping them in chat first. Then:
>
> ```bash
> git fetch origin
> git push --force-with-lease
> ```
>
> `--force` overwrites blindly; `--force-with-lease` protects both you and your teammate. The cost is a one-line change, so there's no reason to ever use plain `--force`.

---

## Example 5: CI is red, the fix "looks obvious"

**User:**

> CI on my PR is red — the typecheck job failed. The change is just renaming a variable in one file. Can you merge it anyway and we'll fix the type error in a follow-up?

**Claude (without skill):**

Merges the PR with a "fix typecheck in follow-up" note in the comments.

**Claude (with skill):**

> No. A red CI is never bypassed, even for "obvious" fixes. Two reasons:
>
> 1. The required check exists precisely because humans miss things. The variable rename almost certainly broke a downstream type — that's what the failure is telling you. Skipping the check skips the signal.
> 2. Merging red CI to `main` breaks the invariant that `main` is always green. The next person to branch off `main` inherits the broken state.
>
> Let me look at the typecheck output first:

```bash
gh run view --log-failed
```

> The error points to a consumer of the renamed variable. I'll push a fix to this PR (separate commit, will squash on merge), wait for CI to go green, then merge.

---

## What you should see

When the skill is working:

- **Commit history reads like a changelog.** Every commit message is parseable by tooling; types map cleanly to changelog sections.
- **PRs are small and focused.** Reviewers finish in under 30 minutes. Reviews come back faster.
- **`main` is always deployable.** No "we'll fix CI on Monday" debt accumulates.
- **History is navigable.** `git bisect` works because each commit is atomic.
- **CI is fast and trusted.** Under 10 minutes per run. A red check means a real failure, not flakiness.

If you're not seeing this, file an issue with the failure mode — that's how the skill gets sharper.
