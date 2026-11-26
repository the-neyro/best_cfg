---
name: debugging
description: Systematic root-cause debugging for bugs, failing or flaky tests, crashes, wrong output and performance problems. Use whenever something does not work as expected and the cause is not already proven - before changing any code to "fix" it.
when_to_use: 'Triggers: bug, баг, ошибка, не работает, сломалось, Fehler, funktioniert nicht, kaputt, crash, error, failing test, flaky, exception, stack trace, regression'
---

# Systematic debugging

**Iron law: no fix without a confirmed root cause.** Patching symptoms creates new bugs.

## Phase 1 - Root cause
- Read the full error and stack trace; note the exact message, file and line.
- Reproduce deterministically (failing test, script or exact steps). If it does not reproduce, gather evidence first: logs, inputs, versions, environment, recent changes (`git log -p`, `git bisect` for regressions).
- Trace backwards from where the error surfaces to where the bad value or state is *created*. Read the real code on that path.
- Done when: you can point at the line where things first go wrong.

## Phase 2 - Pattern analysis
- Find working code that does something similar and diff it against the broken path.
- Check assumptions about inputs, types, nullability, async ordering, time zones, encodings, caching, environment variables.

## Phase 3 - Hypothesis
- Write ONE specific hypothesis: "X happens because Y, so if I change Z, W will happen."
- Test it with the smallest single-variable change or probe (log, assertion, debugger). Confirmed or refuted - never both changed at once.

## Phase 4 - Fix
- Write a failing test that reproduces the bug first.
- Fix at the origin, not downstream with guards. Run the test, then the whole relevant suite.
- Remove temporary probes. Apply the `verification` skill before claiming it is fixed.

## Red flags
| Thought | Reality |
|---|---|
| "Let me just try this quick fix" | Guessing. Go back to Phase 1. |
| "One more attempt" after 2+ failed fixes | Stop. After 3 failed fixes, question the design/architecture and tell the user. |
| "The test is probably wrong" | Prove it, or fix the code. Never weaken assertions, skip tests or add sleeps/retries to hide failures. |
| "It works on my machine / now it passes" | Flaky: look for shared state, ordering, timing, randomness, time zones. |
| "Multiple things are broken, fix them all at once" | One variable at a time. |
