---
name: business-apps
description: Design and build world-class business software - ERP, CRM, inventory, orders, invoicing, accounting, HR, project management, booking, admin and back-office systems, internal tools and B2B SaaS. Covers domain modeling, data integrity, multi-tenancy, roles and permissions, audit trails, workflows, integrations, German compliance (GoBD, DATEV, XRechnung/ZUGFeRD, DSGVO) and power-user UX. Use for any ERP, CRM or business-system request.
when_to_use: 'Triggers: ERP, CRM, склад, Lager, Warenwirtschaft, инвойс, Rechnung, счёт, бухгалтерия, Buchhaltung, заказы, Aufträge, admin panel, back office, internal tool, B2B SaaS, Kundenverwaltung, учёт'
---

# Business apps (ERP / CRM / back office)

What makes business software worth a fortune: **the data is always right, every action is traceable, the workflows match how the business really runs, and power users fly through it with the keyboard.** Pretty screens come last - but they come (use `design` + `dashboard-design`).

## 1. Discovery - model the business, not the screens
Ask (or infer and confirm) in one batch: industry, company size and users/roles, current tools (Excel, DATEV, Lexoffice, SAP, HubSpot…), the 3-5 core processes end to end (e.g. lead -> quote -> order -> delivery -> invoice -> payment -> dunning), documents produced, integrations, legal requirements, data to migrate. Write a short domain glossary (DE/RU/EN terms) - one name per concept, used everywhere in code and UI.

## 2. Architecture defaults
- **Modular monolith** first (clear modules: crm, sales, inventory, purchasing, invoicing, accounting, hr, projects, core), not microservices. Modules talk through explicit service interfaces, never through each other's tables.
- **PostgreSQL** as the single source of truth. Strong constraints in the database: foreign keys, `NOT NULL`, `CHECK`, unique constraints, exclusion constraints for overlaps (bookings).
- **TypeScript full-stack** (Next.js or a React SPA + Node API, Drizzle/Prisma, zod) or **Django/Laravel** when admin-heavy - pick what the team knows. Background jobs via a queue (pg-boss, BullMQ, Celery).
- Generated, typed API contracts (OpenAPI or tRPC) and a public REST API + webhooks from day one if customers will integrate.

## 3. Data integrity rules (non-negotiable)
- **Money**: integer minor units (cents) or `numeric(19,4)`; never floats. Store currency per amount. Rounding rules explicit (commercial rounding per line vs. total - decide and test).
- **Tax**: VAT rates as data with validity dates (19 %, 7 %, 0 %, reverse charge, OSS); store the rate used on each document line.
- **Documents are immutable once issued**: invoices, credit notes, delivery notes get gapless sequential numbers per number range, never edited or deleted - corrections via cancellation/credit note (GoBD).
- **Accounting**: double-entry ledger (every transaction balances to zero), postings append-only, period close/lock.
- **Inventory**: stock as a ledger of movements (receipt, issue, transfer, adjustment) with the current quantity derived or kept in sync transactionally; no negative stock unless configured; reservations separate from on-hand.
- **Concurrency**: transactions around every multi-row business operation; optimistic locking (`version` column) on editable records; idempotency keys on create endpoints.
- **Time**: store UTC (`timestamptz`), display in the user's time zone; business dates (invoice date, due date) as `date`.
- **History**: audit log for every change (who, when, what, before/after) on business records; soft delete (`archived_at`) for master data; hard delete only for GDPR erasure.

## 4. Multi-tenancy, roles, security
- `tenant_id` on every tenant-owned table, enforced by Postgres Row Level Security + application checks; tests that prove tenant isolation.
- RBAC with permissions per module and action (`invoice.create`, `invoice.approve`), optional record-level rules (own customers only), field-level restrictions for sensitive data (salaries, margins). Approval workflows with limits (four-eyes principle).
- Everything in the `secure-coding` skill applies; SSO (OIDC/SAML) and MFA for business customers.

## 5. Workflows and automation
- Explicit **state machines** for documents and processes (quote: draft -> sent -> accepted/declined -> converted), transitions guarded by permissions and validations, every transition logged.
- Background jobs for heavy work (PDF generation, imports, syncs, emails) with progress, retries and failure reporting (see `automation` skill).
- Notifications in-app + email, configurable per user; tasks and reminders (follow-ups, dunning levels, expiring contracts).

## 6. German / EU compliance (when the market is DE/EU)
- **GoBD**: immutability, traceability, gapless numbering, retention (10 years for invoices/booking records), procedure documentation, export for auditors (GDPdU/IDEA format).
- **E-invoicing**: B2B e-invoices in Germany must be receivable since 2025 and issued in a structured format (XRechnung / ZUGFeRD-Factur-X) on the legal timeline - generate and parse both; validate against the official schemas.
- **DATEV** export (EXTF booking batch format) and SKR03/SKR04 account mapping for accountants.
- **DSGVO**: processing records, deletion concepts that respect retention duties, data processing agreements, EU hosting.
- Mandatory invoice fields (§ 14 UStG), dunning and payment terms, SEPA (pain.001/pain.008) when payments are handled.
Confirm current legal requirements against official sources (BMF, DATEV docs) - rules and deadlines change.

## 7. Power-user UX (what makes users love it)
- Fast data tables: server-side sort/filter/search, saved views, column chooser, inline edit, bulk actions, CSV/Excel export, keyboard navigation.
- **Command palette** (Cmd/Ctrl+K) for navigation and actions; global search across customers, orders, invoices.
- Keyboard shortcuts for frequent actions; forms that never lose input (autosave drafts), smart defaults, validation inline.
- Record pages: header with key facts and status, primary actions, related records in tabs, activity timeline (changes, emails, notes, tasks).
- Status workflows (orders, tickets, repairs, deals) get a **board view** (columns per status, move items between them, counts per column) next to the table - it is how people actually run their day.
- **First run shows the app working**: for prototypes and demos the default start command loads realistic seed data (clearly marked as demo data, resettable); the empty states are still designed for real first use.
- Imports with preview, column mapping, validation report and rollback; templates for documents (PDF) with the customer's branding.
- Speed budget: list views < 300 ms server time, interactions feel instant (optimistic updates where safe).
- Follow `design` + `dashboard-design`: dense but calm, no card walls, tabular numbers, designed empty/loading/error states.

## 8. Quality bar
- Domain logic in pure, unit-tested services (TDD for money, tax, stock, numbering, permissions - see `tdd`).
- Integration tests against a real Postgres (Testcontainers) including concurrency cases.
- E2E tests (Playwright) for each core process end to end.
- Seed data that looks real (German companies, addresses, VAT IDs, realistic amounts) for demos and tests.
- Migrations reversible and reviewed; backups and restore tested.

## References
- `references/modules.md` - core entities and fields per module, ready to adapt
