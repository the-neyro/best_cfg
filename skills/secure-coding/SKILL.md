---
name: secure-coding
description: Build and review features with security by default - authentication, authorization, sessions, input validation, APIs, file uploads, payments, secrets, security headers, dependencies, LLM features and GDPR/DSGVO. Use whenever code handles users, data, money, files, external input or credentials, and before any release.
when_to_use: 'Triggers: auth, login, signup, password, session, API, upload, payment, Stripe, webhook, admin, roles, security, безопасность, Sicherheit, DSGVO, GDPR, before release'
---

# Secure coding

Assume every endpoint is attacked on day one. Security is designed in, not added at the end.

## Workflow
1. **Threat-model in 5 lines** before building: assets (what is valuable), actors (anonymous, user, admin, other tenant), entry points (routes, forms, webhooks, uploads, LLM input), trust boundaries, worst realistic abuse.
2. **Build with the defaults below.** When a requirement conflicts with them, stop and tell the user the risk and the secure alternative.
3. **Verify**: write tests for the abuse cases (another user's id, missing auth, oversized/invalid input, replayed webhook), run the dependency audit, and for anything non-trivial delegate to the `security-auditor` subagent (or run its checklist yourself).

## Defaults by area
Detailed checklists with code patterns: `references/checklists.md`.

- **Validation**: one schema per input at the boundary (zod/valibot/pydantic), strict (reject unknown keys), with length/size/range limits. Validate env vars at startup.
- **AuthN**: maintained library/provider (e.g. Auth.js, Better Auth, Clerk, Supabase Auth, Keycloak, Django/Laravel built-ins). Passkeys or MFA for admin. argon2id for passwords. Session cookies `HttpOnly; Secure; SameSite=Lax; Path=/`, rotated on login, server-side invalidation on logout/password change.
- **AuthZ**: checked server-side in every handler / server action / resolver, on the object level (`where: { id, ownerId: session.user.id }`). Deny by default. Multi-tenant: tenant id on every query, enforced by DB policies (Postgres RLS) where possible.
- **Data access**: parameterized queries/ORM only; least-privilege DB role; no raw SQL string concatenation; select only needed columns; never return password hashes, tokens or internal ids to clients unnecessarily.
- **Output**: framework auto-escaping; sanitize any HTML you must render (DOMPurify); strict CSP with nonces; never put user input into `href` without scheme allowlist (`javascript:`).
- **APIs**: rate limiting (per IP + per account), request size limits, timeouts, pagination caps, idempotency keys for payments, consistent error format without stack traces, CORS allowlist.
- **Webhooks**: verify signatures (Stripe `constructEvent`, HMAC with timing-safe compare), check timestamps against replay, process idempotently.
- **Files**: verify content type by magic bytes, size limits, random names, private storage + signed URLs, no SVG/HTML served inline from user uploads, image re-encoding.
- **Secrets**: environment / secret manager, never in repo or client bundle; separate keys per environment; rotate on leak; `.env.example` documents names only.
- **Headers**: HSTS, CSP, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy`, `frame-ancestors 'none'` unless embedding is needed.
- **Logging**: security events logged (login failures, permission denials, admin actions) without passwords, tokens or unnecessary personal data.
- **Dependencies & supply chain**: few, maintained, popular packages; check exact names (typosquatting); lockfile committed; `npm ci`; audit in CI; pin GitHub Actions to commit SHAs; no `curl | sh` installs.
- **LLM features**: treat model output as untrusted input (validate, escape, never execute directly); defend against prompt injection from retrieved content; tool calls behind allowlists, scopes and human confirmation for destructive actions; no secrets or other users' data in prompts.
- **Privacy (GDPR/DSGVO)**: data minimization, purpose limitation, consent for non-essential cookies/tracking, export and deletion flows, data processing agreements with vendors, EU data residency where possible. German-market sites need an Impressum and a Datenschutzerklärung.

## Never
- Roll your own crypto, JWT parsing or password hashing.
- Trust client-side checks, hidden fields, or `role` values sent by the client.
- Disable TLS verification, CSRF protection or CORS checks "to make it work".
- Log or echo secrets, even in debug output.
