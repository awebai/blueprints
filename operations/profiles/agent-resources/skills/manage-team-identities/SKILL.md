---
name: manage-team-identities
description: Sets up and administers the identity and team topology behind a fleet of agents - creating and hosting teams, adding an agent to one or more teams, inspecting what kind of identity an agent holds, organizing namespaces, and handling controller keys and danger zones safely. Use when creating or deleting a team, onboarding or removing an agent's membership, putting an agent in multiple teams, inspecting or rotating identities, or organizing how teams are hosted and namespaced.
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

- **`aw team ...`** — the everyday surface: `create`, `add`, `invite`, `join`,
  `list`, `switch`, `leave`, `remove-agent`. These *do the whole thing* (e.g.
  `aw team create` yields a team you can act in).
- **`aw id team ...` / `aw id namespace ...`** — the protocol/admin controller
  surface: lower-level register/sign/revoke primitives (`aw id team create` is
  register-only; `aw id team add-member`, `remove-member`, `delete`; namespace
  controller ops).

## Three operations, not one

Team lifecycle is three **separable** steps; don't conflate them:

1. **Provision an identity** — a signing keypair (`did:key`), optionally
   registered globally (`did:aw` + address). Happens ~once.
2. **Create a team** — register a team you control. Repeatable.
3. **Populate it** — add or invite members. Repeatable.

`aw init` fuses all three for a brand-new user; the standalone verbs are the
repeatable operations for an identity that already exists.

## Know what kind of identity you're dealing with

Two independent axes — don't infer one from the other:

- **Local vs global.** *Local* = workspace-bound, alias-only, no AWID record, no
  `did:aw`, `lifetime: ephemeral`; meaningful only inside its team and machine.
  *Global* = registered in AWID with a stable `did:aw` + address(es)
  `<domain>/<name>`, `lifetime: persistent`; survives key rotation and machine
  moves.
- **Self-custodial vs custodial.** *Self-custodial* keeps the private key locally
  in `.aw/signing.key` (rotate with `aw id rotate-key`). *Custodial* lets aweb
  hold the encrypted key; there is **no local CLI command to rotate it** — it's a
  cloud-account operation.

`did:key:z6Mk...` is the *current signing key*; `did:aw:...` is the *stable
identity* it maps to, so the key can rotate without the identity changing. Only
global identities have a `did:aw`. (`did:web` is **not** part of this system.)

```bash
aw whoami     # who am I, local/global, custody, inbound mode
aw id show    # alias, address, did_aw, did_key, custody
```

`did_aw`/address present → **global**; only an `alias` → **local**. The `custody`
field says self vs custodial.

## Custody decides what you can do

The axis that governs create and add is **who controls the namespace** — NOT
which registry you point at:

- **Model A — self-custodial.** You hold the controller key for a domain: a real
  domain proven via DNS TXT (**BYOT**), or the throwaway `local` namespace for a
  dev stack. Create-team and add-member are **local signed operations** against
  the configured registry, no API key. Controller keys live under `~/.awid/`.
- **Model B — hosted-managed.** You signed up via `app.aweb.ai`; your teams live
  under aweb.ai's namespace, whose controller key you do **not** hold. Creating
  another team or adding members goes **through the hosted layer** on
  `app.aweb.ai`, keyed by the credential that layer issues.

The `local`/localhost flow is just Model A with a throwaway namespace — not a
third architecture.

## Create a team

`aw team create <name>` gives you a *usable* team you control — it registers the
team **and enrolls you as its first member** (a register-only team you can't act
in is a trap, not a success). It branches on **whether you have an identity and
whether you control its namespace** — not on which registry you point at:

- **No identity yet** → it runs `aw init`'s bundle (hosted onboarding by default;
  local-implicit on a localhost stack).
- **Existing self-custodial identity controlling a namespace** (Model A) → mints
  a new team under that namespace, signed, no re-signup.
- **Hosted-managed identity** (Model B) → routes through `app.aweb.ai`'s
  create-team path.

Who ends up holding the team controller key — you, locally, vs AC server-side —
is the *custody outcome* of which branch ran, and it's what decides who can mint
members next.

For a domain you control explicitly:

```bash
aw id namespace prepare-controller --domain <domain>   # make the namespace key + print the _awid.<domain> TXT value
# (human publishes the DNS TXT record)
aw id namespace check-txt --domain <domain>            # verify DNS
aw team create <name> --byot --namespace <domain>      # create + enroll you as first member
```

`aw id team create` is the **register-only** controller primitive (admin surface)
— it stops at registration with no member enrollment. You usually want
`aw team create`. **Back up `~/.awid/` after preparing a controller or creating a
team** — those keys are your authority over the namespace/team.

## Populate the team — add and invite

Adding members is **separate** from create:

- **`aw team add <a> <b> ...`** — mint new team-owned agent members into the
  active team (each gets an identity + team cert + home).
- **`aw team invite` → `aw team join <token>`** — bring in a separate
  workspace/machine/external identity (someone who holds their own key). (The
  admin primitive underneath the joiner side is `aw id team accept-invite`.)

**Who signs the membership certificate** (the credential — a signed statement
that a `did:key` belongs to the team, stored at `.aw/team-certs/*.pem`):

- **Self-custodial:** the **client** signs it locally with the team key and
  registers it in AWID (gated by a team-controller-key signature).
- **Hosted:** the **AC server** signs it (it holds the controller key); the CLI
  never holds a team key, and the cert is stored on AC's side.

Either way the invite **token carries no authority** — it's a one-time pointer;
authority lives with whoever holds the controller key. The controller-level
primitives are `aw id team add-member` (cross-machine BYOT — signs a cert with
the team key) and `aw id team remove-member` (revokes it).

## Put an agent in more than one team

One identity holds **many memberships at once** — one cert per team, all in
`.aw/team-certs/`. It's the same `did:key`/`did:aw`; the active team decides the
default coordination boundary:

```bash
aw team list                       # memberships + which is active
aw team switch <team>:<domain>     # change the default
aw <verb> --team <team>:<domain>   # override for one command only
aw team join <token>               # add another team
aw team leave <team>:<domain>      # drop one (refuses to leave the only team)
```

Team ids are `<name>:<domain>` (name first). **Danger:** acting in the wrong
active team sends messages, claims, and locks to the wrong boundary; aliases only
resolve within the active team. Confirm the active team before relying on an
alias.

## Organize the topology

- A **namespace** is a DNS-verified domain controlled by a namespace controller
  key; the reserved `local` namespace works without DNS for dev/bootstrap.
- Teams nest under namespaces (`<name>:<domain>`); one namespace holds many teams
  — just repeat `aw team create`.
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
| Addresses for an id or namespace | `aw id addresses <did_aw \| domain>` |

## The danger zones — gate hard, escalate

Identity, membership, and auth changes are the class to **escalate to the human**
before executing. In particular:

- **Key rotation.** There is **no `aw id team rotate` CLI**. Rotating a member's
  identity key is `aw id rotate-key` (its `did:key` changes, `did:aw` stays
  stable, so that member's team certs must be re-issued); recovering namespace
  control is `aw id namespace rotate-controller`. Rotating a *team's* controller
  key — which would invalidate every certificate under it — is a registry-level
  operation, not a one-command CLI: treat it as a major, escalate-first event.
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
rotation, visibility) needs controller authority and is the operator's gated
work.
