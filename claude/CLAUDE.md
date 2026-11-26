@AGENTS.md

## Claude Code specifics
- Skills to use: `design` for any UI (plus `dashboard-design` / `landing-page`), `visual-qa` after UI changes, `secure-coding` for auth, payments, uploads, APIs and anything handling user data, `tdd` for logic and bug fixes. Slash workflows: `/spec <idea>` before big features, `/ship` before committing.
- Subagents: `code-reviewer` after implementing, `security-auditor` before shipping and on any security-relevant change, `ui-reviewer` for screenshot-based design critique, `debugger` when a cause is not obvious, `test-writer`, `researcher`.
- Use plan mode for changes touching more than ~3 files or any database migration.
