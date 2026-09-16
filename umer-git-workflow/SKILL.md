---
name: umer-git-workflow
description: Professional Git and GitHub workflow conventions, including CI configuration. Use this skill for every version control or repository operation — staging changes, writing commit messages, creating or switching branches, opening pull requests, rewriting history, tagging releases, setting up branch protection, authoring or reviewing GitHub Actions workflows, or any `git` command. Apply these rules mechanically to keep `main` deployable, commits atomic and conventional, history navigable, PRs reviewable in under thirty minutes, and CI fast and reliable. Trigger this whenever you're about to commit, push, open or merge a PR, run `rebase`, `reset`, `cherry-pick`, write a `.github/workflows/*.yml` file, or configure repository settings — even for trivial one-line changes. Free-text prose in commit bodies and PR descriptions is run through the `umer-tone` skill before it ships.
license: MIT
metadata:
  version: "1.0.0"
  author: Umer Karachiwala
---

# Git & GitHub Professional Workflow

Stack-agnostic conventions for any software project. The goal: a commit history that reads like a changelog, branches that map one-to-one to units of work, a `main` branch that is always green and always deployable, and CI that catches regressions before review.

## Core principles

- `main` is sacred. Always deployable, always green, never force-pushed.
- One commit = one logical change, revertible in isolation without breaking anything.
- One branch = one unit of work. Open small, review fast, merge, delete.
- Rewrite local history freely. Never rewrite history others have pulled.

---

## Before you start any work

```bash
git status                                              # working tree clean?
git branch --show-current                               # on the right branch?
git fetch origin && git log HEAD..origin/main --oneline # behind main?
```

If the tree is dirty: commit, stash, or discard before starting unrelated work. If the branch is behind `main`: rebase first (see "Keeping a branch in sync").

---

## Commits

### Format — Conventional Commits

```
type(scope): description

[optional body]

[optional footer]
```

- `type` required, one of: `feat`, `fix`, `chore`, `docs`, `test`, `refactor`, `style`, `perf`, `ci`.
- `scope` optional. Include when the change is localized to a named area (`auth`, `api`, `parser`, `deps`). Omit when the scope adds no information.
- `description` is imperative mood, lowercase, no trailing period, max 72 characters. Imperative because the commit *applies* a change — write it as a command.

**Type cheat sheet:**

| Type       | Use for                                                       |
|------------|---------------------------------------------------------------|
| `feat`     | New user-visible capability                                   |
| `fix`      | Bug fix (user-visible behavior was wrong, now correct)        |
| `refactor` | Behavior-preserving code change                               |
| `perf`     | Behavior-preserving change that improves performance          |
| `test`     | Adding or fixing tests, no production code change             |
| `docs`     | Docs only (README, comments, ADRs)                            |
| `style`    | Formatting, whitespace — no code change                       |
| `chore`    | Tooling, config, deps, build scripts                          |
| `ci`       | CI configuration only                                         |

### Description — good vs. bad

```
✅ feat(auth): add refresh token rotation
✅ fix(parser): handle empty input without panicking
✅ refactor(api): extract pagination into shared helper
✅ chore(deps): bump lodash to 4.17.21

❌ Updated stuff                          # vague, past tense, capitalized
❌ feat: Added new feature.               # past tense, capitalized, period
❌ fix(auth): fixes the bug where users   # redundant "fixes", truncated
❌ misc                                   # tells you nothing
❌ WIP                                    # never commit WIP to a shared branch
```

### Body

Add a body when the *why* is not obvious from the diff. Skip it when the description fully covers the change.

- Separate from the description with one blank line.
- Wrap at 72 columns.
- Explain **what changed and why**, not **how**.
- Run the drafted body through the `umer-tone` skill before committing. Commit bodies are prose, not just structured metadata, so they pick up the same AI tells (staged run-ups, inflated significance, forced triads) that `umer-tone` catches everywhere else. The `type(scope): description` line stays mechanical and is not run through it.

```
fix(scheduler): avoid double-firing of retry jobs

The retry queue was being polled by both the worker pool and the
supervisor, causing jobs to execute twice under load. The supervisor
poll was vestigial — removing it and letting the workers own the
queue exclusively.

Closes #482
```

### Footer

Use for:

- **Breaking changes:** start a line with `BREAKING CHANGE:` followed by the migration note. This is the only thing that promotes a commit to a major version bump.
- **Issue references:** `Closes #123`, `Refs #456`.
- **Co-authors:** `Co-authored-by: Name <email>`.

