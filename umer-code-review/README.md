# Umer Code Review

A comprehensive, modular code review skill for Claude Code. Covers architecture, performance, security, and code-quality review across 20+ languages and frameworks, plus language-agnostic cross-cutting guides (SQL injection, XSS, N+1 queries, error handling, async/concurrency).

Forked from [awesome-skills/code-review-skill](https://github.com/awesome-skills/code-review-skill) (MIT licensed) and rebranded for personal use.

## Install

Copy this folder into your Claude Code skills directory (e.g. `~/.claude/skills/umer-code-review`), or point your agent's skill loader at `SKILL.md` directly.

## Structure

```
.
├── SKILL.md                  # the skill itself: review process, techniques, guide index
├── reference/                 # per-language guides plus cross-cutting guides (security, perf, architecture, bugs)
├── assets/                    # PR review comment template, quick-reference checklist
└── scripts/pr-analyzer.py     # triages a diff's complexity before review
```

## Relevant for this stack

- **TypeScript** (`reference/typescript.md`) for `core-api` (Express + Prisma)
- **React** (`reference/react.md`) for `web-frontend` (Next.js 15 / React 19)
- **Cross-cutting guides**: SQL injection, XSS, N+1 queries, error handling, async/concurrency patterns apply across every service

## License

[MIT](./LICENSE)
