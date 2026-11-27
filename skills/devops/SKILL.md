---
name: devops
description: Ship and run apps reliably - deployment (Vercel, Hetzner/VPS, Docker, Coolify, Fly, Railway), CI/CD with GitHub Actions, environments and secrets, databases and migrations in production, backups and restore tests, monitoring, logging, uptime and incident basics, EU/GDPR-friendly hosting. Use for deploy, hosting, CI, Docker, backup, monitoring or "go live" requests.
when_to_use: 'Triggers: deploy, деплой, задеплой, hosting, хостинг, сервер, Docker, CI, CD, GitHub Actions, pipeline, backup, бэкап, monitoring, мониторинг, logs, логи, production, продакшен, go live, Hetzner, Vercel, Domain, SSL'
---

# DevOps

Production is where the app meets reality. Goal: **boring, reproducible deploys; nothing lost when something breaks; problems noticed before customers notice.**

## Choose hosting
- Next.js/static frontends: Vercel or Netlify (EU region, DPA signed) - or self-host on a VPS when data must stay fully in the EU.
- Apps with DB/backend for the German market: Hetzner (or another EU provider) with Docker Compose or Coolify; managed Postgres (EU) when the team cannot run databases.
- Keep it simple: one VPS + Docker Compose + Caddy (automatic HTTPS) beats Kubernetes for most small and mid-size apps.

## Build and deploy
- Reproducible builds: lockfiles, pinned base images (`node:22-alpine@sha256…` or at least a version tag), multi-stage Dockerfiles, non-root user, healthcheck, `.dockerignore`.
- CI on every PR (GitHub Actions): install (frozen), lint, typecheck, tests, build, dependency audit, secret scan. Deploy only from `main` after green CI; preview deploys for PRs.
- Actions security: pin third-party actions to commit SHAs, minimal `permissions:`, secrets in environments with protection rules, no secrets in logs.
- Zero-downtime: health checks, rolling restart or blue/green; database migrations backward-compatible (expand -> migrate -> contract), run as a separate step, never destructive in the same release that stops using a column.
- Config via environment variables validated at startup; separate dev/staging/prod with separate credentials.

## Data safety
- Automated backups of databases and uploaded files: daily (or point-in-time), encrypted, stored off-site (different provider/region), retention defined (e.g. 7 daily, 4 weekly, 12 monthly).
- **A backup that was never restored is not a backup**: schedule a restore test (monthly) and document the runbook.
- Least-privilege DB users; DB not reachable from the internet; SSH by key only, no root login, firewall (only 22/80/443), automatic security updates.

## Observe
- Error tracking (Sentry or similar, EU region, PII scrubbing), structured JSON logs with request IDs, uptime checks with alerts (email/Telegram/Slack), basic metrics (CPU, memory, disk, response times, error rate).
- Alerts on disk > 80 %, backup failures, certificate expiry, error-rate spikes.
- Incident basics: status page or customer message template, rollback command documented and tested.

## Go-live checklist
- [ ] HTTPS + HSTS, security headers, domain + DNS (SPF/DKIM/DMARC if sending email)
- [ ] Backups running and one restore tested
- [ ] Monitoring and alerts verified by triggering a test alert
- [ ] Secrets rotated from development values; debug off; error pages without stack traces
- [ ] Impressum, Datenschutzerklärung, cookie consent where required
- [ ] Load-tested the critical path if traffic is expected (k6/autocannon)
