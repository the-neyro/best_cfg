---
name: web-quality
description: Audit and fix web performance (Core Web Vitals), accessibility (WCAG 2.2 AA), SEO and best practices for a website or web app using Lighthouse, axe and code inspection. Use before launch, after big UI changes, or when the user mentions speed, Lighthouse, PageSpeed, SEO or accessibility.
when_to_use: 'Triggers: lighthouse, pagespeed, slow site, performance, core web vitals, SEO, accessibility, a11y, before launch'
---

# Web quality audit

## 1. Measure (production build, not dev server)
Build and start the production server, then:
```bash
# Lighthouse (mobile emulation by default)
npx -y lighthouse http://localhost:3000 --quiet --chrome-flags="--headless=new" \
  --only-categories=performance,accessibility,best-practices,seo \
  --output=json --output-path=.lighthouse/report.json
# Extract scores and failing audits
node -e "const r=require('./.lighthouse/report.json');for(const c of Object.values(r.categories))console.log(c.title,Math.round(c.score*100));for(const a of Object.values(r.audits))if(a.score!==null&&a.score<0.9&&a.details)console.log('-',a.id,'|',a.title,'|',a.displayValue||'')"
```
If Chrome is not found, set `CHROME_PATH` to the Playwright Chromium binary. For accessibility, also run axe via Playwright (`@axe-core/playwright`) on key pages if available.

## 2. Fix by impact
**Performance**
- LCP: preload/priority the hero image, serve AVIF/WebP with correct `sizes`, avoid client-side rendering for the hero, reduce server response time (static generation, caching).
- CLS: width/height or aspect-ratio on media, reserve space for embeds and banners, font `size-adjust` / fallback metrics.
- INP: split long tasks, defer non-critical JS, avoid heavy hydration (Server Components, islands), debounce input handlers.
- Bundle: analyze (`@next/bundle-analyzer`, `vite-bundle-visualizer`), remove unused deps, dynamic-import heavy components (charts, editors, maps), tree-shake icon imports.
- Third parties: load analytics/chat widgets after interaction or idle; self-host fonts.

**Accessibility (WCAG 2.2 AA)**
- Color contrast, focus visible, keyboard operable (no traps, logical order), skip link, landmarks, headings in order, labels and error messages tied to inputs (`aria-describedby`), accessible names for icon buttons, `alt` text, reduced motion, target size >= 24px (44px recommended), no content only on hover.

**SEO**
- Title/description per page, one `h1`, canonical, OG/Twitter tags, `sitemap.xml`, `robots.txt`, JSON-LD structured data, crawlable links (`<a href>`), meaningful URLs, `lang`, `hreflang` for multi-language.

**Best practices**
- HTTPS, no console errors, no deprecated APIs, correct image aspect ratios, security headers (CSP, HSTS, X-Content-Type-Options, Referrer-Policy).

## 3. Re-measure and report
Re-run Lighthouse after fixes. Report before/after scores per category and the list of fixes. Target >= 90 in every category on mobile; explain anything that cannot reach it.