```
feat(api): replace v1 endpoints with v2 schema

BREAKING CHANGE: /users now returns `id` as string instead of int.
Clients must update their type definitions.

Closes #311
```

### Atomic commits

A commit is atomic when it answers yes to all three:

1. Does it represent **exactly one** logical change?
2. Could it be **reverted alone** without breaking the build?
3. Would a reviewer understand it without reading the surrounding commits?

**Never mix:** refactor with feature, fix with formatting, unrelated changes across modules just because you happened to touch them.

If you wrote "and" in a commit message, you probably have two commits.

### Staging — never `git add .` blind

```bash
git status                # what changed?
git diff                  # actual content of the changes
git add -p                # stage by hunk, not by file
git diff --staged         # confirm exactly what will be committed
```

`git add -p` is the default. It forces a look at every hunk. This is how you avoid committing debug prints, stray `console.log`, or secrets.

---

## Branches

### Naming

```
<type>/<short-kebab-description>
```

Types match commit types: `feat/`, `fix/`, `chore/`, `hotfix/`, `docs/`, `refactor/`. Description in kebab-case, 2–5 words.

```
✅ feat/oauth-google-login
✅ fix/null-pointer-in-checkout
✅ chore/upgrade-typescript-5
✅ hotfix/payment-webhook-retry

❌ my-branch
❌ johns-work
❌ feature/AddNewAuthFlowAndAlsoFixSomeBugs
❌ test
```

### Branch from `main`

Always off `main`, not off another feature branch — unless that branch is a hard dependency and you're explicitly stacking PRs. Stacked branches multiply review complexity; avoid when you can.

### Keep one branch = one unit of work

If mid-work you find an unrelated bug or want a tangential refactor, do not add it to the current branch. Stash, switch to `main`, branch off, open a separate PR. Future you will thank present you when bisecting.

### Keeping a branch in sync with `main`

Rebase, don't merge. Linear history is readable history.

```bash
git fetch origin
git rebase origin/main
# resolve any conflicts, then:
git push --force-with-lease
```

Always `--force-with-lease`, never `--force`. The former refuses the push if someone else pushed to your branch; the latter overwrites their work.

If the branch is shared with other humans, coordinate before rebasing.

### Never commit directly to `main`

Not even one-character typo fixes. Branch, PR, merge. The protection is the workflow, not the diff size.

---

## Pull Requests

### When to open

Open when the PR is **reviewable in under thirty minutes**. Past that budget, split it:

- Refactor PR first (no behavior change), feature PR second on top.
- Extract a "prep" PR with renames, file moves, or pure additions.
- One user-facing change per PR, even if it spans files.

### Title

Same format as a commit message: `type(scope): description`. This becomes the merged commit on `main` when you squash-merge.

### Body

Use the template at `assets/PULL_REQUEST_TEMPLATE.md`. Sections:

- **What** — one or two sentences. A reviewer should understand the PR from this alone in 30 seconds.
- **Why** — motivation. Link the issue, design doc, or bug.
- **How to test** — concrete steps. Command, input, expected output.
- **Screenshots** — for UI changes. Delete the section if N/A.
- **Checklist** — tests, docs, no unrelated changes, CI green.

Run the **What** and **Why** prose through the `umer-tone` skill before posting. Same reasoning as commit bodies: free text in a PR description is where AI tells creep in, and a reviewer notices a staged opener or an inflated claim faster than they notice a missing test.

### Draft PRs

Open as draft when:

- You want early feedback on direction before going deep.
- The change depends on a not-yet-merged PR.
- CI needs to run on something you're not ready to ship.

Mark "Ready for review" only when the checklist is satisfied and CI is green.

### Responding to review

