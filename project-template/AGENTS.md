# AGENTS.md

Instructions for AI coding agents (Claude Code, Codex, Cursor, Gemini CLI, Copilot, ...).
Keep this file short and specific. Fill in every `TODO`, delete sections that do not apply.
Do not describe the folder structure here - agents read the code. Write only what they cannot infer.

## Project
TODO: one or two sentences - what this is and who uses it.

## Commands
- Install: `TODO (e.g. pnpm install)`
- Dev server: `TODO (e.g. pnpm dev -> http://localhost:3000)`
- Typecheck: `TODO (e.g. pnpm typecheck)`
- Lint: `TODO (e.g. pnpm lint)`
- Test all: `TODO (e.g. pnpm test)`
- Test one file: `TODO (e.g. pnpm vitest run path/to/file.test.ts)`
- E2E: `TODO (e.g. pnpm playwright test)`
- Build: `TODO (e.g. pnpm build)`

## Stack decisions
TODO: only the non-obvious choices, e.g.
- UI: Tailwind CSS v4 + shadcn/ui; design tokens live in `src/styles/globals.css` - never hardcode colors or sizes.
- Data fetching: TanStack Query on the client, Server Components by default.
- Validation: zod schemas in `src/lib/schemas/`, shared by client and server.
- Errors: use helpers in `src/lib/errors.ts`; never throw raw strings.

## Conventions
TODO: rules that differ from tool defaults, e.g.
- Named exports only; one component per file.
- Server code must not import from `src/components/client/`.
- Database changes only through migrations in `db/migrations/`.

## Gotchas
TODO: things that bit you or the agent before, e.g.
- `src/legacy/` is still live, but do not copy its patterns into new code.
- Integration tests need `DATABASE_URL`; see `.env.example`.

## Definition of done
- Typecheck, lint and the relevant tests pass (show the command output).
- UI changes are checked in a real browser at mobile and desktop widths, light and dark.
- New behavior has tests; fixed bugs have a regression test.
- No secrets, debug logs or commented-out code in the diff.
