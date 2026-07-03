---
name: manage-profiles
description: >-
  Manages a team's role profiles through the library plugin - adopt a public
  blueprint profile, author one from scratch, evolve it on the private shelf,
  pull upstream improvements without losing team edits, and publish back to the
  catalog. Use when creating, specializing, versioning, or publishing a profile
  or a whole blueprint, or when setting up the library plugin for a team.
---

# Manage profiles

The library holds the team's role profiles. A profile lives first on the team's
**private shelf**, where you author and evolve it; from there you **publish** it
into a **public blueprint** other teams can adopt. Every step is a library plugin
verb, authenticated by the team certificate's `library:write` scope — any team
member whose cert holds that scope can do this; it is not gated to one role.

The exact flags for each verb are in `aw library <verb> --help`; the inputs noted
below are what each call carries.

## Setup: install the plugin

The library exposes its API as `aw library <verb>` through its manifest. Install
it once into the trusted plugin directory, then confirm the verbs are present:

```
aw plugin install <library manifest>
aw plugin list
```

Calls authenticate with the team cert (`aw id request --team-auth`); the team is
taken from the cert, never passed. `aw library register` (once, idempotent) binds
the team to the library.

## The two homes: shelf vs public blueprint

- **Shelf** — the team's *private* profile store. Yours to author, version, and
  evolve freely; invisible to other teams.
- **Public blueprint** — the *catalog* entry other teams adopt. A profile reaches
  it only by being **published** from the shelf (or imported whole).

## Create a profile

Two starting points.

**Author from scratch** — `aw library create-shelf-profile`. The input is the
profile's files: `profile.yaml`, `instructions.md`, and each `skills/<s>/SKILL.md`
(plus tags). It lands on the shelf as version 1.

**Adopt and specialize an existing one** — `aw library import-to-shelf` with a
source `blueprint_ref` / `profile_ref`. This copies a public-blueprint profile
onto the shelf under its source ref and records that source — the path for "start
from a generic catalog profile, then make it ours." Re-importing the same source
is a no-op; it never pulls a newer version (that is `update-from-source`).

## Evolve it

`aw library shelf-version <profile_ref>` adds a new content version from the new
files. Source provenance, tags, and per-part baselines carry forward.

## Track the source — the asset-scoped loop

When the generic profile you adopted improves upstream, pull those improvements
without losing your edits:

`aw library update-from-source --profile_ref <profile_ref>` is a Library plugin verb (manifest-dispatched after `aw plugin install`). It runs a **per-part 3-way merge** — pulling upstream changes only into the parts you have **not** edited on the shelf, and never clobbering a part you have evolved. A real merge mints a new version and advances the source pin; if nothing is pullable it is a no-op. This is how an adopted profile stays current with its generic base while keeping our specializations.

## The learning gate: propose / approve

Reviewed learning operates on the **shelf** profile, not on public blueprints:

- `aw library propose <profile_ref>` — submit an asset-scoped changeset (file and
  `profile.yaml`-field assets).
- `aw library proposals` — list open proposals.
- `aw library approve <proposal_id>` — apply it; auto-bumps the next patch version
  after per-asset stale checks.
- `aw library reject <proposal_id>` — drop it.

Use this when a profile should evolve **under review** rather than by a direct
`shelf-version` write — the agent proposes, a reviewer approves.

## Apply the approved version to a running home

A proposal approval or `update-from-source` merge mints a new shelf profile
version, but running agents keep using the old materialized files until their
home is refreshed. Close the loop explicitly:

```bash
aw team refresh <name>
```

`aw team refresh <name>` reads the home's recorded `.aw/profile/ref.json`, pulls
the latest shelf version for that profile, and re-materializes the home. It never
asks a remote service which profile the agent should use. It prunes the managed
set, preserves home state outside that set, updates `.aw/profile/ref.json`, and
is a no-op when the digest is unchanged. If you are pulling upstream blueprint
improvements, install/use the Library plugin and do that first, then refresh:

```bash
aw library update-from-source --profile_ref <profile_ref>
aw team refresh <name>
```

Without the refresh, the approved improvement exists on the shelf but the live
agent keeps running the previous home.

## Publish to the catalog

Two ways a profile reaches a public blueprint.

**Promote one shelf profile** — `aw library publish-profile <profile_ref>`,
into a new blueprint or a new version of one the team owns. The library generates
the `blueprint.yaml`; the published profile keeps its shelf digest; the
blueprint's profile set accumulates.

**Import a whole blueprint at once** — `aw library publish-blueprint`, body = the
canonical `import-payload.v1` (files + schema). This is the **first-party /
repo-source** path: hand-author a blueprint in a repo, build its canonical import
payload, import the whole thing. Idempotent on (owner_team, blueprint_ref,
version).

## Materialize an agent from a profile

`aw library materialize` (agent_id, profile_ref, runtime_kind, target) produces a
runnable home — composed `AGENTS.md`, installed skills, the profile under
`.aw/profile/` — from a shelf or catalog profile. It is the library-side
counterpart to the souls / `aw init` path.

## Tags and binding

- `aw library set-profile-tags <profile_ref>` — discovery tags on a shelf profile.
- `aw library bind <agent_id>` / `aw library get-binding <agent_id>` — bind an
  agent to a profile, and read the binding.

## Guardrails

- Authoring and shelf evolution are private; **publishing** makes a profile
  public — treat `publish-profile` / `publish-blueprint` as the outward-facing
  step, with the care any outward action deserves.
- Prefer `update-from-source` over re-adopting to pull upstream — re-import never
  pulls a newer version by design.
- Prefer `propose`/`approve` (reviewed) when a change is learning the team wants
  to keep; use `shelf-version` for direct authoring.
- The canonical `import-payload.v1` digest is the identity of a published
  blueprint; keep the source that generates it under version control.
