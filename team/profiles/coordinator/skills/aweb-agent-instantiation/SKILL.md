---
name: aweb-agent-instantiation
description: This skill should be used when staffing a team — instantiating, refreshing, running, onboarding, or retiring an agent built from a shipped blueprint profile. Covers creating and launching one teammate with aw team add --start, reconciling materialized homes with aw team up, refreshing them after profile evolution, removing team membership, and handing the agent its first task over mail. The mechanics that turn a profile into a working teammate.
allowed-tools: "Bash(aw *), Bash(rm *), Bash(mkdir *)"
---

# aweb Agent Instantiation

Use this skill to turn a shipped blueprint profile into a **live teammate**:
materialize its home, bring the local team up, refresh the home when its profile
improves, and retire it cleanly when the work is done. This is the
**mechanics** layer. The role using this skill supplies the staffing
*judgment* — when to staff, who, and how to onboard. The **coordinator** uses it
for local, name-only agents; the **AR (agent resources)** role uses it for the
same local mechanics and additionally owns global, identity-bearing staffing
through `manage-team-identities`. This skill is the *how*.

For team coordination (tasks, work discovery, locks) load `aweb-coordination`;
for mail/chat policy load `aweb-messaging`. This skill assumes those and covers
only the instantiate/run/refresh/remove mechanics they do not.

## What you produce

A materialized agent home and a running teammate. The home carries the agent's
identity and body, and the work happens outside the home itself:

- `AGENTS.md` — composed from the profile, including the injected aweb
  coordination block and the profile's working-layout instructions.
- `CLAUDE.md` — symlink for Claude Code homes.
- `.aw/` — identity, team certificate state, and `.aw/profile/ref.json` with the
  profile provenance, digest, and runtime pin.
- `worktree/` — when git-worktree setup is available, every agent gets its own
  git worktree of the selected work repo on its own branch; this is where task
  git/build/test work happens.
- `work-main/` — only when the teammate's profile has `works_on_main: true`, a
  deliberate symlink to the work repo's main checkout for roles that must inspect
  or operate on main.

The agent reads its profile, connects to the aweb channel, and is reachable over
`aw mail` — it wakes on mail, acts as its profile, and replies.

## Preconditions — check, don't assume

- You can run a local tmux session. `aw team add --start` launches a single new
  teammate; `aw team up` reconciles the materialized fleet.
- Use `aw 1.31.0+`, which includes `aw team add --start`, `aw team up`, and the
  `works_on_main` home anatomy.
- You are a member of the team you are staffing into.

## The add spec (aw 1.31+)

`aw team add` accepts these everyday agent specs:

- `[NAME@]BLUEPRINT/PROFILE[:local|global][=RUNTIME]` — materialize a profile
  from a public blueprint. The blueprint defaults to `aweb.team` when omitted,
  and profile-only selectors can use `--blueprint` / `AWEB_BLUEPRINT`.
- `NAME[:local|global]` — create an empty-profile home.
- Omitted names are server-authoritative; do not invent the next classic name
  locally when the command can choose it.
- `=RUNTIME` selects the materialization target (`claude-code`, `pi`, `codex`,
  or `local-shell`). Runtime binds at **materialize** time: a `pi` home differs
  from a `claude-code` home.
- `--home <dir>` writes a single agent to a specific home directory.
- `--work-dir <repo>` points the agent `worktree/` at a separate project repo;
  the default is the repo containing the home, and non-git homes skip worktree
  setup gracefully.
- `--layout-only` creates the `agents/instances/<name>` layout without creating
  identity state; use only for deliberate layout preparation, not normal
  staffing.
- `--start` launches the added agent in tmux after materializing it. It handles
  exactly one agent, rejects `--layout-only`, accepts `--session`, `--attach`,
  and `--no-attach` like `aw team up`, and skips launch if the home is already a
  running process cwd.

**Scope — local agents only.** `aw team add` defaults to local identity scope,
which creates a name-only member scoped to exactly this team and is the boundary
of this skill. Do **not** pass `--global` and do **not** use the `:global` spec
suffix here. Global agents (a stable `did:aw`, optional addresses, reusable
memberships across teams) are a separate identity-level operation owned by the
**AR** role via the `manage-team-identities` skill.

## Create and launch one local teammate

For a single teammate, `--start` is the primary staffing path. `aw team add
[NAME@]BLUEPRINT/PROFILE[:local|global][=RUNTIME] --start` materializes the
home, sets up the home/worktree isolation (plus `work-main/` for
`works_on_main` roles), and launches the agent in tmux in one command via the
same team-up path: channel preflight, prompt auto-answering, and `pi --approve`.

```bash
aw team add alice@aweb.team/developer:local=claude-code --start --no-attach
aw team add bob@aweb.team/reviewer:local=pi --start --session <session>
```

For one explicit target directory:

```bash
aw team add "alice@aweb.team/developer:local=claude-code" --home "agents/instances/alice" --start --no-attach
```

`--start` handles exactly one agent. It is rejected with `--layout-only`, takes
`--session`, `--attach`, and `--no-attach` like `aw team up`, and skips launch if
the home is already a running process cwd.

