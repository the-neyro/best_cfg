# SEO + GEO audit checklist

Mark each item OK / FIX / N/A. Report FIX items ordered by impact with the exact change.

## Crawl & index
- [ ] `robots.txt` reachable, not blocking important paths or CSS/JS; retrieval AI bots allowed; training bots per business decision
- [ ] CDN/WAF does not block search or AI retrieval bots (test with their user agents)
- [ ] `sitemap.xml` valid, submitted, only canonical 200 URLs, `lastmod` accurate
- [ ] Important content present in raw HTML (`curl` test), not only after JS
- [ ] Canonical tags correct; no duplicate URLs (http/https, www, trailing slash, parameters)
- [ ] No important pages `noindex`; no soft-404s; redirects single-hop 301
- [ ] Internal linking: every page reachable within 3 clicks, descriptive anchors, no orphans

## On-page
- [ ] Unique `<title>` (<= 60 chars, primary topic first) and meta description (<= 155 chars) per page
- [ ] Exactly one `h1`; logical H2/H3 hierarchy; question-style headings where users ask questions
- [ ] Direct answer in the first 1-2 sentences of each section
- [ ] Specific facts (numbers, prices, dates, names), original data or experience, sources linked
- [ ] Author, publish and update dates visible on articles; author page exists
- [ ] Images: descriptive file names, `alt`, modern formats, dimensions set
- [ ] Open Graph / Twitter tags with 1200x630 image

## Structured data
- [ ] `Organization` + `WebSite` on home, `sameAs` to official profiles
- [ ] Page-type schema (`Article`, `Product`, `SoftwareApplication`, `LocalBusiness`, `BreadcrumbList`, `FAQPage` for real FAQs)
- [ ] Schema matches visible content; passes Rich Results Test without errors

## Performance & UX
- [ ] LCP < 2.5s, CLS < 0.1, INP < 200ms on mobile (field data if available)
- [ ] Mobile-friendly, no intrusive interstitials, readable font sizes

## International
- [ ] Separate URLs per language, `hreflang` reciprocal incl. `x-default`, `lang` attribute correct
- [ ] Translated metadata and slugs; no IP-based forced redirects

## Entity & off-site (GEO)
- [ ] Brand/product described identically across site, Google Business Profile, social profiles, directories
- [ ] Present in relevant comparisons, reviews, forums, publications; brand mentions growing
- [ ] Wikidata/Wikipedia entry if notable (never self-promotional)

## Measurement
- [ ] Search Console (+ Bing / Yandex Webmaster) verified
- [ ] Analytics segment for AI referrers
- [ ] Monthly AI-visibility log: 10-20 real customer questions x engines (ChatGPT, Perplexity, Gemini, Google AI Mode, Copilot) -> cited? which URL? competitor cited instead?

## Legal (DE/EU)
- [ ] Impressum, Datenschutzerklärung, cookie consent for non-essential cookies, self-hosted fonts
