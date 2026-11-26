---
name: landing-page
description: Plan, write and build high-converting marketing websites and landing pages that look premium - structure, copy, sections, SEO and performance. Use when creating or redesigning a landing page, marketing site, product page, portfolio or pricing page. Works together with the design skill for visual design.
when_to_use: 'Triggers: landing, website, marketing site, home page, pricing page, portfolio, лендинг, сайт'
---

# Landing page

Visual quality comes from the `design` skill - load and follow it. This skill covers what makes a site *work*: message, structure, proof and speed.

## 1. Message first
Before layout, write:
- **Audience**: who exactly, and what they are trying to get done.
- **Promise** (headline, <= 10 words): the outcome for the user, specific to this product. Not a slogan about the product.
- **Subheadline** (1-2 sentences): how it delivers the promise and for whom.
- **Primary CTA**: one specific verb phrase ("Start a 14-day trial", "Book a 20-min demo"). One primary CTA across the page; secondary CTA only if it serves a different intent.
- **Proof**: the strongest real evidence available (customer logos, numbers with sources, testimonials with name/role/photo, ratings, case studies).
If real content is missing, write realistic draft copy and mark it clearly for the user to replace - never fake customers or statistics.

## 2. Structure (adapt; cut what does not apply)
1. **Header**: logo, 3-5 nav links, CTA. Sticky with background blur only after scroll.
2. **Hero**: promise, subheadline, CTA, and a *specific* product visual (real UI, a short loop video, an interactive demo) - not a generic illustration.
3. **Proof strip**: logos or a single strong metric/testimonial.
4. **Problem -> solution**: the pain in the user's words, then how the product resolves it.
5. **How it works**: 3 steps max, each with a real visual.
6. **Key features as benefits**: 3-4 deep sections alternating layout (not a 6-card grid), each answering "so what?" for the user.
7. **Social proof**: testimonials with real attribution, case-study numbers.
8. **Pricing** (if applicable): 2-3 tiers, recommended tier highlighted, annual/monthly toggle, feature comparison collapsed below.
9. **FAQ**: real objections (price, security, migration, cancellation). Use `<details>` or an accessible accordion.
10. **Final CTA**: restate the promise + CTA.
11. **Footer**: navigation, legal, contacts, social.

## 3. Copy rules
- Write to the reader ("you"), concrete nouns and numbers, short sentences, no buzzwords ("revolutionary", "seamless", "unlock", "leverage", "next-generation").
- Each section heading should make sense on its own when skimming.
- Microcopy under CTAs reduces risk ("No credit card required", "Cancel anytime") - only if true.
- Write in the site's language natively (German by default); do not translate English idioms literally. Correct umlauts, German typography („Anführungszeichen“, non-breaking spaces in numbers and units).

## 4. Technical requirements
- Framework: Next.js (App Router, static/SSG where possible) or Astro for content-heavy sites; use what the project has.
- **Performance budget**: LCP < 2.5s, CLS < 0.1, INP < 200ms on mobile. Hero image optimized (AVIF/WebP, `priority`/`fetchpriority="high"`, correct `sizes`), fonts preloaded and subset, no heavy JS for static sections, lazy-load below-the-fold media and third-party embeds.
- **SEO**: unique `<title>` (<= 60 chars) and meta description (<= 155 chars), one `h1`, logical heading order, Open Graph + Twitter image (1200x630), canonical URL, `sitemap.xml`, `robots.txt`, JSON-LD (`Organization`, `Product`/`SoftwareApplication`, `FAQPage` when applicable), descriptive `alt` text, `lang` attribute.
- **Analytics hooks**: CTA clicks and form submits identifiable (data attributes or event calls), without blocking render.
- **Forms**: minimal fields, inline validation, clear success state, spam protection, accessible labels and errors.
- **Legal (DE/EU)**: Impressum and Datenschutzerklärung linked from every page; cookie consent only for non-essential cookies, with equal reject/accept buttons and no tracking before consent; self-hosted fonts (no Google Fonts CDN).

## 5. Verify
Run the `visual-qa` skill (375 / 768 / 1440, light/dark if supported), then the `web-quality` skill for Lighthouse, accessibility and SEO checks. Fix everything below 90 in Performance, Accessibility, Best Practices and SEO unless there is a stated reason.
