#!/usr/bin/env bash
# Notification hook: desktop notification when Claude Code needs you
# (permission prompt, waiting for input). macOS, Linux, WSL; silent fallback.

input="$(cat)"
msg=""
if command -v jq >/dev/null 2>&1; then
  msg="$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null)"
elif command -v python3 >/dev/null 2>&1; then
  msg="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("message",""))' 2>/dev/null)"
fi
[ -z "$msg" ] && msg="Claude Code wartet auf dich"
msg="$(printf '%s' "$msg" | tr -d '"\\' | cut -c1-180)"
title="Claude Code"

if command -v osascript >/dev/null 2>&1; then
  osascript -e "display notification \"$msg\" with title \"$title\" sound name \"Glass\"" >/dev/null 2>&1
elif command -v notify-send >/dev/null 2>&1; then
  notify-send -a "$title" "$title" "$msg" >/dev/null 2>&1
elif command -v powershell.exe >/dev/null 2>&1; then
  powershell.exe -NoProfile -Command "[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); \$n=New-Object System.Windows.Forms.NotifyIcon; \$n.Icon=[System.Drawing.SystemIcons]::Information; \$n.Visible=\$true; \$n.ShowBalloonTip(5000,'$title','$msg','Info'); Start-Sleep -s 6; \$n.Dispose()" >/dev/null 2>&1 &
else
  { printf '\a' > /dev/tty; } 2>/dev/null
fi
exit 0