Materialization produces the home anatomy above. The default work repo is the repo
containing the home; use `--work-dir <repo>` to point `worktree/` at a separate
project repo. When git-worktree setup is available, the release aw creates
`worktree/` for every teammate and creates `work-main/` only for profiles with
`works_on_main: true`; non-git homes skip worktree setup gracefully. The
materializer installs the right channel integration.

Operator note: the teammate's layout follows the teammate profile's
`works_on_main` value, not the operator's role. Inspect the recorded profile
provenance before you run or refresh it, and include the teammate's `worktree/`
path in the first-task onboarding mail so the agent knows where to do the work.
Never do git work in the teammate's home directory.

```bash
aw agent profile show alice
```

After launch, onboard over mail and leave the TTY alone:

```bash
aw mail send --to "alice" --subject "onboarding" --body "<role + project context + first scoped task; work in agents/instances/alice/worktree/>"
```

The channel injects the mail; the agent wakes, acts as its profile, and replies.
From here coordinate only over mail/chat (`aweb-messaging`) — never by driving
the TUI.

## Materialize first, then reconcile the fleet with `aw team up`

Use the two-step flow when you are preparing several homes before launching, when
you intentionally want to inspect the materialized home first, or when you need
to reconcile/restart existing materialized teammates:

```bash
aw team add alice@aweb.team/developer:local=claude-code
aw team add bob@aweb.team/reviewer:local=pi
aw team up --dry-run
aw team up
```

`aw team up` is the fleet/reconcile/restart path. It scans
`agents/instances/<name>` for materialized homes, reads each home's runtime from
`.aw/profile/ref.json`, and starts one tmux window per supported interactive
runtime. It is idempotent: homes already running are skipped; run it again after
materializing more homes, after a refresh, or after a runtime is killed.

Useful controls:

```bash
aw team up --session <name>      # choose the tmux session name
aw team up --no-attach           # start/reconcile but do not attach
aw team up --attach              # attach/switch after launch
aw team up --force               # ignore the active-home running-process check
aw team up --recreate            # kill and recreate the tmux session
```

`aw team up` preflights the channel/runtime itself:

- For `claude-code`, it ensures the Claude Code `aweb-channel` plugin is
  installed, launches Claude with the aweb channel and
  `--dangerously-skip-permissions`, and auto-answers the known trust-folder and
  development-channel prompts.
- For `pi`, it ensures `npm:@awebai/pi@latest` is installed and launches `pi
  --approve` in the agent home.

Supported launch runtimes are `claude-code` and `pi`. `codex` and `local-shell`
can be materialized, but they are not launched by `aw team up`; start those
manually from the materialized home if you intentionally use them.

## Refresh an existing agent after profile evolution

A running home does **not** pick up shelf/profile changes just because a profile
proposal was approved. Refresh is the closing step of the learning loop:

```bash
aw team refresh <name>
```

`aw team refresh <name>` re-materializes `agents/instances/<name>` from the
latest version of the profile recorded in that home's `.aw/profile/ref.json`.
It reads the recorded profile ref locally and never asks a remote service which
profile to use. It prunes the managed set, preserves local state outside that
managed set, updates `.aw/profile/ref.json`, and is a no-op when the digest is
unchanged.

Upstream blueprint improvements are a separate, composable step: pull them onto
the team's private shelf first with the Library plugin, then refresh the home:

```bash
aw library update-from-source --profile_ref <profile_ref>
aw team refresh <name>
```

Re-run `aw team up` after refresh. It reconciles idempotently and starts only
homes that are not already running; use `--force` or `--recreate` deliberately
when you need to restart a running home.

## Remove / retire an agent

Removal is a lifecycle step, not just a process cleanup.

1. **Stop the runtime first.** In Claude Code use `/quit`, or close the tmux
   window/pane. For pi, quit/close that interactive process.
2. **Remove team membership with the everyday verb:**

   ```bash
   aw team remove-agent <member-address>
   ```

   This is revocation only: customer-controlled teams revoke with the local team
   controller key; hosted aweb.ai teams use the cloud-mediated controller revoke
   endpoint.
3. **Decide deliberately what to do with the home directory.** `aw team
   remove-agent` does not delete the home. The home persists by default for
   audit/recovery. Deleting it is separate and irreversible; do it only when the
   team explicitly wants the local files gone.

## Guardrails — do NOT use these (each is a known dead-end)

- Earlier per-agent launcher commands are gone; `aw team up` is the only run
  path. Launching an interactive runtime detached, without a TTY and the team-up
  channel preflight, does not work for Claude Code or pi.
- **`--global` or `:global` in this skill** — global staffing belongs in
  `manage-team-identities`, not the local instantiation flow.

## References

- `docs/running-agents.md` and `docs/team-blueprints-sot.md` (aweb repo) — the
  about-to-release run/materialization contract.
- The **AR (agent resources)** blueprint profile — the role that orchestrates
  this skill: when to staff, onboarding content, roster tracking, retire.
