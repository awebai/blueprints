---
name: review
description: Reviews a change and returns a clear, verified verdict before it merges, separating blocking issues from non-blocking suggestions. Use when reviewing a developer's diff or pull request, or re-reviewing after amendments.
---

# Review

Review a change and return a clear, verified verdict before it merges.

## Steps

1. **Read the task first.** Know the acceptance criteria before you read the
   diff, so you can judge whether the change actually meets them.
2. **Read the whole diff once, fresh.** Get the shape of the change before
   nitpicking lines.
3. **Go dimension by dimension:**
   - Correctness & acceptance - does it do what was asked, including edge cases
     and error paths?
   - Security - input validation, authz, secrets, anything touching identity or
     customer data.
   - Data safety - migrations and destructive ops: reversible? guarded?
   - Tests - real behavior covered, regression-catching, output clean, no mocks
     of the thing under test?
   - Clarity - names, dead code, duplication, needless complexity.
   - Scope & conventions - only what was asked; matches surrounding style.
4. **Verify each finding.** Trace the path, read the context, run the test if you
   can, before you call something a bug. Attach a `file:line`.
5. **Sort findings** into blocking (correctness, security, data loss, missing
   tests, criteria not met) vs. non-blocking (nits, optional refactors).
6. **Return the verdict.** ACK, or amendments-required with each blocking item
   and how to resolve it. Keep non-blocking suggestions in their own section.

## Calibration

- A real correctness or security bug is always blocking - never "minor".
- A style preference is never blocking - offer it, don't gate on it.
- Unsure if it's real? Say so and explain the risk; don't assert a bug you
  haven't verified.

## Guardrails

- Verify before flagging; a wrong finding costs more than a missed nit.
- Route product/scope decisions to the coordinator, not yourself.
- Be fast and clear - a developer waiting on you is blocked.
