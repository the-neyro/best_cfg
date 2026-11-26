#!/usr/bin/env bash
# Stop hook: when Claude tries to finish a turn with uncommitted code changes,
# run the project's fast checks (typecheck + lint). If they fail, exit 2 so
# Claude gets the errors back and keeps working. Blocks at most once in a row
# (stop_hook_active) so pre-existing failures never trap the session.

input="$(cat)"
if printf '%s' "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Only run when source files changed (staged, unstaged or untracked).
changed="$( { git diff --name-only HEAD 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null; } \
  | grep -E '\.(ts|tsx|js|jsx|mjs|cjs|vue|svelte|astro|py|go|rs)$' | head -n 1)"
[ -z "$changed" ] && exit 0

fail=0
log="$(mktemp)"
run() { # $1 = label, rest = command
  local label="$1"; shift
  if ! "$@" >"$log" 2>&1; then
    { echo "### $label failed: $*"; tail -n 60 "$log"; echo; } >&2
    fail=1
  fi
}

has_script() { [ -f package.json ] && node -e "process.exit(require('./package.json').scripts?.['$1'] ? 0 : 1)" 2>/dev/null; }

if [ -f package.json ]; then
  pm=npm
  [ -f pnpm-lock.yaml ] && pm=pnpm
  [ -f yarn.lock ] && pm=yarn
  { [ -f bun.lock ] || [ -f bun.lockb ]; } && pm=bun

  if has_script typecheck; then run "Typecheck" $pm run typecheck
  elif [ -f tsconfig.json ] && [ -x node_modules/.bin/tsc ]; then run "Typecheck" node_modules/.bin/tsc --noEmit
  fi
  if has_script lint; then run "Lint" $pm run lint; fi
fi

if [ -f pyproject.toml ] && command -v ruff >/dev/null 2>&1; then
  run "Ruff" ruff check .
fi
if [ -f go.mod ] && command -v go >/dev/null 2>&1; then
  run "go vet" go vet ./...
fi
if [ -f Cargo.toml ] && command -v cargo >/dev/null 2>&1; then
  run "cargo check" cargo check --quiet
fi

rm -f "$log"
if [ "$fail" -ne 0 ]; then
  echo "Fix the errors above that your changes caused, then finish. If a failure is pre-existing and unrelated, say so explicitly in your final message." >&2
  exit 2
fi
exit 0
