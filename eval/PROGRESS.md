# Eval-Fortschritt (Lauf 2026-11-27)

Modell beider Varianten: opus. cfg = mit Konfig (effort high), base = ohne Konfig.

| Aufgabe | cfg Zeit | base Zeit | Ergebnis |
|---|---|---|---|
| auth | 816 s | 86 s | Beide funktionieren (Smoke-Test). cfg: Sessions statt JWT, 25 Tests, npm audit, Reviewer fanden und behoben 7 echte Fehler (u. a. fremdes Konto per 5 Fehlversuchen sperrbar, argon2-Flood). base: JWT, keine Tests. Berechtigungs-Fix bestätigt: cfg installiert und startet selbst. Mangel cfg: Tests in Scratch-Ordner statt im Projekt -> Regel in AGENTS.md ergänzt. |
| landing | 1158 s | 269 s | slop-scan: cfg 0 Funde vs. base 5 HIGH + 10 MED (große Radien, Glas, Blobs). cfg: flaches Split-Layout, Kalender mit markiertem Fristende, Frist korrekt (27.11. + 3 Wochen = 18.12.), rechtliche Aussagen als ungeprüft markiert. base: abgerundete Karte mit großem Schatten, Pill-Buttons, rotierendes Badge, Gold auf Creme. Fehlalarm des Limit-Detektors (Wort "rate limiting" im Text) -> Detektor korrigiert. |
| report | 129 s | 31 s | Beide Berichte ohne Zahlenfehler (stichprobenartig nachgerechnet). cfg vollständiger: Netto pro Monat, Retouren +82,6 % vs. Umsatz +15,8 %, Hinweis zur unklaren MwSt.-Basis, Upgrade-Empfehlung, Quellenangabe. Mangel cfg: Berechnungsskript im Scratch-Ordner -> Regel auf alle Belegskripte erweitert. Score-Fehlalarm "Mehrwert" in "Mehrwertsteuer" korrigiert. |

## Offen
- dashboard, erp, seo, text laufen (mit der bereits verbesserten Konfig)

## Weiter bei Abbruch
`EVAL_DIR=$HOME/eval-run bash eval/run.sh <fehlende Aufgaben>`; Ergebnisse in `$HOME/eval-run/status.txt`.
