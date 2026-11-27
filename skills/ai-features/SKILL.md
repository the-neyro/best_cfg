---
name: ai-features
description: Build AI/LLM features into products - chat assistants, document and email processing, extraction to structured data, classification, summarization, RAG over company data, agents with tools - with correct model choice, structured outputs, cost control, evals and prompt-injection defenses. Use whenever an app should call an LLM (Claude or other providers).
when_to_use: 'Triggers: AI feature, ИИ, нейросеть в приложении, KI-Funktion, chatbot, чат-бот, LLM, Claude API, GPT, RAG, embeddings, extraction, классификация, assistant, агент, prompt'
---

# AI features in apps

An LLM feature is a probabilistic component inside deterministic software. Treat its output as untrusted input, measure quality with evals, and design for the cases where it is wrong.

## 1. Decide if and how
- Prefer the simplest tier: a single call (classify, extract, summarize) < a fixed workflow of calls < an agent with tools. Agents only when the steps cannot be specified in advance.
- Define success before building: 20-50 real examples with expected outputs (the eval set). No eval, no way to know whether a prompt change helped.

## 2. Model and API defaults (Claude)
- If the `claude-api` skill is available, load it - it has current model IDs, parameters and SDK patterns. Never guess API shapes from memory; check current docs.
- Default to the most capable current model for quality-critical features; use the small/fast tier for high-volume classification or extraction only after the eval shows it holds quality.
- Use the official SDK, streaming for long outputs, structured outputs (JSON schema) for anything the code parses, prompt caching for long stable system prompts and documents, and the provider's handling for refusals and stop reasons.
- Keep prompts in versioned files, not scattered strings; stable content first (cacheable), variable content last.

## 3. Safety and robustness
- **Prompt injection**: retrieved web pages, emails, PDFs and user uploads can contain instructions. Never let that content trigger tools with side effects; separate instructions from data; require human confirmation for destructive or outward actions (sending emails, payments, deletions).
- Validate every model output against a schema; on failure retry once with the error, then fall back gracefully.
- Never put secrets, other tenants' data or unnecessary personal data in prompts; respect GDPR (DPA with the provider, EU data residency options, retention settings).
- Rate-limit AI endpoints per user, cap tokens per request and per user per day, show costs in admin analytics.

## 4. UX
- Stream responses; show progress for long tasks; let users stop, edit and retry.
- Show sources/citations for answers grounded in documents; make it easy to report a bad answer.
- Be explicit that output is AI-generated where it matters (legal, medical, financial).

## 5. Evaluate and monitor
- Automated eval run on every prompt/model change (exact match, schema validity, or an LLM grader with a rubric checked against human labels).
- Log inputs/outputs (with PII redaction), latency, tokens and cost per feature; sample and review real traffic weekly.