- Reply to every comment. Either resolve it (push a fix, mark resolved) or push back with reasoning.
- Don't resolve a thread the reviewer opened — let them resolve once satisfied.
- Push fixes as **separate commits** during review (don't amend — it makes the diff impossible to re-review). Squash on merge.
- Request re-review explicitly via the GitHub UI.

### Merge strategy

Default: **squash and merge**. One PR = one commit on `main`. The squash commit message is the PR title in conventional commit form.

Use **rebase and merge** only when every commit in the branch is independently meaningful and you want all of them on `main` (rare — usually only for clean refactor sequences).

**Never** use merge commits on `main`. They pollute the log and break linear history.

After merge: delete the branch. Always.

---

## Branch protection

Configure on `main` (and any long-lived branch):

- Require pull request before merging — no direct pushes.
- Require approvals — minimum 1 for solo projects, 2 for teams.
- Require status checks to pass — at minimum: lint, typecheck, test, build.
- Require branches up to date before merging.
- Require conversation resolution before merging.
- Block force pushes to `main`.
- Block deletions of `main`.
- Automatically delete head branches after merge.

If a check fails on a PR, never bypass to merge. Investigate, fix, re-run.

---

## Continuous Integration

CI is the automated reviewer that runs on every change. It catches regressions the human reviewer won't notice.

### Principles

- **Fast.** CI on a PR should finish in under 10 minutes. Past that, developers context-switch and feedback loops break. Cache aggressively, parallelize jobs.
- **Reliable.** A red CI must mean a real failure. Flaky tests destroy trust — quarantine or fix them immediately, never re-run hoping for green.
- **Deterministic.** Same commit, same result. Pin tool versions, pin dependency versions in lockfiles, pin runner OS versions.
- **Required.** Every check that matters is a required check in branch protection. If it's not required, it doesn't exist.
- **Isolated.** CI runs in a clean environment every time. Never depend on state from a previous run.

### The four job pillars

Every project should run these on every PR and every push to `main`:

| Job         | Purpose                                                |
|-------------|--------------------------------------------------------|
| `lint`      | Style and static analysis (formatting, common bugs)   |
| `typecheck` | Static type checking (skip only if untyped language)   |
| `test`      | Unit and integration tests                             |
| `build`     | Produce the production artifact                        |

Run `lint` and `typecheck` in parallel — they're independent. `build` depends on the rest passing.

### When workflows run

- **Pull requests** — all four pillars, on every push to the PR branch.
- **Push to `main`** — all four pillars, plus deploy (if applicable).
- **Tags matching `v*.*.*`** — release workflow (build artifacts, create GitHub Release, publish).
- **Manual dispatch** — for ops tasks (re-run a deploy, regenerate docs).

### Workflow file conventions

- One workflow per concern: `ci.yml`, `release.yml`, `deploy.yml`. Do not put everything in one mega-workflow.
- Files live in `.github/workflows/`.
- File names are lowercase kebab-case.
- The `name:` field at the top is what shows in the UI — make it human-readable.

### Performance — non-negotiable

- **Cache dependencies.** Every package manager has a cache action. Use it.
- **Concurrency control.** Cancel in-progress runs for the same PR when a new push comes in. Don't cancel runs on `main`.
- **Fail fast.** In matrix jobs, set `fail-fast: true` for PRs (one failure cancels the rest) and `false` for `main` (you want full signal).
- **Conditional jobs.** Skip jobs that don't apply to the changed paths (e.g., skip frontend tests if only backend changed). Use `paths:` filters or `dorny/paths-filter`.

### Secrets

- Never commit secrets. Use repository or organization secrets (`Settings → Secrets and variables → Actions`).
- Reference as `${{ secrets.NAME }}`.
- Never echo a secret to logs. GitHub masks known secrets, but only the literal value.
- For PRs from forks: secrets are not available by default. This is intentional. Use `pull_request_target` only with extreme care and never to run untrusted code.

### Reusability

- Extract repeated steps into composite actions (`.github/actions/<name>/action.yml`).
- For workflows shared across repos, use reusable workflows (`workflow_call`).
- Pin third-party actions to a full commit SHA, not a tag — tags are mutable, SHAs are not.

```yaml
# ✅ Pinned to immutable SHA, with version comment
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

# ❌ Mutable tag — attacker who hijacks the repo can swap your build
- uses: actions/checkout@v4
```

### Bundled templates

Skeletons in `assets/`:

- `assets/workflows/ci.yml` — four-pillar CI workflow with cache, concurrency, and placeholders for toolchain commands.
- `assets/workflows/release.yml` — tag-driven release workflow that creates a GitHub Release with auto-generated notes.
- `assets/PULL_REQUEST_TEMPLATE.md` — copy to `.github/PULL_REQUEST_TEMPLATE.md`.
- `assets/CODEOWNERS` — copy to `.github/CODEOWNERS` and customize.

To bootstrap a new repo: copy from `assets/`, fill in the placeholders marked `# <...>`, commit.

---

## Rewriting history

**Rewrite local history freely. Never rewrite history that has been pushed to a shared branch.**

A shared branch is any branch another human or machine may have pulled. `main` is always shared. Your feature branch is shared the moment a teammate pulls it for review. If you must rewrite shared history, communicate first.

### `git commit --amend`

Fix the *last* commit only — typo in message, forgot a file, missed a debug print. Only if not yet pushed.

```bash
git add forgotten-file
git commit --amend --no-edit         # add file, keep message
git commit --amend                   # edit message
```

### Interactive rebase

Use `git rebase -i` before opening a PR to clean up local history.

```bash
git rebase -i origin/main
```

Operations: `reword` (fix message), `squash` (combine, merge messages), `fixup` (combine, discard message), `drop` (remove), reorder by moving lines.

When in doubt, branch first as backup (`git switch -c backup-branch`).

### `git reset`

- `--soft HEAD~1` — undo last commit, keep changes staged.
- `--mixed HEAD~1` — undo last commit, keep changes unstaged (default).
- `--hard HEAD~1` — undo last commit, discard changes. Destructive — confirm what you're discarding first.

---

## Tags & releases

### Semantic versioning

`vMAJOR.MINOR.PATCH`

- **MAJOR** — incompatible changes. Bumped by any commit with `BREAKING CHANGE:` in the footer.
- **MINOR** — new functionality, backward-compatible. Bumped by `feat:`.
- **PATCH** — backward-compatible fixes. Bumped by `fix:`.

Other types (`chore`, `docs`, `style`, `test`, `refactor`, `ci`, `perf`) do not bump the version on their own.

### Tagging

Tag every deploy to production. The tag is the source of truth for "what's running."

```bash
git tag -a v1.4.0 -m "Release v1.4.0"
git push origin v1.4.0
```

Annotated tags (`-a`), not lightweight. Annotated tags carry the tagger, date, and message — required by most release tooling.

### Changelog

Generate from conventional commits. Group by `feat` (Added), `fix` (Fixed), `perf` (Performance), `BREAKING CHANGE` (Breaking). Skip `chore`, `style`, `ci`, `test` — internal noise.

GitHub's auto-generated release notes (used in `assets/workflows/release.yml`) handle this if your PR titles follow the convention.

---

## Anti-patterns — never do these

| Anti-pattern                                                        | Do this instead                                              |
|---------------------------------------------------------------------|--------------------------------------------------------------|
| `git add .` without looking                                         | `git add -p`, then `git diff --staged`                       |
| Commit message "fix stuff" / "updates" / "wip"                      | Conventional commit with imperative description              |
| One commit with refactor + feature + formatting                     | Three commits: refactor, then feature, then format           |
| `git push --force` on a shared branch                               | `git push --force-with-lease`, coordinate first              |
| `git commit --amend` on a pushed commit                             | New commit; squash on merge                                  |
| Merging a PR with red CI                                            | Fix CI first; never bypass                                   |
| Re-running flaky tests until green                                  | Quarantine or fix the test; flakes are bugs                  |
| PR titled "WIP" or "fixes"                                          | Conventional commit format with real scope                   |
| 2000-line PR                                                        | Split into a chain of <500-line PRs                          |
| Committing directly to `main`                                       | Branch, PR, merge — even for typos                           |
| Long-lived feature branch never rebased                             | Merge often, ship behind a feature flag if needed            |
| Self-merging without review on a team project                       | Wait for approval                                            |
| Resolving a reviewer's comment yourself                             | Let the reviewer resolve once satisfied                      |
| Force-pushing during active review                                  | Push fixup commits; squash on merge                          |
| Leaving merged branches around                                      | Delete after merge — every time                              |
| Third-party action pinned to `@v4`                                  | Pin to full commit SHA with version comment                  |
| Mega-workflow doing CI + release + deploy                           | One file per concern in `.github/workflows/`                 |
| Committed `.env` or API keys                                        | Repository secrets; rotate the leaked key immediately        |

---

## Operating defaults for Claude in a session

1. Before touching anything, run the pre-flight: `git status`, `git branch --show-current`, `git fetch && git log HEAD..origin/main --oneline`.
2. Plan the commit sequence before starting work. If the task needs three commits, know what each one is going to be.
3. Commit at every completed logical unit — not at the end of the session.
4. Inspect every diff before committing. No `git add .` without justification.
5. Write the commit message in the imperative; if you wrote "and", split the commit. Run any commit body through `umer-tone` before committing.
6. Before opening a PR, rebase on `main` and run lint, typecheck, tests, and build locally.
7. Fill the PR body using the template. Never open a PR with an empty description. Run the What/Why prose through `umer-tone` before posting.
8. If CI fails on your PR, investigate the failure before doing anything else — no speculative fixes.
9. When authoring a workflow file, start from `assets/workflows/` and adapt — don't write from scratch.
10. After merge: delete the branch, pull `main`, confirm the change is in.
