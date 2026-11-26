---
name: ship
description: Pre-commit quality gate - run every check the project has, get an independent review, fix real problems, then create a clean commit. Run with /ship when a piece of work is ready.
argument-hint: "[optional commit message hint]"
disable-model-invocation: true
---

# Ship

Goal: the work is verified, reviewed and committed cleanly. Hint from the user: $ARGUMENTS

## 1. Inventory
- `git status` and `git diff --stat` to see what changed. Flag files that should not be committed (secrets, `.env*` except examples, build output, screenshots, large binaries, debug logs) and leave them out.

## 2. Run every check the project defines
Detect commands from CLAUDE.md / package.json scripts / Makefile / pyproject / CI config, then run in this order and read every output:
1. Format check (prettier/biome/ruff format --check/gofmt)
2. Lint (eslint/biome/ruff/clippy/golangci-lint)
3. Typecheck (tsc --noEmit / mypy / pyright)
4. Tests (unit, then integration)
5. Build (production build)
Fix failures caused by this change. If a failure is pre-existing and unrelated, report it instead of masking it.

## 3. Review
- Delegate the diff to the `code-reviewer` and `security-auditor` subagents (in parallel). Without subagents, run their checklists yourself, starting with the `secure-coding` skill.
- Run the secret scan on the staged diff (`gitleaks git --staged` if installed) and the ecosystem audit (`npm audit --omit=dev --audit-level=high`, `pip-audit`, ...).
- For UI changes: `slop-scan` from the `design` skill and the `visual-qa` skill.
- Fix Critical and Important findings that are real; explain any you reject.
- Re-run the checks affected by fixes.

## 4. Verification gate
Apply the `verification` skill: every claim in the report backed by a command run in this turn.

## 5. Commit
- Stage only the intended files (by name, not `git add -A` blindly).
- Commit message in German: imperative subject <= 72 chars, blank line, body with what and why if non-trivial. Follow the repo's convention (e.g. Conventional Commits prefixes) if it has one.
- Do not push unless the user asks.

## 6. Report
Checks run with results, review findings fixed/declined, the commit hash and message.
