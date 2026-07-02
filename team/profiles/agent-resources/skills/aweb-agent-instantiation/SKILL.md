---
name: aweb-agent-instantiation
description: This skill should be used when staffing a team — instantiating, refreshing, running, onboarding, or retiring an agent built from a shipped blueprint profile. Covers materializing the agent home with aw team add, launching materialized homes with aw team up, refreshing them after profile evolution, removing team membership, and handing the agent its first task over mail. The mechanics that turn a profile into a working teammate.
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

A running agent built from a profile: it reads its profile (`AGENTS.md`),
connects to the aweb channel, and is reachable over `aw mail` — it wakes on
mail, acts as its profile, and replies.

## Preconditions — check, don't assume

- You can run a local tmux session. `aw team up` is the canonical launcher and
  creates one tmux window per supported materialized agent home.
- Use the about-to-release `aw` that includes `aw team up`. These skills ship
  with that release; older installed `aw 1.30.0` help is not authoritative for
  the run flow.
- You are a member of the team you are staffing into.

## The add spec (aw 1.30+)

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
- `--layout-only` creates the `agents/instances/<name>` layout without creating
  identity state; use only for deliberate layout preparation, not normal
  staffing.

**Scope — local agents only.** `aw team add` defaults to local identity scope,
which creates a name-only member scoped to exactly this team and is the boundary
of this skill. Do **not** pass `--global` and do **not** use the `:global` spec
suffix here. Global agents (a stable `did:aw`, optional addresses, reusable
memberships across teams) are a separate identity-level operation owned by the
**AR** role via the `manage-team-identities` skill.

## Create local agents

Materialize homes first. The run step is separate and handled by `aw team up`.
Keeping this as a two-step flow lets you inspect, refresh, or add more homes
before launching.

```bash
aw team add alice@aweb.team/developer:local=claude-code
aw team add bob@aweb.team/reviewer:local=pi
```

For one explicit target directory:

```bash
aw team add "alice@aweb.team/developer:local=claude-code" --home "agents/instances/alice"
```

Materialization produces `AGENTS.md` (profile body + the injected aweb
coordination block), `CLAUDE.md` symlink for Claude Code homes, `.aw/` identity
and team-cert state, and `.aw/profile/ref.json` recording the profile provenance,
digest, and runtime kind. The fixed about-to-release materializer installs the
right channel integration.

Inspect a home's recorded profile provenance before you run or refresh it:

```bash
aw agent profile show alice
```

## Run the materialized team with `aw team up`

The canonical launcher is:

```bash
aw team up --dry-run
aw team up
```

`aw team up` is an operator-managed tmux launcher. It scans
`agents/instances/<name>` for materialized homes, reads each home's runtime from
`.aw/profile/ref.json`, and starts one tmux window per supported interactive
runtime. It is an idempotent reconcile: homes already running are skipped; run it
again after materializing or refreshing more homes.

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

After launch, onboard over mail and leave the TTY alone:

```bash
aw mail send --to "alice" --subject "onboarding" --body "<role + project context + first scoped task>"
```

The channel injects the mail; the agent wakes, acts as its profile, and replies.
From here coordinate only over mail/chat (`aweb-messaging`) — never by driving
the TUI.

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
