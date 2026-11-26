# Typography and color

## Typography

Type carries most of a page's personality. Choose with intent; never fall back to the first font that comes to mind.

### Choosing families
- One family with a wide weight range is often enough. Two families: a characterful display face for headlines + a highly legible text face.
- Match the subject:
  - Precise / technical / fintech: Geist, Inter Display, Söhne-like grotesks (e.g. "Hanken Grotesk", "Schibsted Grotesk"), mono accents (Geist Mono, JetBrains Mono, IBM Plex Mono).
  - Editorial / luxury / culture: a serif display (Fraunces, Instrument Serif, Newsreader, "Playfair Display" only if truly fitting) with a neutral sans body.
  - Friendly / consumer: rounded or humanist sans (Nunito Sans, "DM Sans", Figtree, Manrope).
  - Bold / brutalist / creative: condensed or wide grotesks (Archivo, "Bricolage Grotesque", Unbounded), big sizes, tight tracking.
- Avoid choosing Inter/Roboto/Arial/system-ui by reflex for display type; they are fine for dense UI text when the brand voice lives elsewhere.
- Load fonts self-hosted / via `next/font`, variable weights, `font-display: swap`, subset to needed scripts (add `cyrillic` when content is Russian).

### Scale and rhythm
- Use a modular scale (ratio 1.2-1.333) or a hand-tuned set: 12, 14, 16, 18, 20, 24, 30, 36, 48, 60, 72, 96.
- Body 16-18px, line-height 1.5-1.7. Headings line-height 1.0-1.2. Display type tracking -0.02 to -0.04em.
- Use fluid sizes for display: `font-size: clamp(2.5rem, 1.5rem + 4vw, 5rem)`.
- Limit to 2-3 weights per family (e.g. 400, 500, 600). Hierarchy comes from size + weight + color, not from all three maxed.
- Line length 45-75 characters (`max-width: 65ch`).
- `text-wrap: balance` for headings, `text-wrap: pretty` for paragraphs, `font-variant-numeric: tabular-nums` for numbers in tables/metrics.

## Color

### Build the palette in OKLCH
OKLCH keeps perceived lightness consistent across hues, which makes accessible palettes and dark mode far easier.

- **Neutrals carry 90% of the UI.** Build a 11-step neutral ramp (50-950) with a tiny tint of the brand hue (chroma 0.005-0.02) - pure grey looks cheap next to a colored accent.
- **One accent** for primary actions, links and key data. Optionally one support color. Semantic colors (success, warning, danger, info) are separate and never reused as decoration.
- Accent usage: the primary button, active states, one highlight per view. If everything is accent, nothing is.
- Typical light theme: background L≈0.99, surface L≈1.0 or 0.975, border = foreground at 8-12% alpha, text L≈0.20, muted text L≈0.45-0.55 (check contrast!).

### Dark mode is its own design
- Background not pure black: L≈0.14-0.18 with slight brand tint. Elevation = lighter surfaces, not stronger shadows.
- Reduce accent chroma/lightness slightly so it does not glow; re-check contrast for every text/background pair.
- Avoid pure white text on near-black for long reading; use L≈0.93-0.96.

### Contrast targets (WCAG 2.2 AA)
- Normal text 4.5:1, large text (>= 24px or >= 18.66px bold) 3:1, UI component boundaries and focus rings 3:1.
- Verify with a tool (e.g. `npx wcag-contrast` or browser devtools) rather than guessing.

### Palette starting points (adapt, don't copy blindly)
| Mood | Background | Text | Accent |
|---|---|---|---|
| Precise fintech | oklch(0.99 0.003 250) | oklch(0.21 0.02 260) | oklch(0.55 0.19 255) cobalt |
| Warm premium | oklch(0.985 0.008 80) | oklch(0.23 0.02 60) | oklch(0.52 0.13 40) burnt orange |
| Calm health | oklch(0.99 0.005 170) | oklch(0.24 0.03 190) | oklch(0.58 0.11 170) teal |
| Dark pro tool | oklch(0.16 0.01 270) | oklch(0.94 0.005 270) | oklch(0.72 0.15 150) signal green |
| Luxury editorial | oklch(0.97 0.004 90) | oklch(0.18 0 0) | oklch(0.45 0.08 25) oxblood |
