---
name: frontend-engineering
description: Engineering quality for web frontends - React/Next.js performance (waterfalls, bundle size, re-renders, server components), interface details that separate polished apps from average ones (forms, focus, keyboard, touch, animation, typography, URL state, i18n), and browser testing. Use whenever writing or reviewing React, Next.js or other frontend code, together with the `design` skill for visuals.
when_to_use: 'Triggers: React, Next.js, Vue, Svelte, frontend, фронтенд, component, form, форма, Formular, performance, slow page, re-render, hydration, bundle, Playwright, e2e'
---

# Frontend engineering

`design` decides how it looks; this skill makes it fast, robust and pleasant to use. Review new code against both reference files before calling it done.

## Priorities (fix in this order)
1. **Waterfalls** - sequential awaits/fetches that could run in parallel. Biggest wins.
2. **Bundle size** - heavy client JS, unsplit routes, third-party scripts.
3. **Server work** - uncached data, oversized props sent to the client.
4. **Client data fetching** - duplicate requests, missing caching/deduplication.
5. **Re-renders** - unnecessary state, effects, subscriptions.
6. **Rendering** - long lists, layout thrash, hydration flicker.

Details and patterns: `references/react-performance.md`.

## Interface details
Polished apps get hundreds of small things right: forms that never lose input, visible keyboard focus, URL-driven state, correct typography, interruptible animation, touch-friendly targets. Checklist: `references/interface-guidelines.md`.

## Testing in the browser
- Playwright with role-based locators (`getByRole`, `getByLabel`) and web-first assertions; never fixed sleeps.
- For dynamic apps wait for `networkidle` (or a specific element) before inspecting the DOM.
- Recon first: screenshot + list interactive elements, then act. Static HTML can be tested via `file://`.
- Capture console errors and failed requests in every e2e run; a passing test with console errors is not passing.
- Visual checks via the `visual-qa` skill.
