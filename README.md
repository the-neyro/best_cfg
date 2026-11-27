# best_cfg – AI-Coding-Konfiguration

Eine schlanke, harte Konfiguration für Claude Code, Codex, Cursor, Gemini CLI & Co. Ziel: sicherer Code, wenige Fehler und Design, das nie nach generischem AI-Output aussieht.

Grundidee (aus Anthropics offiziellen Best Practices): **kurze Regeln, harte Garantien über Hooks, Wissen in Skills, die nur bei Bedarf laden.** Mehr Text ≠ bessere Ergebnisse.

## Installation
```bash
git clone <dieses-repo> ~/best_cfg && cd ~/best_cfg
./install.sh --dry-run      # zeigt, was passieren würde
./install.sh                # installiert für alle erkannten Tools (Backup unter ~/.ai-config-backup/)
./install.sh --project ~/code/meine-app   # Projektvorlage (überschreibt nichts)
```
Voraussetzungen: `bash`, `jq` (>= 1.6), `python3`, `node` (Windows: WSL oder Git Bash). Danach in Claude Code: `/hooks`, `/agents`, `/context` prüfen, MCP-Server aus [docs/mcp.md](docs/mcp.md) hinzufügen.

## Inhalt
```
core/AGENTS.md          Globale Regeln für ALLE Agenten: Anfragen verstehen (auch diktiert), Zero-Error-Protokoll,
                        Sprache, Security by Default, Anti-AI-Slop-Design, Qualität, Ton
skills/                 Agent Skills (offener Standard) – laufen in Claude Code, Codex, Cursor, Gemini
  design/               Anti-AI-Slop-Design: harte Verbote, 8 Design-Richtungen, Tokens, slop-scan.mjs
  dashboard-design/     Dashboards, KPIs, Charts, Tabellen
  landing-page/         Struktur, Copy, SEO, Performance, Impressum/DSGVO
  visual-qa/            Screenshots 375/768/1440 hell+dunkel, Konsolenfehler, Overflow (shoot.mjs)
  business-apps/        ERP/CRM/Backoffice: Domänenmodell, Geld, Belege, Audit, RBAC, GoBD, DATEV, XRechnung
  secure-coding/        Security by Default: Auth, AuthZ, Uploads, Webhooks, Header, Supply Chain, LLM, DSGVO
  seo-geo/              SEO + GEO (Zitate in ChatGPT, Perplexity, AI Overviews), Audit-Checkliste
  automation/           n8n/Make/Zapier/Code: idempotent, Retries, Dry-Run, Alerting
  reports/              Berichte: Kernaussage zuerst, jede Zahl per Code geprüft, menschlicher Ton
  human-writing/        Texte ohne AI-Floskeln (DE/RU/EN), Liste der AI-Tells
  fact-check/           Jede Zahl, jedes Datum, jede Behauptung verifizieren
  orchestrate/          Multi-Agent-Arbeit: Aufwand skalieren, Briefing-Vorlage, Parallelisierung, Ledger, Rulings
  frontend-engineering/ React/Next-Performance, Interface-Details, PWA/React Native, i18n DE/RU/EN, E-Mail-Templates
  debugging/            Systematisches Debugging: Ursache zuerst, eine Hypothese, failing Test, Stopp nach 3 Fehlversuchen
  verification/         Beweis vor Behauptung: Claim -> Evidence-Tabelle
  payments/             Stripe, Abos, Webhooks idempotent, MwSt./Rechnungen DE/EU, Fehlerpfade
  devops/               Deploy, CI/CD, Docker, Backups mit Restore-Test, Monitoring, EU-Hosting
  ai-features/          LLM-Funktionen in Apps: Evals, Structured Outputs, Prompt-Injection-Schutz, Kosten
  tdd/ spec/ ship/ web-quality/
claude/                 Nur Claude Code
  CLAUDE.md             importiert AGENTS.md + Orchestrator-Regeln
  settings.json         Opus 5.5 + effort high, Permissions, Hooks, Statuszeile
  hooks/                skill-router, guard-bash, secret-scan, protect-files, format-on-edit, statusline
  agents/               architect, implementer, test-writer, debugger, code-reviewer, security-auditor,
                        ui-reviewer, researcher, editor, fact-checker
project-template/       AGENTS.md-Vorlage, CLAUDE.md, Stop-Hook (Typecheck+Lint), Frontend-Regeln, .mcp.json
docs/                   Modelle, Arbeitsweise, MCP, andere Tools
```

