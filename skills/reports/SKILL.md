---
name: reports
description: Write reports that are accurate to the last digit and pleasant to read - business, analytics, project status, audit, research, client and management reports - in German, Russian or English, in a human conversational-professional style. Use for any report, summary for stakeholders, analysis write-up, memo or presentation text.
when_to_use: 'Triggers: отчёт, отчет, репорт, report, Bericht, Auswertung, Analyse, summary, сводка, Statusbericht, memo, Zusammenfassung'
---

# Reports

A great report is **correct, short and readable**: the reader knows the answer after the first paragraph and trusts every number in it.

## 1. Brief (before writing)
Clarify or infer: reader (CEO, client, team, investor), the decision or action the report should enable, scope and period, language and form of address (Sie/du, вы/ты), length, format (Markdown, docx, PDF, slides, email). If data is missing, list exactly what is needed instead of inventing it.

## 2. Gather and verify
- Use primary data (exports, databases, analytics, invoices, source documents). Note the source and timestamp of every dataset.
- Compute numbers with code (Python/pandas, SQL), not mentally. Save the script in the project (e.g. `analysis/<report>.py`) next to the report so every figure is reproducible - not in a temp folder.
- Cross-check totals: parts sum to the whole, percentages to 100 (± rounding), period comparisons use identical definitions.
- Every claim gets a source or is marked as an assumption/estimate.
- Run the `fact-check` skill (or the `fact-checker` subagent) on the final draft. Zero tolerance for wrong numbers, names or dates.

## 3. Structure (adapt)
1. **Kernaussage / Главное / Bottom line** - 2-4 sentences: what happened, what it means, what to do.
2. **Key figures** - a small table: metric, value, change vs. previous period/target, short comment.
3. **What happened and why** - the story behind the numbers, causes, not just descriptions.
4. **Risks and open issues** - honest, with likelihood/impact.
5. **Recommendations / next steps** - concrete actions, owner, deadline.
6. **Appendix** - method, definitions, data sources, detailed tables.

## 4. Style
- Follow the `human-writing` skill: conversational-professional, active voice, concrete, no filler, no AI clichés.
- Write like a smart colleague briefing the reader in person: "Der Umsatz lag im Oktober bei 182.400 € – 12 % über Plan. Hauptgrund: zwei Großaufträge aus Bayern."
- Numbers: consistent units and decimals, locale-correct formatting (DE: 1.234,5 €; RU: 1 234,5 ₽; EN: 1,234.5), always show the comparison base ("vs. Vormonat", «к прошлому году»).
- Charts only when they show a pattern faster than a table; follow the `dashboard-design` chart rules (one axis, labeled, title states the insight).
- Bad news first and plainly. No spin.

## 5. Final checklist
- [ ] The first paragraph alone answers "what's the situation and what should I do?"
- [ ] Every number traced to a source/script and re-verified; totals reconcile
- [ ] Dates, names, units, currencies, periods consistent throughout
- [ ] No AI tells (see `human-writing`), no filler, no repeated summary at the end
- [ ] Spelling and grammar checked in the target language; correct quotes and number formats
- [ ] Format renders correctly (open the docx/PDF or preview the Markdown)
