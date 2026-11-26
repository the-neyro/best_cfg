#!/usr/bin/env bash
# UserPromptSubmit hook: when the prompt is about design/UI (Russian, German or
# English), inject a reminder so the agent always loads the `design` skill and
# its anti-slop rules. Never blocks.

input="$(cat)"

prompt=""
if command -v jq >/dev/null 2>&1; then
  prompt="$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null)"
elif command -v python3 >/dev/null 2>&1; then
  prompt="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("prompt",""))' 2>/dev/null)"
fi
[ -z "$prompt" ] && exit 0

# Lowercase including Cyrillic and umlauts.
if command -v python3 >/dev/null 2>&1; then
  lower="$(printf '%s' "$prompt" | python3 -c 'import sys; print(sys.stdin.read().lower())')"
else
  lower="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"
fi

pattern='design|дизайн|редизайн|(^|[^a-z])u[ix]([^a-z]|$)|interface|интерфейс|oberfläche|gestalt|layout|вёрст|верст|лендинг|landing|website|webseite|сайт|homepage|startseite|dashboard|дашборд|дэшборд|frontend|фронтенд|component|компонент|komponente|tailwind|css|макет|mockup|figma|screen|экран|bildschirm|hero|navbar|kachel|карточк|button|кнопк|schaltfläche|красив|schön|premium|премиум'

if printf '%s' "$lower" | grep -Eq "$pattern"; then
  cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"Design/UI request detected. Load and follow the `design` skill before writing any UI (plus `dashboard-design` or `landing-page` if relevant). Hard bans unless the user explicitly asks otherwise: no content boxed in bordered cards, radius 0-4px by default, no decorative shadows, no decorative borders, no icons in colored rounded tiles and no decorative icons/emoji, no purple/blue gradients, gradient text or glassmorphism, no template layouts, no unstyled shadcn/library defaults. Show the design plan (direction, palette, type, grid, signature moment) before building. Finish with slop-scan and visual-qa screenshots."}}
JSON
fi
exit 0
