# Eval-Fortschritt (Lauf 2026-11-27)

Modell beider Varianten: opus. cfg = mit Konfig (effort high), base = ohne Konfig.

| Aufgabe | cfg Zeit | base Zeit | Ergebnis |
|---|---|---|---|
| auth | 816 s | 86 s | Beide funktionieren (Smoke-Test). cfg: Sessions statt JWT, 25 Tests, npm audit, Reviewer fanden und behoben 7 echte Fehler (u. a. fremdes Konto per 5 Fehlversuchen sperrbar, argon2-Flood). base: JWT, keine Tests. Berechtigungs-Fix bestätigt: cfg installiert und startet selbst. Mangel cfg: Tests in Scratch-Ordner statt im Projekt -> Regel in AGENTS.md ergänzt. |
| landing | 1158 s | 269 s | slop-scan: cfg 0 Funde vs. base 5 HIGH + 10 MED (große Radien, Glas, Blobs). cfg: flaches Split-Layout, Kalender mit markiertem Fristende, Frist korrekt (27.11. + 3 Wochen = 18.12.), rechtliche Aussagen als ungeprüft markiert. base: abgerundete Karte mit großem Schatten, Pill-Buttons, rotierendes Badge, Gold auf Creme. Fehlalarm des Limit-Detektors (Wort "rate limiting" im Text) -> Detektor korrigiert. |
| report | 129 s | 31 s | Beide Berichte ohne Zahlenfehler (stichprobenartig nachgerechnet). cfg vollständiger: Netto pro Monat, Retouren +82,6 % vs. Umsatz +15,8 %, Hinweis zur unklaren MwSt.-Basis, Upgrade-Empfehlung, Quellenangabe. Mangel cfg: Berechnungsskript im Scratch-Ordner -> Regel auf alle Belegskripte erweitert. Score-Fehlalarm "Mehrwert" in "Mehrwertsteuer" korrigiert. |
| dashboard | 1023 s | 213 s | cfg: Kernaussage als Headline ("7,8 % über Vorjahr, aber 3,3 % unter Plan"), KPI-Band mit Trennlinien statt Karten, Sparklines mit Vorjahr, 20/20 Tests im Projekt (neue Regel wirkt). base: sauber, aber klassische SaaS-Kartenwand mit Rahmen, Icon-Kreisen und Pill-Badges. slop-scan übersah Karten aus reinem CSS -> Scanner um CSS-Regeln erweitert (base jetzt 4 MED, cfg 2 MED Schatten an Tooltip/Sticky-Spalte). |
| erp | 912 s | 247 s | Unabhängiger Probe-Test (eval/data/erp-probe.test.ts: Nummernkreis lückenlos, Rundung bei 1,5 Stk. und 19/7 %, Storno, doppeltes Storno, ungültige Eingaben, DB-Manipulation per Trigger blockiert, Jahreswechsel): beide 6/6. Beide tsc sauber. cfg gründlicher: 94 vs. 47 eigene Tests, strikte zod-Validierung, Pflichtangaben § 14 UStG (Anschrift, Leistungsdatum), GoBD-Rückdatierungsgrenze, Mehrprozess-Test der Nummernvergabe, AGENTS.md-Befehle ausgefüllt. Erster Versuch lief ins 5-h-Limit (Detektor kannte die Meldung nicht -> korrigiert). |
| seo | 479 s | 79 s | eval/seo-score.sh: beide 12/12 eingebaute Fehler behoben. cfg tiefer: sitemap.xml, Unterscheidung KI-Suche vs. KI-Training in robots.txt, Test gegen Platzhalter-Domain vor Release, fehlendes hero.jpg und Impressum gemeldet, Preise-Link als Anker statt toter /preise-Seite. Mängel cfg: Schlussantwort auf Englisch statt Russisch; audit.md auf Deutsch, weil Regel 'Doku auf Deutsch' zu breit war -> Sprachregeln präzisiert. |

## Offen
- text läuft (mit der bereits verbesserten Konfig)

## Weiter bei Abbruch
`EVAL_DIR=$HOME/eval-run bash eval/run.sh <fehlende Aufgaben>`; Ergebnisse in `$HOME/eval-run/status.txt`.
