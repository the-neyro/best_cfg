# Andere Agenten (Codex, Cursor, Gemini CLI, Copilot …)

Die Konfig ist in zwei Schichten gebaut:

1. **Universell** – funktioniert in jedem Agenten:
   - `core/AGENTS.md` → globale Regeln (Sprache, Sicherheit, Design, Qualität, Ton).
   - `skills/` → Agent Skills nach offenem Standard (`SKILL.md`), installiert nach `~/.agents/skills/`.
   - `project-template/AGENTS.md` → Projektregeln; der De-facto-Standard, den Codex, Cursor, Gemini CLI, Copilot, Windsurf u. a. lesen.
2. **Claude-Code-spezifisch** – Hooks, Subagents, Permissions in `claude/`. Das sind die *harten* Garantien (blockierte Befehle, Secret-Scan, Auto-Format, Design-Trigger), die andere Tools so nicht haben.

| Tool | Globale Regeln | Skills | Projektregeln |
|---|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` → importiert `~/.claude/AGENTS.md` | `~/.claude/skills/` | `CLAUDE.md` (importiert `AGENTS.md`) |
| Codex | `~/.codex/AGENTS.md` | `~/.agents/skills/` | `AGENTS.md` |
| Gemini CLI | `~/.gemini/GEMINI.md` | `~/.agents/skills/` | `GEMINI.md` oder `AGENTS.md` (über `contextFileName` in `~/.gemini/settings.json`) |
| Cursor | Settings → Rules → User Rules (Inhalt von `core/AGENTS.md` einfügen) | `.agents/skills/` im Projekt | `AGENTS.md` |
| Copilot | – | je nach Version | `AGENTS.md` / `.github/copilot-instructions.md` |

`./install.sh` erkennt installierte Tools und legt die Dateien an die richtigen Stellen. Pfade ändern sich bei diesen Tools schnell – im Zweifel deren aktuelle Doku prüfen.

## Was in anderen Tools fehlt und wie man es ersetzt
- **Secret-Scan**: `gitleaks` als Git-Pre-commit-Hook installieren – greift dann für jeden Agenten und Menschen.
- **Format on save**: Formatter (Prettier/Biome/Ruff) über die Projekt-Skripte oder `lint-staged` + `husky`.
- **Prüfung vor „fertig“**: Typecheck/Lint/Test im CI erzwingen – das ist die einzige Garantie, die toolunabhängig gilt.
