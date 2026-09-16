#!/usr/bin/env bash
# Installs umer-tone, umer-git-workflow, and umer-code-review into
# your Claude Code skills directory (~/.claude/skills by default).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Umer-2612/umer-claude-skills/main/install.sh | bash
# or, from a local clone of this repo:
#   ./install.sh

set -euo pipefail

REPO_URL="https://github.com/Umer-2612/umer-claude-skills.git"
SKILLS=(umer-tone umer-git-workflow umer-code-review)
TARGET_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"

if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/umer-tone" ]; then
  SRC_DIR="$SCRIPT_DIR"
else
  command -v git >/dev/null 2>&1 || { echo "git is required to install (not run from a local clone)." >&2; exit 1; }
  SRC_DIR="$(mktemp -d)"
  trap 'rm -rf "$SRC_DIR"' EXIT
  echo "Cloning $REPO_URL..."
  git clone --depth 1 --quiet "$REPO_URL" "$SRC_DIR"
fi

mkdir -p "$TARGET_DIR"

for skill in "${SKILLS[@]}"; do
  if [ ! -d "$SRC_DIR/$skill" ]; then
    echo "Skipping $skill (not found in source)." >&2
    continue
  fi
  rm -rf "${TARGET_DIR:?}/$skill"
  cp -R "$SRC_DIR/$skill" "$TARGET_DIR/$skill"
  echo "Installed $skill -> $TARGET_DIR/$skill"
done

echo
echo "Done. Restart Claude Code (or start a new session) to load the skills."
