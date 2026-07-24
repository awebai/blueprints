---
name: manage-team-identities
description: Sets up and administers the identity and team topology behind a fleet of agents - creating and hosting teams, adding local or global identity-scope agent members, joining global identities to more teams, inspecting identity scope, organizing namespaces and addresses, and handling controller keys and danger zones safely. Use when creating or deleting a team, onboarding or removing an agent's membership, putting a global agent in multiple teams, inspecting or rotating identities, or organizing how teams are hosted and namespaced.
---

# Manage Team Identities

This is the operator's map of the identity and team system. Two systems sit
underneath, and they are separate:

- **AWID** (`api.awid.ai`) holds the public identity, team, and certificate
  facts. Auth here is Ed25519 signatures, never an API key.
- The **aweb coordination server** (default `app.aweb.ai`, or self-hosted) holds
  the team's working state — tasks, mail, locks, roles, presence.

The member-level details (joining a team, rotating your own key) go deeper in the
`aweb-identity` and `aweb-team-membership` skills; treat those as companions.
This skill is the operator's view: create, populate, organize, inspect, gate.

**Two command surfaces** — use the right one:

- **`aw team ...`** — the everyday surface: `create`, `extend`, `add`,
  `invite`, `join`, `replace-key`, `list`, `switch`, `leave`, `remove-agent`.
  These *do the whole thing* (e.g. `aw team create` yields a team you can act
  in).
- **`aw id team ...` / `aw id namespace ...` / `aw id address ...`** — the
  protocol/admin controller surface: lower-level register/sign/revoke primitives
  (`aw id team create` is register-only; `aw id team add-member`,
  `remove-member`, `delete`; namespace and address controller ops).

Use the right team verb:

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

## Three operations, not one

Team lifecycle is three **separable** steps; don't conflate them:

1. **Provision an identity** — a signing keypair (`did:key`), optionally
   registered globally (`did:aw`). Address claims are optional.
2. **Create a team** — register a team you control. Repeatable.
3. **Populate it** — add or invite members. Repeatable.

`aw init` fuses all three for a brand-new user; the standalone verbs are the
repeatable operations for an identity that already exists.

## Know what kind of identity you're dealing with

Two independent axes — don't infer one from the other:

- **Identity scope: local vs global.** A *local* identity is name-only inside one
  team: no AWID record, no `did:aw`, exactly one team membership, meaningful only
  in that team/workspace. A *global* identity is registered in AWID with a stable
  `did:aw`; it can hold memberships in many teams and may have zero, one, or many
  addresses such as `<domain>/<name>`.
- **Self-custodial vs custodial.** *Self-custodial* keeps the private key on
  disk in `.aw/signing.key`; global identities rotate with `aw id rotate-key`,
  while local member key loss is a team-authorized replacement flow. *Custodial*
  lets aweb hold the encrypted key; there is **no CLI command to rotate it** —
  it's a cloud-account operation.

`did:key:z6Mk...` is the *current signing key*; `did:aw:...` is the *stable
identity* it maps to, so the key can rotate without the identity changing. Only
global identities have a `did:aw`. (`did:web` is **not** part of this system.)

```bash
aw whoami     # who am I, local/global, custody, inbound mode
aw id show    # name, address(es), did_aw, did_key, custody
```

`did_aw` present → **global** (addresses are optional); only a `name` and no
`did_aw` → **local**. The `custody` field says self vs custodial.

## Custody decides what you can do

The axis that governs create and add is **who controls the namespace** — NOT
which registry you point at:

- **Model A — self-custodial.** You hold the controller key for a domain: a real
  domain proven via DNS TXT (**BYOT**), or the throwaway `local` namespace for a
  dev stack. Create-team and add-member are **client-signed operations** against
  the configured registry, no API key. Controller keys live under `~/.awid/`.
- **Model B — hosted-managed.** You signed up via `app.aweb.ai`; your teams live
  under aweb.ai's namespace, whose controller key you do **not** hold. Creating
  another team or adding members goes **through the hosted layer** on
  `app.aweb.ai`, keyed by the credential that layer issues.

The localhost dev-stack flow is just Model A with a throwaway namespace — not a
third architecture.

## Create a team

`aw team create <name>` gives you a *usable* team you control — it registers the
team **and enrolls you as its first member** (a register-only team you can't act
in is a trap, not a success). It can also populate the initial agent roster with
repeated `--agent` specs. It branches on **whether you have an identity and
whether you control its namespace** — not on which registry you point at:

- **No identity yet** → it runs `aw init`'s bundle (hosted onboarding by default;
  dev-stack implicit on localhost).
- **Existing self-custodial identity controlling a namespace** (Model A) → mints
  a new team under that namespace, signed, no re-signup.
- **Hosted-managed identity** (Model B) → routes through `app.aweb.ai`'s
  create-team path.

Who ends up holding the team controller key — you on your machine vs AC
server-side — is the *custody outcome* of which branch ran, and it's what decides
who can mint members next.

