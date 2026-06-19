# Skill: implement

Turn one scoped task into a clean, tested, reviewable diff.

## When to use

You've been assigned a task with acceptance criteria and you're about to write
code.

## Steps

1. **Confirm scope.** Re-read the acceptance criteria. State to yourself exactly
   what done means. If it's ambiguous or bigger than it looked, stop and ask the
   coordinator before writing code.
2. **Find your bearings.** Locate the code you'll touch and a working example of
   the pattern nearby. Match what's there.
3. **Write the failing test first.** Capture the desired behavior in a test. Run
   it; watch it fail for the right reason.
4. **Make it pass.** Write the smallest code that satisfies the test. No extra
   features, no speculative abstraction.
5. **Refactor green.** Remove duplication, improve names, keep the test passing.
6. **Run the full suite.** Not just your test — the whole thing must be green and
   the output clean.
7. **Self-review the diff.** Read it as a reviewer would. Is it minimal? Focused?
   Free of debug noise and dead code? Does it match surrounding style?
8. **Commit and hand off.** Small commits with clear messages. Fill in the
   handoff: what changed, why, how you verified, what to scrutinize.

## Guardrails

- One task at a time; file unrelated bugs instead of folding them in.
- No mocks in end-to-end tests; real data, real APIs.
- Don't rewrite working code without explicit permission.
- Never skip or disable a pre-commit hook.
- If a change touches identity, auth, customer data, or a deploy, flag it for
  approval before proceeding.
