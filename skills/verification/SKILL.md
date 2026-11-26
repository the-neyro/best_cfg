---
name: verification
description: Evidence before claims - the gate every agent passes before saying "done", "fixed", "passes", "works" or "ready". Use before every completion report, before committing, after a subagent reports success, and whenever about to state that something works.
when_to_use: 'Triggers: done, fixed, works, ready, finished, fertig, erledigt, готово, сделано, before reporting results'
---

# Verification before completion

**Iron law: no completion claim without fresh evidence produced in this turn.** "Should work", "looks right" and an earlier run do not count.

## The gate
1. Name the command or observation that proves the claim.
2. Run it completely (not a subset, not with `--bail` hiding later failures).
3. Read the full output and the exit code.
4. Only then claim - and quote the evidence (command + key output line).

## Claim -> required evidence
| Claim | Evidence |
|---|---|
| "Tests pass" | Full relevant test command, exit 0, count of passed tests |
| "Build succeeds" | Production build command, exit 0 (lint passing is not a build) |
| "Types are fine" | Typecheck command over the whole project, exit 0 |
| "Bug is fixed" | Reproduction now passes AND a regression test that failed before the fix passes now |
| "Regression test works" | Revert the fix -> test fails -> restore fix -> test passes |
| "UI looks right" | Screenshots at 375/768/1440 (light+dark) actually viewed, no console errors |
| "Subagent finished X" | Its diff inspected (`git diff`) and its key check re-run by you |
| "Number in report is correct" | Recomputed from source data with code |
| "Secure" | Specific checks run (authz tests, audit, secret scan) and listed |

## Red flags - stop and verify
- You are about to write "should", "probably", "I believe", "seems to" next to a result.
- You fixed something and did not re-run the failing check.
- Only part of the suite ran; warnings were skipped over; output was truncated.
- The success report came from someone else (subagent, tool summary).

If verification is impossible (no test setup, missing credentials, no browser), say exactly what was not verified and why. Never paper over it.