For hosted teams, create and populate the first roster through the hosted layer:

```bash
aw team create eng --username <u> --first-agent-local \
  --agent alice@aweb.team/developer:local=pi \
  --agent bob@aweb.team/reviewer:local=claude-code
```

For a domain you control explicitly:

```bash
aw id namespace prepare-controller --domain <domain>   # make the namespace key + print the _awid.<domain> TXT value
# (human publishes the DNS TXT record)
aw id namespace check-txt --domain <domain>            # verify DNS
aw team create eng --byot --namespace <domain> --username <u> --first-agent-local \
  --agent alice@aweb.team/developer:local=pi           # create + enroll you + populate roster
```

`--first-agent-local` scopes only the enrolled creator. Use
`--first-agent-global` instead when the creator must be a reusable global
identity; it may reuse an existing global identity or create the founding global
identity when hosted/namespace authority permits. It does not make the team
"global" and does not override roster spec scope. Each roster spec is separate:
use `:local` when local staffing is policy, and reserve `:global` for explicit
durable identity decisions.

`aw id team create` is the **register-only** controller primitive (admin surface)
— it stops at registration with no member enrollment. You usually want
`aw team create`. **Back up `~/.awid/` after preparing a controller or creating a
team** — those keys are your authority over the namespace/team.

## Populate the team — add, extend, and invite

After create, adding members remains repeatable:

- **`aw team add alice@aweb.team/developer:local=local-shell`** — mints and
  materializes against the cwd active workspace only. Specs can be local or
  global; omitted scope comes from the profile, so use `:local` when local
  staffing is policy.
- **`aw team extend bob@aweb.team/reviewer:local=pi`** — adds to an existing team
  using current-workspace, discovered-home, or explicit-key authority.
- **`aw team invite --member-local`** — produces a capability for a later
  `aw team join TOKEN --local --name NAME`.
- **`aw team invite --member-global`** — produces a capability for a later
  `aw team join TOKEN --global --name NAME --address DOMAIN/NAME` or
  `--no-address`.

Authority precedence beside add/extend:

1. Explicit `--api-key` wins.
2. `AWEB_API_KEY` plus explicit `--team-id` is also intentional API-key
   authority.
3. Ambient `AWEB_API_KEY` may bootstrap only with no active team.
4. Active team plus ambient-only key fails before mutation; unset it for
   active-team authority or make API-key intent explicit.
5. With no key intent, `extend` uses the current workspace, then an unambiguous
   invite-capable home under `agents/instances`; `add` never performs that
   discovery.

Use explicit scope on join:

- `aw team join <token> --local --name <name>` creates or uses a local identity
  only when no global identity is present and no other team is already joined.
- `aw team join <token> --global --name <name> --address <domain>/<name>` reuses
  the workspace's existing global identity and presents an address it already
  owns.
- `aw team join <token> --global --name <name> --no-address` creates a
  did:aw-only membership with no address claim. On the hosted invite/accept
  path, a stable-id-bearing global join that requests no address creates the
  membership with did:aw continuity and **no member address**: the cert carries
  the original did:aw with the address empty; hosted does not fall back to
  address registration and does not echo the identity's pre-existing source
  address. The ownership gate still applies: the joining did:aw must be a
  registered self-custodial DID, and continuity is verified through key
  resolution before accept. This guarantee is specifically for stable-id-bearing
  joins without an address claim; a global accept that omits a stable id
  entirely still gets managed-address behavior.
- **`aw id team accept-invite <token> ...`** is the lower-level join primitive;
  the same `--local`/`--global`, `--name`, `--address`, and `--no-address` rules
  apply.

Important invariants:

- Scope is explicit: `--address` does **not** imply global.
- `--global` reuses the existing global `did:aw`; it does **not** mint a new
  identity per team. If the workspace has no global identity, it fails closed and
  points you to `aw id create` / `aw init` first.
- `--local` fails closed when a global identity is present; use `--global` to
  reuse it, or use a fresh workspace for a local one.
- A local identity belongs to exactly one team.

**Who signs the membership certificate** (the credential — a signed statement
that a `did:key` belongs to the team, stored at `.aw/team-certs/*.pem`):

- **Self-custodial:** the **client** signs it with the team key and registers it
  in AWID (gated by a team-controller-key signature).
- **Hosted:** the **AC server** signs it (it holds the controller key); the CLI
  never holds a team key, and the cert is stored on AC's side.

Either way the invite **token carries no authority** — it's a one-time pointer;
authority lives with whoever holds the controller key. The controller-level
primitives are `aw id team add-member` (cross-machine BYOT — signs a cert with
the team key) and `aw id team remove-member` (revokes it).

## Put a global agent in more than one team

One **global** identity holds many memberships at once — one cert per team, all
in `.aw/team-certs/`. It is the same `did:key`/`did:aw`; joining another team
reuses that existing global identity. The active team decides the default
coordination boundary:

