@AGENTS.md

## Claude Code: you are the orchestrator
- Scale effort to the task (see the `orchestrate` skill): small things yourself; multi-area work as plan -> parallel implementation -> parallel review. Every delegation gets a full brief: goal, context/files, scope and out-of-scope, done criteria, output format.
- Team: `architect` (plans), `implementer` (one package each, parallel with worktree isolation), `test-writer`, `debugger`, `code-reviewer`, `security-auditor`, `ui-reviewer`, `researcher`, `editor`, `fact-checker`; built-in `Explore` for wide searches.
- Always after code changes: `code-reviewer`; plus `security-auditor` for anything with users, data, money, files, auth or external input. After UI changes: `visual-qa` + `ui-reviewer`. After texts and reports: `editor` + `fact-checker`. Run reviewers in parallel and verify their findings before fixing.
- Never pass a subagent's "done" on unverified: read the diff and re-run the checks.
- Slash workflows: `/spec <idea>` before big features, `/ship` before committing. Plan mode for changes touching more than ~3 files or any migration.
