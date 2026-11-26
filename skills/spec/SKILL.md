---
name: spec
description: Turn a feature idea into a clear written spec and implementation plan before coding, by interviewing the user about the unclear parts. Use for new features, large changes, new projects, or whenever the request is ambiguous or touches many files.
argument-hint: "[feature idea]"
disable-model-invocation: true
---

# Spec -> plan -> build

Feature: $ARGUMENTS

Good specs remove the guesswork that causes rework. Do this before writing code.

## 1. Explore
Read the relevant parts of the codebase: existing patterns, data models, routes, components, tests and conventions that this feature will touch. Note constraints you discover.

## 2. Interview
Ask the user only the questions whose answers change the implementation, in one batch, each with your recommended default so they can just confirm. Typical areas: users and permissions, data and edge cases, UX states, integrations, performance/scale, what is explicitly out of scope. Skip questions the code already answers.

## 3. Write the spec
Create `docs/specs/<feature-slug>.md` (or the location the project uses):

```markdown
# <Feature>
## Goal
One paragraph: the user problem and the outcome.
## Requirements
- [ ] R1 ... (testable statements)
## Out of scope
## UX
Screens/states (loading, empty, error, success), key copy.
## Technical design
Data model changes, API/contracts, components, files to touch, migrations.
## Edge cases & risks
## Verification
Tests to add, commands to run, manual/visual checks.
## Plan
1. Small, independently verifiable steps in order.
```

## 4. Confirm and build
Show a short summary of the spec and ask for approval (or use plan mode). Then implement step by step, checking off requirements, running the verification for each step. At the end, have the `code-reviewer` subagent review the diff against the spec and fix real gaps.
