---
name: orchestrate
description: Run large or multi-part work as an orchestrator - decompose the task, decide what to delegate, brief specialist subagents precisely, run independent work in parallel, verify and integrate results. Use for features spanning several areas (backend + frontend + tests), new apps (ERP, CRM, sites), audits, research across many sources, or any task too big for one focused pass.
when_to_use: 'Triggers: build an app, сделай приложение, ERP, CRM, full project, end to end, parallel, agents, team, многоагентно, großes Feature, audit everything'
---

# Orchestration

You are the lead. Subagents bring parallelism, isolation of noisy work and an unbiased second opinion - **not** extra intelligence. Delegation costs tokens and context-gathering time, so delegate deliberately.

## 1. Scale effort to the task
| Task | Approach |
|---|---|
| Small fix, one file, clear cause | Do it yourself. No subagents. |
| Normal feature (one area) | Do it yourself; then one `code-reviewer` pass. Add `security-auditor` only for risk areas (auth, payments, personal data, uploads, money, migrations). |
| Feature across areas / new module | `architect` plan -> implement (parallel `implementer`s for independent packages) -> `test-writer` -> reviewers in parallel. |
| New app / large system (ERP, CRM, platform) | `/spec` with the user first -> `architect` -> phased build, 2-4 parallel implementers per phase -> full review round per phase. |
| Research / audit across many sources | 2-5 parallel `researcher`s with disjoint scopes -> you synthesize. |

## 2. Team (Claude Code subagents)
| Agent | Use for | Model |
|---|---|---|
| `architect` | Decompose, data model, plan with independent work packages | opus, xhigh |
| `implementer` | Build one well-scoped package and verify it | opus, high |
| `test-writer` | Tests for packages, regression tests | sonnet, high |
| `debugger` | Root cause when not obvious | opus, xhigh |
| `code-reviewer` | Independent correctness review of a diff | opus, high |
| `security-auditor` | Security review | opus, high |
| `ui-reviewer` | Screenshot-based design critique | opus, high |
| `researcher` | Current docs, library choices, market/tech research | sonnet, medium |
| `editor` | Make texts human, clear and on-tone | opus, high |
| `fact-checker` | Verify every claim and number in a text/report | opus, high |
Built-in `Explore` for broad read-only codebase searches.

## 3. The delegation brief (every single delegation)
Vague briefs make subagents duplicate work or solve the wrong problem. Always include:
```
GOAL: one sentence - the outcome, not the activity.
CONTEXT: what is already known/decided; relevant files (paths); spec/plan location; constraints.
SCOPE: exactly what to touch. OUT OF SCOPE: what not to touch (other packages' files!).
DONE WHEN: concrete, checkable criteria (tests X pass, endpoint returns Y, screenshot shows Z).
OUTPUT: the exact format to return (e.g. "files changed + commands run with results + open issues, max 200 words").
```

## 4. Parallel work rules
- Parallelize only truly independent packages with **disjoint files**. Shared files (schema, routes index, design tokens) are done first by one agent or by you.
- Run parallel implementers with **worktree isolation** (Agent tool `isolation: "worktree"`), then merge their branches one at a time, running tests after each merge.
- Launch independent agents in the same message so they run concurrently; when several reviewers are warranted by risk, run them in parallel.
- Keep the count small: 2-4 parallel agents per phase is usually optimal; more creates merge pain and token burn.

## 5. Trust, but verify
- Never forward a subagent's "done" to the user unverified: read the diff, re-run the key checks yourself.
- Reviewer findings: verify each one is real before fixing; reject false positives with a reason.
- If two agents disagree, investigate the code yourself instead of picking one.
- Integrate in small steps; keep the build green between steps.

## 6. Long runs: ledger and rulings
- Keep a progress ledger (`docs/plans/<slug>-progress.md`): packages, status, verification evidence. It survives context compaction.
- When you must decide something the plan did not cover, log it and continue: `Ruling: <decision> - <why> - <cost if wrong>`.
- Stop and ask the user only for: destructive operations, security-sensitive choices, external side effects (deploy, push, payments, emails to real people), or when every path is a guess.

## 7. Handling review feedback
- Give reviewers the exact range (`git diff <base_sha>..<head_sha>`), the requirements and what to focus on.
- For each finding: restate it, verify it against the code, then fix or reject with evidence. No performative agreement.
- Fix Critical immediately, Important before continuing, note Minor. Cap fix loops at ~3 rounds, then decide and log a ruling.
- YAGNI check on suggestions that add features or abstractions: grep for real usage first.

## 8. Agent teams (optional, experimental)
For work where agents must talk to each other (competing hypotheses, cross-layer debugging, adversarial review), Claude Code agent teams can be enabled with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. Start with 3-5 teammates, each owning its own files. For everything else, subagents are cheaper and simpler.

## 9. Final artifact
Apply the `verification` skill. Before reporting done: all phases merged, full test suite + typecheck + lint + build green, reviewers' critical findings fixed, UI checked with `visual-qa`, texts passed through `editor`/`fact-checker` where relevant. Report: what was built, how it was verified (commands + results), known limitations.
