---
paths:
  - "**/*.{tsx,jsx,vue,svelte,astro}"
  - "**/*.{css,scss}"
---

# Frontend rules

- Use design tokens (CSS variables / Tailwind theme) for every color, font size, radius, shadow and spacing value. No hex codes or magic pixel values inside components.
- Reuse existing components from the project's UI folder before creating new ones; extend variants instead of copying.
- Semantic HTML first (`button`, `a`, `nav`, `main`, `section`, headings in order); ARIA only when HTML cannot express it.
- Every interactive element: hover, `focus-visible`, active and disabled styles. Every async view: loading, empty and error states.
- Images with explicit size or aspect ratio; icons from a single library.
- Mobile-first responsive styles; test at 375px and 1440px.
- Client components only where interactivity requires it (Next.js App Router: Server Components by default).
- After visible changes, run the `visual-qa` skill before reporting done.
