# Design tokens - starter file

Adapt names and values to the design plan. Components reference only these tokens.

## Tailwind CSS v4 (`app/globals.css` or `src/styles/globals.css`)

```css
@import "tailwindcss";

@custom-variant dark (&:where(.dark, .dark *));

@theme {
  /* Fonts - wire these to next/font variables or @font-face */
  --font-sans: var(--font-text), ui-sans-serif, system-ui, sans-serif;
  --font-display: var(--font-heading), var(--font-sans);
  --font-mono: var(--font-code), ui-monospace, monospace;

  /* Type scale */
  --text-xs: 0.75rem;   --text-xs--line-height: 1rem;
  --text-sm: 0.875rem;  --text-sm--line-height: 1.25rem;
  --text-base: 1rem;    --text-base--line-height: 1.6rem;
  --text-lg: 1.125rem;  --text-lg--line-height: 1.75rem;
  --text-xl: 1.25rem;   --text-xl--line-height: 1.75rem;
  --text-2xl: 1.5rem;   --text-2xl--line-height: 2rem;
  --text-3xl: 1.875rem; --text-3xl--line-height: 2.25rem;
  --text-4xl: 2.25rem;  --text-4xl--line-height: 2.5rem;
  --text-5xl: 3rem;     --text-5xl--line-height: 1.05;
  --text-6xl: 3.75rem;  --text-6xl--line-height: 1.02;
  --text-7xl: 4.5rem;   --text-7xl--line-height: 1;

  /* Radius: small by default. Raise only as a deliberate, consistent brand decision. */
  --radius-none: 0px;
  --radius-sm: 2px;
  --radius-md: 4px;
  --radius-full: 9999px; /* only for true circles: avatars, dots, toggles */

  /* Motion */
  --ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);
  --ease-in-out-quart: cubic-bezier(0.76, 0, 0.24, 1);
  --duration-fast: 120ms;
  --duration-base: 200ms;
  --duration-slow: 320ms;

  /* Semantic colors mapped from the theme variables below */
  --color-background: var(--background);
  --color-surface: var(--surface);
  --color-surface-2: var(--surface-2);
  --color-foreground: var(--foreground);
  --color-muted: var(--muted);
  --color-border: var(--border);
  --color-ring: var(--ring);
  --color-accent: var(--accent);
  --color-accent-foreground: var(--accent-foreground);
  --color-success: var(--success);
  --color-warning: var(--warning);
  --color-danger: var(--danger);
}

:root {
  --background: oklch(0.99 0.003 250);
  --surface: oklch(1 0 0);
  --surface-2: oklch(0.975 0.004 250);
  --foreground: oklch(0.21 0.02 260);
  --muted: oklch(0.50 0.02 260);
  --border: oklch(0.21 0.02 260 / 0.12); /* for rules, table lines and inputs only - not for boxing content */
  --ring: oklch(0.55 0.19 255 / 0.55);
  --accent: oklch(0.55 0.19 255);
  --accent-foreground: oklch(0.99 0 0);
  --success: oklch(0.62 0.15 150);
  --warning: oklch(0.75 0.15 75);
  --danger: oklch(0.58 0.21 27);

  /* The only shadow: for layers that truly float (menus, popovers, dialogs, toasts). */
  --shadow-overlay: 0 8px 24px oklch(0.2 0.02 260 / 0.12), 0 1px 2px oklch(0.2 0.02 260 / 0.08);
}

.dark {
  --background: oklch(0.16 0.01 260);
  --surface: oklch(0.20 0.012 260);
  --surface-2: oklch(0.24 0.014 260);
  --foreground: oklch(0.95 0.005 260);
  --muted: oklch(0.70 0.015 260);
  --border: oklch(0.95 0.005 260 / 0.10);
  --ring: oklch(0.70 0.16 255 / 0.6);
  --accent: oklch(0.68 0.16 255);
  --accent-foreground: oklch(0.16 0.01 260);
  --success: oklch(0.72 0.15 150);
  --warning: oklch(0.80 0.14 75);
  --danger: oklch(0.68 0.19 27);

  /* In dark mode, elevation comes from lighter surfaces; the overlay shadow stays subtle. */
  --shadow-overlay: 0 8px 24px oklch(0 0 0 / 0.45), 0 0 0 1px oklch(1 0 0 / 0.06);
}

@layer base {
  html { color-scheme: light dark; -webkit-font-smoothing: antialiased; text-rendering: optimizeLegibility; }
  body { @apply bg-background text-foreground font-sans; }
  h1, h2, h3 { @apply font-display; text-wrap: balance; letter-spacing: -0.02em; }
  p { text-wrap: pretty; }
  :focus-visible { outline: 2px solid var(--ring); outline-offset: 2px; }
  @media (prefers-reduced-motion: reduce) {
    *, *::before, *::after { animation-duration: 0.01ms !important; animation-iteration-count: 1 !important; transition-duration: 0.01ms !important; scroll-behavior: auto !important; }
  }
}
```

## Fonts with next/font (App Router)

```tsx
// app/fonts.ts
import { Geist, Geist_Mono, Instrument_Serif } from "next/font/google";

export const text = Geist({ subsets: ["latin", "cyrillic"], variable: "--font-text", display: "swap" });
export const heading = Instrument_Serif({ subsets: ["latin"], weight: "400", variable: "--font-heading", display: "swap" });
export const code = Geist_Mono({ subsets: ["latin"], variable: "--font-code", display: "swap" });

// app/layout.tsx -> <html className={`${text.variable} ${heading.variable} ${code.variable}`}>
```

Check that every chosen family actually ships the subsets you need (e.g. Cyrillic) before committing to it.

## Restyling shadcn/ui (its defaults are the generic AI look)
- In `components.json` / globals: set `--radius: 0.125rem` (or 0), map its color variables to the tokens above.
- Remove `shadow-*` from `Card`, `Button`, `Input`, `Select` and `Tabs`; keep `--shadow-overlay` only on `Popover`, `DropdownMenu`, `Dialog`, `Toast`.
- Do not use `Card` as the default wrapper. Prefer plain sections separated by space, background bands or rules.

## Layout primitives

```css
.container-page { width: min(100% - 2rem, 72rem); margin-inline: auto; }
.section { padding-block: clamp(4rem, 3rem + 5vw, 8rem); }
.stack > * + * { margin-top: var(--stack-gap, 1rem); }
```
