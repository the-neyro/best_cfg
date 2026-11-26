#!/usr/bin/env bash
# PreToolUse hook for Bash: blocks catastrophic commands, asks before risky ones.
# Input: hook JSON on stdin. Output: a permission decision as JSON (exit 0).
# Fails open (allows) if it cannot parse the input, so it never bricks a session.

input="$(cat)"

json_get() { # $1 = jq path, e.g. .tool_input.command
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

decide() { # $1 = deny|ask, $2 = reason
  local reason="${2//\\/\\\\}"
  reason="${reason//\"/\\\"}"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' "$1" "$reason"
  exit 0
}

cmd="$(json_get .tool_input.command)"
[ -z "$cmd" ] && exit 0

# Normalise whitespace for matching.
c="$(printf '%s' "$cmd" | tr '\n\t' '  ' | tr -s ' ')"

# --- Hard blocks: never useful for an agent, catastrophic if wrong -------------
if printf '%s' "$c" | grep -Eq '(^|[;&|[:space:]])(sudo[[:space:]]+)?rm[[:space:]]+(-[a-zA-Z]*[rR][a-zA-Z]*[fF]?|-[a-zA-Z]*[fF][a-zA-Z]*[rR]|--recursive|--force)([[:space:]]+-[^[:space:]]+)*[[:space:]]+("|'"'"')?(/|/\*|~|~/|~/\*|\$HOME|\$HOME/|\$HOME/\*|\.\.?|\.\./?\*?|\*)("|'"'"')?([[:space:]]|$|;|&)'; then
  decide deny "Blocked by guard-bash: recursive delete of /, ~, \$HOME, . or a bare wildcard. Delete specific paths instead."
fi
if printf '%s' "$c" | grep -Eq '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba|z|da)?sh([[:space:]]|$)'; then
  decide deny "Blocked by guard-bash: piping a downloaded script into a shell. Download it, read it, then run it explicitly."
fi
if printf '%s' "$c" | grep -Eq '(^|[;&|[:space:]])(mkfs(\.[a-z0-9]+)?|fdisk|parted)[[:space:]]|dd[[:space:]].*of=/dev/|>[[:space:]]*/dev/(sd|nvme|disk)'; then
  decide deny "Blocked by guard-bash: raw disk / filesystem operation."
fi
if printf '%s' "$c" | grep -Eq 'chmod[[:space:]]+(-R[[:space:]]+)?0?777'; then
  decide deny "Blocked by guard-bash: chmod 777. Use the narrowest permission that works (e.g. 755 / 644 / u+x)."
fi
if printf '%s' "$c" | grep -Eq ':\(\)[[:space:]]*\{[[:space:]]*:[[:space:]]*\|[[:space:]]*:'; then
  decide deny "Blocked by guard-bash: fork bomb."
fi
if printf '%s' "$c" | grep -Eq 'git[[:space:]]+push([[:space:]]+[^;&|]*)?[[:space:]](-f|--force)([[:space:]]|$)' &&
   printf '%s' "$c" | grep -Eq '(^|[[:space:]:/])(main|master|production|prod|release)([[:space:]]|$)'; then
  decide deny "Blocked by guard-bash: force-push to a protected branch."
fi
if printf '%s' "$c" | grep -Eq '(^|[;&|[:space:]])(cat|less|more|head|tail|bat|strings|xxd)[[:space:]]+[^;&|]*\.env(\.[A-Za-z0-9_-]+)?([[:space:]]|$)' &&
   ! printf '%s' "$c" | grep -Eq '\.env\.(example|sample|template|dist)'; then
  decide deny "Blocked by guard-bash: reading a .env file would put secrets into the transcript. Use .env.example or ask the user."
fi

# --- Ask first: legitimate sometimes, destructive if done by accident ----------
if printf '%s' "$c" | grep -Eq 'git[[:space:]]+push([[:space:]]+[^;&|]*)?[[:space:]](-f|--force|--force-with-lease)'; then
  decide ask "Force-push rewrites remote history. Confirm this is intended."
fi
if printf '%s' "$c" | grep -Eq 'git[[:space:]]+(reset[[:space:]]+--hard|clean[[:space:]]+-[a-zA-Z]*f|checkout[[:space:]]+--[[:space:]]+\.|restore[[:space:]]+\.|stash[[:space:]]+(drop|clear)|branch[[:space:]]+-D)'; then
  decide ask "This git command discards uncommitted work or branches. Confirm."
fi
if printf '%s' "$c" | grep -Eq 'git[[:space:]]+commit[^;&|]*--no-verify|git[[:space:]]+push[^;&|]*--no-verify'; then
  decide ask "--no-verify skips the repo's hooks (lint/tests). Confirm."
fi
if printf '%s' "$c" | grep -Eiq '(drop[[:space:]]+(database|schema|table)|truncate[[:space:]]+table|delete[[:space:]]+from[[:space:]]+[a-z_."]+[[:space:]]*(;|$|"))'; then
  decide ask "Destructive SQL statement. Confirm the target database is not production."
fi
if printf '%s' "$c" | grep -Eq '(^|[;&|[:space:]])(npm|pnpm|yarn|bun)[[:space:]]+publish|cargo[[:space:]]+publish|twine[[:space:]]+upload|(^|[;&|[:space:]])(vercel|netlify)[[:space:]].*--prod|terraform[[:space:]]+(apply|destroy)|kubectl[[:space:]]+(delete|apply)'; then
  decide ask "This publishes or changes live infrastructure. Confirm."
fi

exit 0
