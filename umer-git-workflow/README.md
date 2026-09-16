# Umer Git Workflow

A single `SKILL.md` (plus bundled CI templates) that makes Claude Code handle Git, GitHub, and CI the way a senior engineer at a top-tier product company would.

Stack-agnostic. Applies to any language, any project, any team size.

Forked from [ivogabriel19/git-github-workflow-skill](https://github.com/ivogabriel19/git-github-workflow-skill) (MIT licensed) and rebranded for personal use.

## The Problem

LLM coding agents — Claude Code included — tend to handle version control like an afterthought:

- Commit messages like `"updates"`, `"fix stuff"`, `"WIP"`.
- One commit mixing a refactor, a feature, and a stray formatting change.
- 2000-line pull requests that mash three unrelated changes together.
- Direct pushes to `main` "just for a quick fix."
- Blind `git push --force` that overwrites teammates' work.
- `.github/workflows/*.yml` files that ignore caching, pin nothing, and grow into mega-workflows.
- Merging PRs with red CI because "the fix is obvious."

Each of these is small in isolation. Together they produce a repository whose history is unreadable, whose `main` is sometimes broken, and whose CI no one trusts.

## The Solution

A single opinionated skill, ~440 lines, readable in five minutes. It covers:

| Section                  | What it gives you                                                       |
|--------------------------|-------------------------------------------------------------------------|
| **Pre-flight**           | The three commands to run before any work touches a repo.               |
| **Commits**              | Conventional Commits format, atomic-commit rule, staging discipline.    |
| **Branches**             | Naming, GitHub Flow, when to rebase, when not to force-push.            |
| **Pull Requests**        | When to open, title format, body template, review etiquette, merge strategy. |
| **Branch protection**    | Required settings on `main` for any serious repo.                       |
| **CI**                   | Stack-agnostic principles + the four job pillars + performance rules.   |
| **History rewriting**    | The local-vs-shared rule, `amend`, interactive rebase, `reset`.         |
| **Tags & releases**      | Semver mapped to commit types, when to tag, changelog generation.       |
| **Anti-patterns**        | Cheat-sheet of things to never do, with the right alternative.          |
| **Operating defaults**   | A ten-step checklist Claude follows in every session.                   |

The skill is bundled with **ready-to-copy templates** in `assets/`: a four-pillar `ci.yml`, a tag-driven `release.yml`, a `PULL_REQUEST_TEMPLATE.md`, and a `CODEOWNERS` skeleton.

## Install

Copy this folder into your Claude Code skills directory (e.g. `~/.claude/skills/umer-git-workflow`), or point your agent's skill loader at `SKILL.md` directly. It becomes available across all your projects, with no per-repo setup.

### Bootstrapping a repo with the bundled templates

Once installed, ask Claude something like:

> Bootstrap this repo with the `git-github-workflow` conventions. It's a [Python | Node | Go | Rust | …] project.

Claude reads the skill, copies the relevant templates from `assets/` into `.github/`, fills in toolchain placeholders for your stack, and leaves you a PR with the setup.

## Repository structure

```
.
├── SKILL.md                                 # the skill itself
├── assets/
│   ├── workflows/
│   │   ├── ci.yml                           # four-pillar CI template
│   │   └── release.yml                      # tag-driven release template
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── CODEOWNERS
├── EXAMPLES.md                              # before/after concrete examples
├── README.md
└── LICENSE
```

## Core principles

The skill in one breath:

1. **`main` is sacred.** Always deployable, always green, never force-pushed.
2. **One commit = one logical change**, revertible in isolation without breaking anything.
3. **One branch = one unit of work.** Open small, review fast, merge, delete.
4. **Rewrite local history freely. Never rewrite history others have pulled.**

The four-pillar CI rule:

> Every project runs **lint**, **typecheck**, **test**, and **build** on every PR and every push to `main`. All four are required checks. Lint and typecheck run in parallel; build depends on the rest passing.

## How to know it's working

You'll see:

- **Commit history that reads like a changelog.** Types and scopes are consistent; messages are imperative and bounded.
- **Pull requests under 500 lines** that any reviewer can grasp in 30 seconds from the title alone.
- **A `main` that's always green.** No "we'll fix CI on Monday" debt.
- **CI runs under 10 minutes** with cached dependencies and concurrency control.
- **`git bisect` actually works** because every commit is atomic.

See [EXAMPLES.md](./EXAMPLES.md) for concrete before/after scenarios.

## Customization

The skill is opinionated by design but mergeable with project-specific rules. To add overrides, append a section to your project's `CLAUDE.md`:

```markdown
## Project-specific workflow overrides

- We use `release-please` to manage tags — Claude should not tag manually.
- All migrations to `db/` require a manual approval from @db-team — add it to the PR checklist.
- Our `main` branch is `master`. Treat `master` everywhere this skill says `main`.
```

## Tradeoff note

The skill biases toward **rigor over speed**. For trivial repos (personal scratch projects, single-author throwaways), some rules are overkill — use judgment. The goal is to eliminate avoidable mistakes on non-trivial work, not to slow down two-file experiments.

## License

[MIT](./LICENSE)
