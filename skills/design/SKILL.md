---
name: design
description: Design and build distinctive, premium web and app interfaces that never look like generic AI output - no default cards, borders, rounded corners, shadows or icon tiles. Use for ANY design or UI request - pages, apps, components, landing pages, dashboards, design systems, restyling - in any language ("дизайн", "Design", "UI", "сайт", "Webseite", "Oberfläche").
when_to_use: 'Triggers: design, дизайн, Gestaltung, UI, UX, interface, интерфейс, Oberfläche, make it look good, premium, redesign, landing, лендинг, website, сайт, Webseite, dashboard, дашборд, component, looks generic'
---

# Design without AI slop

Generic AI UI has a recognizable fingerprint: a grid of rounded cards, each with a 1px grey border, a soft drop shadow and a Lucide icon inside a pastel rounded square, under a centered gradient headline. **Never produce that.** Premium design is one clear idea executed with discipline: confident typography, a precise grid, a restrained palette, real content, and space doing the work that boxes usually do.

## Hard bans (default state - only allowed when the brief explicitly asks for it)
1. **No boxes by default.** Do not wrap content in bordered/shadowed cards. Group with whitespace, alignment, typographic hierarchy and background color shifts. A container needs a reason (it is clickable, draggable, or a real object like a product tile).
2. **No rounded-everything.** Default radius is **0-4px**. Larger radii only as a deliberate brand decision, applied consistently and sparingly. No `rounded-xl/2xl/3xl` on sections and cards, no pill buttons by default.
3. **No decorative shadows.** Flat surfaces. Shadows only for layers that truly float (menus, popovers, dialogs, toasts), and then subtle. No `shadow-md/lg/xl` on cards, buttons or images.
4. **No decorative borders.** No 1px border around every block. Use rules/dividers only where they carry structure (tables, form fields, a deliberate editorial grid).
5. **No icon tiles and no icon confetti.** No icon in a colored rounded square above feature text, no icon before every heading or bullet, no emoji as icons. Icons only where they speed recognition (navigation, actions, status), from one deliberately chosen set at one stroke width - or none at all. Replace decorative icons with numbers, typography, real product imagery or purpose-made illustration.
6. **No gradients, glass or glow** as the look: no purple/blue/pink gradients, gradient text, glassmorphism, blurred blobs, neon glows.
7. **No template layouts**: no centered hero + two buttons + floating screenshot, no 3-column feature grid of identical blocks, no "New ✨" pill badge above the headline, no avatar stack "loved by 10,000+ users", no fake logos or stats.
8. **No unstyled library defaults.** shadcn/ui, MUI, Chakra, DaisyUI, Bootstrap defaults ARE the AI look. Use their behavior (accessibility primitives), restyle every visual with the project's tokens.

## Process

### 1. Understand the subject
In 3-5 lines: what the product is, who uses it, the single most important action, and 3 adjectives for the feel. Look at existing tokens, fonts and brand assets in the repo and reuse them. If the brief is vague, derive from the domain - a law firm, a logistics tool and a fashion label must not share a look.

### 2. Diverge, then choose a direction (show the plan before building)
Models collapse onto the same 2-3 looks. Break that deliberately:
1. Roll the dice: `node <this skill's folder>/scripts/design-dice.mjs "<domain keywords in English>" [--cyrillic]` (Claude Code: `~/.claude/skills/design/scripts/design-dice.mjs`). It proposes three concepts - composition x type pairing x palette strategy x signature device - avoiding what recent projects used.
2. Write three one-line concepts that differ in composition, type and color (start from the dice; adapt freely). Name which one is the most *expected* for this kind of site and drop it unless the brief demands it.
3. Choose one, tie it to the subject's world (`references/design-directions.md` for full recipes), then write:
- **Direction**: one sentence, e.g. "Swiss grid: 12 columns, oversized grotesk headlines, black/white with one signal red, hairline rules."
- **Palette**: 4-6 named colors in OKLCH (background, ink, muted ink, line, one accent, optional support).
- **Type**: families, scale, weights, tracking. See `references/typography-color.md`.
- **Grid & space**: columns, max width, gutters, spacing scale; ASCII wireframe of the key screens/sections, with asymmetry where it helps.
- **Hero composition**: choose deliberately from the subject, not by habit - typographic poster (type only, full width), full-bleed photography with overlaid type, product-first (real UI or object as the hero), editorial (centered headline + lead + image band below), asymmetric collage, data-first (one striking number or chart), or a split layout. The split "giant headline left + boxed interactive widget right" has become this config's own default - use it only when the brief clearly calls for a tool in the hero.
- **Signature moment**: the ONE memorable element (oversized type, a striking product visual, an unusual grid break, a data visualization, a precise interaction).
- **How things are grouped** without cards (space, rules, color fields, typography).

