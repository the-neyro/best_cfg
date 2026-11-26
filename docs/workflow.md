# Arbeitsweise: wenig Fehler, kein AI-Look

## Grundregel: Gib dem Agenten etwas zum Prüfen
Ein Agent hört auf, wenn die Arbeit *fertig aussieht*. Ohne Prüfung bist du der Test.
- Trag Typecheck / Lint / Test / Build in die `AGENTS.md` des Projekts ein.
- Der Stop-Hook aus `project-template` lässt Claude Typecheck + Lint laufen, bevor er aufhört.
- UI: `visual-qa` (Screenshots 375/768/1440, hell/dunkel) + `slop-scan`.
- Verlange Belege: Befehl + Ausgabe, nicht „alle Tests grün“.

## Ablauf für jede ernsthafte Aufgabe
1. **Erkunden** – „Schau dir X und Y an, ändere nichts.“ Große Sachen im Plan Mode (`Shift+Tab`).
2. **Spec** – `/spec <Idee>`: Rückfragen, dann Spezifikation in `docs/specs/`.
3. **Umsetzen** in kleinen, geprüften Schritten.
4. **Prüfen** – Tests, Typecheck, `visual-qa`.
5. **Review** – `code-reviewer` + `security-auditor` (sie kennen den Entstehungsweg nicht und sehen deshalb mehr).
6. **Commit** – `/ship`: alle Checks, Review, Secret-Scan, sauberer Commit.

## Design-Briefing, das funktioniert
Schlecht: „Mach eine schöne Landingpage.“

Gut:
```
Landingpage für [Produkt] – [was es tut, für wen].
Gefühl: [3 Adjektive, z. B. präzise, ruhig, teuer].
Referenzen: [Links/Screenshots + WAS genau daran gefällt].
Marke: [Farben/Schriften/Logo, falls vorhanden].
Hauptaktion: [z. B. Demo buchen].
Zeig zuerst den Designplan (Richtung, Palette, Schrift, Raster, Signature-Moment).
```
Das Wort „Design“ (oder „дизайн“, „UI“, „Webseite“ …) aktiviert per Hook automatisch den `design`-Skill mit den harten Verboten: keine Karten mit Rahmen+Schatten, Radius 0–4 px, keine Icon-Kacheln, keine Verläufe.

Noch besser: Referenz-Screenshots in den Chat ziehen, Figma-Link (Figma MCP), und in Schleifen per Screenshot korrigieren.

## Kontext
- `/clear` zwischen unabhängigen Aufgaben – kostenlos und bessere Antworten.
- `/compact <Fokus>` bei langen Sessions.
- Parallele Aufgaben in eigenen Git-Worktrees.
- `/usage` zeigt, wohin das Limit geht.

## Wenn der Agent Fehler macht
- Zweimal derselbe Fehler → eine konkrete Zeile unter „Gotchas“ in `AGENTS.md`.
- Muss *immer* gelten → kein Text, sondern Hook oder Deny-Regel.
- KEINE GROSSBUCHSTABEN und „WICHTIG!!!“ – moderne Modelle übertreiben dann. Wird eine Zeile ignoriert, ist die Datei zu lang oder es ist ein Fall für einen Hook.
- Zwei gescheiterte Fix-Versuche → `/clear`, neu mit „Bug, bisherige Versuche, finde die Ursache“ oder direkt `debugger` / `/model fable`.

## Nützliche Befehle (Claude Code)
| Befehl | Zweck |
|---|---|
| `/init` | CLAUDE.md für ein bestehendes Projekt erzeugen (danach kürzen!) |
| `/doctor prompt-audit` | Veraltete/widersprüchliche Anweisungen finden |
| `/code-review` | Eingebautes Review des aktuellen Diffs |
| `/hooks`, `/agents`, `/mcp`, `/context` | Prüfen, was geladen ist |
| `/goal <Bedingung>` | Weiterarbeiten, bis die Bedingung erfüllt ist |
| `Esc Esc` | Zu einer früheren Nachricht zurück |
