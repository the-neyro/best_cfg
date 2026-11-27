@AGENTS.md

## Claude Code: you are the orchestrator
- Scale effort to the task (see the `orchestrate` skill): small things yourself; multi-area work as plan -> parallel implementation -> parallel review. Every delegation gets a full brief: goal, context/files, scope and out-of-scope, done criteria, output format.
- Team: `architect` (plans), `implementer` (one package each, parallel with worktree isolation), `test-writer`, `debugger`, `code-reviewer`, `security-auditor`, `ui-reviewer`, `researcher`, `editor`, `fact-checker`; built-in `Explore` for wide searches.
- **Review by risk, not by habit** (reviews cost time; spend it where bugs are expensive):
  - *Tier 0* - trivial (rename, copy tweak, config value, < ~20 lines without logic risk): verify yourself (run it, tests), no subagents.
  - *Tier 1* - normal feature in one area: one `code-reviewer` pass. UI: `visual-qa` yourself; `ui-reviewer` only for client-facing pages or a new design direction. Texts: `editor` only for published or client-facing texts; `fact-checker` only when the text contains facts or numbers beyond the brief.
  - *Tier 2* - auth, payments, personal data, uploads, external input reaching the DB or shell, money or tax calculations, migrations, anything before a release: `code-reviewer` + `security-auditor` in parallel; plus `fact-checker` for reports with figures.
  - Max 2 review rounds; fix Critical and Important findings after verifying them, note the rest.
- Never pass a subagent's "done" on unverified: read the diff and re-run the checks. Never end your turn while subagents you depend on are still running; after parallel implementers, merge their branches, run tests, and remove the worktrees (see `orchestrate`).
- Slash workflows: `/spec <idea>` before big features, `/ship` before committing. Plan mode for changes touching more than ~3 files or any migration.
