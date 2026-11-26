---
name: tdd
description: Test-driven development loop (red -> green -> refactor) for implementing features and fixing bugs with high confidence. Use for business logic, algorithms, parsers, API handlers, data transformations and any bug fix, or when the user asks for TDD or "write tests first".
when_to_use: "implement", "add logic", "fix bug", "write tests first", "TDD", "edge cases"
---

# TDD

Tests written first describe behavior; tests written after tend to describe the implementation. Use this loop for logic-heavy code. For pure visual work, use `visual-qa` instead.

## Loop
1. **List behaviors.** Write the test names first as a checklist: happy path, boundaries (empty / one / many / max), invalid input, errors, and the specific bug if fixing one.
2. **Red.** Write ONE failing test for the next behavior. Run it and confirm it fails for the expected reason (assertion failure, not an import error or typo).
3. **Green.** Write the minimum code to pass. Run the test; then run the nearby suite.
4. **Refactor.** Clean up names, duplication and structure in both code and tests while everything stays green. Run the suite again.
5. Repeat for the next behavior. Commit at green points if the user wants commits.

## Bug fixes
Always reproduce first: a test that fails because of the bug, then the fix, then confirm the test passes and nothing else broke.

## Rules
- Use the project's existing test framework and conventions; find the command in CLAUDE.md, package.json, pyproject.toml, Makefile.
- Test behavior through public interfaces. Mock only system boundaries (network, time, randomness, filesystem).
- Never change a test's expectation just to make it pass unless the requirement itself changed - say so explicitly if it did.
- Keep the loop tight: run only the relevant test file while iterating (`vitest run path`, `pytest path::test -q`, `go test ./pkg -run Name`), the full suite at the end.
- Finish with the full test command output summary in your reply.
