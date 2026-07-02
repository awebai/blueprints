# aweb AI Team

The default first-party blueprint: a complete AI team that plans, builds,
reviews, and runs real product work over shared aweb task/mail/chat state.

## The default set

Adopt these to start — they are the working core:

- **coordinator** (1) — the long-lived planning and routing surface. Turns
  goals into small reviewable tasks, staffs them, gates merges on review, and
  escalates the calls that are the human's to make.
- **developer** (2, scale 1–4) — implements one scoped task at a time,
  test-first, and hands off a clean, reviewable diff with evidence.
- **reviewer** (1) — reads the diff fresh and gives an independent
  blocking-vs-non-blocking verdict before anything merges.
- **agent-resources** (1) — owns identity, the fleet, and the team's
  profiles; provisions and retires global agents on request.

## Opt-in roles

Add these when the work calls for them:

- **frontend-author** — writes aweb-style web pages in the Paper/Clay system.
- **proofreader** — reads and polishes copy and web pages in the house voice.
- **deployer** — executes releases and verifies them on the live URLs.
- **reliability** — watches the live services and runs incidents.

## First missions

- Turn this product goal into a set of scoped, reviewable tasks and staff them.
- Implement this issue test-first and hand it to the reviewer.
- Review this diff and give a blocking-vs-non-blocking verdict before merge.
- Provision a new global agent for the team and onboard it.

The profiles describe behavior, not tool lock-in: agents adapt to whichever
runtime each one uses (see each profile's `runtime_hints`).
