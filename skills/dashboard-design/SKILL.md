---
name: dashboard-design
description: Design and build data dashboards, admin panels, analytics and SaaS app screens that feel like a premium product (Linear / Stripe / Vercel quality) - KPI tiles, charts, tables, filters, dense-but-calm layouts. Use for any dashboard, analytics page, admin UI, data table or chart work.
when_to_use: 'Triggers: dashboard, admin panel, analytics, KPI, metrics, charts, data table, CRM, back office, SaaS app'
---

# Dashboard design

A great dashboard answers "what changed, is it good or bad, what should I do" in under five seconds. Density is fine; noise is not. Apply the `design` skill for tokens, type and craft; this skill adds the data-specific rules.

## 1. Start from questions, not widgets
List the 3-5 questions the user opens this screen to answer (e.g. "Are we on track for monthly revenue?", "Which deals are stuck?"). Each question gets one component; anything that answers no question is cut. Order by importance: top-left is read first.

## 2. Layout
- **App shell**: left sidebar (collapsible, 240-280px, text labels with at most one small icon each, grouped sections) or top nav for <= 6 sections; page header with title, short description or breadcrumb, primary action and the page-level filters (date range, segment) in one row.
- **Grid**: 12-column, 16-24px gutters, max content width 1440-1600px; panels align to shared edges.
- **No card wall**: separate panels with space, hairline rules and subtle background bands - not bordered, rounded, shadowed cards. Radius 0-4px. Shadows only on popovers and dialogs.
- **Hierarchy band**: KPI row (3-5 stat tiles) -> primary chart (full or 2/3 width) -> secondary charts -> detail table. Not a wall of equal-sized cards.
- **Density**: 13-14px for table/UI text is fine on desktop; keep 16px+ on mobile. Use spacing and subtle dividers instead of boxing everything.

## 3. KPI / stat tiles
- Not boxed: a KPI row is a band of numbers divided by thin vertical rules or space.
- Label (what), value (big, tabular numbers), delta vs comparison period with direction icon and sign ("+12.4% vs last 30 days"), optional sparkline without axes.
- Color the delta by meaning, not by sign: a rising churn rate is bad. Never rely on color alone - add an arrow icon and the sign.
- Format numbers for humans: `Intl.NumberFormat` with `notation: "compact"` (1.2M), correct currency and locale, consistent decimals; full value in a tooltip.

## 4. Charts
Read `references/charts.md` before writing chart code. Core rules:
- Choose the form by the job: trend over time -> line/area; compare categories -> horizontal bar (sorted); part of whole -> stacked bar or a single 100% bar (avoid pies beyond 3 slices); distribution -> histogram; correlation -> scatter; single number -> stat tile, not a chart.
- One y-axis per chart. Never dual axes.
- Categorical colors in a fixed order assigned to entities (the same series keeps its color across all charts and filters); sequential = one hue light->dark; status colors reserved for status.
- Recessive grid and axes, thin marks (2px lines), direct labels where possible, legend whenever there are 2+ series, tooltip with crosshair on hover.
- Every chart has a title that states the insight or the metric, the unit, and the time range.
- Libraries: use what the project has. Defaults for React: Recharts or the shadcn/ui chart components (built on Recharts) for standard charts; visx or D3 for custom; Tremor for fast KPI layouts; TanStack Table for data tables.

## 5. Tables
- Left-align text, right-align numbers (tabular-nums), consistent decimals, units in the header.
- Sticky header, sortable columns with visible sort indicator, row hover, comfortable row height (40-48px) or a density toggle.
- Status as small badges with icon + text; truncate long text with a tooltip; actions in a row-end menu.
- Pagination or virtualization for > 100 rows; server-side sort/filter for large data.
- Empty, loading (skeleton rows) and error states designed.

## 6. Filters and interaction
- Global filters (date range with presets: Today, 7D, 30D, QTD, YTD, Custom; segment/team) in the page header and reflected in the URL query string so views are shareable.
- Filters never repaint survivor series colors.
- Clicking a chart element drills down or filters; make it discoverable (cursor, hover state).
- Real-time data: show "Updated 2 min ago" and a subtle refresh, never jittery reflows.

## 7. Verify
Fill with realistic data (plausible magnitudes, seasonality, a few outliers, long names, zero and null values). Then run the `visual-qa` skill at 1440 and 1280 widths plus mobile, light and dark, and fix overflow, truncation and alignment issues.
