# Security checklists and patterns

Aligned with OWASP Top 10 (2025) and OWASP ASVS. Use the patterns, adapt to the stack.

## Input validation (TypeScript + zod)
```ts
import { z } from "zod";

export const CreateOrder = z.object({
  productId: z.string().uuid(),
  quantity: z.number().int().min(1).max(100),
  note: z.string().trim().max(500).optional(),
}).strict(); // reject unknown keys

const parsed = CreateOrder.safeParse(await req.json());
if (!parsed.success) return Response.json({ error: "Ungültige Eingabe" }, { status: 400 });
```

## Env validation at startup
```ts
const Env = z.object({
  DATABASE_URL: z.string().url(),
  AUTH_SECRET: z.string().min(32),
  STRIPE_SECRET_KEY: z.string().startsWith("sk_"),
});
export const env = Env.parse(process.env); // crash early, never run misconfigured
```

## Object-level authorization (IDOR prevention)
```ts
// Wrong: any logged-in user can read any invoice
const invoice = await db.invoice.findUnique({ where: { id } });
// Right: scope by owner/tenant in the query itself
const invoice = await db.invoice.findFirst({ where: { id, organizationId: session.orgId } });
if (!invoice) return notFound(); // 404, do not reveal existence
```
Next.js: check the session and permissions inside every Server Action and Route Handler - middleware alone is not authorization.

## Postgres Row Level Security (multi-tenant / Supabase)
```sql
alter table invoices enable row level security;
create policy "tenant isolation" on invoices
  using (organization_id = current_setting('app.org_id')::uuid);
```

## Security headers (Next.js `next.config.ts`)
```ts
const securityHeaders = [
  { key: "Strict-Transport-Security", value: "max-age=63072000; includeSubDomains; preload" },
  { key: "X-Content-Type-Options", value: "nosniff" },
  { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
  { key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=()" },
  { key: "X-Frame-Options", value: "DENY" },
];
export default { async headers() { return [{ source: "/(.*)", headers: securityHeaders }]; } };
```
Add a nonce-based Content-Security-Policy via middleware (`script-src 'self' 'nonce-…' 'strict-dynamic'; object-src 'none'; base-uri 'none'; frame-ancestors 'none'`).

## Rate limiting
- Login / signup / password reset / OTP: e.g. 5 attempts per 15 min per account + per IP, exponential backoff, generic error ("E-Mail oder Passwort falsch").
- Use a shared store (Redis/Upstash, database) in serverless or multi-instance deployments; in-memory limits do not work there.

## Webhook verification (Stripe)
```ts
const sig = req.headers.get("stripe-signature")!;
const event = stripe.webhooks.constructEvent(await req.text(), sig, env.STRIPE_WEBHOOK_SECRET);
// then: idempotency - store event.id, skip if already processed
```
Generic HMAC: compute over the raw body, compare with `crypto.timingSafeEqual`, reject timestamps older than 5 minutes.

## File uploads
- Allowlist types; detect by magic bytes (`file-type`), not by extension or the client's `Content-Type`.
- Size limit at the proxy and in code; random UUID names; private bucket + short-lived signed URLs.
- Re-encode images (sharp) to strip metadata and payloads; never serve user SVG/HTML inline.

## SSRF (server fetches a user-provided URL)
- Allowlist hosts where possible; otherwise resolve DNS and block private/loopback/link-local ranges (10/8, 172.16/12, 192.168/16, 127/8, 169.254/16, ::1, fc00::/7), disable redirects or re-check after each, enforce timeouts and size limits.

## Passwords and tokens
- argon2id (memory >= 19 MiB, iterations >= 2) or bcrypt cost >= 12.
- Tokens: `crypto.randomBytes(32)` / `crypto.randomUUID()`; store only hashes of reset/verification tokens; short expiry; single use.
- JWT: verify signature with a pinned algorithm, check `exp`, `iss`, `aud`; prefer server sessions for web apps.

## Dependency and CI hygiene
- `npm ci` / `pnpm install --frozen-lockfile`; `npm audit --omit=dev --audit-level=high` in CI.
- Dependabot/Renovate for updates; review new transitive install scripts.
- GitHub Actions: pin third-party actions to a full commit SHA, `permissions:` minimal per job, secrets only in protected environments.
- Secret scanning: gitleaks in pre-commit and CI.

## LLM / AI features
- Untrusted content (web pages, emails, documents, user files) can contain instructions: never let it trigger tools with side effects without confirmation.
- Validate structured model output with a schema before use; escape before rendering; never `eval` or run generated code outside a sandbox.
- Scope API keys and tools per feature; log tool calls; cap tokens and cost per user.

## GDPR / DSGVO quick list
- Record what personal data is processed, why, where, and for how long.
- Cookie banner only for non-essential cookies, with equal "Ablehnen" and "Akzeptieren" options; no tracking before consent.
- Self-host fonts (Google Fonts loaded from Google servers has been ruled a GDPR issue in Germany).
- Account deletion and data export available to users; retention limits enforced.
- Impressum (§ 5 DDG) and Datenschutzerklärung linked from every page of German-market sites.
