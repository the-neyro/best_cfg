# Chart craft

## Form picker
| Data job | Use | Avoid |
|---|---|---|
| One headline number | Stat tile (+ sparkline, delta) | A chart with one bar |
| Change over time, 1-5 series | Line (area if one series and volume matters) | Bars for >20 time points, 3D |
| Change over time, many series | Small multiples, or highlight 1-2 and grey the rest | 10-line spaghetti |
| Compare categories | Horizontal bar, sorted by value | Unsorted vertical bars with rotated labels |
| Part-to-whole | Stacked bar / single 100% bar / treemap | Pie or donut with > 3 slices |
| Distribution | Histogram, box plot | Average alone |
| Two measures relation | Scatter (size for a 3rd measure) | Dual-axis line chart |
| Funnel / conversion | Horizontal bar per step with % retained | Decorative funnel shapes |
| Geography | Choropleth with a sequential scale | Rainbow color scales |

## Color
- **Categorical** (identity): up to ~6-8 hues in a fixed order; series 1 is always the brand/primary hue. A 9th series folds into "Other" or small multiples.
- **Sequential** (magnitude): one hue, light -> dark (in dark mode, dark -> light), 5-9 steps.
- **Diverging** (above/below a midpoint): two hues with a neutral grey midpoint.
- **Status**: success / warning / danger reserved; always paired with icon or label.
- Text (labels, values, legends) uses text colors, not the series color.
- Check color-vision-deficiency safety: adjacent series must differ in lightness too, not only hue. Add dashes or markers as a secondary encoding when series are close.

## Marks and anatomy
- Lines 2px, round joins; points only on hover or for sparse data (>= 8px hit target).
- Bars: 4px rounded data end, square at the baseline; gap between bars >= 25% of bar width; 2px surface-colored gap between stacked segments.
- Axes: no heavy axis lines; light horizontal gridlines (foreground at 6-8% alpha); 4-6 ticks; format ticks (1.2k, Jan, 09:00); start bar charts at zero.
- Labels: direct-label the last point of each line when <= 4 series; avoid a number on every point.
- Legend: present for 2+ series, placed top-left above the plot, in series order.
- Tooltip: crosshair on line/area; shows date + every series value with its color swatch, sorted by value; formatted numbers.
- Empty / loading / error states inside the chart frame at the final size.

## Recharts baseline (React)

```tsx
import { ResponsiveContainer, LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip } from "recharts";

const fmt = new Intl.NumberFormat("en-US", { notation: "compact", maximumFractionDigits: 1 });

export function RevenueChart({ data }: { data: { date: string; revenue: number; target: number }[] }) {
  return (
    <ResponsiveContainer width="100%" height={280}>
      <LineChart data={data} margin={{ top: 8, right: 16, bottom: 0, left: 0 }}>
        <CartesianGrid vertical={false} stroke="var(--border)" />
        <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} minTickGap={24}
               tick={{ fill: "var(--muted)", fontSize: 12 }} />
        <YAxis tickLine={false} axisLine={false} width={48} tickFormatter={(v) => fmt.format(v)}
               tick={{ fill: "var(--muted)", fontSize: 12 }} />
        <Tooltip cursor={{ stroke: "var(--border)" }}
                 contentStyle={{ background: "var(--surface)", border: "1px solid var(--border)", borderRadius: 10 }}
                 formatter={(v: number) => fmt.format(v)} />
        <Line type="monotone" dataKey="revenue" stroke="var(--accent)" strokeWidth={2} dot={false} activeDot={{ r: 4 }} />
        <Line type="monotone" dataKey="target" stroke="var(--muted)" strokeWidth={1.5} strokeDasharray="4 4" dot={false} />
      </LineChart>
    </ResponsiveContainer>
  );
}
```

## Accessibility
- Every chart has an accessible name (`aria-label` or a visible title linked with `aria-labelledby`) and a data table alternative (toggle or visually hidden).
- Never encode meaning by color alone.
- Keyboard: focusable data points or a focusable table view.
