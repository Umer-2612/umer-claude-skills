# Umer's Claude Skills

Personal collection of [Claude Code](https://claude.com/claude-code) skills.

| Skill | What it does |
|---|---|
| [`umer-tone`](./umer-tone) | Rewrites AI-sounding text so it reads like a person wrote it, without changing what it says. |
| [`umer-git-workflow`](./umer-git-workflow) | Professional Git/GitHub conventions: conventional commits, branch naming, PR hygiene, CI, branch protection, releases. Commit bodies and PR text get run through `umer-tone` before they ship. |
| [`umer-code-review`](./umer-code-review) | Modular code review skill covering 20+ languages/frameworks, plus cross-cutting security, performance, and architecture guides. |

Each skill was forked from an open-source Claude skill (MIT licensed) and rebranded for personal use. See each skill's own README for its upstream source and license.

## Install

### One command

```bash
curl -fsSL https://raw.githubusercontent.com/Umer-2612/umer-claude-skills/main/install.sh | bash
```

This clones the repo into a temp directory and copies all three skill folders into `~/.claude/skills/` (override the target with `CLAUDE_SKILLS_DIR=/some/path`). Restart Claude Code (or start a new session) and the skills are available: `/umer-tone`, `/umer-git-workflow`, `/umer-code-review`.

### Manual

Clone this repo and copy whichever skill folders you want:

```bash
git clone https://github.com/Umer-2612/umer-claude-skills.git
cp -R umer-claude-skills/umer-tone ~/.claude/skills/
cp -R umer-claude-skills/umer-git-workflow ~/.claude/skills/
cp -R umer-claude-skills/umer-code-review ~/.claude/skills/
```

## License

Each skill folder carries its own `LICENSE` (MIT) from its upstream project.
