# i18n (DE / RU / EN) and e-mail templates

## i18n setup
- Library: `next-intl` (Next.js) or `i18next`/`react-i18next`; messages in ICU MessageFormat, one JSON file per locale, keys by feature (`invoice.create.title`), no string concatenation.
- Locale in the URL (`/de/`, `/ru/`, `/en/`) for SEO; detect from `Accept-Language` on first visit, let the user switch, remember the choice.
- **Plurals** differ: German/English have one/other; Russian has one/few/many/other (`1 счёт`, `2 счёта`, `5 счетов`, `21 счёт`). Always use ICU plural rules, never `count === 1 ? … : …`.
- Formatting via `Intl`: dates (DE `27.11.2026`, RU `27.11.2026`, EN-US `11/27/2026`), numbers (DE `1.234,56`, RU `1 234,56`, EN `1,234.56`), currency (`1.234,56 €` / `1 234,56 €` / `€1,234.56`), relative time.
- Layout: German strings are ~30 % longer, Russian words can be long too - no fixed-width buttons, allow wrapping, test with the longest locale.
- Typography per locale: quotes „…“ (DE), «…» (RU), “…” (EN); non-breaking spaces before units and in number groups.
- Fonts must include Cyrillic glyphs when Russian is supported (check subsets: `latin`, `latin-ext`, `cyrillic`).
- Translations written natively (see `human-writing`), not machine-literal; formal "Sie" vs informal "du" decided per product and used consistently.

## Transactional e-mail templates
- Build with React Email or MJML; output table-based HTML with inline styles; max width ~600px; always include a plain-text version.
- Works in Outlook, Gmail (web/app) and Apple Mail, light and dark mode (test both; avoid pure white logos on transparent backgrounds).
- Content: clear subject (<= 50 chars), preheader text, one primary action as a real button (bulletproof button), sender name the user recognizes.
- Legal (DE): Impressum details in the footer of marketing mails, unsubscribe link (List-Unsubscribe header) for anything non-transactional, double opt-in for newsletters.
- Deliverability: SPF, DKIM and DMARC set for the sending domain; send via a reputable provider (Postmark, Resend, SES, Brevo - EU options for GDPR); separate streams for transactional and marketing mail.
- Security: no sensitive data in the email body; sign-in and reset links single-use, short-lived, and never include passwords.
