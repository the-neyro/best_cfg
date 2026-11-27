#!/usr/bin/env bash
# UserPromptSubmit hook: detects the topic of a prompt (Russian / German / English)
# and injects which skills and rules must be applied - so the right skill loads
# every time, deterministically. Never blocks.

input="$(cat)"

prompt=""
if command -v jq >/dev/null 2>&1; then
  prompt="$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null)"
elif command -v python3 >/dev/null 2>&1; then
  prompt="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("prompt",""))' 2>/dev/null)"
fi
[ -z "$prompt" ] && exit 0

if command -v python3 >/dev/null 2>&1; then
  lower="$(printf '%s' "$prompt" | python3 -c 'import sys; print(sys.stdin.read().lower())')"
else
  lower="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"
fi

# Regex match; Python handles Cyrillic word boundaries correctly, grep is the fallback.
if command -v python3 >/dev/null 2>&1; then
  has() { printf '%s' "$lower" | python3 -c 'import re,sys; sys.exit(0 if re.search(sys.argv[1], sys.stdin.read()) else 1)' "$1"; }
else
  has() { printf '%s' "$lower" | grep -Eq "$1"; }
fi
ctx=""
add() { ctx="${ctx}${ctx:+ }$1"; }

if has 'design|дизайн|редизайн|(^|[^a-z])u[ix]([^a-z]|$)|interface|интерфейс|oberfläche|gestalt|layout|вёрст|верст|лендинг|лендос|визитк|landing|startseite|portfolio|портфолио|(сделай|создай|сверстай|переделай|нарисуй|build|create|make|design|erstell|bau|gestalte|mach).{0,40}(сайт|website|webseite|homepage|seite|page|app|приложени|страниц|экран|screen)|dashboard|дашборд|дэшборд|frontend|фронтенд|component|компонент|komponente|tailwind|(^|[^a-z])css|макет|mockup|figma|экран|bildschirm|красив|schön|premium|премиум'; then
  add "[design] Load and follow the \`design\` skill (plus \`dashboard-design\` / \`landing-page\` if relevant). Hard bans unless explicitly requested: no content boxed in bordered cards, radius 0-4px, no decorative shadows or borders, no icons in colored tiles, no decorative icons/emoji, no purple/blue gradients, gradient text or glassmorphism, no template layouts, no unstyled shadcn/library defaults. Show the design plan first; finish with slop-scan and visual-qa screenshots (ui-reviewer for client-facing pages or a new design direction)."
fi
if has 'pwa|mobile app|мобильн|react native|expo|i18n|übersetz|перевод интерфейс|mehrsprachig|мультиязыч|email.?template|e-?mail-?vorlage|шаблон письм|react|next\.?js|(^|[^a-z])vue|svelte|frontend|фронтенд|component|компонент|komponente|(^|[^a-z])form([^a-z]|$)|форм[аыу]|formular|hydration|re-?render|bundle|playwright'; then
  add "[frontend-engineering] Apply the \`frontend-engineering\` skill: no waterfalls (Promise.all), small client bundles (Server Components, dynamic imports), no derived state in effects, interface details (forms, focus-visible, URL state, typography, reduced motion)."
fi
if has '(^|[^a-z])bug|баг|ошибк|не работает|не грузит|не открывает|не запускает|белый экран|ничего не делает|не реагирует|не срабатывает|reagiert nicht|passiert nichts|does nothing|not responding|вылета|зависа|глючит|stürzt|absturz|hängt|freez|сломал|fehler|funktioniert nicht|geht nicht|lädt nicht|weiße seite|kaputt|crash|exception|(^|[^a-z])error|throws|stack ?trace|failing|падает|flaky|regression|white screen|does(n.t| not) (work|load)'; then
  add "[debugging] Use the \`debugging\` skill: reproduce, find the root cause before any fix, one hypothesis at a time, failing test first; after 3 failed fixes stop and rethink. Delegate to \`debugger\` if the cause is not obvious."
fi
if has '(^|[^a-z])(erp|crm)([^a-z]|$)|склад|lager|warenwirtschaft|инвойс|rechnung|счёт-фактур|бухгалтер|buchhaltung|faktur|aufträge|заказ|back.?office|admin.?panel|админк|internal tool|b2b|kundenverwaltung|учёт|учет|warehouse|inventory|invoice|datev|xrechnung|zugferd'; then
  add "[business-apps] Load the \`business-apps\` skill (and \`orchestrate\` for a full system): model the domain first, money as integers/decimal, immutable numbered documents, audit log, RBAC, multi-tenant isolation, GoBD/DATEV/XRechnung for Germany, power-user UX. Start with \`architect\` and a spec."
