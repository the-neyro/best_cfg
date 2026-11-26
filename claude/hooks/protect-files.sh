#!/usr/bin/env bash
# PreToolUse hook for Edit|Write|MultiEdit|NotebookEdit: protects files that must
# not be hand-edited by the agent (secrets, lockfiles, git internals, keys).
# Fails open if it cannot parse the input.

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

decide() {
  local reason="${2//\\/\\\\}"
  reason="${reason//\"/\\\"}"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' "$1" "$reason"
  exit 0
}

path="$(json_get .tool_input.file_path)"
[ -z "$path" ] && path="$(json_get .tool_input.notebook_path)"
[ -z "$path" ] && exit 0
name="$(basename "$path")"

case "$name" in
  .env.example|.env.sample|.env.template|.env.dist) exit 0 ;;
  .env|.env.*|*.env)
    decide deny "protect-files: $name holds secrets. Edit .env.example instead and tell the user which variables to set." ;;
  package-lock.json|pnpm-lock.yaml|yarn.lock|bun.lock|bun.lockb|Cargo.lock|poetry.lock|uv.lock|Pipfile.lock|composer.lock|Gemfile.lock|go.sum)
    decide deny "protect-files: $name is generated. Change the manifest and run the package manager instead of editing the lockfile." ;;
  id_rsa|id_ed25519|id_ecdsa|*.pem|*.key|*.p12|*.pfx|credentials.json|service-account*.json)
    decide deny "protect-files: $name looks like a private key or credential file." ;;
esac

case "$path" in
  */.git/*|.git/*)
    decide deny "protect-files: do not edit git internals; use git commands." ;;
  */node_modules/*|*/.venv/*|*/site-packages/*|*/.next/*|*/.nuxt/*|*/.svelte-kit/*)
    decide ask "protect-files: $path is a dependency or build output and will be overwritten. Edit the source instead unless you are sure." ;;
esac

exit 0
