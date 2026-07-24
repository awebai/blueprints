---
name: aweb-agent-instantiation
description: This skill should be used when staffing a team — creating and populating a team from shipped blueprint profiles, launching the roster, adding one teammate later, refreshing homes after profile evolution, removing team membership, and handing agents their first tasks over mail. The mechanics that turn profiles into working teammates.
allowed-tools: "Bash(aw *), Bash(rm *), Bash(mkdir *)"
---

# aweb Agent Instantiation

Use this skill to turn shipped blueprint profiles into a **live roster**:
create and populate a team, launch it, add one teammate later when needed,
refresh homes when profiles improve, and retire agents cleanly when the work is
done. This is the **mechanics** layer. The role using this skill supplies the
staffing *judgment* — when to staff, who, and how to onboard. The
**coordinator** commonly staffs local identity-scope, name-only agents; the
**AR (agent resources)** role uses the same mechanics and additionally owns
global identity-scope staffing through `manage-team-identities`. This skill is
the *how*.

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

- You can run a tmux session. `aw team create --agent ...` populates a roster;
  `aw team up` launches and reconciles it; `aw team extend --start` adds one
  teammate later.
- Use `aw 1.32.9+`. It is the first released line whose local forced-re-key
  command works against homes actually materialized by add/extend, and it
  includes the team-create roster flags, `aw team extend`, `aw team add --start`,
  `aw team up`, and the `works_on_main` home anatomy.
- You are a member of the team you are staffing into, or you have explicit
  API-key authority for the team you intend to staff.

## Create, populate, then launch the roster

Use the right verb; they are not interchangeable:

- `aw team create NAME` always creates a **new** team; repeated `--agent` specs
  populate its initial roster.
- `aw team extend SPEC...` adds to an **existing** team and may discover
  authority from the current workspace, an invite-capable `agents/instances`
  home, or explicitly intended API-key authority.
- `aw team add SPEC...` is the lower-level current-workspace primitive. It
  requires the cwd itself to hold an active team workspace; it does not discover
  a sibling agent home. Keep it for explicit `--home` / `--layout-only` use and
  other cases where the current workspace is deliberately the authority anchor.

Never teach `create` as an add-if-team-exists command or `add` as a
clean-directory bootstrap command.

The primary staffing flow is **create + populate + up**: create the team, declare
its initial roster with one `--agent` flag per teammate, then launch the
materialized roster.

Hosted team:

```bash
aw team create eng --username <u> --first-agent-local \
  --agent alice@aweb.team/developer:local=pi \
  --agent bob@aweb.team/reviewer:local=claude-code \
  --agent charlie@aweb.team/proofreader:local=claude-code
aw team up
```

Self-hosted/BYOT team:

```bash
aw team create eng --byot --namespace <domain> --username <u> --first-agent-local \
  --agent alice@aweb.team/developer:local=pi \
  --agent bob@aweb.team/reviewer:local=claude-code \
  --agent charlie@aweb.team/proofreader:local=claude-code
aw team up
```

Use `--first-agent-global` instead when the enrolled creator must be a reusable
global identity; it reuses an existing global identity or creates the founding
global identity when hosted/namespace authority permits. `--first-agent-local` /
`--first-agent-global` scopes only the enrolled creator, never the team or the
roster specs. Each roster spec has its own scope.

The `--agent` specs use `[NAME@]BLUEPRINT/PROFILE[:local|global][=RUNTIME]`:

- The blueprint defaults to `aweb.team` when omitted.
- `=RUNTIME` selects the materialization target (`claude-code`, `pi`, `codex`, or
  `local-shell`). Runtime binds at **materialize** time: a `pi` home differs from
  a `claude-code` home.
- `:local` and `:global` describe **agent identity scope only**. A local
  identity-scope agent is name-only inside one team; a global identity-scope
  agent uses a stable `did:aw` and belongs in the `manage-team-identities` flow.
- Omitted scope comes from `profile.yaml`. Because coordinator/AR policy is
  local staffing, examples spell `:local`; this intentional per-spec override
  remains local even if a catalog profile default changes. `:global` is an
  explicit durable identity decision owned by the `manage-team-identities` flow.
- On `aw team add` and `aw team extend`, command-wide `--local` / `--global`
  override all specs, but prefer the visible per-spec form in staffing examples.
  `aw team create` has no command-wide scope override: its `--first-agent-*`
  flag scopes only the creator, so every roster override must use per-spec
  `:local` / `:global`.
- Omitted names are server-authoritative; do not invent the next classic name
  when the command can choose it.

Team kind is a separate axis: use the hosted form for aweb-cloud-managed teams;
use `--byot --namespace <domain>` for self-hosted/BYOT teams where the customer
controls the namespace/controller authority.

`aw team create ... --agent ...` materializes the roster homes and their home
anatomy. The default work repo is the repo containing the home; use
`--work-dir <repo>` in later add flows to point `worktree/` at a separate project
repo. When git-worktree setup is available, the release aw creates `worktree/`
for every teammate and creates `work-main/` only for profiles with
`works_on_main: true`; non-git homes skip worktree setup gracefully. The
materializer installs the right channel integration.

