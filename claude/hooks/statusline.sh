#!/usr/bin/env bash
# Status line: model · folder · git branch(*dirty) · context used %
# Claude Code pipes session JSON on stdin.

input="$(cat)"

get() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$input" | python3 -c '
import json, sys
data = json.load(sys.stdin)
for key in sys.argv[1].lstrip(".").split("."):
    data = data.get(key) if isinstance(data, dict) else None
print("" if data is None else data)' "$1" 2>/dev/null
  fi
}

model="$(get .model.display_name)"
cwd="$(get .workspace.current_dir)"; [ -z "$cwd" ] && cwd="$(get .cwd)"; [ -z "$cwd" ] && cwd="$PWD"
ctx="$(get .context_window.used_percentage)"

branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch="$(git -C "$cwd" symbolic-ref --short -q HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)"
  [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null | head -n1)" ] && branch="${branch}*"
fi

dim=$'\033[2m'; cyan=$'\033[36m'; green=$'\033[32m'; yellow=$'\033[33m'; red=$'\033[31m'; reset=$'\033[0m'

out="${cyan}${model:-Claude}${reset} ${dim}·${reset} $(basename "$cwd")"
[ -n "$branch" ] && out="$out ${dim}·${reset} ${green}${branch}${reset}"
if [ -n "$ctx" ]; then
  pct="${ctx%%.*}"
  color="$green"; [ "${pct:-0}" -ge 50 ] && color="$yellow"; [ "${pct:-0}" -ge 80 ] && color="$red"
  out="$out ${dim}·${reset} ${color}ctx ${pct}%${reset}"
fi
printf '%s\n' "$out"