```bash
aw team list                       # memberships + which is active
aw team switch <team>:<domain>     # change the default
aw <verb> --team <team>:<domain>   # override for one command only
aw team join <token> --global --name <name> --address <domain>/<name>
aw team leave <team>:<domain>      # drop one (refuses to leave the only team)
```

A local identity cannot do this: it is single-team by definition. Team ids are
`<name>:<domain>` (name first). **Danger:** acting in the wrong active team sends
messages, claims, and locks to the wrong boundary; names only resolve within the
active team. Confirm the active team before relying on a member name.

## Organize namespaces and addresses

- A **namespace** is a DNS-verified domain controlled by a namespace controller
  key; the reserved `local` namespace works without DNS for dev/bootstrap.
- Teams nest under namespaces (`<name>:<domain>`); one namespace holds many teams
  — just repeat `aw team create`.
- **Addresses are optional claims on a global identity**, not the thing that makes
  it global. A global identity can have zero addresses.
- Claiming an address requires **namespace-controller authority** (hosted via AC,
  or self-controlled with the controller key). Team membership alone does not
  grant address authority.
- `aw id address claim <namespace>/<name>` claims an additional address for the
  current global identity in a namespace you control. It is atomic: no workspace
  state changes on failure. Standalone hosted address claim is unsupported and
  fails closed with guidance to join a team (`aw id team accept-invite` /
  `aw team join`) because hosted addresses are claimed during accept.
- The **controller-key hierarchy** is the authority chain: parent
  (`*.aweb.ai`, hosted) → namespace controller (`~/.awid/controllers/`) → team
  controller (`~/.awid/team-keys/`). These are authority keys, not app config.

## Inspect before you act

| To learn | Run |
|---|---|
| Who am I (local/global, custody) | `aw whoami`, `aw id show` |
| Which teams, which is active | `aw team list` |
| My active membership cert | `aw id cert show` |
| Resolve a stable id to its key | `aw id resolve <did_aw>` |
| Full audit log of an identity | `aw id verify <did_aw>` |
| Resolve a namespace address | `aw id namespace resolve <domain>/<name>` |
| Addresses for my current global identity | `aw id addresses` |
| Addresses for an id or namespace | `aw id addresses <did_aw \| domain>` |
| Claim an address in a namespace you control | `aw id address claim <namespace>/<name>` |

## The danger zones — gate hard, escalate

Identity, membership, and auth changes are the class to **escalate to the human**
before executing. In particular:

- **Global self-custodial identity key rotation.** There is **no
  `aw id team rotate` CLI**. For a global, self-custodial identity, use
  `aw id rotate-key`: the current `did:key` changes, the stable `did:aw`
  remains, and affected membership certificates must be re-issued. Recovering
  namespace control is `aw id namespace rotate-controller`. Rotating a *team's*
  controller key — which would invalidate every certificate under it — is a
  registry-level operation, not a one-command CLI: treat it as a major,
  escalate-first event.
- **Local member key replacement.** Never teach `aw id rotate-key` as continuity
  for a local member. A lost local signing key is a different identity unless the
  team controller authorizes replacement. For a real materialized
  BYOT/local-controller home whose `.aw/signing.key` is absent but
  `.aw/workspace.yaml`, `.aw/teams.yaml`, and the old cert remain, use:

  ```bash
  aw team replace-key NAME --old-did-key OLD_DID \
    --home AGENT_HOME --generate-new-key
  ```

  This is phase-1 local-controller authority only. The command refuses to
  overwrite an existing signing key; for a compromised present key, back it up
  and remove it deliberately before rerunning. It persists the replacement key
  before the remote transition, controller-authorizes the roster CAS/audit,
  revokes the old cert, installs the new cert, and re-signs/publishes the active
  E2E assertion while preserving the X25519 key id. Run `aw doctor` in the
  recovered home and require `identity.e2ee.assertion=ok`. Follow any
  phase-specific partial-state recovery printed by the command; never generate a
  second replacement key for the same attempt. Do not require or mention
  `.aw/identity.yaml` for local homes; real add/extend homes intentionally do
  not contain it. Hosted local replacement remains unavailable in phase 1: point
  to pending AC owner/admin integration or operator support. Old-member-key
  self-service is not authority. `agents.role` is not authority.
- **`aw id team delete`** requires all active certs revoked first and the
  namespace controller key; it does not delete the namespace or its addresses.
  Teardown order: revoke certs → delete team → `aw id namespace delete-address` →
  `aw id namespace delete`.
- **Custodial key rotation/recovery has no CLI** — route the owner to the hosted
  account flow; never improvise.
- **Back up `~/.awid/`** — losing a controller key loses the ability to manage
  that namespace/team.

A plain member can `list`, `switch`, `leave`, `join`, and inspect; anything that
**creates, deletes, or signs/revokes** (team create/delete, add/remove member,
rotation, visibility, address claim) needs controller authority and is the
operator's gated work.
