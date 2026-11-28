---
name: learn
description: Turn a correction or a repeated mistake into a lasting rule, so it never happens again - writes one precise line into the right place (project AGENTS.md Gotchas/Conventions, a path-scoped rule, or a hook proposal). Use when the user runs /learn, corrects the same thing a second time, or says "remember this for this project" / "запомни для проекта" / "merk dir das".
argument-hint: "[what to remember - optional, defaults to the last correction]"
---

# Learn

Lesson to capture: $ARGUMENTS (if empty: the most recent correction or mistake in this conversation).

## 1. Distill
Write the lesson as ONE concrete, checkable line - what to do, where, and why if not obvious.
- Bad: "Be careful with dates."
- Good: "Invoice dates are business dates: store as `date`, compute deadlines in Europe/Berlin (`src/lib/dates.ts`), never from UTC timestamps."

## 2. Choose the right place
| Kind of lesson | Where |
|---|---|
| Project fact, command, convention, pitfall | Project `AGENTS.md` -> `## Gotchas` or `## Conventions` |
| Applies only to some files (e.g. all migrations, all API routes) | `.claude/rules/<topic>.md` with `paths:` frontmatter |
| Must hold every time, no exceptions (never edit X, always run Y) | Propose a hook or a deny rule instead of text, and show the exact config |
| Personal preference across all projects | Tell the user it belongs in their global `~/.claude/AGENTS.md` (from the config repo) and propose the line - do not edit global files unasked |

## 3. Write it
- Check for an existing line that covers it; update that line instead of adding a duplicate or a contradiction.
- Keep the file short: if a section grows past ~15 lines, merge or remove stale lines (ask before deleting anything the user wrote).
- No emphasis words (IMPORTANT, NEVER in caps) - a precise sentence is enough; if it needs force, it needs a hook.

## 4. Confirm
Show the exact line(s) added or changed and the file path, in one short message.