## Multi-Agent-Setup
Die Hauptsession ist der **Orchestrator**: kleine Aufgaben selbst, große als Plan (`architect`) → parallele Umsetzung (`implementer` in isolierten Worktrees) → parallele Reviews (`code-reviewer`, `security-auditor`, `ui-reviewer`) → Verifikation. Jede Delegation bekommt ein Briefing mit Ziel, Kontext, Scope, Done-Kriterien und Ausgabeformat. Texte laufen durch `editor` + `fact-checker`. Details: `skills/orchestrate/SKILL.md`.

## Was automatisch passiert (Claude Code)
| Hook | Wirkung |
|---|---|
| skill-router | Erkennt das Thema (RU/DE/EN) und erzwingt den passenden Skill: Design, Frontend, Bugs, ERP/CRM, SEO/GEO, Berichte, Texte, Automatisierung, Security |
| guard-bash | Blockt `rm -rf /`, `curl … \| sh`, Force-Push auf main, `.env` lesen, `chmod 777`; fragt bei `reset --hard`, `--no-verify`, `DROP TABLE`, `publish`, `terraform apply` |
| secret-scan | Blockt Commits mit API-Keys, privaten Schlüsseln, DB-Passwörtern, `.env`-Dateien (+ gitleaks, falls installiert) |
| protect-files | Keine Edits an `.env`, Lockfiles, Schlüsseln, `.git/` |
| format-on-edit | Formatiert mit dem Formatter des Projekts (Biome/Prettier/Ruff/gofmt/rustfmt) |
| verify-on-stop (Projekt) | Typecheck + Lint, bevor Claude „fertig“ sagt |

## Getestet (A/B gegen Claude ohne Konfig)
8 Aufgaben mit gleichem Modell (Opus 5.5): Login-Server, Landingpage, Bericht, Dashboard, ERP-Rechnungsmodul, SEO/GEO-Audit, Über-uns-Text, kleine Umbenennung. Die Konfig gewinnt oder zieht in allen gleich - deutlich bei Design (0 statt 5-15 AI-Slop-Muster), Sicherheit, Testabdeckung und Ehrlichkeit (keine erfundenen Fakten). Preis: große Aufgaben dauern 4-10x länger, weil geprüft, getestet und reviewt wird. Details: [eval/RESULTS-2026-11-27.md](eval/RESULTS-2026-11-27.md), wiederholbar mit `bash eval/run.sh all`.

## Konventionen
- Antworten in der Sprache des Nutzers (Russisch/Deutsch), kurz, mit Humor.
- Code: Bezeichner Englisch; Kommentare, Docstrings, Commits, Doku und Fehlermeldungen **Deutsch**. Komplett deutsche Bezeichner? Eine Zeile in `core/AGENTS.md` → Abschnitt „Language“ ändern.

## Anpassen
- Modell/Effort: `claude/settings.json` → `model`, `modelSettings`. Siehe [docs/models.md](docs/models.md).
- Eigene Regel, die *immer* gelten muss → Hook, nicht Text. Siehe [docs/workflow.md](docs/workflow.md).
- Nach Änderungen erneut `./install.sh` (idempotent, mit Backup).

## Credits
Eigene Texte, inspiriert von und abgeglichen mit: Anthropics offiziellen Claude-Code-Docs und dem `frontend-design`-Skill, [obra/superpowers](https://github.com/obra/superpowers) (MIT – Debugging, Verification, Planung, Review-Umgang), [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) (MIT – React-Performance, Web Interface Guidelines), [trailofbits/skills](https://github.com/trailofbits/skills) (CC-BY-SA-4.0 – Sharp Edges, Insecure Defaults, Supply Chain; Ideen paraphrasiert).
