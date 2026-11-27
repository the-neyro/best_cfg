#!/usr/bin/env bash
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Scores the A/B eval outputs.
E="${EVAL_DIR:-$HOME/eval-run}"
SLOP=$REPO/skills/design/scripts/slop-scan.mjs

echo "===== LANDING: slop-scan ====="
for v in cfg base; do
  f="$E/$v-landing/index.html"
  [ -f "$f" ] || { echo "$v: no index.html"; continue; }
  printf '%s: ' "$v"; node "$SLOP" "$f" --max 0 | grep -E '^\[|finding|No slop' | tr '\n' ' '; echo
  printf '   radius>md: %s  shadow: %s  border: %s  icons(svg/i): %s  lines: %s\n' \
    "$(grep -oE 'rounded-(lg|xl|2xl|3xl|full)' "$f" | wc -l)" "$(grep -oE 'shadow(-[a-z0-9]+)?' "$f" | wc -l)" \
    "$(grep -oE '(^|[" ])border([" ]|-[a-z0-9])' "$f" | wc -l)" "$(grep -oE '<svg|<i class' "$f" | wc -l)" "$(wc -l < "$f")"
done

echo; echo "===== REPORT: numbers & AI tells ====="
for v in cfg base; do
  f="$(ls "$E/$v-report/"*.md 2>/dev/null | grep -v -E 'CLAUDE|AGENTS' | head -1)"
  [ -n "$f" ] || { echo "$v: no report"; continue; }
  hits=0
  for n in '508[.,  ]?200' '490[.,  ]?200' '18[.,  ]?000' '324' '157[.,  ]?100' '154[.,  ]?300' '178[.,  ]?800' '294[.,  ]?500'; do
    grep -Eq "$n" "$f" && hits=$((hits+1))
  done
  tells=$(grep -oiE 'nahtlos|maßgeschneidert|ganzheitlich|zukunftsweisend|wegweisend|spannend|eintauchen|Mehrwert([^s]|$)|zusammenfassend lässt sich|es ist wichtig zu beachten|im folgenden|spielt eine entscheidende rolle|in der heutigen' "$f" | wc -l)
  printf '%s: file=%s words=%s key-numbers-found=%s/8 ai-tells=%s em-dashes=%s\n' "$v" "$(basename "$f")" "$(wc -w < "$f")" "$hits" "$tells" "$(grep -o '—' "$f" | wc -l)"
done

echo; echo "===== AUTH: security checklist ====="
chk() { grep -Eqi "$2" $1 && printf '✓' || printf '✗'; }
for v in cfg base; do
  d="$E/$v-auth"; files="$(ls $d/*.js $d/src/*.js $d/*.ts 2>/dev/null | tr '\n' ' ')"
  [ -n "$files" ] || { echo "$v: no code"; continue; }
  printf '%s: hash(argon2/bcrypt/scrypt)%s ratelimit%s helmet/headers%s validation(zod/joi/express-validator)%s cookie-httpOnly%s secure-flag%s sameSite%s csrf%s secret-from-env%s param-SQL%s generic-auth-error%s\n' "$v" \
    "$(chk "$files" 'argon2|bcrypt|scrypt')" "$(chk "$files" 'rate.?limit|express-rate-limit|slow.?down')" \
    "$(chk "$files" 'helmet|Content-Security-Policy|Strict-Transport')" "$(chk "$files" 'zod|joi|express-validator|valibot|yup')" \
    "$(chk "$files" 'httpOnly')" "$(chk "$files" 'secure[[:space:]]*:')" "$(chk "$files" 'sameSite')" "$(chk "$files" 'csrf|csurf|origin.*check|x-csrf')" \
    "$(chk "$files" 'process\.env\.[A-Z_]*(SECRET|KEY)')" "$(chk "$files" '\?|\$[a-z0-9]+|prepare\(')" "$(chk "$files" 'invalid (email or password|credentials)|ungültig|falsch')"
  grep -nE "(secret|password|key)[[:space:]]*[:=][[:space:]]*['\"][^'\"]{6,}['\"]" $files | grep -viE 'process\.env|example|test' | head -2 | sed "s/^/   hardcoded? /"
done
