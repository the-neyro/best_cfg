#!/usr/bin/env bash
# Checks the skill router against labelled phrases (RU/DE/EN).
# usage: bash eval/router-test.sh [file.tsv ...]   (default: all sets in eval/data/router)
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
files="$*"; [ -n "$files" ] || files="$REPO/eval/data/router/"*.tsv
total_ok=0; total=0
for f in $files; do
  ok=0; n=0
  while IFS=$'\t' read -r p exp; do
    n=$((n+1))
    got=$(jq -nc --arg p "$p" '{prompt:$p}' | bash "$REPO/claude/hooks/skill-router.sh" | jq -r '.hookSpecificOutput.additionalContext' 2>/dev/null | grep -o '\[[a-z-]*\]' | tr -d '[]' | tr '\n' ',' | sed 's/,$//')
    [ -z "$got" ] && got="-"
    miss=""
    if [ "$exp" = "-" ]; then [ "$got" = "-" ] || miss="FALSE+"
    else for e in ${exp//,/ }; do echo ",$got," | grep -q ",$e," || miss="$miss miss:$e"; done; fi
    if [ -z "$miss" ]; then ok=$((ok+1)); else printf '  %-55.55s got=%s %s\n' "$p" "$got" "$miss"; fi
  done < "$f"
  echo "$(basename "$f"): $ok/$n"; total_ok=$((total_ok+ok)); total=$((total+n))
done
echo "TOTAL $total_ok/$total"
[ "$total_ok" -eq "$total" ]
