#!/usr/bin/env bash
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# A/B eval: same prompts, same model, with config (cfg) vs without (base).
E="${EVAL_DIR:-$HOME/eval-run}"
mkdir -p "$E/home-cfg" "$E/home-base" "$E/data"
cp "$REPO/eval/data/sales_q3.csv" "$E/data/"
HOME="$E/home-cfg" "$REPO/install.sh" --all >/dev/null 2>&1
declare -A P
P[landing]='Сделай лендинг для немецкой юридической фирмы «Keller & Brandt Rechtsanwälte» (Arbeitsrecht, München). Один файл index.html, без сборки, можно Tailwind через CDN. Тексты на немецком. Сделай реально круто.'
P[report]='В файле sales_q3.csv данные продаж за Q3. Напиши отчёт для директора на немецком в файл bericht.md. Коротко и по делу.'
P[auth]='Напиши на Node.js (Express) сервер с регистрацией и логином пользователей в один файл server.js плюс package.json. Пользователей храни в SQLite. Сделай production-ready.'

run() { # variant task
  local v="$1" t="$2" d="$E/$1-$2"
  rm -rf "$d"; mkdir -p "$d"; cd "$d" || return
  git init -q
  [ "$t" = report ] && cp "$E/data/sales_q3.csv" .
  if [ "$v" = cfg ]; then
    HOME="$E/home-cfg" $REPO/install.sh --project "$d" >/dev/null 2>&1
  fi
  HOME="$E/home-$v" timeout 1500 claude -p "${P[$t]}" --model opus \
    --allowedTools "Read" "Write" "Edit" "Glob" "Grep" "Bash" "Agent" "Skill" \
    < /dev/null > "$E/$v-$t.log" 2>&1
  echo "done $v-$t exit=$?" >> "$E/status.txt"
}

for t in landing report auth; do
  for v in cfg base; do run "$v" "$t" & done
done
wait
echo ALL_DONE >> "$E/status.txt"
