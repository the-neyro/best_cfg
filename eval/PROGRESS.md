# Eval-Fortschritt (Lauf 2026-11-27)

Modell beider Varianten: opus. cfg = mit Konfig (effort high), base = ohne Konfig.

| Aufgabe | cfg Zeit | base Zeit | Ergebnis |
|---|---|---|---|
| auth | 816 s | 86 s | Beide funktionieren (Smoke-Test). cfg: Sessions statt JWT, 25 Tests, npm audit, Reviewer fanden und behoben 7 echte Fehler (u. a. fremdes Konto per 5 Fehlversuchen sperrbar, argon2-Flood). base: JWT, keine Tests. Berechtigungs-Fix bestätigt: cfg installiert und startet selbst. Mangel cfg: Tests in Scratch-Ordner statt im Projekt -> Regel in AGENTS.md ergänzt. |

## Offen
- landing, report, dashboard, erp, seo, text laufen (eval/run.sh, Paare nacheinander)

## Weiter bei Abbruch
`EVAL_DIR=$HOME/eval-run bash eval/run.sh <fehlende Aufgaben>`; Ergebnisse in `$HOME/eval-run/status.txt`.
