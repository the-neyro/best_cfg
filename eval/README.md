# A/B-Eval

Vergleicht dieselben Aufgaben mit Konfig (`cfg`) und ohne (`base`), gleiches Modell.

```bash
EVAL_DIR=~/eval-run bash eval/run.sh     # 6 Läufe parallel (landing, report, auth), dauert ~10-20 min
EVAL_DIR=~/eval-run bash eval/score.sh   # slop-scan, Zahlen-Check, Security-Checkliste
EVAL_DIR=~/eval-run bash eval/smoke.sh base-auth 3102 /api/me NODE_ENV=development
```
Wahrheitswerte für den Bericht: Umsatz 508.200 €, Retouren 18.000 €, netto 490.200 €, Neukunden 324.

Ergebnisse 2026-11-26 (Opus 5.5): Design cfg 0 HIGH vs base 15 HIGH slop-Funde; Auth beide funktionsfähig, cfg mit 5 zusätzlichen Schutzmaßnahmen; Bericht beide fehlerfrei, cfg vollständiger. Kosten: cfg-Läufe deutlich länger (mehr Token).
