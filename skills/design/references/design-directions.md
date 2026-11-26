# Design directions

Pick one that fits the subject, or combine two at most. Each direction is a complete set of decisions - follow it consistently. Values are starting points; tune to the brand.

## 1. Swiss / International
For: B2B tools, agencies, consulting, architecture, fintech.
- Type: one neo-grotesk in 2-3 weights (Inter Display, "Hanken Grotesk", "Schibsted Grotesk", Geist). Headlines 64-120px, tracking -0.03em, flush left.
- Color: white/off-white, near-black ink, ONE signal color (red oklch(0.58 0.22 28) or cobalt).
- Layout: strict 12-column grid, asymmetric placement, lots of white, hairline rules (1px ink at 15%) to divide sections, section numbers (01, 02) only when the order matters.
- Radius 0. No shadows. Icons: none or minimal line icons.

## 2. Editorial / Magazine
For: content products, luxury, culture, personal brands, premium consumer.
- Type: high-contrast serif display (Fraunces, Instrument Serif, Newsreader) + clean sans text; italic for emphasis; drop caps or pull quotes as signature.
- Color: warm paper oklch(0.97 0.01 85), ink oklch(0.20 0.01 60), one deep accent (oxblood, forest, ink-blue).
- Layout: multi-column text, large images with captions, generous margins, varied section rhythm.
- Radius 0. No shadows. Imagery does the decoration.

## 3. Technical / Instrument
For: developer tools, data products, infrastructure, AI products, dashboards.
- Type: grotesk + monospace for labels, numbers and metadata (Geist + Geist Mono, IBM Plex Sans + Plex Mono).
- Color: dark graphite oklch(0.17 0.005 260) or light grey-white; one precise accent (signal green, amber, electric blue) used for state and data only.
- Layout: dense but ordered, aligned to a baseline, thin rules, tabular numbers, keyboard-hint chips, real code/data as imagery.
- Radius 2-4px. Shadows only on floating menus.

## 4. Quiet luxury / Minimal
For: premium services, real estate, hospitality, fashion, high-end apps.
- Type: refined serif or light grotesk at large sizes with wide letter-spacing on small labels; very few weights.
- Color: stone/sand/ivory neutrals, charcoal ink, accent as a material tone (brass, olive, deep green).
- Layout: extreme whitespace, few elements per view, full-bleed photography, slow and subtle motion.
- Radius 0. No shadows, no icons.

## 5. Neo-Brutalist (refined)
For: creative tools, startups that want attitude, youth brands, events.
- Type: heavy or wide grotesk (Archivo Black, "Bricolage Grotesque", Unbounded) at huge sizes; mono for small text.
- Color: bold flat fields (e.g. yellow oklch(0.90 0.17 100), black, white) with hard contrast.
- Layout: visible grid lines, hard edges, overlapping blocks, raw but precise alignment.
- Radius 0. Hard offset shadow (4px 4px 0 ink) allowed as the ONE signature, nowhere else.

## 6. Bauhaus / Geometric
For: education, kids-adjacent but premium, design tools, cultural institutions.
- Type: geometric sans (Futura-like: "Jost", "Outfit", "League Spartan").
- Color: primary triad (red, blue, yellow) at controlled saturation + black and off-white.
- Layout: geometric shapes (circle, square, triangle) as composition elements and illustrations, strong grid.
- Radius: only true circles or 0, nothing in between.

## 7. Nordic / Soft functional
For: health, wellbeing, productivity, family, sustainability.
- Type: humanist sans (Figtree, "Nunito Sans", Manrope) with comfortable sizes.
- Color: muted natural palette (sage, fog, clay) with good contrast for text; one calm accent.
- Layout: generous space, clear sections via soft background bands (not cards), photography of real people/places.
- Radius 4-8px maximum, consistent. No shadows; no icon tiles.

## 8. Data-forward / Dashboard
For: analytics, finance, operations, admin.
- Type: grotesk for UI, tabular numbers everywhere, mono for IDs and codes.
- Color: neutral ink scale carries 90%; categorical data palette (validated for color-vision deficiency); status colors reserved.
- Layout: panels separated by space and hairlines (not bordered cards), KPI row, primary chart, then detail table; sidebar navigation with text labels.
- Radius 0-4px. Shadows only on popovers. See the `dashboard-design` skill.

## How to make it yours
After picking a direction, add ONE element drawn from the product's own world: a material (paper, metal, fabric), an artifact (ticket, receipt, map, blueprint), a vocabulary (nautical, medical, architectural), or its real data. That element is what makes the result unmistakably *this* product.