Run the plan against `references/anti-patterns.md`. Replace every item that is the obvious default for this kind of page.

### 3. Foundation first
Create tokens before components (CSS variables / Tailwind v4 `@theme`): colors, type scale, spacing, radius (small), motion. Dark theme as its own palette. See `references/tokens.md`. No hardcoded colors or sizes inside components.

### 4. Build
- Use the project's stack. New React projects: Tailwind CSS v4, Radix/shadcn primitives **restyled**, Motion for animation, self-hosted variable fonts. Icons only if needed (see ban 5).
- Real content: realistic copy written for this product and audience, in the product's language (German by default), real-looking data. No lorem ipsum, "John Doe", "Acme", "Feature 1".
- Every state designed: hover, `focus-visible`, active, disabled, loading (skeletons matching layout), empty (with a next action), error (what happened + how to fix).
- Images with fixed aspect ratios and no layout shift.

### 5. Check, deterministically and visually
Log the chosen concept so the next project does not repeat it: `node <skill folder>/scripts/design-dice.mjs --log '{"project":"<name>","composition":"<id>","type":"<pairing>","palette":"<id>","signature":"<device>"}'`.

Code quality and interaction details: follow the `frontend-engineering` skill (performance, forms, focus, URL state, typography details).

1. Run the slop scanner on the changed UI code and fix every finding:
   `node <this skill's folder>/scripts/slop-scan.mjs src` (path to the UI source; Claude Code install: `~/.claude/skills/design/scripts/slop-scan.mjs`).
2. Render and screenshot with the `visual-qa` skill (375 / 768 / 1440, light + dark). Look at every screenshot and ask: "Would a designer at a top studio ship this? Does anything look like a template?" Fix and re-shoot.
3. For important screens, get an independent critique (Claude Code: `ui-reviewer` subagent) and fix the top issues.

## Taste - what makes it stylish, not just different
Variety without taste is noise. Every concept must pass these:
- **Coherence**: type, color, layout, imagery and motion all express the same idea. If a choice cannot be explained by the subject or the concept, remove it.
- **Restraint**: max two typefaces (often one), one accent color, one signature moment. Color roughly 60 % ground / 30 % ink and structure / 10 % accent.
- **Proportion**: a modular type scale with real contrast (display 4-8x body), a consistent spacing scale, generous outer margins, a visible grid that holds across sections.
- **Hierarchy through contrast, not decoration**: big vs small, dense vs empty, bold vs light - never extra boxes, badges or icons to create importance.
- **Imagery**: real and art-directed (same light, crop and color treatment), or none. No stock clichés (handshakes, people pointing at laptops, smiling headsets).
- **Craft details**: tight tracking on display type, correct quotes and dashes per language, hanging punctuation in large quotes, tabular numbers, optical alignment, no widows in headlines.
- **Edit**: before finishing remove one more element. Ask: "Would a top studio put its name on this, and is it unmistakably *this* client?"

## Quality floor
- WCAG 2.2 AA: 4.5:1 text, 3:1 large text and UI boundaries; visible `focus-visible`; full keyboard use; semantic HTML; labels and `alt` text.
- `prefers-reduced-motion` respected; responsive from 360px with no horizontal scroll; touch targets >= 44px.
- No layout shift; `text-wrap: balance` on headings, `pretty` on paragraphs, line length <= ~70ch; `tabular-nums` for numbers.

## What premium is made of instead
- **Typography as the main visual**: big confident headlines with tight tracking, a clear scale, contrast between display and text faces.
- **A visible grid** with intentional asymmetry and alignment that holds across the page.
- **Color fields**: full-bleed bands of background color to separate sections instead of boxes.
- **Hairline rules and numbering** where they encode real structure (sequences, tables, indices).
- **Real imagery**: product UI rendered crisply, photography with art direction, or custom illustration/data viz made for this product.
- **Restraint**: one accent, one signature moment, generous space. When in doubt, remove.

## References
- `references/design-directions.md` - 8 concrete non-generic directions with token recipes
- `references/typography-color.md` - type pairing, scales, OKLCH palettes, dark mode
- `references/tokens.md` - starter token file (CSS + Tailwind v4)
- `references/motion.md` - motion rules and snippets
- `references/anti-patterns.md` - full slop checklist
- `scripts/slop-scan.mjs` - static scanner for slop patterns in code
- `scripts/design-dice.mjs` - proposes three different concepts (13 compositions, 28 type pairings with Cyrillic flags, 10 palette strategies, 12 signature devices), avoids recently used ones, logs choices
