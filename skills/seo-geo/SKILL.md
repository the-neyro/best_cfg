---
name: seo-geo
description: Search visibility for websites and content - classic SEO (Google, Bing, Yandex) and GEO / AI search optimization (getting cited by ChatGPT, Perplexity, Google AI Overviews / AI Mode, Gemini, Claude). Covers technical SEO, structured data, content structure, keyword and entity research, local SEO, multilingual sites (DE/RU/EN) and measurement. Use for any SEO, GEO, AEO, rankings, traffic, "AI search" or content-strategy request.
when_to_use: 'Triggers: SEO, СЕО, GEO, AEO, LLMO, ранжирование, Ranking, Sichtbarkeit, Google, ChatGPT finds us, AI Overviews, Perplexity, keywords, ключевые слова, Suchmaschine, трафик'
---

# SEO + GEO

Classic SEO gets a page ranked; GEO gets it **quoted** by AI answer engines. Both reward the same core: a crawlable, fast site with clear, specific, trustworthy content about well-defined entities. Do the fundamentals first - tricks without them do nothing.

## 1. Audit before changing anything
Run through `references/checklist.md` against the live site (or the build) and list issues by impact. Measure the baseline: indexed pages (Search Console), Core Web Vitals, top queries and pages, and AI visibility (ask ChatGPT, Perplexity, Gemini and Google AI Mode the 10-20 questions customers really ask; record whether and how the brand is cited).

## 2. Technical foundation (both SEO and GEO)
- Server-rendered or static HTML for all important content - many AI crawlers do not execute JavaScript. Check with `curl -s URL | grep "key sentence"`.
- `robots.txt`: allow search engines and the AI **retrieval** bots that produce citations (`OAI-SearchBot`, `ChatGPT-User`, `PerplexityBot`, `Perplexity-User`, `Claude-SearchBot`, `Claude-User`, `Googlebot`, `Bingbot`). Training crawlers (`GPTBot`, `ClaudeBot`, `Google-Extended`, `CCBot`) are a separate business decision - ask the user. Check CDN/WAF bot rules too (Cloudflare often blocks AI bots by default).
- `sitemap.xml` with `lastmod`, canonical URLs, clean URL structure, no orphan pages, internal links with descriptive anchor text.
- Core Web Vitals green on mobile (see `web-quality` skill).
- Structured data (JSON-LD) that matches visible content: `Organization` (with `sameAs` to official profiles), `WebSite`, `BreadcrumbList`, `Article` (author, dates), `Product`/`Offer`, `SoftwareApplication`, `LocalBusiness`, `FAQPage` only for real FAQs. Validate with Google's Rich Results Test.
- Multilingual: one URL per language (`/de/`, `/ru/`, `/en/`), `hreflang` incl. `x-default`, translated slugs and metadata, never auto-redirect by IP.
- `llms.txt` is optional: cheap to add, but major engines are not known to rely on it. Never prioritize it over the items above.

## 3. Content that ranks and gets cited
- **One page = one clear intent.** Map keywords/questions to pages; no two pages competing for the same intent.
- **Answer first**: the direct answer in the first 1-2 sentences under each question-style heading, then depth. Short paragraphs, descriptive H2/H3, lists and tables for comparisons, specs and steps.
- **Specifics beat adjectives**: numbers, prices, dates, versions, named examples, original data, quotes from named experts. AI engines prefer citable, verifiable statements.
- **Entity clarity**: say plainly what the brand/product is, for whom, where, at what price; keep names, descriptions and facts identical across the site, Google Business Profile, LinkedIn, Wikipedia/Wikidata (if eligible), directories and marketplaces.
- **E-E-A-T**: real author pages with credentials, first-hand experience (photos, case studies, test results), sources linked, "last updated" dates that reflect real updates.
- **Freshness**: review important pages on a schedule; update facts, dates and examples rather than only the timestamp.
- **Off-site presence** drives AI citations: mentions in reputable publications, review platforms, Reddit/forums, YouTube, industry lists and comparisons. Earn them; never buy links or spam.
- Write like a human (`human-writing` skill): AI-sounding filler is ignored by readers and gives engines nothing to quote.

## 4. Local and market specifics
- Local: Google Business Profile complete and consistent NAP (name, address, phone), reviews strategy, local pages per real location.
- Germany: Impressum and Datenschutzerklärung, German keyword research with real search phrasing (compound nouns, "kaufen", "Kosten", "Erfahrungen"), `.de`/`/de/` targeting.
- Russian-speaking markets: also Yandex (Yandex Webmaster, regional settings, Turbo/feeds where relevant).

## 5. Measure
- Search Console / Bing Webmaster / Yandex Webmaster: impressions, clicks, CTR, positions per query; indexing errors.
- AI referrals in analytics (referrers like chatgpt.com, perplexity.ai, gemini.google.com, copilot.microsoft.com, claude.ai).
- Repeat the AI question set monthly and log citations per engine.

## Never
Keyword stuffing, hidden text, doorway pages, mass AI-generated pages without unique value, fake reviews or schema that does not match the page, buying links. These get sites penalized and destroy trust with AI engines too.
