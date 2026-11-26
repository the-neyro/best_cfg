#!/usr/bin/env bash
# PreToolUse hook for Bash: before `git commit`, scan what is about to be
# committed for secrets and secret files. Denies the commit when it finds one.
# Uses gitleaks too when it is installed. Fails open on parse errors.

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

deny() {
  local reason="${1//\\/\\\\}"
  reason="${reason//\"/\\\"}"
  reason="${reason//$'\n'/ }"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 0
}

cmd="$(json_get .tool_input.command)"
printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit([[:space:]]|$)' || exit 0

cwd="$(json_get .cwd)"
[ -n "$cwd" ] && cd "$cwd" 2>/dev/null
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# What will be committed: staged changes, plus tracked changes when -a/--all is used.
files="$(git diff --cached --name-only 2>/dev/null)"
diff="$(git diff --cached -U0 --no-color 2>/dev/null)"
if printf '%s' "$cmd" | grep -Eq 'commit[^;&|]*[[:space:]](-[a-zA-Z]*a[a-zA-Z]*|--all)([[:space:]]|$)'; then
  files="$files"$'\n'"$(git diff --name-only 2>/dev/null)"
  diff="$diff"$'\n'"$(git diff -U0 --no-color 2>/dev/null)"
fi

# `git add ... && git commit` in one command: the hook runs before `git add`,
# so also scan what that `git add` is about to stage.
addargs="$(printf '%s' "$cmd" | grep -Eo 'git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+add[[:space:]]+[^;&|]*' | sed -E 's/^git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+add[[:space:]]+//')"
if [ -n "$addargs" ]; then
  if printf ' %s ' "$addargs" | grep -Eq '[[:space:]](-A|--all|\.|-u|--update)[[:space:]]'; then
    cand="$(git diff --name-only 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null)"
  else
    cand="$(for a in $addargs; do case "$a" in -*) ;; *) if [ -d "$a" ]; then git ls-files --others --exclude-standard -- "$a"; git diff --name-only -- "$a"; else printf '%s\n' "$a"; fi ;; esac; done 2>/dev/null)"
  fi
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    files="$files"$'\n'"$f"
    if git ls-files --error-unmatch -- "$f" >/dev/null 2>&1; then
      diff="$diff"$'\n'"$(git diff -U0 --no-color -- "$f" 2>/dev/null)"
    elif [ -f "$f" ] && [ "$(wc -c < "$f")" -lt 2000000 ]; then
      diff="$diff"$'\n'"$(sed 's/^/+/' "$f" 2>/dev/null)"
    fi
  done <<EOF_CAND
$cand
EOF_CAND
fi

# 1. Secret files.
bad_file="$(printf '%s\n' "$files" | grep -E '(^|/)(\.env(\.[A-Za-z0-9_-]+)?|id_rsa|id_ed25519|id_ecdsa|[^/]*\.pem|[^/]*\.key|[^/]*\.p12|[^/]*\.pfx|credentials\.json|service-account[^/]*\.json)$' \
  | grep -Ev '\.env\.(example|sample|template|dist)$' | head -n 3)"
if [ -n "$bad_file" ]; then
  deny "secret-scan: refusing to commit secret file(s): $bad_file. Unstage them (git restore --staged <file>) and add them to .gitignore."
fi

# 2. Secret patterns in added lines.
added="$(printf '%s\n' "$diff" | grep -E '^\+' | grep -Ev '^\+\+\+ ')"
patterns='AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|-----BEGIN ([A-Z]+ )?PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{40,}|glpat-[A-Za-z0-9_-]{20,}|sk-ant-[A-Za-z0-9_-]{20,}|sk-(proj-)?[A-Za-z0-9_-]{32,}|(sk|rk)_live_[A-Za-z0-9]{20,}|whsec_[A-Za-z0-9]{20,}|xox[abposr]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|SG\.[A-Za-z0-9_-]{22}\.[A-Za-z0-9_-]{43}|eyJhbGciOi[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}|(postgres(ql)?|mysql|mongodb(\+srv)?|redis|amqp)://[^:/[:space:]]+:[^@/[:space:]]{6,}@'
hit="$(printf '%s\n' "$added" | grep -Eo "$patterns" | head -n 1)"
if [ -n "$hit" ]; then
  masked="$(printf '%s' "$hit" | cut -c1-8)..."
  deny "secret-scan: the staged changes contain what looks like a secret ($masked). Move it to an environment variable / secret manager, rotate it if it was ever pushed, then commit again."
fi

# 3. gitleaks, if available (more rules).
if command -v gitleaks >/dev/null 2>&1; then
  if gitleaks git --help >/dev/null 2>&1; then
    out="$(gitleaks git --pre-commit --staged --no-banner --redact 2>&1)"; rc=$?
  else
    out="$(gitleaks protect --staged --no-banner --redact 2>&1)"; rc=$?
  fi
  if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qi 'leaks found'; then
    deny "secret-scan (gitleaks): $(printf '%s' "$out" | grep -E 'RuleID|File|leaks found' | head -n 6 | tr '\n' ' ')"
  fi
fi

exit 0
