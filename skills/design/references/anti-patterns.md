# AI-slop checklist - run before you finish

If the design matches an item here, change it unless the brief explicitly asks for it.

## The usual suspects (highest priority)
- [ ] Content wrapped in cards with `border` + `rounded-xl` + `shadow` (the "card trinity").
- [ ] Large radius everywhere (sections, cards, images, buttons, inputs) - `rounded-2xl`, `rounded-3xl`, pill buttons.
- [ ] Soft drop shadows on static elements.
- [ ] 1px grey borders around every block.
- [ ] Icon inside a pastel/colored rounded square above each feature title ("icon tile").
- [ ] Decorative icons before every heading, list item or stat; emoji as icons; Lucide everywhere by reflex.
- [ ] Purple/indigo/violet/pink gradients; gradient text; glassmorphism (`backdrop-blur` panels); blurred gradient blobs; glow effects.

## Layout and content clichés
- [ ] Our own house default: giant headline on the left + boxed interactive widget/calculator on the right. Fine once, a template when it appears on every page.
- [ ] Centered hero: badge pill ("New ✨ ...") + gradient headline + subtext + two buttons + floating screenshot.
- [ ] 3- or 6-column grid of identical feature blocks with vague benefits ("Blazing fast", "Secure", "Scalable").
- [ ] Avatar stack + "Trusted by 10,000+ users"; fake company logos; unsourced stats ("10x faster").
- [ ] Every section the same height, same centered alignment, same rhythm.
- [ ] Three pricing cards with the middle one scaled up and glowing.
- [ ] Testimonials in rounded cards with 5 stars and stock avatars.
- [ ] Lorem ipsum, "John Doe", "Acme Inc.", "Feature One", placeholder images.
- [ ] Generic CTAs ("Get started", "Learn more") where a specific verb fits ("Erste Rechnung erstellen").
- [ ] Dark mode = black background with neon accents by default; light mode = beige with terracotta by default.
- [ ] Small all-caps "eyebrow" label above every heading; arrows on every link.

## Craft gaps
- [ ] Unstyled component library defaults (shadcn/MUI/Bootstrap look).
- [ ] No designed hover / focus / disabled / loading / empty / error states.
- [ ] Spacing values off-scale (13px, 18px, 22px...).
- [ ] More than 2 font families or more than 3 weights; default system font for display type without a reason.
- [ ] Muted text failing contrast; text over images without enough contrast.
- [ ] Layout shift on load; horizontal scroll on mobile.
- [ ] Fade-in-on-scroll on every block; bouncing elements; animations > 400ms on interactions.
- [ ] Parallax text, scroll-jacking, carousels / auto-rotating tabs, 3D-tilt cards.
- [ ] Stock photos presented as the client's own place or team; invented reviews or customer counts.

## The fix pattern
For each hit ask: "What would this look like if it were designed specifically for *this* product and *these* users?" Replace the default with a decision from the chosen direction and the product's own world: typography, grid, color fields, real imagery, real data.
