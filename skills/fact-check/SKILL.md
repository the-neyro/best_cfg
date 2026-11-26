---
name: fact-check
description: Rigorous verification of every factual claim, number, date, name, quote, calculation and citation in a text, report, website copy or answer before it goes out. Use before publishing or sending anything important, after writing a report, and whenever correctness matters more than speed.
when_to_use: 'Triggers: проверь, проверь факты, prüfen, Faktencheck, fact check, verify, are these numbers right, before sending reports, articles, client texts'
---

# Fact-check

Goal: zero wrong facts. Assume every claim is wrong until verified.

## Process
1. **Extract claims.** List every checkable statement: numbers, percentages, dates, names, titles, prices, quotes, technical facts, legal statements, causal claims ("X led to Y"), and every calculation.
2. **Verify each one** against the strongest available source:
   - Internal data: recompute from the raw data with code; never trust a number copied from an earlier draft.
   - External facts: primary sources first (official sites, laws, filings, documentation, original studies), then reputable secondary sources. Check the date - is it still current?
   - Calculations: recompute (sums, growth rates, averages, unit conversions, currency, VAT). Percent change = (new - old) / old.
   - Quotes: exact wording and attribution from the original source.
   - Legal/tax/medical statements: only from official sources; flag that a professional should confirm.
3. **Classify** each claim: ✅ verified (source) · ⚠️ partly / outdated / imprecise (correction) · ❌ wrong (correction) · ❓ unverifiable (remove, soften, or mark as assumption).
4. **Fix the text**: apply corrections, add sources where the reader needs them, and make uncertainty explicit instead of hiding it.

## Output
A short table: claim -> status -> source -> correction. Then the corrected text (or the diff). State clearly how many claims were checked and how many changed.

## Rules
- No invented sources, studies, statistics or quotes - ever. If nothing supports a claim, say so.
- Consistency check across the whole document: the same number, name and date must be identical everywhere.
- Round only at the end; keep the precision of the source.
