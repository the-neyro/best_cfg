#!/usr/bin/env bash
# PostToolUse hook for Edit|Write|MultiEdit: formats the edited file with the
# formatter the project already uses. Only uses locally installed binaries (no
# network downloads), never blocks, and stays silent when nothing applies.

input="$(cat)"

json_get() {
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

file="$(json_get .tool_input.file_path)"
[ -n "$file" ] && [ -f "$file" ] || exit 0

# Walk up from the file to find the nearest directory containing one of the markers.
find_up() { # $1 = start dir, rest = marker names
  local dir="$1"; shift
  while [ -n "$dir" ] && [ "$dir" != "/" ]; do
    for m in "$@"; do [ -e "$dir/$m" ] && { printf '%s' "$dir"; return 0; }; done
    dir="$(dirname "$dir")"
  done
  return 1
}

dir="$(cd "$(dirname "$file")" && pwd)"

case "$file" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.jsonc|*.css|*.scss|*.less|*.html|*.vue|*.svelte|*.astro|*.md|*.mdx|*.yaml|*.yml|*.graphql)
    root="$(find_up "$dir" package.json)" || exit 0
    if [ -x "$root/node_modules/.bin/biome" ] && find_up "$dir" biome.json biome.jsonc >/dev/null; then
      "$root/node_modules/.bin/biome" format --write "$file" >/dev/null 2>&1
    elif [ -x "$root/node_modules/.bin/prettier" ]; then
      "$root/node_modules/.bin/prettier" --write --ignore-unknown --log-level silent "$file" >/dev/null 2>&1
    fi
    ;;
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      ruff format --quiet "$file" >/dev/null 2>&1
    elif command -v black >/dev/null 2>&1; then
      black --quiet "$file" >/dev/null 2>&1
    fi
    ;;
  *.go)   command -v gofmt   >/dev/null 2>&1 && gofmt -w "$file" >/dev/null 2>&1 ;;
  *.rs)   command -v rustfmt >/dev/null 2>&1 && rustfmt --edition 2021 "$file" >/dev/null 2>&1 ;;
  *.swift) command -v swift-format >/dev/null 2>&1 && swift-format -i "$file" >/dev/null 2>&1 ;;
esac

exit 0
