---
name: automation
description: Design and build reliable automations and integrations - workflows (n8n, Make, Zapier, Power Automate), scripts and cron jobs, webhooks, API integrations, data syncs, email/document processing, AI agents in workflows, scheduled reports. Use for any "automate this", integration, bot, scraper, ETL, sync or recurring-task request.
when_to_use: 'Triggers: автоматизация, автоматизируй, Automatisierung, automatisieren, n8n, Make, Zapier, webhook, integration, интеграция, cron, bot, бот, sync, Workflow, парсер, scraper, ETL'
---

# Automation

An automation is production software that runs while nobody watches. It must be **idempotent, observable, secure and recoverable** - otherwise it silently corrupts data at 3 a.m.

## 1. Understand the process
Write down: trigger (event, schedule, manual), inputs and their sources, each step, outputs and destinations, volume and frequency, what must never happen (duplicate invoices, emails to wrong customers), and who gets notified when it fails. Map the current manual process first and look for steps to remove rather than automate.

## 2. Choose the tool
- **No-code/low-code (n8n self-hosted preferred for GDPR, Make, Zapier)**: simple linear flows, business users maintain it, standard connectors exist.
- **Code (TypeScript/Python)**: complex logic, high volume, custom APIs, needs tests and version control. Run as a scheduled job (cron, GitHub Actions, cloud scheduler) or a small service with a queue.
- **AI step**: only where judgment on unstructured input is needed (classify an email, extract invoice fields). Use structured output with a schema, validate it, and route low-confidence cases to a human.

## 3. Reliability rules
- **Idempotency**: every run can be repeated safely. Use idempotency keys / external IDs, upserts instead of inserts, "already processed" markers.
- **Retries** with exponential backoff and jitter for transient errors (429, 5xx, timeouts); no retries for 4xx validation errors; respect rate limits.
- **Checkpoints / cursors** for batch syncs (last processed timestamp or ID) so a crash resumes instead of restarting.
- **Dry-run mode** that logs what would happen without writing anything; use it before the first real run.
- **Validation** of every input and API response with a schema; reject and report malformed data instead of guessing.
- **Timeouts** on every external call; overall run time limit.
- **Dead-letter handling**: failed items go to a list/queue with the error, for review and replay.
- **Logging and alerting**: structured logs with run ID; alert (email/Slack/Telegram) on failure and on suspicious results (zero records, 10x normal volume).

## 4. Security
- Credentials in the tool's credential store or a secret manager, never in workflow JSON, code or logs. Least-privilege API scopes, separate keys per environment.
- Verify webhook signatures; restrict who can trigger manual runs.
- Personal data: minimal fields, GDPR-compliant processors (EU hosting where possible), retention limits.

## 5. Deliver
- Version control: export workflow JSON (n8n/Make) or code into the repo, with a README: purpose, trigger, schedule, credentials needed (names only), how to run, how to replay failures, owner.
- Tests: unit tests for transformations; an end-to-end test against a sandbox/test account.
- First run supervised in dry-run, then on a small batch, then full.
