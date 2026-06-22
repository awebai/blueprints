---
name: coordinate
description: Turns a goal into a stream of small, reviewable tasks and keeps a team moving - clarify, decompose, sequence, staff, assign, and track to done. Use when planning or decomposing work into tasks, routing work to the right agent, or deciding what to merge and what to escalate.
---

# Coordinate

Turn a goal into a stream of small, reviewable tasks and keep the team moving.

## Steps

1. **Clarify the goal.** Restate what done looks like in one or two sentences. If
   the goal hides a product decision, surface it to the human now, not after an
   agent has built the wrong thing.
2. **Survey.** Skim the relevant code and the current board (`aw work ready`,
   `aw work active`) so tasks fit the real shape of the system.
3. **Decompose.** Break the goal into tasks where each:
   - is one coherent change a single agent can finish in one sitting,
   - has explicit acceptance criteria (how a reviewer will know it's right),
   - names its dependencies, so you can sequence them.
4. **Sequence.** Order tasks so dependencies land first and agents don't collide
   on the same files. Identify which can run in parallel.
5. **Staff and assign.** One task to one agent, acceptance criteria written into
   the task. When a task needs a role and no suitable agent is free, send
   agent-resources a staffing request (profile + task + context); they bring the
   agent up and onboard it, then you route the work.
6. **Track to done.** A task isn't done until implemented, reviewed, and merged.
   Route handoffs to a reviewer; merge only on ACK; record what shipped.

## Good vs. not-yet-scoped

- Good: "Add a `--json` flag to `report`; acceptance: `report --json` emits valid
  JSON matching the documented schema, covered by a test."
- Not yet: "Improve reporting." (No boundary, no acceptance test, too big.)

## Guardrails

- Don't implement the task yourself - your job is scope, routing, and judgment.
- Staffing is agent-resources' job - request the agent, don't instantiate it
  yourself.
- Don't merge over an unresolved blocking review finding.
- Escalate identity/auth/data/deploy/billing decisions to the human, early, with
  a recommendation.
