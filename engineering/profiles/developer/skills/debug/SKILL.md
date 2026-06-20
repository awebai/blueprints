# Skill: debug

Find and fix the root cause - never patch a symptom.

## When to use

A test fails, an exception appears, logs show an error, or code behaves
differently than expected.

## Method

1. **Reproduce reliably.** Get a consistent, minimal repro before investigating.
   An intermittent bug you can't trigger on demand isn't understood yet.
2. **Read the error.** Read the full message and stack trace carefully - they
   often name the cause or the fix directly. Don't skim them.
3. **Locate, don't guess.** Trace to the actual line and state involved. Compare
   against a working example in the codebase doing the same thing correctly.
4. **One hypothesis at a time.** Form a single, specific hypothesis about the
   cause. Predict what you'd see if it's true.
5. **One change at a time.** Make the smallest change that tests the hypothesis.
   Run the test. If it doesn't behave as predicted, revert and re-analyze - don't
   stack fixes.
6. **Fix the cause.** Once you understand it, fix the root cause, not the
   surface. Add or adjust a test so the bug can't come back silently.
7. **Verify clean.** Full suite green, output pristine. If the bug produced log
   noise, make sure the fix removes it.

## Anti-patterns

- Adding a workaround that hides the symptom while the cause remains.
- Changing several things at once and declaring victory when it goes green.
- Suppressing an error or a warning instead of resolving it.
- Pretending to understand. If you don't, say "I don't understand X" and dig or
  ask.

## Escalate

If the root cause turns out to be a design problem, a contract mismatch with
another component, or anything touching identity/auth/data, stop and raise it
with the coordinator rather than working around it.
