#!/usr/bin/env bash
# best_cfg installer.
#   ./install.sh                  install global config for every detected agent (Claude Code, Codex, Gemini CLI)
#   ./install.sh --all            install for all agents even if not detected
#   ./install.sh --project DIR    copy the project template into DIR (never overwrites existing files)
#   ./install.sh --dry-run        show what would happen
# Existing files are backed up to ~/.ai-config-backup/<timestamp>/ before being replaced.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.ai-config-backup/$STAMP"
DRY=0; ALL=0; PROJECT=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY=1 ;;
    --all) ALL=1 ;;
    --project) PROJECT="${2:?--project needs a directory}"; shift ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

say()  { printf '\033[36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!!\033[0m  %s\n' "$*"; }
run()  { if [ "$DRY" -eq 1 ]; then echo "    [dry-run] $*"; else "$@"; fi; }

backup() { # back up an existing path before replacing it
  local target="$1"
  [ -e "$target" ] || return 0
  local rel="${target#"$HOME"/}"
  run mkdir -p "$BACKUP/$(dirname "$rel")"
  run cp -R "$target" "$BACKUP/$rel"
}

install_file() { # src dst
  local src="$1" dst="$2"
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then return 0; fi
  backup "$dst"
  run mkdir -p "$(dirname "$dst")"
  run cp "$src" "$dst"
  echo "    $dst"
}

install_dir_items() { # srcdir dstdir: replace each top-level item of srcdir inside dstdir, keep other items
  local srcdir="$1" dstdir="$2"
  run mkdir -p "$dstdir"
  for item in "$srcdir"/*; do
    [ -e "$item" ] || continue
    local name; name="$(basename "$item")"
    if [ -e "$dstdir/$name" ] && diff -rq "$item" "$dstdir/$name" >/dev/null 2>&1; then continue; fi
    backup "$dstdir/$name"
    run rm -rf "${dstdir:?}/$name"
    run cp -R "$item" "$dstdir/$name"
    echo "    $dstdir/$name"
  done
}

merge_settings() { # merge our settings.json into an existing one (lists unioned, hooks appended without duplicates)
  local ours="$1" dst="$2"
  if [ ! -f "$dst" ]; then install_file "$ours" "$dst"; return; fi
  if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found: replacing $dst (backup kept). Install jq to merge instead."
    install_file "$ours" "$dst"; return
  fi
  local merged
  merged="$(jq -s '
    .[0] as $old | .[1] as $new
    | ($old * $new)
    | .permissions.allow = (((($old.permissions.allow) // []) + (($new.permissions.allow) // [])) | unique)
    | .permissions.ask   = (((($old.permissions.ask)   // []) + (($new.permissions.ask)   // [])) | unique)
    | .permissions.deny  = (((($old.permissions.deny)  // []) + (($new.permissions.deny)  // [])) | unique)
    | .hooks = (reduce ((($old.hooks // {}) | keys) + (($new.hooks // {}) | keys) | unique)[] as $ev
        ({}; .[$ev] = ((($old.hooks[$ev]) // []) + (($new.hooks[$ev]) // []) | unique_by(tojson))))
    | .hooks |= with_entries(.value |= map(select((tojson | test("design-trigger\\.sh")) | not)))
  ' "$dst" "$ours")"
  if [ -n "$merged" ]; then
    if printf '%s\n' "$merged" | cmp -s - "$dst"; then return 0; fi
    backup "$dst"
    if [ "$DRY" -eq 1 ]; then echo "    [dry-run] merge into $dst"; else printf '%s\n' "$merged" > "$dst"; fi
    echo "    $dst (merged)"
  fi
}

has() { command -v "$1" >/dev/null 2>&1; }

# ---------------------------------------------------------------- project mode
if [ -n "$PROJECT" ]; then
  [ -d "$PROJECT" ] || { echo "No such directory: $PROJECT" >&2; exit 1; }
  say "Copying project template into $PROJECT (existing files are kept)"
  (cd "$REPO/project-template" && find . -type f) | while read -r f; do
    f="${f#./}"
    if [ -e "$PROJECT/$f" ]; then warn "exists, skipped: $f"; continue; fi
    run mkdir -p "$PROJECT/$(dirname "$f")"
    run cp "$REPO/project-template/$f" "$PROJECT/$f"
    echo "    $PROJECT/$f"
  done
  run chmod +x "$PROJECT/.claude/hooks/"*.sh 2>/dev/null || true
  say "Next: fill in the TODOs in $PROJECT/AGENTS.md (commands, stack, gotchas)."
  exit 0
fi

# ---------------------------------------------------------------- global mode
say "Shared Agent Skills -> ~/.agents/skills (read by Codex, Gemini CLI, Cursor and other Agent Skills clients)"
install_dir_items "$REPO/skills" "$HOME/.agents/skills"

if [ "$ALL" -eq 1 ] || has claude || [ -d "$HOME/.claude" ]; then
  say "Claude Code -> ~/.claude"
  install_file "$REPO/core/AGENTS.md" "$HOME/.claude/AGENTS.md"
  install_file "$REPO/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  install_dir_items "$REPO/claude/agents" "$HOME/.claude/agents"
  install_dir_items "$REPO/claude/hooks" "$HOME/.claude/hooks"
  install_dir_items "$REPO/skills" "$HOME/.claude/skills"
  # Remove hooks from earlier versions of this config.
  for legacy in design-trigger.sh; do
    [ -e "$HOME/.claude/hooks/$legacy" ] && { backup "$HOME/.claude/hooks/$legacy"; run rm -f "$HOME/.claude/hooks/$legacy"; }
  done
  run chmod +x "$HOME/.claude/hooks/"*.sh
  merge_settings "$REPO/claude/settings.json" "$HOME/.claude/settings.json"
else
  warn "Claude Code not detected (use --all to install anyway)"
fi

if [ "$ALL" -eq 1 ] || has codex || [ -d "${CODEX_HOME:-$HOME/.codex}" ]; then
  say "Codex -> ${CODEX_HOME:-$HOME/.codex}/AGENTS.md"
  install_file "$REPO/core/AGENTS.md" "${CODEX_HOME:-$HOME/.codex}/AGENTS.md"
else
  warn "Codex not detected (use --all to install anyway)"
fi

if [ "$ALL" -eq 1 ] || has gemini || [ -d "$HOME/.gemini" ]; then
  say "Gemini CLI -> ~/.gemini/GEMINI.md"
  install_file "$REPO/core/AGENTS.md" "$HOME/.gemini/GEMINI.md"
else
  warn "Gemini CLI not detected (use --all to install anyway)"
fi

say "Cursor / Windsurf / Copilot: they read AGENTS.md from the project. For global rules, paste core/AGENTS.md into Cursor Settings -> Rules -> User Rules."

for tool in jq python3 node; do has "$tool" || warn "$tool not found: hooks and scripts work best with jq, python3 and node installed."; done
[ -d "$BACKUP" ] && say "Backups of replaced files: $BACKUP"
say "Done. In Claude Code run /hooks, /agents and /context to confirm everything loaded."
