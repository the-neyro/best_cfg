# Modell- und Effort-Wahl

Stand: November 2026. Preise pro 1 Mio. Token über die API (Input / Output). Im Abo (Pro/Max) zahlst du mit Limits statt Geld – die Verhältnisse bleiben gleich.

| Modell | Alias | API-Preis | Wofür |
|---|---|---|---|
| **Claude Fable 5.2** | `fable` | $8 / $40 | Das stärkste Modell. Harte Architekturfragen, Bugs, die niemand findet, lange autonome Aufgaben, Security-Audits. |
| **Claude Opus 5.5** | `opus` | $4 / $20 | **Standard in dieser Konfig.** Fast alle ernsthafte Arbeit: Features, Design, Reviews. |
| **Claude Sonnet 5.5** | `sonnet` | $2 / $10 | Routine: kleine Änderungen, Tests, einfache Features, Subagents. |
| **Claude Haiku 5.5** | `haiku` | $0.10 / $0.50 | Triviales: Suchen, Zusammenfassen, billige Subagents. Nicht für Design. |

`opusplan` = Opus plant (Plan Mode), Sonnet setzt um – spart Limit bei großen Aufgaben.

## Effort

Effort ist der wichtigste Qualitätshebel – wichtiger als „denk gründlich nach“ im Prompt (das wirkt kaum noch).

| Stufe | Wann |
|---|---|
| `low` | Schnelles Hin und Her, Entwürfe |
| `medium` | Default von Opus 5.5 / Sonnet 5.5 / Fable 5.2, klar umrissene Features |
| `high` | **In dieser Konfig gesetzt.** Bugs, fremder Code, Randfälle – weniger Fehler |
| `xhigh` | Flaky Tests, Schema-Migrationen, komplexe Logik |
| `max` | Nur für echt harte Probleme (Schwachstellensuche); sonst Overthinking |

Bedienung: `/effort high`, `/model fable`, und `ultrathink` im Prompt für einen einzelnen tiefen Durchgang.

## Rezepte
- **Normaler Tag**: `opus` + `high` (Default).
- **Limit sparen**: `opusplan` oder `sonnet` + `medium`, an kniffligen Stellen `ultrathink`.
- **Festgefahren / Architektur / großer Umbau**: `/model fable`, Effort `high`.
- **Premium-Design**: `opus` oder `fable` + `high`. Geschmack skaliert mit dem Modell.

## Gemessen (27.11.2026)
Mit Konfig (opus, high) dauerten große Aufgaben 4-10x länger als Opus ohne Konfig, kleine etwa 2x - dafür mit Tests, Reviews und Fact-Check, deutlich weniger generischem Design und weniger erfundenen Fakten. Empfehlung: high als Standard behalten; beim schnellen Iterieren an Entwürfen `/effort medium`, für triviale Massenaufgaben `/model sonnet`.

## Subagents dieser Konfig
| Agent | Modell | Grund |
|---|---|---|
| architect, debugger | opus, xhigh | Planung und Ursachensuche sind die denkintensivsten Aufgaben |
| implementer | opus, high | Baut ein Arbeitspaket, oft mehrere parallel in Worktrees |
| code-reviewer, security-auditor, ui-reviewer | opus, high | Hier spart man nicht – verpasste Bugs und Lücken kosten mehr |
| editor, fact-checker | opus, high | Texte und Zahlen müssen stimmen und menschlich klingen |
| test-writer | sonnet, high | Tests nach Vorlage kann Sonnet sehr gut |
| researcher | sonnet, medium | Doku suchen und zusammenfassen |

Ein Subagent auf demselben Modell macht die Antwort nicht klüger – er bringt Parallelität und einen unvoreingenommenen Blick. Jeder kostet Token, deshalb sind es wenige mit klarer Rolle.
