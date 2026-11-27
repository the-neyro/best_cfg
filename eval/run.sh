#!/usr/bin/env bash
# A/B eval: same prompt, same model, with config (cfg) vs without (base).
# Runs in batches: one task = a cfg+base pair in parallel.
#   bash eval/run.sh landing report        # selected tasks
#   bash eval/run.sh all                   # every task, one batch after another
# Results: $EVAL_DIR/<variant>-<task>/, logs $EVAL_DIR/<variant>-<task>.log,
# timings and limit hits in $EVAL_DIR/status.txt.
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
E="${EVAL_DIR:-$HOME/eval-run}"
MODEL="${EVAL_MODEL:-opus}"
TIMEOUT="${EVAL_TIMEOUT:-1800}"
mkdir -p "$E/home-cfg" "$E/home-base"
HOME="$E/home-cfg" "$REPO/install.sh" --all >/dev/null 2>&1

declare -A P
P[landing]='Сделай лендинг для немецкой юридической фирмы «Keller & Brandt Rechtsanwälte» (Arbeitsrecht, München). Один файл index.html, без сборки, можно Tailwind через CDN. Тексты на немецком. Сделай реально круто.'
P[report]='В файле sales_q3.csv данные продаж за Q3. Напиши отчёт для директора на немецком в файл bericht.md. Коротко и по делу.'
P[auth]='Напиши на Node.js (Express) сервер с регистрацией и логином пользователей в один файл server.js плюс package.json. Пользователей храни в SQLite. Сделай production-ready.'
P[dashboard]='Сделай дашборд продаж для интернет-магазина велосипедов: один файл dashboard.html, без внешних CDN и библиотек (всё инлайн, графики на SVG/Canvas), реалистичные данные за 12 месяцев захардкодь. Интерфейс на немецком. Чтобы директор за 5 секунд понял, как дела.'
P[erp]='Сделай модуль счетов (Rechnungen) для нашей ERP: Node.js + TypeScript + SQLite (better-sqlite3). Создание счёта с позициями, НДС 19 % и 7 %, сквозная нумерация RE-2026-00001, сторно (Storno/Gutschrift) вместо удаления, расчёт сумм. Сервисный слой + тесты (vitest). Должно работать.'
P[seo]='Вот наш сайт (index.html, app.js, robots.txt). Проведи SEO и GEO аудит (чтобы нас находили Google и ИИ-поисковики вроде ChatGPT и Perplexity), запиши результат в audit.md с приоритетами и сразу исправь файлы.'
P[text]='Напиши текст для страницы «О нас» на русском для немецкой IT-компании WerkstattCRM: мы делаем CRM для автосервисов (запись клиентов, заказ-наряды, счета), команда 12 человек из Мюнхена, работаем с 2019 года, 340 автосервисов-клиентов. Человеческим языком, файл about.md.'
TASKS_ALL="landing report auth dashboard erp seo text"

run_one() { # variant task
  local v="$1" t="$2" d="$E/$1-$2" start end
  rm -rf "$d"; mkdir -p "$d"; cd "$d" || return
  git init -q
  case "$t" in
    report) cp "$REPO/eval/data/sales_q3.csv" . ;;
    seo) cp "$REPO/eval/data/seo-site/"* . ;;
  esac
  git add -A >/dev/null 2>&1; git -c user.email=eval@local -c user.name=eval commit -qm init >/dev/null 2>&1
  [ "$v" = cfg ] && HOME="$E/home-cfg" "$REPO/install.sh" --project "$d" >/dev/null 2>&1
  start=$(date +%s)
  HOME="$E/home-$v" timeout "$TIMEOUT" claude -p "${P[$t]}" --model "$MODEL" \
    --allowedTools "Read" "Write" "Edit" "Glob" "Grep" "Bash" "Agent" "Skill" "WebSearch" "WebFetch" \
    < /dev/null > "$E/$v-$t.log" 2>&1
  local rc=$?; end=$(date +%s)
  local lim=""
  # Only real CLI/API limit errors, not the words "rate limit" inside an answer.
  if [ "$rc" -ne 0 ] || [ "$(wc -c < "$E/$v-$t.log")" -lt 400 ]; then
    grep -qiE 'usage limit|limit reached|limit will reset|rate_limit_error|overloaded_error|(^|[^0-9])429([^0-9]|$)|credit balance' "$E/$v-$t.log" && lim=" LIMIT_SIGNAL"
  fi
  echo "done $v-$t exit=$rc seconds=$((end-start))$lim" >> "$E/status.txt"
}

tasks="$*"; [ -z "$tasks" ] || [ "$tasks" = all ] && tasks="$TASKS_ALL"
for t in $tasks; do
  [ -n "${P[$t]}" ] || { echo "unknown task: $t" >&2; continue; }
  run_one cfg "$t" & run_one base "$t" & wait
  if grep -q "LIMIT_SIGNAL" "$E/status.txt" 2>/dev/null; then echo "LIMIT_STOP after $t" >> "$E/status.txt"; break; fi
done
echo "BATCH_DONE $tasks" >> "$E/status.txt"