fi
if has '(^|[^a-z])(seo|geo|aeo|llmo)([^a-z]|$)|сео|гео|ki-suche|индексир|блог|(^|[^a-z])blog|ai[- ]search|ии-поиск|нейропоиск|findbar|gefunden werden|(für|in|bei) google|в гугл|(optimier|оптимизир).{0,40}(seite|website|сайт|google)|ранжир|ranking|sichtbarkeit|suchmaschin|search engine|поисков|ai overview|perplexity|chatgpt (findet|finds|находит)|keyword|ключев(ые|ых) слов|schema\.org|sitemap|indexier|индексац'; then
  add "[seo-geo] Load the \`seo-geo\` skill: audit first, technical foundation (SSR content, robots incl. AI retrieval bots, sitemap, schema, hreflang), answer-first specific content, entity consistency, measurement of AI citations."
fi
if has 'отчёт|отчет|репорт|report|bericht|auswertung|сводк|summary|zusammenfassung|memo|präsentation|презентац|analyse|аналитик'; then
  add "[reports] Load the \`reports\` skill: bottom line first, every number computed with code and traced to a source, human conversational-professional style. Verify every figure against the data; for client-facing reports finish with \`editor\` + \`fact-checker\`."
fi
if has 'текст|напиши|перепиши|очелов|статья|статью|статьи|пост(а|ы)?([^a-z]|$)|письм|(e-?mail|mail) an |email to |newsletter an|schreib|umschreib|artikel|beitrag|copy|humani[sz]e|рассылк|newsletter|beschreibung|описани|презентац|präsentation|presentation|slides|(^|[^a-z])deck'; then
  add "[writing] Load the \`human-writing\` skill: point first, concrete, varied rhythm, native typography, no AI tells or filler. Verify facts with \`fact-check\` for anything published or sent."
fi
if has 'автоматиз|automati|n8n|zapier|(^|[^a-z])make\.com|webhook|вебхук|интеграц|integration|cron|(^|[^а-яёa-z])бот(а|ы|ов|у)?([^а-яё]|$)|телеграм|telegram|(^|[^a-z])bot([^a-z]|$)|parser|парсер|scraper|скрапер|(^|[^a-z])etl|(^|[^a-z])sync|синхрон|workflow'; then
  add "[automation] Load the \`automation\` skill: idempotent, retries with backoff, checkpoints, dry-run first, schema validation, alerting, secrets in a vault, GDPR-compliant processors."
fi
if has 'stripe|страйп|оплат|платеж|платёж|подписк|checkout|payment|zahlung|bezahl|(^|[^a-z])abo([^a-z]|$)|abonnement|billing|subscription|sepa|paypal|refund|возврат денег'; then
  add "[payments] Load the \`payments\` skill: hosted Checkout/Portal, fulfil only from verified idempotent webhooks, amounts as integers, never from the client, VAT/invoice rules for DE/EU, design failure paths."
fi
if has 'deploy|деплой|задеплой|hosting|хостинг|docker|(^|[^a-z])ci([^a-z]|$)|github actions|pipeline|backup|бэкап|бекап|monitoring|мониторинг|(^|[^a-z])logs?([^a-z]|$)|логи|production|продакшен|прод([^а-яё]|$)|go live|hetzner|vercel|ssl|домен'; then
  add "[devops] Load the \`devops\` skill: reproducible builds, CI gates, safe migrations, encrypted off-site backups with restore tests, monitoring and alerts, EU hosting."
fi
if has '(^|[^a-z])ai([^a-z]|$)|(^|[^а-яё])ии([^а-яё]|$)|нейросет|(^|[^a-z])ki([^a-z]|$)|llm|gpt|claude api|chat-?bot|чат-?бот|(^|[^a-z])rag([^a-z]|$)|embedding|prompt'; then
  add "[ai-features] Load the \`ai-features\` skill (and \`claude-api\` if available): simplest tier first, eval set before prompt tuning, structured outputs validated, prompt-injection defenses, cost caps."
fi
if has 'auth|login|логин|spam|спам|(^|[^a-z])sicher|безопасн|регистрац|registrier|anmeld|sign.?up|signup|kundenportal|личный кабинет|кабинет клиента|passwor|парол|session|сесси|token|токен|oauth|security|безопасн|sicherheit|uploads?|загрузк|payment|оплат|zahlung|stripe|webhook|admin|роль|rolle|permission|доступ|dsgvo|gdpr'; then
  add "[security] Apply the \`secure-coding\` skill; risk tier 2: \`code-reviewer\` + \`security-auditor\` before finishing."
fi

[ -z "$ctx" ] && exit 0

if command -v jq >/dev/null 2>&1; then
  jq -nc --arg c "Skill router: $ctx" '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$c}}'
else
  python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"Skill router: "+sys.argv[1]}}))' "$ctx"
fi
exit 0
