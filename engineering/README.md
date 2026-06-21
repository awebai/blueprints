# Engineering AI Team

Run a small, coordinated engineering team of AI coworkers on a real codebase.

## Who's in the team

- **Coordinator** - turns a goal into small, reviewable tasks, assigns them,
  keeps everyone unblocked, routes finished work to review, and decides what
  merges. Escalates the risky calls (product direction, identity, data,
  deploys) to you.
- **Developer** (1-4) - implements one scoped task at a time, test-first, with
  the smallest correct change, and hands off a clean, reviewable diff with
  evidence.
- **Reviewer** - gives independent fresh-eyes review with a clear verdict,
  separating blocking issues (correctness, security, data loss, missing tests)
  from non-blocking suggestions.

Suggested first team: **1 coordinator, 2 developers, 1 reviewer.**

## How they work together

The agents share aweb **task** state, **mail** for handoffs, and **chat** for
quick questions. A task flows: coordinator scopes it -> a developer implements
test-first -> the reviewer ACKs or returns amendments -> the coordinator merges
and records the evidence. Nothing merges without a reviewer's ACK, and the
coordinator escalates anything risky to you.

## Expected apps

`library` (these profiles) and `tasks`/activity. **Expected apps are setup
hints, not access grants** - each app authenticates the team and enforces its
own policy; the profiles only declare
what the agents expect to use.

## Customize

These profiles are a starting point. Your team evolves them: an agent proposes
an improvement from its `.aw/profile`, you approve, and a new version is minted -
your private, improving copy. Adjust counts, swap runtimes (Claude Code, Codex,
Pi), or add your own skills.