`aw team up` is the fleet launch and reconcile path. It scans
`agents/instances/<name>` for materialized homes, reads each home's runtime from
`.aw/profile/ref.json`, and starts one tmux window per supported interactive
runtime. It is idempotent: homes already running are skipped; run it again after
materializing more homes, after a refresh, or after a runtime is killed.

Useful controls:

```bash
aw team up --dry-run             # print the launch plan
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

Operator note: each teammate's layout follows that teammate profile's
`works_on_main` value. Inspect recorded profile provenance before refresh or
handoff, include the teammate's `worktree/` path in the first-task onboarding
mail, and never do git work in the teammate's home directory.

```bash
aw agent profile show alice
aw mail send --to "alice" --subject "onboarding" --body "<role + project context + first scoped task; work in agents/instances/alice/worktree/>"
```

The channel injects the mail; the agent wakes, acts as its profile, and replies.
From here coordinate only over mail/chat (`aweb-messaging`) — never by driving
the TUI.

## Add one teammate later with `aw team extend --start`

Use `extend` when the team already exists and you need one more teammate:

```bash
aw team extend alice@aweb.team/developer:local=claude-code --start --no-attach
aw team extend bob@aweb.team/reviewer:local=pi --start --session <session>
```

`extend` can run in the team workspace, an agent home, or a repository layout
whose `agents/instances` contains an invite-capable home. It materializes the
home, sets up home/worktree isolation plus `work-main/` for `works_on_main`
roles, and can launch the agent in tmux in one command via the same team-up path:
channel preflight, prompt auto-answering, and `pi --approve`.

Preserve the lower-level current-workspace primitive when you need its unique
controls:

```bash
aw team add "alice@aweb.team/developer:local=claude-code" \
  --home "agents/instances/alice" --work-dir <repo> --start --no-attach
```

`extend` intentionally has no `--home` or `--layout-only`; use `add` only when
cwd is the active member workspace and those primitive controls are needed. Both
verbs accept `--start`; it still requires exactly one agent, takes `--session`,
`--attach`, and `--no-attach` like `aw team up`, and skips launch if the home is
already a running process cwd. `--start` is rejected with `--layout-only`.

Authority precedence for `extend`/`add`:

- Current workspace/discovered-home authority is used when no API-key intent is
  present.
- An ambient `AWEB_API_KEY` bootstraps only where there is no active team. If an
  active team exists, ambient-key ambiguity is an error before mutation: unset it
  to extend the active team.
- Explicit `--api-key`, or `AWEB_API_KEY` together with explicit `--team-id`,
  states API-key intent and wins over filesystem discovery. `--team-id` also
  asserts the expected team.

## Refresh an existing agent after profile evolution

A running home does **not** pick up profile changes until its home is refreshed:

```bash
aw team refresh <name>
```

`aw team refresh <name>` re-materializes `agents/instances/<name>` from the
profile source recorded in `.aw/profile/ref.json`. It prunes the managed set,
preserves home state outside that managed set, updates `.aw/profile/ref.json`,
and is a no-op when the digest is unchanged.

There are two source paths:

1. **Public-pinned home.** Homes created from the public catalog stay pinned to
   their public blueprint source. Refresh pulls the latest published version of
   that source profile — the upstream catalog improvement path.
2. **Adopted shelf home.** `aw team adopt <name>` re-points a public-pinned home
   onto this team's private Library shelf. After that, refresh follows the shelf
   path and can apply team-approved profile mints.

The order matters. Adopt first, then evolve the shelf, then refresh:

```bash
aw team adopt <name>
aw library propose --target profile --profile_ref <profile_ref> --content "$(cat proposal.json)" --summary 'brief summary' --rationale 'why this role should learn it'
aw library approve --proposal_id <proposal_id>
aw team refresh <name>
```

The approve/reject step belongs to the team's reviewing authority — typically
the coordinator, or a designated reviewer — because they have the context to
judge the proposal. The human sets policy and holds override; every proposal and
mint stays signed and auditable.

The Library plugin is required for `aw team adopt`'s shelf import and for the
Library evolution verbs. `update-from-source` remains the shelf-side way
to pull newer upstream blueprint parts into portions of the shelf profile your
team has not edited:

```bash
aw library update-from-source --profile_ref <profile_ref> --target_version <v>
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

   This is revocation only: self-hosted/BYOT teams revoke with the
   self-custodial team controller key; hosted aweb.ai teams use the
   cloud-mediated controller revoke endpoint.
3. **Decide deliberately what to do with the home directory.** `aw team
   remove-agent` does not delete the home. The home persists by default for
   audit/recovery. Deleting it is separate and irreversible; do it only when the
   team explicitly wants the home files gone.

## Guardrails — do NOT use these (each is a known dead-end)

- Earlier per-agent launcher commands are gone; `aw team up` is the only run
  path. Launching an interactive runtime detached, without a TTY and the team-up
  channel preflight, does not work for Claude Code or pi.
- **Unplanned global identity-scope staffing in this skill** — durable `did:aw`
  identity decisions belong in `manage-team-identities`, not an incidental roster
  edit.

## References

- `docs/running-agents.md` and `docs/team-blueprints-sot.md` (aweb repo) — the
  shipped run/materialization contract.
- The **AR (agent resources)** blueprint profile — the role that orchestrates
  this skill: when to staff, onboarding content, roster tracking, retire.
