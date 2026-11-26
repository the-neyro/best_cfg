# MCP-Server und Plugins

Jeder MCP-Server bringt Tools mit, zwischen denen das Modell wählen muss, und kostet Kontext. Deshalb: **wenige, aber starke.**

| Server | Wozu | Installation (Claude Code, global) |
|---|---|---|
| Playwright | Agent sieht und bedient den Browser (Screenshots, Konsole) | `claude mcp add --scope user playwright -- npx -y @playwright/mcp@latest` |
| Context7 | Aktuelle Library-Doku statt Trainingswissen | `claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp` |
| Figma | Designs aus Figma lesen/schreiben | `claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp` (danach `/mcp` → anmelden) |
| GitHub | PRs/Issues – nur wenn nötig | offizielles Plugin/Connector oder `gh` CLI |

Prüfen: `/mcp` – alle Server `connected`. Für Teams liegt `project-template/.mcp.json` bereit.

Codex: `codex mcp add playwright -- npx -y @playwright/mcp@latest` (analog für Context7).

## Plugins
`/plugin` öffnet den offiziellen Marketplace. Optional interessant: **frontend-design** (Anthropics Design-Skill) – überschneidet sich mit `design` aus dieser Konfig, also nur eines von beiden aktiv nutzen.

## Finger weg
- Riesige Sammlungen mit hunderten Agents/Skills – blähen den Kontext auf, die Qualität sinkt eher.
- MCP-Server mit Schreibzugriff auf Produktionsdaten oder Geld ohne Read-only-Modus.
- Ungeprüfte MCP-Server aus beliebigen Repos – das ist fremder Code mit deinen Rechten.
