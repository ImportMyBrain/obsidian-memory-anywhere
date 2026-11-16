#!/usr/bin/env bash
# Install the obsidian-memory Agent Skill for multiple AI clients.
#
#   ./install.sh --vault "/path/to/Obsidian/Vault"
#   ./install.sh --project /path/to/repo --vault "/path/to/Vault"
#
# Copies the skill to:
#   ~/.agents/skills/obsidian-memory   Codex / Cursor / GitHub Copilot / Gemini CLI (user scope)
#   ~/.claude/skills/obsidian-memory   Claude Code (personal skills)
# With --project:
#   <project>/.agents/skills/obsidian-memory
#   <project>/.claude/skills/obsidian-memory
set -euo pipefail

VAULT=""
PROJECT=""
FORCE=0

usage() {
  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vault)   VAULT="${2:-}"; shift 2 ;;
    --project) PROJECT="${2:-}"; shift 2 ;;
    --force)   FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/obsidian-memory"
[[ -f "$SRC/SKILL.md" ]] || { echo "Cannot find $SRC/SKILL.md — run this script from the repository root." >&2; exit 1; }

installed=0

install_skill() {
  local target="$1"
  if [[ -e "$target" ]]; then
    if [[ "$FORCE" -ne 1 ]]; then
      echo "skip (already exists): $target"
      echo "     use --force to overwrite (the old copy is backed up first)"
      return 0
    fi
    local backup="$target.bak-$(date +%Y%m%d-%H%M%S)"
    mv "$target" "$backup"
    echo "backup: $backup"
  fi

  mkdir -p "$(dirname "$target")"
  cp -R "$SRC" "$target"

  if [[ -n "$VAULT" && -f "$target/SKILL.md" ]]; then
    local tmp="$target/SKILL.md.tmp"
    while IFS= read -r line || [[ -n "$line" ]]; do
      printf '%s\n' "${line//__VAULT_PATH__/$VAULT}"
    done < "$target/SKILL.md" > "$tmp"
    mv "$tmp" "$target/SKILL.md"
  fi

  echo "installed: $target"
  installed=$((installed + 1))
}

if [[ -n "$PROJECT" ]]; then
  install_skill "$PROJECT/.agents/skills/obsidian-memory"
  install_skill "$PROJECT/.claude/skills/obsidian-memory"
else
  install_skill "$HOME/.agents/skills/obsidian-memory"
  install_skill "$HOME/.claude/skills/obsidian-memory"
fi

echo ""
if [[ "$installed" -eq 0 ]]; then
  echo "Nothing installed (existing copies were skipped; use --force to overwrite)."
  exit 0
fi

if [[ -z "$VAULT" ]]; then
  echo "Note: --vault was not provided, so VAULT in the installed copies is still __VAULT_PATH__."
  echo "      Re-run with: ./install.sh --vault \"/path/to/Obsidian/Vault\" --force"
fi

echo ""
echo "Next steps:"
echo "  1. Restart your AI client (Claude Code / Codex / Cursor / Copilot / Gemini CLI) so it rescans skills."
echo "  2. Build the digest + index once (and after major vault changes):"
echo "     node obsidian-memory/scripts/memory-build.mjs --vault \"$VAULT\" --archive \"Chats\""
echo "  3. For always-on behavior, add the rule from obsidian-memory/references/always-on.md to"
echo "     AGENTS.md / CLAUDE.md / GEMINI.md / .cursor/rules / .github/copilot-instructions.md."
echo "  4. Chat-only clients (ChatGPT web / Claude.ai / mobile):"
echo "     node obsidian-memory/scripts/memory-pack.mjs --vault \"$VAULT\" --out MEMORY_PACK.md"
echo "     then attach MEMORY_PACK.md to a Project or chat."
echo ""
