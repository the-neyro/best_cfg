# Motion

Motion should explain change and add a sense of quality. It should never be the reason a page feels slow.

## Rules
- Never: parallax on text, scroll-jacking, carousels or auto-rotating tabs, tilting cards, a fade-in on every section, random blinking. Anything that moves longer than 5 s gets a pause control.
- Hover on photos: zoom at most 1.02-1.03; on linked rows: background shift, not a lift. Ambient loops: 2.5-4 s, subtle.
- **Feedback** (hover, press, toggle): 100-200ms, ease-out. Press = subtle scale 0.98 or translateY(1px).
- **Transitions** (panels, dialogs, route changes): 200-320ms. Enter with ease-out, exit faster (~70% of enter duration).
- **Entrance choreography**: at most one orchestrated sequence per page (e.g. hero headline -> subcopy -> CTA -> visual, 40-80ms stagger). Do not fade-in every section on scroll.
- Animate only `transform` and `opacity` (and `filter` sparingly). Never animate width/height/top/left on large elements.
- Prefer springs for interactive elements: `{ type: "spring", stiffness: 400, damping: 30 }` feels crisp; lower stiffness feels floaty and cheap.
- Respect `prefers-reduced-motion`: replace movement with a simple opacity change or nothing.
- Loading: skeletons that match the final layout with a slow shimmer (1.5-2s), not spinners in the middle of content.

## Snippets (Motion for React - `import { motion } from "motion/react"`)

```tsx
// Staggered hero entrance
const container = { hidden: {}, show: { transition: { staggerChildren: 0.06, delayChildren: 0.05 } } };
const item = {
  hidden: { opacity: 0, y: 12, filter: "blur(4px)" },
  show: { opacity: 1, y: 0, filter: "blur(0px)", transition: { duration: 0.5, ease: [0.25, 1, 0.5, 1] } },
};

<motion.div variants={container} initial="hidden" animate="show">
  <motion.h1 variants={item}>...</motion.h1>
  <motion.p variants={item}>...</motion.p>
  <motion.div variants={item}>...</motion.div>
</motion.div>
```

```tsx
// Tactile button
<motion.button whileTap={{ scale: 0.98 }} transition={{ type: "spring", stiffness: 500, damping: 30 }} />
```

```tsx
// Shared layout animation for tabs / segmented control indicator
{active && <motion.span layoutId="tab-indicator" className="absolute inset-0 rounded-md bg-surface-2" />}
```

```tsx
// Respect reduced motion
import { useReducedMotion } from "motion/react";
const reduce = useReducedMotion();
const y = reduce ? 0 : 12;
```

## CSS-only

```css
/* Hover on a clickable row/tile: shift background and nudge the label - no lift, no shadow. */
.link-row { transition: background-color var(--duration-fast) var(--ease-out-quart); }
.link-row:hover { background-color: var(--surface-2); }
.link-row .label { transition: transform var(--duration-base) var(--ease-out-quart); }
.link-row:hover .label { transform: translateX(4px); }
```
